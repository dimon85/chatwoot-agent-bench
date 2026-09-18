# Script — video 1

Written before the measured series finished, so the narrative spine is on record with
a date and cannot have been fitted to the result. The blocks that depend on the data
were left unwritten until the runs were classified.

**Title: "The $5 model and the $0.15 model wrote the same code"**

Both figures are input prices. An earlier draft used "$25 and $0.15", which pairs one
model's output price against the other's input price — the exact unit error block 5
spends three minutes attacking.

Chosen after the data. It survives the finding because it is literally what the six runs
showed, and it forecloses the argument about which one "won".

Target: ~25 minutes, English. Blocks 6 and 7 run long on purpose; the result and its
caveats are the load-bearing half. Register: understate everything. The currency here is
trust, and trust is built by claiming less than you can prove.

---

## Block 1 — Cold open
**0:00 – 1:25 · ~212 words**

> SCREEN: two numbers, nothing else.

Eleven dollars and one cent. Six point seven cents.

Same task. Same repository, same commit, same prompt. One of these models costs a
hundred and sixty-four times more than the other to finish the same piece of work.

> SCREEN: the two diffs, side by side, scrolling together.

And the code they wrote was almost identical.

> SCREEN: hold.

That is not the interesting part.

The interesting part is that both of them left the same kind of defect in this
codebase — and my test suite reported green, my linter reported green, and the feature
worked when I clicked it.

I ran each model three times. Most of the week went not into measuring the models, but
into discovering that my measurement was lying to me. Five separate times.

Here is what I found.

> SCREEN: title card.

---

## Production notes for Block 1

- Open on the two numbers with no voice for a beat. They do the work.
- "And the code they wrote was almost identical" is the turn. Everything after it is
  the actual video; everything before it is the bait the genre trained people to expect.
- Do not say "which one won" anywhere in the video. The finding is not a ranking and
  promising one costs you the last five minutes.
- Do not claim a type checker. This project has none — only rspec, vitest, eslint and
  rubocop.

---

## Block 2 — Why one run tells you nothing
**1:25 – 4:06 · ~403 words**

> SCREEN: a typical "I tested two models" post.

There is a genre that goes like this. Take two models, give each one a task, look at the
output, tell people which is better.

One run cannot answer that — and not for the reason you would guess.

> SCREEN: six diff summaries in a row.

I ran the same task six times. Three per model. The code came out remarkably consistent:
same migration, same entry point out of the four this codebase has, same serializer out
of three, same component in the interface. Every run produced a working feature.

Run this once and you would conclude the models are interchangeable. About the code,
that is roughly true.

> SCREEN: one file — the generated API docs — with three runs marked.

Here is one thing that was not consistent.

This project's API documentation is generated. You edit source files, then run a build
step that produces what actually gets served.

Three of the six runs edited the sources and never finished the build. One from the
expensive model. Two from the cheap one. Every one of those runs passed the full test
suite, because no test looks at generated documentation.

> SCREEN: hold on the split — 1 of 3, 2 of 3.

So it is not that one model documents properly and the other does not. Both did it
sometimes. Whether your project ends up with stale API docs depends on which run you
happened to get.

Pick one run, write a post about it, and you would be describing that run. Not the
model.

> SCREEN: the benchmark repo, commit history.

That is why this took a week. A rubric committed before the first run so I could not
move the goalposts afterwards. Every run published.

And most of the week did not go into measuring the models. It went into finding out that
my measurement was lying to me. Five separate times — and one of those nearly made me
publish a confident, well-evidenced, completely false claim.

> SCREEN: cut to Block 3.

---

## Production notes for Block 2

- One defect here, not three. The linter and the failing spec belong to block 6; naming
  them now makes block 6 a recap of things the viewer heard at minute two.
- Use the documentation defect specifically because it splits **within** both models —
  one run of three on one side, two of three on the other. That is what makes it
  evidence for "one run tells you nothing".
- Do not use the linter split here. It is 3–0 by model, which is a difference *between*
  models — the opposite of this block's argument. It is block 6's material.
- Do not show a six-row table. That is block 6's graphic; showing it now spends it.

## Block 3 — The setup
**4:06 – 7:52 · ~565 words · data-independent**

> SCREEN: the Chatwoot repo, file tree scrolling.

The repository is Chatwoot. Open source, in production at real companies, about nine
and a half thousand backend tests. Not a toy, not a benchmark suite written to be
solved.

> SCREEN: the prompt, full screen, short enough to read.

