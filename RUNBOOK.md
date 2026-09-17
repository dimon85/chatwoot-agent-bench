# Runbook — the measured series

Ten runs: five Claude Code, five Codex. Everything below is fixed in advance;
if something here has to change mid-series, the series restarts.

## Before starting

- [ ] Nothing else heavy running. Suites are timed and one known failure is
      order-dependent; a busy machine can destabilise it.
- [ ] `brew services list` — postgresql@14 and redis both started.
- [ ] Check the subscription limits (`/usage` in Claude Code). Dollars are not the
      constraint here — both arms run on subscriptions — but a rate limit hit
      halfway through the series is.
- [ ] `git -C ~/chatwoot rev-parse bench-base` → `bacb65d4f683ef40abb21796efe54c38d01a6d90`
- [ ] Working tree of this repo clean and pushed.

## Running

One run at a time, serially:

Credentials come from `~/.chatwoot-bench.env` (chmod 600, outside the repo), sourced
automatically by the harness. Keys are never written into the repo or into
opencode's auth.json.

    cd ~/chatwoot-agent-bench/harness
    OPENCODE_MODEL=anthropic/claude-opus-5 ./run_one.sh a1 opencode
    OPENCODE_MODEL=deepseek/deepseek-flash  ./run_one.sh b1 opencode

Pin `claude-opus-5`, never `claude-opus-5-fast` — same model, double the rate, no
benefit to the measurement.

Legacy form, kept for reference:

    ./run_one.sh a1 claude
    ./run_one.sh a2 claude
    ./run_one.sh a3 claude
    ./run_one.sh a4 claude
    ./run_one.sh a5 claude
    ./run_one.sh b1 codex
    ./run_one.sh b2 codex
    ./run_one.sh b3 codex
    ./run_one.sh b4 codex
    ./run_one.sh b5 codex

Roughly 17 minutes each: ~3-5 min agent, ~12 min measurement. About 3 hours total,
nearly all of it unattended.

Interleaving the arms is fine and arguably better — it spreads any drift in the
machine or the services across both. Do not run two at once: the measurement is
timed and the suites compete for CPU and Postgres.

## Time-of-day pricing

DeepSeek prices by the clock — off-peak runs are cheaper than peak ones. The series
takes about three hours and can straddle a boundary, which would make part of one arm
look cheaper for reasons that have nothing to do with the model.

Handled by not measuring cost at all. The harness records `run_window_utc` per run
and the token counts; cost is computed afterwards from a rate card written down in
the analysis, stating which window each run fell in. Tokens are invariant, the rate
is not — and a rate card recorded as a number in a results file cannot be rechecked
later, while tokens plus a timestamp can.

Before the series, write the current DeepSeek rate card and its off-peak hours into
`ANALYSIS.md` with the date you read them and a link. Do the same for the Anthropic
rates. If the whole series fits inside one window, say so; if it does not, report the
DeepSeek arm at both rates.

## After each run

Check only this:

    cat ~/chatwoot-agent-bench/runs/<id>/metrics.json | python3 -m json.tool | head -30

Look for `matches_baseline` and for a `CONTAMINATED` file. **Do not read the diff.**
Reading diffs between runs is how you start unconsciously steering the next one.

## After all ten

1. Fill Part A of the rubric for all ten runs — counting only, no judgement.
2. Only then read the diffs, and assign Part B.
3. Apply the interpretation gate in RUBRIC.md. It was fixed before any data existed;
   the data does not get to pick which conclusion it supports.

## What the pilots are not

Four pilot runs exist under `pilots/`. They are published because the harness and
the rubric changed on the strength of what they exposed. They are **not evidence**
and must not appear in the analysis, not even as corroboration — especially not if
the measured runs happen to agree with them.

## Known failures

Every clean run has exactly two, both documented in BASELINE.md:

    ./spec/builders/agent_builder_spec.rb:47
    ./spec/enterprise/services/voice/call_transcription_service_spec.rb:77

Anything else is signal. Anything fewer is also signal — an agent may have
accidentally fixed one.

## If you re-measure a run

measure.sh writes into runs/<id>/, so renaming a bad result directory and measuring
again leaves the new one without the agent's own artifacts — agent.json, agent.status,
agent.model — and the effort metrics come back empty. Copy those three files across
before re-running collect.py.

## If a run breaks

Keep it. Rename the directory with a suffix saying what went wrong, exactly as
`runs/pilot-3-codex.INVALID-harness-bug` did, and record it. A discarded run that
leaves no trace is indistinguishable from one that never happened.
