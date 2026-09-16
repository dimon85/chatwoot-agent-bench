#!/bin/zsh
# Create an isolated worktree at the base commit and provision it.
# If Orca (or anything else) already made the checkout, use provision.sh instead.
#
#   ./new_worktree.sh <run_id>
set -e
HARNESS_DIR="${0:a:h}"
source "$HARNESS_DIR/lib.sh"

RUN_ID="${1:?usage: new_worktree.sh <run_id>}"
WT="$WORKTREE_DIR/$RUN_ID"
[ -e "$WT" ] && die "worktree already exists: $WT"

mkdir -p "$WORKTREE_DIR"
git -C "$CHATWOOT_REPO" worktree add --detach "$WT" "$BASE_TAG" >/dev/null
exec "$HARNESS_DIR/provision.sh" "$RUN_ID" "$WT"
