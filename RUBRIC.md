# Rubric — Contact#preferred_language

Frozen before the first measured run. Base SHA `bacb65d4f`. See BASELINE.md.

Two independent parts. Part A is counting, Part B is judgement. Do Part A for all runs
before reading any diff closely, and never let Part B revise Part A.

---

## Part A — Recorded facts (no scoring)

Counted per run. These are descriptive. Low numbers are NOT failures: `AGENTS.md:46`
tells the agent to "prefer the smallest production-ready change", so a narrow diff may be
compliance rather than negligence. Breadth is reported, not graded.

| # | Fact | How to count |
|---|---|---|
| A1 | Migration present | 0/1 |
| A2 | `db/schema.rb` regenerated | 0/1 |
| A3 | Model annotation updated (`app/models/contact.rb` header) | 0/1 |
| A4 | Param entry points touched, of 4 | `api/v1/accounts/contacts_controller.rb:174`, `public/api/v1/inboxes/contacts_controller.rb:51`, `api/v1/widget/contacts_controller.rb:88`, `api/v1/widget/conversations_controller.rb:98` |
| A5 | Contact serializers touched, of 3 | `api/v1/models/_contact`, `public/api/v1/models/_contact`, `api/v1/accounts/search/_contact` |
| A5b | Swagger contact definitions touched | of 5 dashboard (`resource/contact`, `resource/contact_detail`, `resource/contact_list_item`, `request/contact/create_payload`, `request/contact/update_payload`) and of 3 public (`resource/public/contact`, `resource/public/contact_record`, `request/public/contact/create_update_payload`) |
| A5c | Generated swagger artifacts | `swagger.json` and `tag_groups/*.json` are built by `rake swagger:build`. Record: regenerated / hand-edited / untouched |
| A6 | Filter/automation surfaces touched | `custom_attribute_definition.rb:28`, `automation_rule.rb:50`, frontend filter constants |
| A7 | Frontend surface touched | Which contact form: `routes/dashboard/conversation/contact/ContactForm.vue` (legacy) or `components-next/Contacts/ContactsForm/ContactsForm.vue` (current), or both, or neither |
| A7b | Frontend supporting files | `i18n/locale/en/contact.json`, story fixtures, vitest specs — count each |
| A8 | Spec files added/modified | count |
| A9 | Validation added | none / presence / inclusion / enum — record which |
| A10 | Diff size | files changed, insertions, deletions |
| A12 | Measurement instrument touched | Did the run edit `.rubocop.yml`, `.eslintrc.js`, `.rspec`, `package.json`, a vitest config, a spec helper, or CI config? Record which and what changed. A run that silences a check has a meaningless lint result until a human reads the edit. |
| A11 | Run effort | Primary and comparable: input / output / cache-read / cache-write tokens, turns, wall-clock seconds |
| A11b | Dollar figure | Annotation only, never an axis of comparison. Claude Code's `total_cost_usd` carries `costBasis: "list"` — it is token usage priced at published API rates, not money billed. Both arms run on subscriptions, so nothing is charged per token, and each vendor's figure uses its own price list. Record it; do not compare it. |

---

## Part B — Failure taxonomy F0–F7

Assign every failure that applies; a run can carry several. Severity is not the axis —
**subtlety** is. F1–F3 are failures a CI run catches. F4–F7 are failures that pass CI and
reach a human reviewer, or don't.

### F0 — no defect found
Requirements met, baseline clean, nothing in F1–F7 applies.

### F1 — does not run
Migration raises, app fails to boot, spec suite fails to load, lint/`vue-tsc` hard error.
Detection: harness exit codes.

### F2 — baseline regression
Any rspec failure outside the known pair
(`agent_builder_spec.rb:47`, `call_transcription_service_spec.rb:77`), or any vitest
failure at all. Compare failure **sets**, not counts.

### F3 — stated requirement unmet
The prompt named five things. Each unmet one is a separate F3:
F3a not persisted · F3b not settable via API · F3c not returned in API responses ·
F3d not editable from the dashboard UI · F3e no specs.

F3a-c are decided by `acceptance.json`, not by reading the diff and not by trusting
the agent's own specs — the harness drives the real Rack stack and checks that the
field is settable on create, actually persisted, updatable, and present with the right
value in a read response. F3d is a human check against the running app; F3e is a
count.

### F4 — silent partial coverage
The field works on one path and is silently dropped on another that the agent also
edited or plainly should have considered — no error, no warning, value vanishes.
The historically real case: upstream shipped `blocked` in Feb 2024 with migration,
model and params but **no serializer**; `json.blocked` landed a year later (f112e500e).
An agent reproducing that shape lands here.

