#!/bin/zsh
# Shared environment for every harness script.
# Toolchain is pinned here, not inherited, so a run cannot silently drift.

CHATWOOT_REPO=${CHATWOOT_REPO:-$HOME/chatwoot}
BENCH_ROOT=${BENCH_ROOT:-$HOME/chatwoot-agent-bench}
BASE_TAG=${BASE_TAG:-bench-base}

WORKTREE_DIR="$BENCH_ROOT/worktrees"
RESULTS_DIR="$BENCH_ROOT/runs"

# Baseline's known failures. A run is clean iff its failure set equals this.
KNOWN_FAILURES=(
  "./spec/builders/agent_builder_spec.rb:47"
  "./spec/enterprise/services/voice/call_transcription_service_spec.rb:77"
)

setup_toolchain() {
  eval "$(rbenv init - zsh)"
  export PATH="/opt/homebrew/opt/postgresql@14/bin:$PATH"
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" --no-use
  nvm use 24.13.0 >/dev/null 2>&1
}

# Redis has 16 databases (0-15). 0 is left for the host; runs get 1-15.
redis_index_for() {
  local run_id="$1"
  local n=$(printf '%s' "$run_id" | cksum | cut -d' ' -f1)
  echo $(( n % 15 + 1 ))
}

db_name_for() { echo "chatwoot_bench_${1//[^a-zA-Z0-9_]/_}"; }

die() { echo "FATAL: $*" >&2; exit 1; }

# Derive .env for a worktree. NEVER a plain copy of .env.example: it ships
# FRONTEND_URL=0.0.0.0 which CI deletes, and leaving it in produces five false
# failures. Each worktree also needs its own database and Redis index, because
# git worktrees isolate files but not services.
derive_env() {
  local dir="$1" run_id="$2"
  local db=$(db_name_for "$run_id")
  local redis_db=$(redis_index_for "$run_id")
  cp "$dir/.env.example" "$dir/.env"
  sed -i '' '/^FRONTEND_URL/d' "$dir/.env"
  sed -i '' 's|^POSTGRES_HOST=postgres$|POSTGRES_HOST=localhost|' "$dir/.env"
  sed -i '' "s|^REDIS_URL=redis://redis:6379$|REDIS_URL=redis://localhost:6379/$redis_db|" "$dir/.env"
  sed -i '' "s|^SECRET_KEY_BASE=replace_with_lengthy_secure_hex$|SECRET_KEY_BASE=$(openssl rand -hex 64)|" "$dir/.env"
  echo "POSTGRES_DATABASE=$db" >> "$dir/.env"
  echo "env:       db=$db redis_db=$redis_db"
}

prepare_db() {
  local dir="$1" run_id="$2"
  local db=$(db_name_for "$run_id")
  ( cd "$dir" && RAILS_ENV=test POSTGRES_DATABASE="$db" \
      bundle exec rails db:chatwoot_prepare >/dev/null 2>&1 )
  local tables=$(psql -d "$db" -tc "SELECT count(*) FROM information_schema.tables WHERE table_schema='public';" | tr -d ' ')
  [ "$tables" -ge 100 ] || die "database $db looks wrong: $tables tables"
  echo "db:        $db ready ($tables tables)"
}
