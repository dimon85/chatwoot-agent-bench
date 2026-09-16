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
| A7 | Frontend touched | 0/1, which files |
| A8 | Spec files added/modified | count |
| A9 | Validation added | none / presence / inclusion / enum — record which |
| A10 | Diff size | files changed, insertions, deletions |
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
The prompt named four things. Each unmet one is a separate F3:
F3a not persisted · F3b not settable via API · F3c not returned in API responses ·
F3d no specs.

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

Against `AGENTS.md`: bare strings instead of i18n, custom/scoped CSS instead of Tailwind,
nested `module`/`class` style, Options API instead of `<script setup>`, missing
`en.yml`/`en.json` entry, specs with helper methods instead of `let`, non-English locale
files edited.

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
