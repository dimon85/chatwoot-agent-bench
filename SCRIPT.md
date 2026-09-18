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
**0:00 – 0:45 · ~120 words**

> SCREEN: two numbers, nothing else.

Eleven dollars and one cent. Six point seven cents.

Same task. Same repository, same commit, same prompt. One of these models costs a
hundred and sixty-five times more than the other to finish the same piece of work.

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
**0:45 – 3:00 · ~350 words · rewritten after the results**

> SCREEN: a typical "I tested two models" post.

There is a genre that goes like this. Take two models, give each one a task, look at the
output, tell people which is better.

I want to show you why one run cannot answer that question — and it is not the reason
you would guess.

> SCREEN: six diff summaries in a row, file counts visible.

I ran the same task six times. Three per model. And the code came out remarkably
consistent. Same migration. Same entry point out of the four this codebase has. Same
serializer out of three. Same component in the interface. Every run produced a working
feature.

If you ran this once, you would conclude the models are interchangeable. That is roughly
true of the code.

> SCREEN: the defect table — three columns, six rows.

It is not true of the defects.

Three of those six runs edited the API documentation and never rebuilt it, so the docs
that actually get served do not have the change. Three of six ran into a linter limit
and switched the linter off for their own file. One shipped tests that assert a
validation it never wrote — failing, in its own commit.

Every one of those runs passed the test suite. Five of the six reported zero lint
problems.

> SCREEN: highlight a single row.

Now pick one run at random and write a post about it. Depending on which one you picked,
you would have concluded that this model documents properly, or that it does not. That
it respects the linter, or that it disables it. That it ships working tests, or broken
ones.

Same model. Same prompt. Same commit.

> SCREEN: the benchmark repo, commit history.

That is why this took a week. A rubric committed before the first run so I could not
move the goalposts. Every run published — prompts, diffs, logs, failures.

And most of that week did not go into measuring the models. It went into discovering
that my measurement was lying to me. Five separate times.

> SCREEN: brief flash of the fix commits, unreadable, texture only.

One of those bugs nearly made me publish a confident, well-evidenced, completely false
claim. That is the most useful thing in this video.

> SCREEN: cut to Block 3.

---

## Production notes for Block 2

- The turn is "It is not true of the defects." Everything before it sets up the
  expectation that the models are interchangeable; everything after shows the variance
  is real but lives somewhere nobody photographs.
- The defect table is the block. Build it as one graphic, six rows, three columns —
  docs regenerated, linter silenced, tests passing — and let the pattern of ticks and
  crosses do the argument.
- Do not use the earlier six-files-versus-fifteen contrast. It came from pilot runs on
  an earlier version of the task and it contradicts both the title and block 6.
- Do not say "which model won" here or anywhere.
- Do not claim the ranking would flip on a rerun. It did not: the two clean splits in
  the data held 3–0 across every run.

## Block 3 — The setup
**3:00 – 6:00 · ~480 words · data-independent**

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
**6:00 – 11:00 · ~760 words · data-independent**

> SCREEN: terminal, the harness finishing a run, everything green.

At this point I had a harness I trusted. It checked out the same commit every time,
gave each run its own database, ran the test suite in a fixed order, and compared the
failures against a baseline I had measured three times.

I had even validated it the careful way: I ran it against a worktree where no agent had
touched anything. Nine thousand four hundred and fifty tests, exactly the two failures
I expected, empty diff. The instrument was working.

> SCREEN: the 359-failure output scrolling.

Then I ran the second model for the first time, and the suite came back with three
hundred and fifty-nine failures. Two of those are the known pair I just described. The
other three hundred and fifty-seven had been passing an hour earlier.

> SCREEN: hold on the failure list — billing, Captain, Cloudflare, Facebook.

Look at where they are. Billing. An AI assistant module. Cloudflare hostname checks.
Facebook message delivery. The task was adding one string column to a contacts table.

And here is the thing I want you to sit with for a second: I had a story ready. *This
model is reckless. It touches things it shouldn't. Look at the blast radius.* It would
have been a great segment. Two hundred and ninety-four of those failures were the same
database error, which makes a beautiful screenshot.

It was completely false.

> SCREEN: the rake file, four lines.

Here is the actual cause. Four lines in a file called `db_enhancements.rake`:

    Rake::Task['db:migrate'].enhance do
      ConfigLoader.new.process
    end

Every time anyone runs `db:migrate` in this repository, it also loads a hundred and
thirteen configuration rows into a table. The test suite expects that table to be
empty. So it collapses.

The model had run `db:migrate`. After writing a migration. Which is the correct thing
to do.

> SCREEN: side by side, two runs.

The first model I tested never ran it — it wrote the migration and moved on. So the
bug had been sitting in my harness the entire time, invisible, waiting for an agent
that behaved slightly differently.

And my careful null-run validation? Useless against this. Nothing had happened in that
worktree. You cannot catch a bug about what agents do by measuring a run where no agent
did anything.

> SCREEN: commit log, the fixes going by.

I fixed it. Then the fix revealed the next one: the same task had been quietly
rewriting the schema file, which meant the diff I was recording was no longer the diff
the agent produced. My measurement was editing the thing it measured.

Fixed that. Which revealed the third: the database reset I had replaced it with was
failing, and my script was swallowing the error with `|| true`. So it measured against
a dirty database and produced four hundred and thirty failures, four hundred and
twenty-eight of them new — again, none of them the agent's.

That one was my fault twice over. The root cause was a decision I made: I had given
each run its own database name, and in this codebase that single name is used by both
the development and the test environment. So an agent running a perfectly ordinary
command in development stamped the database in a way that made the test reset refuse
to run.

> SCREEN: the rubocop diff.

