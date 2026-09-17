# Script — video 1

Written before the measured series finished, so the narrative spine is on record with
a date and cannot have been fitted to the result. Blocks marked MEASURED are left
unwritten until the ten runs are classified.

Target: ~20 minutes, English. Register: understate everything. The currency here is
trust, and trust is built by claiming less than you can prove.

---

## Block 2 — Why every answer you have seen is measuring noise
**0:45 – 3:00 · ~340 words · data-independent**

> SCREEN: two file trees side by side, same prompt visible above both.

There is a genre of video and blog post that goes like this. Someone takes two models,
gives each of them a task, looks at the output, and tells you which one is better.

I want to show you why that number is worthless. Not biased. Not incomplete. Worthless.

> SCREEN: the two diffs, file counts highlighted.

Here are two runs. Same model. Same prompt, character for character. Same repository,
same commit. Same settings, pinned explicitly.

One of them changed six files. The other changed fifteen.

Not a different model. The same one, twice.

> SCREEN: hold on the two numbers.

So when you see a post saying model A scored eighty-five and model B scored
eighty-two — three points apart, one run each — you are not looking at a difference
between two models. You are looking at one sample from each of two distributions you
have not measured, and being told the sample is the distribution.

Run it again and the ranking can flip. Nobody runs it again, because running it again
is boring and the first number already looks like an answer.

> SCREEN: the benchmark repo, commit history visible.

That is the whole reason this took me a week instead of an afternoon. Five runs per
model, not one. A rubric written down and committed before the first run, so I could
not quietly move the goalposts once I saw the results. Every run published — the
prompt, the diffs, the logs, the failures.

And the part I did not expect: most of that week was not spent measuring the models.
It was spent discovering that my measurement was lying to me. Five separate times.

> SCREEN: brief flash of the five bug commit titles, unreadable, just texture.

One of those bugs nearly made me publish a confident, well-evidenced, completely false
claim about one of these models. I will show you exactly how close that got, because
it is the most useful thing in this video — more useful than which model won.

> SCREEN: cut to Block 3.

---

## Production notes for Block 2

- The six-versus-fifteen contrast carries the block. Get both diffs on screen at once;
  do not narrate the file list, let the counts do it.
- Do not name the post being criticised. The genre is the target, not a person.
- "Five separate times" is the hook into Block 4. Do not explain the bugs here.
- Source for the six-vs-fifteen figure: to be taken from the measured series if the
  spread appears there, from the published pilots otherwise — labelled as pilots on
  screen either way.

---

## Block 3 — MEASURED SETUP (to write)
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

Then I ran the second model for the first time, and it broke three hundred and
fifty-nine tests.

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
a dirty database and produced four hundred and thirty failures — again, none of them
the agent's.

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
## Block 5 — Why the cost numbers you read are fake (to write, data-independent)
## Block 6 — MEASURED result
## Block 7 — MEASURED what it means
