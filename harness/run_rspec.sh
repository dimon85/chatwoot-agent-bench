#!/bin/zsh
# The runner that produced the three baseline verification runs in baseline/runs/.
# Kept for provenance: it pins the spec order the whole benchmark depends on.
# For measuring an agent's worktree use measure.sh instead.
#
#   ./run_rspec.sh <run_number> [repo_path]
RUN=${1:?usage: run_rspec.sh <run_number> [repo_path]}
REPO=${2:-$HOME/chatwoot}
OUT="${0:a:h}/../baseline/runs"

mkdir -p "$OUT"
cd "$REPO"
eval "$(rbenv init - zsh)"
export PATH="/opt/homebrew/opt/postgresql@14/bin:$PATH"
export RAILS_ENV=test

SPECS=($(find spec -name '*_spec.rb' | sort))
echo "START $(date +%s) files=${#SPECS[@]}" > "$OUT/run${RUN}.meta"
bundle exec rspec -I ./spec --require spec_helper --format progress \
  --format json --out "$OUT/run${RUN}.json" \
  -- $SPECS > "$OUT/run${RUN}.log" 2>&1
echo "EXIT $? END $(date +%s)" >> "$OUT/run${RUN}.meta"
