#!/bin/zsh
# One complete measured run: worktree -> provision -> agent -> measure.
#
#   ./run_one.sh <run_id> <claude|codex>
#
# Runs serially and leaves metrics.json in runs/<run_id>/. Check that file for a
# CONTAMINATED marker before trusting the diff.
set -e
HARNESS_DIR="${0:a:h}"
source "$HARNESS_DIR/lib.sh"

RUN_ID="${1:?usage: run_one.sh <run_id> <claude|codex>}"
AGENT="${2:?usage: run_one.sh <run_id> <claude|codex>}"
ORCA=/Applications/Orca.app/Contents/Resources/bin/orca

echo "=== $RUN_ID ($AGENT) ==="
WT=$("$ORCA" worktree create --name "$RUN_ID" --repo "path:$CHATWOOT_REPO" \
      --base-branch "$BASE_TAG" --no-parent --setup skip --json \
     | python3 -c 'import json,sys; print(json.load(sys.stdin)["result"]["worktree"]["path"])')
[ -n "$WT" ] || die "orca did not return a worktree path"

"$HARNESS_DIR/provision.sh" "$RUN_ID" "$WT"
"$HARNESS_DIR/run_agent.sh" "$RUN_ID" "$AGENT" "$WT"
"$HARNESS_DIR/measure.sh"   "$RUN_ID" "$AGENT" "$WT"

[ -f "$RESULTS_DIR/$RUN_ID/CONTAMINATED" ] && echo "!!! CONTAMINATED — diff is not the agent's work"
echo "=== $RUN_ID done ==="
