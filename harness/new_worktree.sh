#!/bin/zsh
# Create an isolated worktree at the base commit, ready for an agent to work in.
#
#   ./new_worktree.sh <run_id>
#
# Gives the worktree its own Postgres database and Redis index, because git
# worktrees isolate files only — two worktrees share chatwoot_test otherwise and
# will corrupt each other's test runs.
set -e
source "${0:a:h}/lib.sh"
setup_toolchain

RUN_ID="${1:?usage: new_worktree.sh <run_id>}"
WT="$WORKTREE_DIR/$RUN_ID"
DB=$(db_name_for "$RUN_ID")
REDIS_DB=$(redis_index_for "$RUN_ID")

[ -e "$WT" ] && die "worktree already exists: $WT"

mkdir -p "$WORKTREE_DIR"
git -C "$CHATWOOT_REPO" worktree add --detach "$WT" "$BASE_TAG" >/dev/null
echo "worktree:  $WT @ $(git -C "$WT" rev-parse --short HEAD)"

# .env is DERIVED, never copied verbatim. .env.example ships FRONTEND_URL=0.0.0.0
# which CI deletes; leaving it in produces 5 false failures. See BASELINE.md.
cd "$WT"
cp .env.example .env
sed -i '' '/^FRONTEND_URL/d' .env
sed -i '' 's|^POSTGRES_HOST=postgres$|POSTGRES_HOST=localhost|' .env
sed -i '' "s|^REDIS_URL=redis://redis:6379$|REDIS_URL=redis://localhost:6379/$REDIS_DB|" .env
sed -i '' "s|^SECRET_KEY_BASE=replace_with_lengthy_secure_hex$|SECRET_KEY_BASE=$(openssl rand -hex 64)|" .env
echo "POSTGRES_DATABASE=$DB" >> .env
echo "env:       db=$DB redis_db=$REDIS_DB"

# Dependencies are shared with the main checkout where possible; node_modules is
# per-worktree because pnpm writes .bin shims with absolute paths.
pnpm install --silent 2>&1 | tail -2
bundle install --quiet

RAILS_ENV=test POSTGRES_DATABASE="$DB" bundle exec rails db:chatwoot_prepare >/dev/null 2>&1
tables=$(psql -d "$DB" -tc "SELECT count(*) FROM information_schema.tables WHERE table_schema='public';" | tr -d ' ')
[ "$tables" -ge 100 ] || die "database $DB looks wrong: $tables tables"
echo "db:        $DB ready ($tables tables)"
echo
echo "Ready. Point the agent at: $WT"
