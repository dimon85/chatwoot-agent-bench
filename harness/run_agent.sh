#!/bin/zsh
# Launch one agent against PROMPT.md in a provisioned worktree.
#
#   ./run_agent.sh <run_id> <agent: claude|codex> [path]
#
# Non-interactive on purpose. A benchmark needs a defined stopping condition,
# and an interactive agent can end its turn with a question nobody answers.
# Permissions are bypassed so both arms have identical autonomy: differing
# approval settings would measure the settings, not the agents.
set -e
HARNESS_DIR="${0:a:h}"
source "$HARNESS_DIR/lib.sh"
setup_toolchain

RUN_ID="${1:?usage: run_agent.sh <run_id> <agent> [path]}"
AGENT="${2:?usage: run_agent.sh <run_id> <agent> [path]}"
WT="${3:-$(cat "$BENCH_ROOT/.worktree-$RUN_ID" 2>/dev/null)}"
[ -d "$WT" ] || die "no worktree for $RUN_ID"

OUT="$RESULTS_DIR/$RUN_ID"
mkdir -p "$OUT"
PROMPT=$(cat "$BENCH_ROOT/PROMPT.md")

cd "$WT"
start=$(date +%s)
case "$AGENT" in
  claude)
    claude -p "$PROMPT" --dangerously-skip-permissions \
      --output-format json > "$OUT/agent.json" 2>"$OUT/agent.err" || true
    ;;
  codex)
    codex exec --dangerously-bypass-approvals-and-sandbox "$PROMPT" \
      > "$OUT/agent.log" 2>"$OUT/agent.err" || true
    ;;
  *) die "unknown agent: $AGENT" ;;
esac
echo "$AGENT $(( $(date +%s) - start ))" > "$OUT/agent.status"
echo "agent $AGENT finished in $(( $(date +%s) - start ))s"
git -C "$WT" status --short | head -20
