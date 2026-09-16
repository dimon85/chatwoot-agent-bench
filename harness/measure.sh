#!/bin/zsh
# Measure a worktree after an agent has finished working in it.
#
#   ./measure.sh <run_id> [agent_label] [path-to-worktree]
#
# The worktree path defaults to whatever provisioned this run_id, so a worktree
# created by Orca is measured the same way as one created by new_worktree.sh.
#
# Runs every suite SERIALLY and on a quiet machine. The baseline was measured
# that way; running suites concurrently makes wall-clock meaningless and can
# destabilise the order-dependent known failure.
set -e
HARNESS_DIR="${0:a:h}"
source "$HARNESS_DIR/lib.sh"
setup_toolchain

RUN_ID="${1:?usage: measure.sh <run_id> [agent_label]}"
AGENT="${2:-unknown}"
WT="${3:-$(cat "$BENCH_ROOT/.worktree-$RUN_ID" 2>/dev/null || echo "$WORKTREE_DIR/$RUN_ID")}"
OUT="$RESULTS_DIR/$RUN_ID"
DB=$(db_name_for "$RUN_ID")

[ -d "$WT" ] || die "no worktree at $WT"
mkdir -p "$OUT"
cd "$WT"

export RAILS_ENV=test POSTGRES_DATABASE="$DB"

# The diff is the artifact. Capture it before anything else can touch the tree.
git add -A
git diff --cached "$BASE_TAG" > "$OUT/changes.patch"
git diff --cached --stat "$BASE_TAG" > "$OUT/changes.stat"
git reset -q

# Schema changes only reach the test DB if migrations are applied.
bundle exec rails db:migrate > "$OUT/migrate.log" 2>&1 || true

run_step() {
  local name="$1"; shift
  local start=$(date +%s)
  "$@" > "$OUT/$name.log" 2>&1 && local code=0 || local code=$?
  local dur=$(( $(date +%s) - start ))
  echo "$name: exit=$code ${dur}s"
  echo "$code $dur" > "$OUT/$name.status"
}

SPECS=($(find spec -name '*_spec.rb' | sort))
run_step rspec bundle exec rspec -I ./spec --require spec_helper --format progress \
  --format json --out "$OUT/rspec.json" -- $SPECS
run_step vitest pnpm test
run_step eslint pnpm eslint
run_step rubocop bundle exec rubocop --format json --out "$OUT/rubocop.json"

BASE_SHA=$(git rev-parse "$BASE_TAG") \
RUN_ID="$RUN_ID" AGENT="$AGENT" OUT="$OUT" KNOWN="${(j:,:)KNOWN_FAILURES}" \
python3 "$HARNESS_DIR/collect.py"

echo
echo "metrics: $OUT/metrics.json"