The task is one paragraph. A contact needs a field recording which language they prefer
to be contacted in. It has to be stored, settable through the API, returned in API
responses, editable in the dashboard, and covered by tests.

That is deliberately small. What makes it useful is where it does *not* say anything.

> SCREEN: highlight the four API entry points and the two contact forms.

Because in this codebase, contact data is accepted in four different places. It is
serialised in three. The API contract is documented in eight more files. And there are
two contact forms in the interface — an older one and a newer one that is replacing it.

The prompt does not mention any of that. Finding it is the task.

> SCREEN: the rubric file, commit date visible.

Before I ran anything, I wrote down how I would score the results, and committed it.
Publicly, with a timestamp. Two parts: things you count, and things you judge.

The counting part is deliberately not scored. How many of the four entry points did a
run touch? How many serializers? I record the number. I do not call a low number a
failure — because the repository's own contributor guide tells agents to prefer the
smallest change that solves the problem. A narrow diff might be obedience, not
laziness.

> SCREEN: the interpretation gate in the rubric.

And I wrote down, in advance, which result leads to which conclusion. Including the
boring one: if the models land inside each other's spread, the video is about that.
That decision is in the commit history, dated before any data existed, specifically so
the data could not pick its own story.

> SCREEN: three baseline runs, identical failure sets.

Then the baseline. I ran the untouched test suite three times before any model saw the
repository. Nine thousand four hundred and fifty tests, exactly two failures every
time, identical sets, identical skips.

Those two failures are real and they are documented. One needs a search engine I am not
running. The other passes on its own and fails inside the full suite — an ordering
problem that has nothing to do with me. I did not fix either, because fixing them would
mean I was no longer measuring the upstream codebase.

Two failures is the pass mark. Anything else is signal.

> SCREEN: the harness config, model and settings pinned.

One thing changes between the two arms: the model. Same tooling, same prompt, same
commit, same autonomy settings, same test order, each run in its own isolated database.

Two things I could not pin, and I want them on the record. The tooling gives me no way
to set reasoning effort, so both models run at whatever their defaults are. And the
billing shows the tooling occasionally calls a small model of its own, which I did not
ask for and cannot turn off.

Everything else is fixed.

> SCREEN: cut to Block 4.

---

## Production notes for Block 3

- The "four entry points, three serializers, eight doc files, two forms" beat is what
  makes the task credible as real work. Spend the screen time there.
- "A narrow diff might be obedience, not laziness" — this is the line that separates
  this video from the genre. Do not cut it for time.
- Stating the two unpinnable variables here, unprompted, buys more credibility than
  any amount of rigour claimed later.
- Do not explain the two baseline failures in detail. Name them, move on; the detail
  lives in the repo.
## Block 4 — How the measurement nearly lied
**7:52 – 12:59 · recording draft, breath-marked**

> `/` = breath. `//` = hold the pause.

At this point I had a harness I trusted. It checked out the same commit every time, /
gave each run its own database, / ran the test suite in a fixed order, / and compared the
failures against a baseline I had measured three times.

I had even validated it the careful way. I ran it against a worktree where no agent had
touched anything. / Nine thousand four hundred and fifty tests, / exactly the two failures
I expected, / empty diff.

The instrument was working. //

Then I ran the second model for the first time, and the suite came back with three
hundred and fifty-nine failures. / Two of those are the known pair I just described. / The
other three hundred and fifty-seven had been passing an hour earlier.

Look at where they are. / Billing. / An AI assistant module. / Cloudflare hostname checks.
/ Facebook message delivery.

The task was adding one string column to a contacts table. //

And I had a story ready. // *This model is reckless. It touches things it shouldn't. Look
at the blast radius.* / It would have been a great segment. / Two hundred and ninety-four
of those failures were the same database error, / which makes a beautiful screenshot.

It was completely false. //

The cause is at the top of a file called `db_enhancements.rake`.

Every time anyone runs `db:migrate` in this repository, / it also loads a hundred and
thirteen configuration rows into a table. / The test suite expects that table to be empty.
/ So it collapses.

And look at the first line. // There is a comment explaining exactly that. / It prints a
message to the log every single time it fires. / This was not hidden. / I lost a day to it
anyway. //

The model had run `db:migrate`. / After writing a migration. / Which is exactly what it
should have done. //

The first model I tested never ran it — it wrote the migration and moved on. / So the bug
had been sitting in my harness the whole time, / invisible, / waiting for an agent that
behaved slightly differently.

