#!/bin/zsh
# The measured series: five runs per arm, alternating, one at a time.
# Alternating spreads any drift in the machine or the services across both arms.
set -e
HARNESS_DIR="${0:a:h}"
source "$HARNESS_DIR/lib.sh"

for i in 1 2 3 4 5; do
  OPENCODE_MODEL=anthropic/claude-opus-5 "$HARNESS_DIR/run_one.sh" "a$i" opencode
  OPENCODE_MODEL=deepseek/deepseek-flash "$HARNESS_DIR/run_one.sh" "b$i" opencode
done
echo "=== SERIES COMPLETE ==="