### F5 — convention violation a reviewer would block
Hand-editing a generated artifact counts here: `swagger.json` and
`swagger/tag_groups/*.json` are built from the `.yml` sources by
`rake swagger:build`, so editing them directly produces a diff that the next
build silently reverts.

Editing the measurement instrument counts here, and is worse than an ordinary
violation: adding your own file to `.rubocop.yml`'s `Metrics/ClassLength` exclusion
list turns a real offence into a reported zero. Seen in an opencode pilot.

Against `AGENTS.md`, and now actually reachable because the task includes UI:
bare strings in templates instead of i18n, custom or scoped CSS instead of Tailwind
utilities, Options API instead of `<script setup>`, direction-unaware padding/margin
instead of the logical `ms`/`me`/`start`/`end` utilities, a non-English locale file
edited, nested `module`/`class` style, specs with helper methods instead of `let`.

### F6 — latent data or migration hazard
Irreversible migration, missing index where the codebase indexes comparable columns,
`null:`/`default:` mismatch with sibling fields (`country_code` is `default: ""`,
`blocked` is `default: false, null: false`), a column that ignores account scoping,
or a backfill that would lock a large table.

### F7 — surface or tenancy misjudgement
Treating all four param entry points and all three serializers as interchangeable.
They are not: `public/api/v1/*` and `api/v1/widget/*` are reachable by **end users**,
not agents. Exposing or accepting the field there is a product decision, not a
completeness checkbox. Both directions count as F7 — blindly widening every surface,
or widening one without noticing whose data it exposes. Record which direction.

---

## Sample size

Three runs per arm, not five. See § Amendments, 2026-09-17.

## Known limitation of Part A

A7 and A7b count which frontend files a run touched. They do not and cannot capture
what was built inside them. In the measured series, five runs adding a free-text input
and one run adding a searchable dropdown backed by the project's own language list
produced identical Part A rows.

No automated step in this harness distinguished them. F3d, the human check against the
running application, did — in about a minute. That is why it stays a human check.

## Interpretation gate (decided in advance)

- F4–F7 present in either arm → the finding is about *what agents miss that CI doesn't catch*.
- Only F1–F3, and widely → the finding is *agents don't carry this class of task*.
- All F0, both arms → the finding is *tool choice matters less than run-to-run variance*;
  report the Part A spread as the result.

Whichever lands, it gets published. The gate is fixed here so the result cannot pick it.

---

## Amendments

Changes to this rubric are listed here with their reason. Nothing may be amended
after the first measured run.

### 2026-09-17 — the task now includes the dashboard UI (before any measured run)

The original prompt asked only that the field persist, round-trip through the API and
come back in API responses. Every pilot therefore touched zero frontend files, and the
backend work came out *identical* across all five runs — the same migration down to its
filename, the same permitted param, the same serializer line. The only variance was how
much swagger documentation each run updated.

That makes two of the four suites dead weight: vitest returned 4582/4582 in every run
and eslint was always clean, so neither could distinguish good work from bad.

The prompt now also requires the field to be editable from the dashboard UI. That
activates vitest and eslint, and it reaches a set of `AGENTS.md` rules that are
objectively checkable — Tailwind only, no scoped CSS, `<script setup>`, no bare strings
in templates. It also forces a real judgement the backend task never did: Chatwoot has
two contact forms, a legacy one and a `components-next` one, and picking between them
is a decision rather than a lookup.

Cost of the change, stated plainly: the four existing pilots answered a different
prompt and are no longer pilots for this task. A bigger task also means more variance,
so five runs per arm will support a weaker conclusion than they would have on the
backend-only version.

Part A gains A7/A7b to count the frontend surface. F5 is unchanged in meaning but is
now reachable.

### 2026-09-17 — added A12, agents editing the measurement instrument (before any measured run)

An opencode pilot on the extended task added `app/models/contact.rb` to the
`Metrics/ClassLength` exclusion list in `.rubocop.yml`. Its change had pushed the
class past the limit, and rather than accept the offence it exempted the file. The
harness dutifully reported zero rubocop offences.

The number was true and meaningless: the run silenced the check it was being measured
by. Without noticing, that run would have scored identically to one that genuinely had
no offences.

Part A gains A12 to record it, and the harness now writes an `INSTRUMENT_MODIFIED`
marker when a diff touches `.rubocop.yml`, `.eslintrc.js`, `.rspec`, `package.json`,
a vitest config, a spec helper, or CI config. The marker records the fact; whether it
is defensible is a judgement made later from the diff, under F5.

