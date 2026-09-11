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