And then, separately, one of the runs did something I had not thought to look for. Its
change made a class too long for the linter. Instead of accepting the warning, it
opened the linter's configuration file and added its own file to the exemption list.

My harness reported zero lint violations. The number was true. It was also meaningless.

> SCREEN: back to camera.

So: five separate ways the measurement was wrong, and every single one of them
produced clean, confident, screenshot-ready numbers.

What caught them was not rigour. It was running a second model. If I had only ever
tested one, the harness would have looked perfect, and everything after this point in
the video would have been wrong.

Nobody requires you to run a second model. That is the part that bothers me.

---

## Production notes for Block 4

- The emotional beat is "I had a story ready." Do not rush it. The admission that a
  false conclusion was *attractive* is what makes the rest credible.
- Show the rake file in full. Four lines, no scrolling. The gap between the cause and
  the 359 failures is the whole point.
- Do not name the model that hit the bug. It did nothing wrong; naming it invites the
  comment section to blame it anyway.
- "That one was my fault twice over" — keep it. Distributing blame to the tooling when
  the root cause was a design decision would be the exact dishonesty this video is
  about.
- Final line lands better dry than indignant.
## Block 5 — Why the cost numbers you read are fake
**11:00 – 14:00 · ~470 words · data-independent**

> SCREEN: a typical price-comparison table from a blog post.

Every comparison you read prices models per million tokens. Five dollars here, fifteen
cents there, look at the ratio.

That number cannot be compared across vendors, and I can show you why in one sentence.

> SCREEN: highlight "per million tokens".

Different vendors tokenise text differently. The same paragraph becomes a different
number of tokens depending on whose tokeniser reads it, and nobody publishes a
conversion factor — Anthropic's own migration notes warn that even their own tokenisers
shifted enough between model generations to require re-measuring.

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

My tooling reported what each run cost. For the cheap model it said sixteen cents. The
provider's own billing page said thirty-two. Exactly double — because the tool prices
everything at the base rate and knows nothing about peak windows.

Fine, I thought. Off by a known factor. Then I checked the other provider.

> SCREEN: two numbers side by side, tokens.

My tooling said two and a half million tokens in. The billing console said six point
three million. Not the price — the *tokens*. Two and a half times more consumed than
my tool recorded.

I still do not know why. My best guess is retried requests, which the provider bills
and the tool does not log. That is a guess, and I am telling you it is a guess.

> SCREEN: the Haiku row in the usage table.

And while I was in there, one more thing. That run was pinned to one specific model.
The billing shows a second, smaller model on the same run — a couple of thousand
tokens, probably generating a session title. Small. But it means the thing I pinned was
not the only thing running.

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
**14:00 – 18:00 · ~620 words**

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

> SCREEN: the swagger file list.

Here is the first thing that is actually wrong. This API's documentation is generated.
You edit source files, then run a build task that produces the files that are actually
served.

Three of the six runs edited the sources and did not finish the build. One of them
edited four documentation files and regenerated nothing at all.

So the change is in the source. The documentation that your users read does not have
it. Every test passes. Every linter passes. The diff looks complete.

> SCREEN: the rubocop.yml diff.

Second. Adding this field pushes the Contact class to a hundred and seventy-seven
lines. The linter's limit is a hundred and seventy-five.

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
**18:00 – 20:00 · ~330 words**

> SCREEN: two numbers, billing pages behind them.

Cost per finished task, taken from the providers' billing, not from my tooling.

Eleven dollars and one cent. Six point seven cents.

A hundred and sixty-five times.

> SCREEN: the per-token price table.

The headline prices say thirty-three to one on input. The billing says a hundred and
sixty-five. So the table on every comparison page does not explain what I paid.

> SCREEN: the bill broken down by token type.

It is not volume. Both arms read a comparable amount of context — the cheap one, if
anything, slightly more.

Almost three quarters of the expensive bill is a line item that appears on no
comparison page: **cache reads**. Context the model had already seen, billed at a
discount. Both providers discount it. They discount it very differently — fifty cents
per million against three tenths of a cent. That is a hundred and sixty-seven to one,
against a headline ratio of thirty-three.

> SCREEN: hold on the two ratios.

And this is where I have to stop short of the neat version.

I would like to tell you that a hundred and sixty-seven explains a hundred and
sixty-five. It is the right order of magnitude and it is the right mechanism. But to
prove it I would have to decompose the bill precisely — and one of my two token
counters is wrong. My tooling under-reports consumption on the expensive provider by
somewhere around a factor of two, which I showed you three minutes ago and still cannot
explain.

So I can tell you the direction and not the arithmetic. The headline price ratio is not
what you paid. The cache read rate is what moved the number. Exactly how much of it is
the rate and how much is volume, I cannot separate with instruments I have already told
you are unreliable.

> SCREEN: back to camera.

Which is, I think, the honest version of this whole video. I have a measured ratio I
trust, because it came from two billing pages. I have an explanation I believe, because
the mechanism and the magnitude both fit. And I do not have the proof, because proving
it needs a number my tools get wrong.

Saying it fits and calling that proof would have been the easiest paragraph in this
script to write.

> SCREEN: the limits, plainly listed.

What else this does not prove.

One task, in one codebase. Three runs per model, not five — I ran out of budget, and
that is in the commit history with the reason. I could not pin reasoning effort,
because the tooling does not expose it. And the billing shows a small model being
called that I never asked for.

> SCREEN: back to camera.

The useful thing I can tell you is not which model to buy.

It is that on a well-specified task in a mature codebase, both models produced
essentially the same code — and both left the same kind of hole: generated artifacts
not regenerated, a check switched off instead of satisfied, a test asserting something
that was never built.

None of that is caught by running the test suite. All of it is caught by a human
reading the diff.

That is the part that did not get cheaper.

> SCREEN: repo link, end.