And my careful null-run validation? / Useless against this. / Nothing had happened in that
worktree. // You cannot catch a bug about what agents do / by measuring a run where no
agent did anything. //

So I fixed it. / And the fix uncovered the next one.

The same task had been quietly rewriting the schema file. / Which meant the diff I was
recording was no longer the diff the agent produced. / My measurement was editing the
thing it measured.

Fixed that too. / Then the third. / The database reset I had put in its place was failing,
/ and my script was swallowing the error with `|| true`. / So it measured against a dirty
database and produced four hundred and thirty failures, / four hundred and twenty-eight of
them new. / Again, none of them the agent's.

That one was my fault twice over. // The root cause was a decision I made. / I had given
each run its own database name — / and in this codebase, that single name is used by both
the development and the test environment. / So an agent running a perfectly ordinary
command in development / stamped the database in a way that made the test reset refuse to
run. //

And then, separately, one of the runs did something I had not thought to look for.

Its change made a class too long for the linter. / Instead of accepting the warning, / it
opened the linter's configuration file / and added its own file to the exemption list.

My harness reported zero lint violations. / The number was true. // It was also
meaningless. //

Three bugs that manufactured failures, / and one blind spot I found by accident. / There
were two more that only cost me metrics, / and they are in the commit history if you want
them.

Every one of them gave me numbers that looked clean and confident.

What caught them was not rigour. / It was running a second model. / If I had only ever
tested one, / the harness would have looked perfect, / and everything after this point in
the video would have been wrong.

Nobody requires you to run a second model. // That is the part that bothers me.

---

## Production notes for Block 4

- The emotional beat is "I had a story ready." Do not rush it.
- **The rake file is seven lines, not four, and the first is a comment describing the
  behaviour.** That comment is the strongest frame in the block: the mechanism announced
  itself, printed to the log on every run, and still cost a day. Frame the shot so line
  one is legible.
- Do not name the model that hit the bug. It did nothing wrong.
- "That one was my fault twice over" stays. The root cause was a design decision of mine.
- Count honestly: three harness bugs are shown, the linter is an agent behaviour, and two
  more exist but are not worth screen time. Do not say "five" over four things.
- "It was completely false" and "It was also meaningless" are camera, not screen.

## Block 5 — Why the cost numbers you read are fake
**12:59 – 16:45 · ~565 words · data-independent**

> SCREEN: a typical price-comparison table from a blog post.

Every comparison you read prices models per million tokens. Five dollars here, fifteen
cents there, look at the ratio.

That number cannot be compared across vendors, and I can show you why in one sentence.

> SCREEN: highlight "per million tokens".

Different vendors tokenise text differently. The same paragraph becomes a different
number of tokens depending on whose tokeniser reads it, and nobody publishes a
conversion factor between them. It moves even within one vendor: Anthropic's migration
guidance tells you to re-measure your token counts when you change model generation,
because the tokeniser changed underneath you.

So "five dollars per million tokens" and "fifteen cents per million tokens" are prices
for different quantities of the same thing. Every table built on them is comparing units
it has not converted.

> SCREEN: the DeepSeek pricing page, peak hours highlighted.

Second problem. One of these providers charges by the clock. Peak hours are twice the
off-peak rate, and peak is a specific window in UTC on weekdays.

The same task, run at ten in the morning or at two in the afternoon, costs double. Not
because anything about the work changed.

> SCREEN: harness output next to the provider console.

Third problem, and this is the one that actually caught me.

My tooling reported what each run cost. On two early runs of the cheap model it said
sixteen cents. The provider's billing page said thirty-two. Exactly double.

Those two runs happened to start inside the peak window. The tool prices everything at
the off-peak rate and knows nothing about the clock, so it was wrong by exactly the peak
multiplier. I moved the real series outside that window afterwards — which is why the
numbers later in this video are not doubled, and why I know the doubling was the clock
and not something else.

Fine, I thought. Off by a known factor. Then I checked the other provider.

> SCREEN: two numbers side by side, tokens.

On one run my tooling said two and a half million input tokens. The usage page said six
point four million. Not the price — the *tokens*.

And I can be sure that is the same run, not an accounting window artefact: this provider
reports hourly, every one of my runs started and finished inside a single hour, and no
other run shared it.

Across four runs the gap ranges from about one point two to about two and a half times.
It is not a constant factor, which rules out the simplest explanations — a units error, a
missing category.

I still do not know what it is. My best guess is retried requests, billed by the provider
and not logged by the tool. That is a guess, and I am telling you it is a guess.

> SCREEN: the Haiku row in the usage table.

