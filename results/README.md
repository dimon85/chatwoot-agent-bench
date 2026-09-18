# Measured runs

Six runs, three per arm, 2026-09-17, all off-peak. Same harness, one variable: the model.

    a1 a2 a3   anthropic/claude-opus-5
    b1 b2 b3   deepseek/deepseek-flash

Per run:

| file | what it is |
|---|---|
| `changes.patch` | the agent's diff against `bench-base`, captured before any measurement touched the worktree |
| `changes.stat` | its diffstat |
| `metrics.json` | suites, acceptance, effort, run window, diff summary |
| `acceptance.json` | independent check that the field round-trips through the real API |
| `agent.model` | the model and effort the run was pinned to |
| `agent.jsonl.gz` | the agent's own event stream |
| `rspec.json.gz` | per-example results |
| `rspec.log.gz` | full suite output |
| `rubocop.json.gz` | lint report |
| `INSTRUMENT_MODIFIED` | present when the run edited a file the measurement depends on |

`part_a.json` holds the rubric's Part A for all six, produced by `harness/part_a.py`
before any diff was read closely.

Cost figures in `metrics.json` come from the harness and are **not** what was billed.
See ANALYSIS.md — the harness under-reports, by exactly the peak multiplier on one
provider and by an unexplained 1.67x on the other. Billed totals are in RESULTS.md.
