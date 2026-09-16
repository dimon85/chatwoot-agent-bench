# Pilot runs

Two runs of the same agent (Claude Code) on the same prompt, done before the
measured set to answer two questions: does the harness reproduce, and what does
one run cost.

They are NOT part of the measured data. They are published because the rubric
was amended on the strength of what they exposed — see RUBRIC.md § Amendments.

| | pilot-1 | pilot-2 |
|---|---|---|
| rspec | 9453 examples, 2 failures, baseline clean | 9455 examples, 2 failures, baseline clean |
| vitest | 4582 passed | 4582 passed |
| rubocop | 0 offenses | 0 offenses |
| eslint | clean | clean |
| diff | 14 files, +181/-18 | 17 files, +287/-14 |
| cost | $1.54 | $1.77 |
| turns | 35 | 33 |
| wall | 178s | 158s |

## What they showed

**The harness reproduces.** Both ran end to end without intervention and both
matched the baseline failure set exactly.

**Within-agent variance is real.** Same agent, same prompt, 14 files versus 17.
The core was identical — migration (down to the filename), model annotation,
controller params, jbuilder, controller spec, three swagger definitions and the
generated swagger artifacts. pilot-2 additionally found `spec/models/contact_spec.rb`,
`contact_detail.yml` and `contact_list_item.yml`.

That spread inside one agent is the thing to measure the between-agent
difference against.

**Both stayed on the dashboard surface.** Neither touched the public API or widget
controllers, and neither touched the public swagger definitions — a consistent
reading of the field as dashboard-owned, not an oversight. `AGENTS.md` tells
agents to prefer the smallest production-ready change, so this is compliance.

**Both regenerated swagger rather than hand-editing it.** All four `tag_groups`
files changed coherently, which only `rake swagger:build` produces.