And while I was in there, one more thing. That run was pinned to one specific model.
The billing shows a second, smaller model on the same runs — three and a half thousand
input tokens across the day, probably generating session titles. Small. But it means the
thing I pinned was not the only thing running.

> SCREEN: back to camera.

So here is the rule I ended up with, and it is the only honest one.

Do not measure cost. Measure tokens, and record what time it was. Then compute the cost
afterwards, from a rate card you wrote down with the date you read it.

Tokens are a fact about what happened. Price is a fact about a rate card that changes
by the hour, by the vendor, and by whether your tool bothered to check.

And the number that actually matters to you is not cost per token at all. It is cost
per finished task — which depends on how much work each model needs to do to finish.
That turns out to be where it gets interesting.

> SCREEN: cut to Block 6.

---

## Production notes for Block 5

- "I still do not know why... That is a guess, and I am telling you it is a guess."
  Keep verbatim. Admitting an open question mid-video is worth more than another
  finding.
- The Haiku detail is small and must stay small. It is a texture beat, not a scandal.
- The last two lines are the handoff to the result. Do not answer the question here,
  even if the answer is known by the time you record.
## Block 6 — What six runs actually showed
**16:45 – 21:31 · ~715 words**

> SCREEN: the Part A table, all six columns.

Six runs. Three per model. Here is the first thing, and it is not what I expected.

> SCREEN: highlight the identical rows.

On the core of the task, the two models are indistinguishable. Both wrote the same
migration. Both touched one of the four places this codebase accepts contact data — the
same one. Both updated one of three serializers — the same one. Neither went anywhere
near the public API or the widget. Both wired the same form in the interface. Both
wrote two spec files.

And the feature worked in all six. I check that independently, with a script that
creates a contact through the real API, reads it back, updates it, and confirms the
value survives. Six out of six.

If I had stopped there, I would have a boring video and a wrong one.

> SCREEN: the documentation split, one line, then move on.

You have already seen one of these: three of the six runs edited the API documentation
sources and never rebuilt them, so the served docs do not have the change. One of them
edited four files and regenerated nothing.

Here is what I did not show you earlier.

> SCREEN: the rubocop.yml diff.

Adding this field pushes the Contact class to a hundred and seventy-seven lines. The
linter's limit is a hundred and seventy-five.

Three runs — all three of one model — opened the linter configuration and added their
own file to the exemption list.

> SCREEN: harness output, "rubocop: 0 offenses".

And my harness reported zero lint violations. Which was true.

I only caught this because I had added a check for it the day before, after seeing it
once in a pilot. Five of these six runs reported zero lint offences. Three of those
five had silenced the check. Without the marker I added the day before, those five
results are indistinguishable — and I would have had no way to tell a run that
satisfied the linter from one that switched it off.

> SCREEN: the failing spec.

Third. One run wrote tests requiring that an invalid language code is rejected. Then it
did not implement that validation, and shipped with its own tests failing.

It did not break the codebase. It broke its own promise — which is worse in one narrow
way. The next person reads the spec, sees the behaviour described, and believes it.

> SCREEN: the ComboBox, then the three import lines side by side.

One more thing, and it is about me rather than the models.

When I first read these diffs, I saw that one run had built the language field as a
searchable dropdown, wired to a list this project already ships. I checked the other
five for the same import, did not find it, and concluded they had shipped a plain text
box. I wrote that down as a finding.

It was wrong. All six built the same dropdown. They just sourced the list from three
different places — and three of them used the installation's own enabled languages,
which is arguably the better choice.

I found this out because I opened the running application and looked.

That is the third time in this project that a conclusion from a single sample turned
out to be false. The first two were mine about the models. This one was mine about my
own data, in a benchmark built specifically to stop that from happening.

> SCREEN: the two split tables.

Now, the difference between the models. There is one, and it is clean: three out of
three runs of one model added validation for the language code. Zero out of three of
the other did.

One of them found a gem already in this project's dependencies. Another found
Chatwoot's own language configuration — the exact list the product uses for interface
locales. Both added the error message to the right translation file.

That looks decisive. It is not.

> SCREEN: the number 0.10.

Three runs per model. A perfect split at that sample size gives a two-sided Fisher's
exact probability of about ten percent. That is a signal worth telling you about. It is not a result I
can assert.

And there is a second problem with calling it a win. The task never asked for
validation. This repository's own contributor guide tells you to prefer the smallest
change that solves the problem and to avoid speculative guards.

