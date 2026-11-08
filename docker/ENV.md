# TSecBench Hosted-Mode Configuration Checklist (Throne Protocol online qualifier)

Key rules of the official event (2026-10-17 00:00 — 10-18 23:59):

- **Only 1 evaluation attempt**, submittable from the team-captain account only; no retry on Agent failures
- 50 challenges / 100 flags, task time limit **8 hours** (the image runs 470 minutes by default to keep a safety margin)
- No hints (the API returns null, and there is no penalty)
- Ranking order: **score → effective time → token count** (so verify double-checking is off by default, to save tokens)
- Model rate-limits/timeouts/interruptions do not count as platform failures — the image ships with **model-call retry** (SAPPER_RETRY_MODEL=3, exponential backoff); a single-challenge failure auto-skips and is retried on the next round, never interrupting the whole task
- Never steer the Agent into attacking the platform — the prompts already carry scope discipline; do not add any "attack the platform" steering to the templates

## 1. Auto-injected by the platform (do not fill these in the console by hand)

| Variable | Description |
|---|---|
| `BENCHMARK_BASE_URL` | Base URL of the answer-submission API, auto-injected after the task is created |
| `BENCHMARK_TOKEN` | Answer-submission API credential, auto-injected |

## 2. Runtime environment variables (fill in the console by hand)

| KEY | VALUE | Description |
|---|---|---|
| `ANTHROPIC_BASE_URL` | `https://open.bigmodel.cn/api/anthropic` | Direct public vendor endpoint |
| `ANTHROPIC_AUTH_TOKEN` | Your Zhipu API key | To switch providers, change only this and BASE_URL |
| `SAPPER_MODEL` | `glm-5.3-flash[1m]` | Verified working. The `[1m]` suffix is parsed by the claude CLI as a 1M context window (it strips the suffix and adds a beta header); on the API side the model name is still glm-5.3-flash, so filling `glm-5.3-flash-1m` directly reports a non-existent model |

### Key-pool auto-rotation (strongly recommended)

When a key runs out of quota / hits 401 / is out of balance, the system automatically switches to the next set of credentials in the pool. The `-p` build needs **no restart** (the next model call uses the new key); the tmux build rotates automatically and restarts the corresponding TUI (`claude --continue` restores the original session context). Detection signals: insufficient/balance/quota/exceeded/billing/401/unauthorized/欠费/余额.

| KEY | VALUE format |
|---|---|
| `SAPPER_KEY_POOL` | `[{"base_url":"https://open.bigmodel.cn/api/anthropic","token":"zhipu-key1","model":"glm-5.3-flash[1m]"},{"base_url":"https://api.moonshot.cn/v1","token":"moonshot-key","model":"kimi-k2.5"}]` |

Note: each entry's URL points directly at the respective vendor's public endpoint. With a single key, rotation degrades gracefully into an ordinary retry.

Optional tuning (omit to use image defaults):

| KEY | Default | Description |
|---|---|---|
| `SAPPER_TOTAL_MINUTES` | `470` | Total budget (margin left under the 8h limit) |
| `SAPPER_MINUTES_PER_CHALLENGE` | `9` | Auto minutes per challenge per round; the bench loops over multiple rounds, and challenges not yet solved continue next round (progress is kept in the graph). 50 challenges × 9 min ≈ 450 min |
| `SAPPER_MAX_STEPS` | `10` | Max reason rounds per challenge per round |
| `SAPPER_RETRY_MODEL` | `3` | Number of model-call retries on failure (10s/20s/40s backoff) |
| `SAPPER_VERIFY` | unset | Set to `1` to enable the verifier (costs tokens; off by default for the official event) |

## 3. Container startup flow

1. Validate the `BENCHMARK_*` and model-gateway environment variables; a missing one is FATAL immediately (visible in the log)
2. Platform API connectivity probe + model CLI smoke test
3. `sapper bench --minutes 470`: loop over each unfinished challenge
   `start → build graph (challenge description / target address recorded as untrusted data) → auto self-solve
   → submit any recorded-but-unsubmitted flags (both correct and wrong are written back) → close`
   If one round does not finish every challenge, run another round, until all are done or the 470 minutes are used up
4. Runs as a non-privileged user (Claude Code refuses to skip the permission prompt under root); all keys go through environment variables, and the image contains no keys or challenge memory

## 4. One-shot checklist (self-check before submitting)

- [ ] Ran a full hosted evaluation against **another challenge set** (e.g. the public Tsecbench v1 set), and `correct_flag_count` increased
- [ ] `sapper --version` and `sapper bench --help` work inside the image
- [ ] The three `ANTHROPIC_*` variables hold a public vendor endpoint address + the correct key
- [ ] Submitted from the team-captain account; only this once during the event
