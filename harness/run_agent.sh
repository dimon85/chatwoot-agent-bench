#!/bin/zsh
# Launch one agent against PROMPT.md in a provisioned worktree.
#
#   ./run_agent.sh <run_id> <agent: claude|codex> [path]
#
# The model is pinned, not left to the default. Not because routing drifts within
# a run — it does not; the helper model spent exactly 1014 tokens in both pilots —
# but because a default can change between runs. An update landing mid-series
# would have run 1 and run 5 on different models with nothing in the data to say so.
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
CLAUDE_MODEL="${CLAUDE_MODEL:-claude-opus-5}"
CODEX_MODEL="${CODEX_MODEL:-gpt-5.6-sol}"
# Effort is set explicitly for both arms rather than inherited. Both CLIs read it
# from machine-local config (~/.claude/settings.json, ~/.codex/config.toml) that
# this repo does not contain, so a reader cloning it would silently run at
# whatever their own machine is set to.
EFFORT="${EFFORT:-medium}"

cd "$WT"
start=$(date +%s)
# UTC start/end are recorded because some providers price by time of day
# (DeepSeek runs off-peak discounts). Cost is therefore NOT measured here: tokens
# are invariant, the rate is not. Compute cost in the analysis from a stated rate
# card, and state which window each run fell in.
date -u +"%Y-%m-%dT%H:%M:%SZ" > "$OUT/agent.started_utc"
case "$AGENT" in
  claude)
    echo "model: $CLAUDE_MODEL effort: $EFFORT" > "$OUT/agent.model"
    claude -p "$PROMPT" --model "$CLAUDE_MODEL" --effort "$EFFORT" --dangerously-skip-permissions \
      --output-format json > "$OUT/agent.json" 2>"$OUT/agent.err" || true
    ;;
  codex)
    echo "model: $CODEX_MODEL effort: $EFFORT" > "$OUT/agent.model"
    # --json emits JSONL events including per-turn token usage, so the effort
    # metrics are comparable with the Claude arm. stdin is closed: codex exec
    # reads it by default and would block a detached run.
    codex exec --model "$CODEX_MODEL" -c "model_reasoning_effort=$EFFORT" \
      --json --dangerously-bypass-approvals-and-sandbox "$PROMPT" \
      < /dev/null > "$OUT/agent.jsonl" 2>"$OUT/agent.err" || true
    ;;
  *) die "unknown agent: $AGENT" ;;
esac
date -u +"%Y-%m-%dT%H:%M:%SZ" > "$OUT/agent.finished_utc"
echo "$AGENT $(( $(date +%s) - start ))" > "$OUT/agent.status"
echo "agent $AGENT finished in $(( $(date +%s) - start ))s"
git -C "$WT" status --short | head -20