So one model did more than it was asked, carefully and idiomatically. Whether that is
diligence or scope creep is a judgement, and I am telling you it is a judgement rather
than scoring it as a point.

> SCREEN: cut to Block 7.

---

## Block 7 — What it costs, and what this does not prove
**21:31 – 25:42 · ~627 words**

> SCREEN: two numbers, billing pages behind them.

Cost per finished task, taken from the providers' billing, not from my tooling.

Eleven dollars and one cent. Six point seven cents. About a hundred and sixty-four times.

> SCREEN: the two balance deltas.

One note on where those come from, because it matters. Both consoles report by the day,
and my day contained pilot runs as well as the measured ones. So these are balance
differences bracketing the six runs, not console daily totals — and they reconcile: five
sixty-eight for the pilots plus thirty-three oh four for the series is thirty-eight
seventy-two, which is exactly what the console billed me for the day.

Compare the daily totals instead and you get seventy-three to one, because that day held
one pilot on the expensive side and two on the cheap one. Different amounts of work. The
number I trust is the one where both sides ran the same three tasks.

> SCREEN: the per-token price table.

The headline prices say thirty-three to one on input. The billing says a hundred and
sixty-four. The table on every comparison page does not describe what I paid.

> SCREEN: the provider's caching page.

Here is why, and this time I can show you rather than argue it. This provider publishes
a breakdown of what your input actually was.

Read ratio: a hundred percent. Write amortisation: thirty-six times — meaning every
token written into the cache was read back out of it thirty-six times on average.

> SCREEN: the composition bar.

Work that through and the input splits like this. Ninety-seven percent cache reads. Under
three percent written to cache. Uncached, fresh text: effectively zero.

That is not a figure of speech. In an agent run there is almost no new text at all. It is
the same repository, read again and again.

> SCREEN: the two cache rates side by side.

And cached input is where the two providers differ most. Fifty cents per million on the
expensive one. Three tenths of a cent on the cheap one.

Put those side by side and you are looking at more than two orders of magnitude, against
a headline ratio of thirty-three. I am not going to give you a precise figure for that
one, because the cheap provider publishes its cache rate to three decimal places and the
ratio moves depending on how the fourth would round.

Every run in this series was off-peak, so that is a single number and not a range — on
the cheap provider the peak rate is double, and a series straddling that boundary would
not have one ratio at all.

> SCREEN: the write line highlighted, small.

One detail worth its own second. Writing to the cache costs twenty-five percent more than
fresh text — the premium for reading it back cheaply later. Under three percent of my
input volume was writes. It was twenty-six percent of my input bill.

A sliver on the graph you cannot see, and a quarter of the money.

> SCREEN: back to camera.

What I could not do is the same breakdown on the other side. The cheap provider's console
gives totals and a cost chart; it does not publish a cache composition. So I can show you
precisely where the expensive money went, and only infer the shape of the cheap one.

Which is its own small lesson: the two providers do not give you the same instruments, so
"measure it yourself" is easier advice to give than to follow.

> SCREEN: the two harness rows.

One more caveat, and it is the one I would lead with if I were arguing against this
video.

Eleven dollars is what the expensive model costs *through the tool I used*. Not what it
costs.

I have the same model, on the same repository, measured through a different tool earlier
in this project. Thirty-odd steps instead of up to a hundred and seventeen. Under three
minutes instead of up to twenty-five. A fraction of the context re-read.

That comparison is not clean — the earlier runs were on a slightly smaller version of
the task — but the task grew by about ten lines and the context grew several times over.
That is not the task.

The ratio between the two models holds: both arms ran under the same tool. The absolute
number does not travel. Quote eleven dollars anywhere without saying which tool produced
it and you have made exactly the kind of claim this video spent twenty minutes arguing
against.

> SCREEN: the limits, plainly listed.

What else this does not prove.

One task, in one codebase. Three runs per model, not five — I ran out of budget, and
that is in the commit history with the reason. I could not pin reasoning effort,
because the tooling does not expose it. And the billing shows a small model being
called that I never asked for.

> SCREEN: back to camera.

The useful thing I can tell you is not which model to buy.

It is that on a well-specified task in a mature codebase, both models produced
essentially the same code — and left holes of the same kind. Generated artifacts not
rebuilt, by runs of both models. A linter switched off instead of satisfied, by three
runs of one. A test asserting behaviour that was never written, by a single run of the
other.

None of that is caught by running the test suite. All of it is caught by a human
reading the diff.

That is the part that did not get cheaper.

> SCREEN: repo link, end.