### 2026-09-17 — the harness now checks the feature works (before any measured run)

Every suite in the harness could pass on a change that does not work. rspec runs the
agent's own specs, so the defendant grades itself; vitest and eslint say nothing about
whether a field round-trips; and the diff only shows that lines were written.

`harness/acceptance.rb` now drives the real Rack stack through
`ActionDispatch::Integration` and checks the prompt's API requirements independently:
the field is settable on create, actually persisted to the database, updatable, and
returned with the right value in a read response.

It lives in the harness directory and is run by path, so it never enters the worktree
or the agent's diff, and it runs last so it cannot disturb the suites.

Validated in both directions before being adopted: all six checks pass on a pilot that
implemented the field, and it fails with `column preferred_language does not exist` on
an untouched worktree. A check that cannot fail would measure nothing.

F3a-c are now machine-decided. F3d, the UI requirement, still needs a human looking at
the running app.

### 2026-09-17 — the series is three runs per arm, not five (decided mid-series)

The first Opus run consumed 12.9M context tokens against the pilot's 2.5M — five times
as much for the same prompt on the same model — and the billed multiplier over the
harness's own figure turned out to be 1.71x. Five runs of that arm would have cost
around a hundred dollars against a forty-four dollar balance, and would have run out
partway through, leaving one arm complete and the other truncated.

Stopped at three per arm instead, with both arms equal. An unequal series would have
been worthless; a smaller equal one is merely weaker.

Recorded here rather than quietly: the decision was made after seeing three runs'
resource usage but before seeing any diff or any classification, and the runs already
completed were not re-selected or discarded. What it costs is statistical power. With
the spread already visible inside arm A — 2.5M to 12.9M tokens, 48 to 117 steps — three
points support a much weaker claim than five. If the between-arm difference does not
exceed the within-arm spread, the honest finding is "not distinguishable at this sample
size", and it must be stated that way rather than as a ranking.

### 2026-09-16 — added A5b and A5c, extended F5 (before any measured run)

Both pilot runs edited `swagger/` definitions, a surface the original touchpoint
map missed entirely: the Contact contract is described by eight swagger files —
five for the dashboard API, three for the public API — in addition to the
controllers and jbuilder serializers.

Without a counter for it, a run that documented the new field and a run that
shipped it undocumented would score identically.

The amendment is deliberately minimal. Swagger is not a new axis: neither pilot
touched the public swagger files, exactly as neither touched the public
controller, so the dashboard/public split it exposes is already what F7 measures.
Only the counting in Part A changed, plus one clarification in F5 about generated
artifacts.

Recorded after pilot-1 and pilot-2, both of which are excluded from the measured
set and published as pilots.

### 2026-09-16 — split A11 into effort and dollars (before any measured run)

Both arms run on subscriptions, so no per-token money changes hands. Claude Code's
`total_cost_usd` is explicitly `costBasis: "list"` — token usage priced at published
API rates. In pilot-1 it was $1.54, almost all of it 1.39M cache-read tokens: the
number tracks how much context the agent re-read, not what the run cost anyone.

Worse for a comparison: the other arm's figure would be computed from a different
vendor's price list. Comparing the two would measure pricing policy, not agents —
and a vendor repricing its cache would change the "winner" with no change in
behaviour.

Tokens, turns and wall-clock are independent of price lists, so they become the
comparable metric. The dollar figure stays as an annotation.

No scoring changed; this is a labelling correction.

### 2026-09-16 — pinned model and effort explicitly (before any measured run)

Both CLIs read model and reasoning effort from machine-local config this repo does
not contain — `~/.claude/settings.json` and `~/.codex/config.toml`. On this machine
both happened to be set to medium effort, so the two arms were already at parity by
accident; a reader cloning the repo would have run at whatever their own machine was
set to, and neither the runs nor the data would have said so.

The harness now passes `--model` / `--effort` (Claude) and `--model` /
`-c model_reasoning_effort` (Codex) explicitly, defaulting to the medium effort the
pilots were actually run at, overridable via `CLAUDE_MODEL` / `CODEX_MODEL` / `EFFORT`.
Each run records the pair in `agent.model`.

Pinning the model does not change capability: the pilots resolved to
`claude-opus-5[1m]`, and an explicit `--model claude-opus-5` reports the same
1M context window and 64K max output, so the suffix is a billing label. The pilots
therefore remain comparable with the measured runs.
