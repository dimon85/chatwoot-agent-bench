# chatwoot-agent-bench

A small, pre-registered benchmark: give two coding agents the same feature task in a real
production codebase, run each five times, and classify every result against a rubric that
was written before the first run.

## Base commit — the fixed point

    repo:   https://github.com/chatwoot/chatwoot
    fork:   https://github.com/dimon85/chatwoot
    tag:    bench-base
    SHA:    bacb65d4f683ef40abb21796efe54c38d01a6d90
    date:   2026-09-10
    branch: develop at time of tagging

The tag is pushed to the fork, so this commit survives force-pushes and upstream rebases.
Every run starts from a `git worktree` at this SHA. Nothing in the Chatwoot tree is
patched — not even the two known-failing specs — because patching would move the base
commit away from upstream and make the baseline unreproducible.

## The task

See [PROMPT.md](PROMPT.md). Add `preferred_language` to `Contact`. The field genuinely
does not exist at the base commit; it appears nowhere in the schema, models, or specs.

The prompt is deliberately explicit that the field must round-trip through the API,
and deliberately silent about *which* controllers and serializers that implies — there
are four param entry points and three contact serializers, and finding them is the task.

## Method

1. `git worktree` from `bench-base`
2. run the agent with PROMPT.md, unmodified
3. run rspec (pinned order), vitest, lint
4. record metrics as JSON, keep the full diff
5. classify against [RUBRIC.md](RUBRIC.md)

Part A of the rubric (counting) is filled in for all runs before any diff is read closely.
Part B (judgement) comes after. The interpretation gate — which result leads to which
conclusion — is fixed in the rubric itself, so the data cannot pick its own story.

## Baseline

See [BASELINE.md](BASELINE.md) for the full environment, the two deviations a stock setup
needs, and three verification runs.

Headline: the suite is **deterministic** under a pinned spec order. Two clean runs produced
identical failure sets and identical pending sets. Noise boundary is zero, so any deviation
in an agent run is signal.

| Suite | Examples | Known failures | Duration |
|---|---|---|---|
| rspec | 9450 | 2 (both documented, neither a code defect) | ~11 min |
| vitest | 4582 | 0 | ~24 s |

Raw evidence is in [baseline/runs/](baseline/runs/): per-example JSON, full logs, timings.

## Publishing

Prompt, harness, rubric, every run's JSON, every diff and all logs get published
regardless of which way the result falls. The three possible conclusions are enumerated
in advance in RUBRIC.md.
