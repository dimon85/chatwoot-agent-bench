# Rate cards and cost derivation

The harness records tokens and a UTC timestamp per run. It does **not** record cost.
Cost is derived here, from rates written down with the date they were read, so the
numbers can be rechecked later and recomputed if a provider reprices.

## DeepSeek

Read from DeepSeek's pricing page on 2026-09-16.

Model name is `deepseek-flash`. The legacy `deepseek-v4-flash` is still accepted but
that model is retired: requests are served by DeepSeek-V4.1-Flash and billed at the
Flash price. Pin the current name — a legacy alias silently serving a different model
is exactly the kind of thing that invalidates a benchmark.

USD per 1M tokens:

| | Flash off-peak | Flash peak | Pro off-peak | Pro peak |
|---|---|---|---|---|
| input, cache hit | 0.003 | 0.006 | 0.022 | 0.044 |
| input, cache miss | 0.15 | 0.30 | 0.66 | 1.32 |
| output | 0.60 | 1.20 | 1.98 | 3.96 |

Off-peak is exactly half of peak.

**Peak hours: 01:00-04:00 and 06:00-10:00 UTC, Monday to Friday.** Everything else,
including all weekend, is off-peak.

In Kyiv time (UTC+3): peak is 04:00-07:00 and 09:00-13:00 on weekdays.

Concurrency limits: Flash 2500, Pro 500. Not a constraint — the series is serial.

### Scheduling the series

A series takes about three hours. To keep the whole DeepSeek arm inside one pricing
window, start **after 13:00 Kyiv on a weekday**, or run on a weekend, when every hour
is off-peak.

If a series does straddle a boundary, do not discard it. Report the DeepSeek arm at
both rates and say which runs fell where — `run_window_utc` in each metrics.json has
the answer.

## Anthropic

From the model reference, 2026-09-16. USD per 1M tokens:

| | input | output |
|---|---|---|
| Claude Opus 5 | 5.00 | 25.00 |
| Claude Sonnet 5 | 2.00 | 10.00 |

Cache reads bill at roughly 0.1x input, cache writes at roughly 1.25x. No time-of-day
variation.

## Known limitation: reasoning effort is not pinned

Every other setting in this benchmark is pinned explicitly — model, autonomy, spec
order, database, `.env`. Reasoning effort is not, because opencode exposes no way to
set it: there is no flag on `opencode run`, and nothing in the installed package
matches an effort, reasoning-effort or thinking-budget setting.

Both arms therefore run at whatever opencode's defaults are for their provider. Since
both arms use the same harness, this is not a difference *between* the arms in the way
a mismatched setting would be — but it is not a guarantee of parity either, because
the two providers interpret their own defaults independently.

State this in the writeup rather than implying every variable was controlled. It was
controllable on Claude Code (`--effort`) and on Codex (`-c model_reasoning_effort`);
it is not controllable here, and that is the price of the BYOK harness that makes the
one-variable design possible in the first place.

## Why cost per token is not the comparison

The two vendors use different tokenizers — Anthropic's own guidance puts the Claude
4.7+ tokenizer at roughly 1x to 1.35x the token count of its predecessor for the same
text. Two providers' "per 1M tokens" figures therefore describe different amounts of
work, and every price-comparison table built on them compares nothing.

The comparison is **cost per completed task**: tokens actually spent on this task, at
the rates above, for runs that satisfied the prompt. That is why the rubric records
tokens and the window rather than a dollar figure.
