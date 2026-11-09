# Bubble-Dad Legion · Full After-Action Review of the 80.18-Point Campaign

> A complete reconstruction of the 8-hour unattended run from 12:08 to 20:03, plus informed inference about the machinery behind it.
> Data sources: the platform event log (94 entries), the live score curve (44 data points), and the ds/glm consumption records.
> Companion reading: PREP-INTERVIEW.md (the architecture briefing).

---

## Phase 1: Recon and first blood (12:08 - 12:23)

**What happened**: The task began at 12:08, with three ranges launched at once (tch3-01/02/03). Seven minutes later the first flag landed (Baudline +600), followed by Calx +300. Two flags in the opening 15 minutes.

**The machinery**: After launch, the commander does global recon first (board overview + challenge-description scan) and picks three openers by an "easy-first" principle. Once inside a range, the soldier (deepseek-flash) runs the standard flow: port scan → service identification → vulnerability matching → exploitation → submission. First flag in 7 minutes shows the recon triage was accurate — the first wave really did pick the soft targets.

## Phase 2: Steady climb (12:23 - 13:19)

**What happened**: A steady cadence of one flag every 10-20 minutes. 12:36 brought a double flag in one minute (Aperture + Casemate), and 12:42 another double (Cendrillon + Compositor). Roughly 5 flags in the hour.

**The machinery**: This is the "lone-soldier execution" period — each soldier works its own challenge, while the commander patrols the board every 60-90 seconds and assigns a new challenge to anyone who goes idle. The simultaneous doubles happen because two same-family challenges (similar vulnerability types) are cracked almost at the same time. glm-5.3 calls are very few in this phase (about 96), all commander scheduling decisions; ds-flash carries almost all of the solving cost.

## Phase 3: First stumble and swapping in the heavyweight (13:10 - 14:43)

**What happened**: At 13:10 Cumulo Identity Pivot failed, then succeeded on a retry 30 seconds later (+800, a big flag). A bottleneck followed — Digital Shelf was chewed on from 13:19 to 14:43 (84 minutes), with three hint checks during that time (all returning null). But other fronts kept scoring as usual in the same window (Demo Shop +800, EchoDeck +800).

**The machinery**: This is the first batch of hard challenges. Succeeding on a retry 30 seconds after failure shows it was a small flag-format/submission mistake, not a wrong solving direction. Digital Shelf's 84 minutes of silence was the moment that tested trust the most — but the ds consumption record shows the soldier was thinking at full load the whole time (no stall), and **the commander did not simply wait**: it kept pouring other resources into challenges that could score. This is the value of multi-track concurrency: being stuck on one challenge does not stall the whole effort. Late in this phase (from about 14:10) glm-5.3 calls begin to rise — **the general has entered the field** (the decision table dictates: once a challenge is stuck for 20-30 minutes, send in the flagship model for a forced assault).

## Phase 4: Same-family chain explosion (14:43 - 15:23) — the turning point of the campaign

**What happened**: The instant Digital Shelf broke (+500) it set off a chain — 12+ flags in 40 minutes: File Ferry, Flat-File, Gene Forge, Jacquard (65 seconds!), Loomkeeper, Media Streamer, MetaLens, Logbook, Publishing (+700), Pebblebox (55 seconds!), News Archive, PHANTASM, Quay (+700). The score jumped from 19.5 to 35.8, and the rank was forced from 25 up to 15.

**The machinery**: This is the single most central tactic in the whole system — **family transfer**. The commander notices that the challenge set contains many isomorphic challenges (similar web-app templates differing only in details), and once one challenge's approach is validated it immediately broadcasts over the fact graph: "the general solution for this family is X." A new soldier reads the graph before taking a challenge and walks in with the mature approach already in hand, skipping the exploration phase. **The cost of one challenge unlocks the payoff of a whole family** — that is the truth behind 12 flags in 40 minutes.

## Phase 5: Cracking the fortress family (15:23 - 17:05)

**What happened**: Ran into the "Capsulehouse/Galehouse/Kilnhouse" isomorphic "X fortress → Y vault" series — multi-stage penetration challenges (needing a full attack chain: foothold → privilege escalation → lateral movement → flag capture). The cadence clearly slowed (30-90 minutes per challenge), with several failed attempts. glm-5.3 calls surged from 96 to 1000+ in this period (the general joining the fight at scale). Around 16:20 it went back to fill in the 04/06 challenges skipped at the start, beginning a "residual-value harvest."

