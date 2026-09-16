#!/bin/zsh
# Make an EXISTING worktree runnable: derive .env, install deps, create its own
# database. Use this when something else created the checkout — e.g. Orca's
# `worktree create` — since Orca isolates git state but knows nothing about
# Postgres or Redis.
#
#   ./provision.sh <run_id> <path-to-worktree>
set -e
HARNESS_DIR="${0:a:h}"
source "$HARNESS_DIR/lib.sh"
setup_toolchain

RUN_ID="${1:?usage: provision.sh <run_id> <path>}"
WT="${2:?usage: provision.sh <run_id> <path>}"

[ -d "$WT" ] || die "no such directory: $WT"
[ -f "$WT/.env.example" ] || die "$WT does not look like a chatwoot checkout"

sha=$(git -C "$WT" rev-parse HEAD)
base=$(git -C "$CHATWOOT_REPO" rev-parse "$BASE_TAG")
[ "$sha" = "$base" ] || echo "WARNING: worktree is at ${sha:0:9}, base is ${base:0:9}"

echo "worktree:  $WT @ ${sha:0:9}"
derive_env "$WT" "$RUN_ID"
( cd "$WT" && pnpm install --silent 2>&1 | tail -1; bundle install --quiet )
prepare_db "$WT" "$RUN_ID"
echo "$WT" > "$BENCH_ROOT/.worktree-$RUN_ID"
echo
echo "Ready. Agent works in: $WT"
