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
before_hash=$(shasum "$OUT/changes.patch" | cut -d' ' -f1)

# Did the agent edit the instrument rather than the code? A run that adds its own
# file to .rubocop.yml's exclusion list scores zero offences while having silenced
# the check — the lint and suite results for such a run mean nothing until a human
# reads the change. Detect it, do not judge it here.
INSTRUMENTS='^\+\+\+ b/(\.rubocop\.yml|\.eslintrc\.js|\.rspec|\.prettierrc|package\.json|vitest\.config\..*|spec/spec_helper\.rb|spec/rails_helper\.rb|\.github/|\.circleci/)'
if grep -qE "$INSTRUMENTS" "$OUT/changes.patch"; then
  { echo "Run modified files that the measurement itself depends on:"
    grep -E "$INSTRUMENTS" "$OUT/changes.patch" | sed 's|^+++ b/|  |'
  } | tee "$OUT/INSTRUMENT_MODIFIED"
fi

# Load the agent's schema.rb into a reset test database.
#
# NOT db:migrate: lib/tasks/db_enhancements.rake hooks ConfigLoader onto that
# task, so every invocation writes 113 rows into installation_configs — and a
# suite that expects the table empty then fails in ~360 places across unrelated
# areas. An agent running db:migrate itself (a perfectly normal thing to do)
# would poison its own measurement and read as a catastrophic regression.
#
# db:test:prepare carries no such hook, and resetting from schema.rb also
# discards whatever state the agent left behind — which is what isolation means.
# DISABLE_DATABASE_ENVIRONMENT_CHECK is required, not optional. Chatwoot's
# database.yml reads POSTGRES_DATABASE for BOTH development and test, so pinning
# one name per worktree points both environments at the same database. An agent
# running `rails db:migrate` without RAILS_ENV=test stamps it as development, and
# db:test:prepare then refuses to purge — silently leaving the ConfigLoader rows
# in place and failing ~430 specs. Purging is exactly what we want here: the test
# database is rebuilt from the agent's schema.rb on every measurement.
DISABLE_DATABASE_ENVIRONMENT_CHECK=1 \
  bundle exec rails db:test:prepare > "$OUT/migrate.log" 2>&1

# A failed reset invalidates the whole measurement — do not measure on a dirty database.
grep -qi "aborted\|error" "$OUT/migrate.log" && die "db:test:prepare failed, see $OUT/migrate.log"

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

# Acceptance runs last so it cannot disturb the suites. The agent writes its own
# specs, so the suite alone cannot say whether the feature works — this drives the
# real Rack stack and checks the prompt's three API requirements independently.
# The script lives in the harness, never in the worktree, so it stays out of the diff.
bundle exec rails runner "$HARNESS_DIR/acceptance.rb" > "$OUT/acceptance.json" 2>"$OUT/acceptance.err" || true
python3 - "$OUT/acceptance.json" <<'PYEOF'
import json, sys, pathlib
p = pathlib.Path(sys.argv[1])
raw = p.read_text()
start = raw.find('{')
p.write_text(raw[start:] if start >= 0 else '{"ok": false, "error": "no JSON emitted"}')
PYEOF

# A measurement must not alter what it measures. An earlier version ran
# db:migrate, which rewrote db/schema.rb and silently changed the artifact.
git add -A
after_hash=$(git diff --cached "$BASE_TAG" | shasum | cut -d' ' -f1)
git reset -q
if [ "$before_hash" != "$after_hash" ]; then
  echo "WARNING: measurement modified the worktree — the recorded diff is not what the agent produced" | tee "$OUT/CONTAMINATED"
fi

BASE_SHA=$(git rev-parse "$BASE_TAG") \
RUN_ID="$RUN_ID" AGENT="$AGENT" OUT="$OUT" KNOWN="${(j:,:)KNOWN_FAILURES}" \
python3 "$HARNESS_DIR/collect.py"

echo
echo "metrics: $OUT/metrics.json"
