# Every number in the script, and where it came from

Lookup table for recording and for answering "where did X come from" in the comments.
Written before the edit, while the provenance was still fresh.

**Source codes**

| code | meaning |
|---|---|
| `BILL` | provider billing page or balance delta — the only source used for money |
| `CONSOLE` | provider usage / caching page — token counts |
| `REPO` | measured in this repository: `results/part_a.json`, `results/runs/*`, `baseline/` |
| `RATE` | published rate card, screenshot on file |
| `DERIVED` | arithmetic from the above; the working is shown |
| `UNVERIFIED` | **do not say on camera until checked** |

---

## Block 1 — cold open

| number | source | note |
|---|---|---|
| $11.01 per task, arm A | `BILL` + `DERIVED` | $33.04 ÷ 3. $33.04 = balance 44.32 → 11.28, bracketing a1/a2/a3 |
| 6.7 cents per task, arm B | `BILL` + `DERIVED` | $0.20 ÷ 3. $0.20 = balance 11.66 → 11.46, bracketing b1/b2/b3 |
| 164× | `DERIVED` | 11.01 / 0.067 = 164.3 |

**Reconciliation to guard this:** $5.68 (pilots) + $33.04 (series) = $38.72, which is
exactly the Anthropic console's billed total for 2026-09-17. DeepSeek: $0.32 (peak
pilots) + $0.20 (series) + $0.01 (smoke) = $0.53, the console's day total.

**If challenged with "the console says 73×":** the daily totals contain one Opus pilot
against two DeepSeek pilots. Different workloads. The series figures compare three runs
against three.

## Block 2 — one run tells you nothing

| number | source |
|---|---|
| six runs, three per model | `REPO` |
| 1 of 4 param entry points, 1 of 3 serializers, all six runs | `REPO` `part_a.json` A4, A5 |
| 3 of 6 did not rebuild generated docs — a3, b2, b3 | `REPO` A5c |
| one from the expensive model, two from the cheap | `REPO` a3 is arm A; b2, b3 arm B |
| five harness bugs | `REPO` commit history |

## Block 3 — setup

| number | source |
|---|---|
| ~9,500 backend tests | `REPO` 9,450 examples at base commit |
| four entry points, three serializers, eight swagger files, two contact forms | `REPO` grep at `bench-base` |
| three baseline runs, identical failure sets | `REPO` `baseline/runs/` |
| exactly two known failures | `REPO` `baseline/excluded_specs.txt` |

## Block 4 — how the measurement nearly lied

| number | source | note |
|---|---|---|
| 359 failures, 357 new | `REPO` `runs/pilot-3-codex.INVALID-harness-bug/rspec.json` | 2 of the 359 are the known pair |
| 294 identical DB errors | `REPO` same file, counted by exception class |
| 113 config rows per `db:migrate` | `REPO` measured live: 0 → 113 on the control worktree |
| 430 failures, 428 new | `REPO` `runs/pilot-5-claude.INVALID-db-env-mismatch/rspec.json` |
| 177 lines against a limit of 175 | `REPO` `runs/b3/rubocop.json`, verbatim message |

## Block 5 — why the cost numbers are fake

| number | source | note |
|---|---|---|
| $5 / $0.15 per million, input | `RATE` | Anthropic list; DeepSeek off-peak cache-miss |
| peak is double off-peak | `RATE` | DeepSeek pricing page screenshot |
| peak window 01:00–04:00 and 06:00–10:00 UTC, weekdays | `RATE` | same |
| 16 cents reported vs 32 billed | `BILL` + `REPO` | two pilots that started 07:09 and 07:28 UTC — inside peak |
| 2.5M reported vs 6.4M billed, one run | `CONSOLE` + `REPO` | console hourly bucket 09:00 vs `oc-opus-1` |
| gap ranges 1.16×–2.48× across four runs | `DERIVED` | per-run: 2.48, 1.16, 2.36, 1.49 |
| runs do not cross hour boundaries | `REPO` | 09:07–09:18, 12:20–12:45, 13:21–13:36, 14:21–14:39 |
| 3.5K Haiku input tokens | `CONSOLE` | caching page, day total |
| tokenisers differ between vendors | **`UNVERIFIED`** | the specific migration-guidance page has not been located. Either find it and keep the URL, or state the point without attributing it |

## Block 6 — what six runs showed

| number | source |
|---|---|
| 3 of 3 arm-A runs edited `.rubocop.yml` | `REPO` A12; marker files in `results/runs/a*/` |
| 5 of 6 reported zero lint offences | `REPO` a1 a2 a3 b1 b2 |
| validation 3/3 against 0/3 | `REPO` diffs of `app/models/contact.rb` |
| p ≈ 0.10, two-sided Fisher exact | `DERIVED` | 2 / C(6,3) = 2/20 |
| all six shipped the same ComboBox | `REPO` diffs of `ContactsForm.vue` |
| three different language sources | `REPO` `iso6391Languages` (a1), default import (a2, b2), `useConfig().enabledLanguages` (a3, b1, b3) |

## Block 7 — cost and caveats

| number | source | note |
|---|---|---|
| 47.9M input, 296,594 output, 2026-09-17 | `CONSOLE` | Anthropic Usage, day |
| $38.70 Opus + $0.02 Haiku = $38.72 | `BILL` | Anthropic Cost, day |
| read ratio 100%, write amortisation 36.1× | `CONSOLE` | Anthropic Caching page |
| 97.3% cache reads, 2.7% cache writes | `DERIVED` | write = 47.9M / 37.1 = 1.29M |
| effective input rate $0.65 per million | `DERIVED` | ($38.70 − $7.41 output) / 47.9M |
| cross-check of the $0.50 and $6.25 rates | `DERIVED` | 46.61M × 0.50 + 1.29M × 6.25 = $31.38 against $31.29 actual — 0.3% |
| writes: 2.7% of volume, 26% of the input bill | `DERIVED` | holds for the series alone too: 26% |
| write premium 25% over fresh | `RATE` | $6.25 against $5.00 |
| cache rates $0.50 vs $0.003 | `RATE` | DeepSeek publishes three decimals — do **not** quote a precise ratio off it |
| harness comparison: 32–35 steps vs 48–117; 155–178s vs 702–1513s | `REPO` | Claude Code pilots against opencode runs — **different prompt versions**, say so |

---

## Standing cautions

- **Money only from `BILL`.** The harness under-reports: DeepSeek by exactly the peak
  multiplier, Anthropic by a varying 1.16×–2.48×.
- **Per-run costs are balance deltas**, not console line items. They reconcile to the day,
  but the next series should use one API key per arm so the console reports per-run
  directly.
- **Everything is one task, one codebase, three runs per arm.**
- **Absolute costs are harness-specific.** The ratio travels; $11.01 does not.
