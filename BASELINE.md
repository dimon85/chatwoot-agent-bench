# Baseline — Chatwoot agent benchmark

## Base commit

    repo:     https://github.com/chatwoot/chatwoot (fork: dimon85/chatwoot)
    branch:   develop
    SHA:      bacb65d4f683ef40abb21796efe54c38d01a6d90
    date:     2026-09-10
    subject:  fix(whatsapp): show backend errors when calls fail (#15766)

Push a tag to the fork so this SHA survives force-pushes:

    git tag bench-base bacb65d4f && git push origin bench-base

## Environment

    macOS arm64 (Darwin 25.6.0)
    Ruby      3.4.4      (rbenv, built from source)
    Node      24.13.0    (nvm)
    pnpm      10.2.0     (corepack)
    Postgres  14.20      (homebrew, brew services)
    Redis     8.10.1     (homebrew, brew services)
    Rails     7.2.3.1

### Two deviations from a stock setup — both required

1. **pgvector built from source.** `db/schema.rb:19` declares `enable_extension "vector"`,
   so the extension is mandatory. Homebrew ships pgvector bottles only for postgresql@17/@18,
   not @14. Built v0.8.0 against pg14:

       git clone --branch v0.8.0 --depth 1 https://github.com/pgvector/pgvector.git
       cd pgvector
       PG_CONFIG=/opt/homebrew/opt/postgresql@14/bin/pg_config make && make install

   Verify: `psql -d postgres -c "CREATE EXTENSION vector;"` → 0.8.0

2. **`FRONTEND_URL` removed from `.env`.** `.env.example` sets `http://0.0.0.0:3000`,
   but CI deletes the line (`.circleci/config.yml:277`) and the suite expects the
   `localhost:3000` default. Leaving it in causes 5 false failures (see below).

### .env derivation (must be reproduced by the harness)

    cp .env.example .env
    sed -i '' '/^FRONTEND_URL/d' .env
    sed -i '' 's|^POSTGRES_HOST=postgres$|POSTGRES_HOST=localhost|' .env
    sed -i '' 's|^REDIS_URL=redis://redis:6379$|REDIS_URL=redis://localhost:6379|' .env
    sed -i '' "s|^SECRET_KEY_BASE=replace_with_lengthy_secure_hex$|SECRET_KEY_BASE=$(openssl rand -hex 64)|" .env

Also: `CREATE ROLE postgres LOGIN SUPERUSER CREATEDB;` (homebrew pg has no `postgres` role).

## Run order — fixed, and it matters

CI never runs the suite serially: it shards 904 spec files round-robin across nodes,
with a comment stating this "prevents tests with similar timing from being grouped on
the same runner" (`.circleci/config.yml:300`) — i.e. upstream is aware of isolation
problems. The baseline therefore pins one order:

    SPECS=($(find spec -name '*_spec.rb' | sort))
    bundle exec rspec -I ./spec --require spec_helper --format progress \
      --format json --out runN.json -- $SPECS

Any run compared against this baseline MUST use the same ordering. A red result under a
different order is not comparable.

## Known failures under this exact order

Two, in every clean run. Neither is a code defect introduced by an agent.

| Spec | Cause | Class |
|---|---|---|
| `spec/enterprise/services/voice/call_transcription_service_spec.rb:77` | Needs OpenSearch. `Message#reindex` exists only when `ChatwootApp.advanced_search_allowed?` (`app/models/message.rb:42`), which keys off `OPENSEARCH_URL`. CI runs OpenSearch 2.11.0; this baseline does not. | environmental |
| `spec/builders/agent_builder_spec.rb:47` | **Order-dependent.** Passes in isolation (12 examples, 0 failures). In the full suite `have_enqueued_mail(Devise::Mailer, :confirmation_instructions)` fails with "Wrong number of arguments. Expected 2 to 3, got 0" — a leftover enqueued job from an earlier spec. | suite pollution |

Decision: both are excluded from the pass/fail criterion and listed in `excluded_specs.txt`.
Deliberately NOT fixed — patching the repo would move the base SHA away from upstream.

## Numbers

### JS (vitest) — `pnpm test`

| | |
|---|---|
| Test files | 442 passed / 442 |
| Tests | 4582 passed / 4582 |
| Failures | 0 |
| Duration | 23.8s |

Clean. No flakes, no exclusions.

### Ruby (rspec) — 904 files, serial

| Run | Examples | Failures | Pending | Duration | Note |
|---|---|---|---|---|---|
| 1 | 9450 | 7 | 65 | 672.1s | contaminated: `FRONTEND_URL` still present |
| 2 | 9450 | 2 | 65 | 690.9s | clean |
| 3 | 9450 | 2 | 65 | 678.2s | clean |

**Noise boundary: zero.** Runs 2 and 3 produced *identical* failure sets and identical
pending sets (symmetric difference 0 on both). Wall-clock varied by 12.7s (1.8%). Under a
pinned spec order this suite is fully deterministic, so any deviation from the known set of
2 failures in an agent run is signal, not noise.

Run 1's extra 5 failures (`slack_uploads_controller_spec.rb:17,23,31,37` and
`account_saml_settings_spec.rb:60`) were all `FRONTEND_URL` artifacts and disappeared
once `.env` matched CI. It is kept in the record as evidence of why the harness must
derive `.env` correctly rather than `cp .env.example .env`.

## Harness requirements implied by this baseline

- Each worktree needs its own `.env` derived as above — not a raw copy of `.env.example`.
- Each worktree needs its own Postgres database (`POSTGRES_DATABASE`) and Redis DB index,
  or concurrent runs will corrupt each other's state.
- Pin the spec order. Record the rspec JSON per run; the failure *set*, not just the count,
  is what gets compared.
- Expected clean result: 9450 examples, 2 known failures, 65 pending. Anything else is signal.