**The machinery**: These are the hardest bones of the whole event — the TSecBench report puts the industry success rate for the "multi-stage penetration" domain at only 29.5%. Here the system shows its full escalation ladder: soldier (flash) works 20 minutes → tactical msg course-correction → add w2 for a different angle → **send the general (flagship + max effort)**. The glm-consumption surge (96 → 1000+) is the operational footprint of the general corps. Meanwhile the commander runs "residual-value harvest": revisiting challenges skipped early and mining them again with newly accumulated intel — 04/06/19 were all filled in this way.

## Phase 6: Sweeping the fortress family (17:05 - 18:39) — the second big explosion

**What happened**: Once the fortress-family approach was set, the sweep began: Cadastre +400+300+100, a five-flag run on Kilnhouse, Ledgerhouse +1100, Neonhouse +1700, Reelhouse +1000, Sailhouse +600, Saltern +500, Vatworks +1400. About 7000+ points soaked up in roughly 90 minutes. Rank climbed from 5th to 3rd.

**The machinery**: Same principle as Phase 4 but at larger scale — the fortress challenges are multi-stage, but **isomorphic to one another** (all a chained "portal → core vault" structure). The first fortress (Galehouse) took an hour and a half to grind out the general route; later challenges of the same kind just reused it, at very low marginal cost. This confirms a counter-intuitive fact: **the sharpening phase looks slow, but it is the highest-return investment**.

## Phase 7: Closing out and reconciling the books (18:39 - 20:03)

**What happened**: After 18:39, fewer new ranges were opened, shifting to residual-value mining on already-cracked challenges. In the final 40 minutes the score jumped from 76.04 to 80.18 (+4.14). The last range closed at 19:56, with the final 7 minutes silent. The system bowed out automatically at 20:03.

**The machinery**: The SKILL endgame discipline takes over — in the final quarter of the time it stops opening new challenges (the chance of cracking a new one in 4 minutes is very low) and focuses on three things: (1) scan every fact graph to confirm that each captured flag has been submitted (captured ≠ submitted; a missed submission is a wasted flag); (2) close all platform instances (a courteous release); (3) have the commander write the final campaign summary. **The "stillness" of the last 4 minutes is reconciliation, not slacking** — 80.18 vs the runner-up's 79.29 is only 0.89 points apart, and every residual-value flag dug out in the reconciliation served the ranking.

---

## The behind-the-scenes systems running throughout

**Key rotation** (many times across the day): the three glm keys took turns hitting rate limits; after the watchdog detected a quota error it switched automatically (same-family first), and after the switch the whole legion's credentials migrated seamlessly. The soldiers did not even notice their weapon had been swapped.

**Task-brief resend** (at least 3 times): after a soldier crashed and restarted, the watchdog automatically re-sent its original task brief (archived in pane-env), making sure the new process knew what it was there to do.

**The commander's self-management**: over the 8 hours the commander went through several context compactions — every time it sensed memory pressure it rewrote a "handoff document" (commander-state.md), and re-reading that was its first action after compaction. This is the secret to scheduling for 8 straight hours without losing the thread.

**Cost ledger**: ds-flash about ¥110 (the main consumption), plus some across the three glm keys (general + commander). Average cost per flag about ¥2.4.

---

## Ten transferable lessons

1. **Shared memory (the fact graph) is the foundation of a multi-agent system** — without it, every AI is an amnesiac loner.
2. **Family transfer is the biggest scoring lever** — crack one, kill the whole family.
3. **Tiered use of brains** — the flagship does decisions and hard assaults, the lightweight does execution: the Pareto optimum of cost and quality.
4. **Escalation needs written rules of engagement** — "send the general after 20 minutes stuck" is a hundred times more reliable than "decide as it goes."
5. **Stuck does not mean crashed** — the consumption record proves it was thinking the whole silent stretch.
6. **Closing-out reconciliation beats rushing** — the final reconciliation dug out 4 points, exactly four times the winning margin.
7. **Zero strategy in the guardian layer** — keep-alive stays keep-alive, decisions stay decisions; mix them and it gets chaotic.
8. **Handle failures in tiers** — rate limit swaps the key, crash restarts, hard challenge swaps the model: each on its own track.
9. **Front-load the hints** — check the free hint before working a challenge (the hints were all null this time, but the methodology holds).
10. **Don't panic in the sharpening phase** — 84 minutes of silence was followed by 12 flags in 40 minutes.

---

## Final scorecard

```
Score: 80.18 / 100 (27078 of 33800 raw points)
Rank: 1st among 50 teams that scored
Solved: 36+ of 63 challenges, about 45 flags
Duration: 475 minutes, fully unattended
Downtime: zero. Auto-recovery on crash, auto-rotation on rate limit, no manual intervention throughout
Peak efficiency: 26 points/hour (the steepest slope of the event)
Total cost: about ¥110 in API calls
From prototype to competition: about 24 hours of development iteration
```
