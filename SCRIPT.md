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
## Block 4 — How the measurement nearly lied (to write, data-independent)
## Block 5 — Why the cost numbers you read are fake (to write, data-independent)
## Block 6 — MEASURED result
## Block 7 — MEASURED what it means
