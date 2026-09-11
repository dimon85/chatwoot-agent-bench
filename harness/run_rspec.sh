#!/bin/zsh
RUN=$1
S=/private/tmp/claude-501/-Users-dmytro-chatwoot/09b2c1f3-37b2-4cfb-988a-39ae4da3cc55/scratchpad/baseline
cd /Users/dmytro/chatwoot
eval "$(rbenv init - zsh)"
export PATH="/opt/homebrew/opt/postgresql@14/bin:$PATH"
export RAILS_ENV=test
SPECS=($(find spec -name '*_spec.rb' | sort))
echo "START $(date +%s) files=${#SPECS[@]}" > $S/run${RUN}.meta
bundle exec rspec -I ./spec --require spec_helper --format progress \
  --format json --out $S/run${RUN}.json \
  -- $SPECS > $S/run${RUN}.log 2>&1
echo "EXIT $? END $(date +%s)" >> $S/run${RUN}.meta
touch $S/run${RUN}.done
