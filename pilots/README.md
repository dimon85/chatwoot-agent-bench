# Pilot runs

> **These pilots answered an earlier, backend-only prompt.** On 2026-09-17 the task was
> extended to require the field to be editable from the dashboard UI (see RUBRIC.md
> § Amendments). They remain published as the record of how the harness was debugged and
> why the rubric changed, but they are not pilots for the task that was actually measured,
> and their file counts are not comparable with the measured runs.

Runs made before the measured series, to answer whether the harness reproduces and
what a run costs. They are **not evidence** and must not appear in the analysis —
not even as corroboration, and especially not if the measured runs agree with them.

They are published because the harness and the rubric were both changed on the
strength of what they exposed.

## The clean four

| | agent | files | swagger defs | rspec | wall |
|---|---|---|---|---|---|
| pilot-1 | Claude Code | 14 | 3 | 9453 ex, baseline clean | 178s |
| pilot-2 | Claude Code | 17 | 5 | 9455 ex, baseline clean | 158s |
| pilot-4-codex | Codex | 15 | 4 | 9451 ex, baseline clean | 296s |
| pilot-5-claude | Claude Code | 16 | 5 | 9453 ex, baseline clean | 155s |

An earlier Codex run produced 6 files and touched no swagger at all. Its measurement
was invalidated by a harness defect, so it is not counted above — but the diff itself
was the agent's, and the spread it implies is the reason the measured series needs
five runs per arm rather than one.

## What they exposed

**Three harness defects, all of which would have manufactured a conclusion.**

1. `db:migrate` has ConfigLoader hooked onto it by `lib/tasks/db_enhancements.rake`,
   so every call writes 113 rows into `installation_configs`. The suite expects that
   table empty and failed in 359 places across billing, Captain, Cloudflare and
   Facebook. Codex ran `db:migrate` itself — an entirely normal thing to do after
   adding a migration — and would have scored F2 in all five of its runs for an
   artifact.

2. The same task rewrote `db/schema.rb`, so the recorded diff was no longer the
   agent's work. The measurement was corrupting what it measured.

3. `db:test:prepare` then aborted with `EnvironmentMismatchError` and the harness
   swallowed it with `|| true`, measuring on a database that still held the
   ConfigLoader rows — 430 failures, none of them the agent's. Root cause was the
   harness's own design: Chatwoot's `database.yml` reads `POSTGRES_DATABASE` for
   both the development and test environments, so pinning one name per worktree
   pointed both at the same database.

Every one of these was invisible until a second agent exercised a path the first
never took. The null run — measuring an untouched worktree — did not catch any of
them, because nothing had happened in that worktree.

**A rubric gap.** Both Claude pilots edited `swagger/` definitions, a surface the
original touchpoint map missed entirely. See RUBRIC.md § Amendments.

**Two metrics that are not comparable across arms.** Claude Code reports one
`num_turns` per assistant message (32-35); Codex reports a single `turn.completed`
for the whole run. And the two use different tokenizers, so token counts are the
same order of magnitude but not the same unit.

## Why the prompt changed

Every one of these runs touched **zero** frontend files, and the backend core came out
identical across all of them — same migration filename, same permitted param, same
serializer line. All the visible variance was in how much swagger documentation each run
updated. Meanwhile vitest returned 4582/4582 every time and eslint was always clean: two
of the four suites could not distinguish good work from bad.

That is what prompted extending the task to the UI.

## What the spread looks like

Within Claude Code alone: 14, 16 and 17 files. Codex: 6 and 15. The ranges overlap,
and the widest gap in the whole set is between two runs of the same agent.
