# Diagnostic protocol — is it time to adopt FSRS/SM-2?

**When Juanes says "run the gym diagnostic," read this file and execute it.**

The gym schedules tickets with a **Leitner box system** (boxes 1–5, intervals
1/2/4/8/16 days). That was chosen deliberately over SM-2/FSRS to avoid
overengineering *before we had data*. This protocol decides, from real data,
whether that call still holds or it's time to migrate.

## Data sources

- `.gym-ledger` — current state, one line per ticket: `key  box  next_due`.
- `.gym-history` — append-only grade log: `date  key  grade  old_box  new_box`.
  This is the evidence. Everything below is an `awk`/`sort`/`uniq` pass over it.

## Step 1 — is there enough data yet?

Count graded events and distinct tickets:

```
wc -l .gym-history
cut -f2 .gym-history | sort -u | wc -l
```

**If < 40 grade events or < 10 distinct tickets with 3+ reps each → STOP.**
Not enough signal. Report "keep Leitner, recheck later" and set a new reminder.

## Step 2 — compute the three failure signatures

Leitner is "too coarse" only if the data shows patterns a *per-card* algorithm
would fix. Look for these three, in order:

### (a) Bouncers — cards that never graduate
Tickets that keep resetting to box 1 (grade `fail`) after reaching box 2+.

```
# fails that came from box >=2, grouped by ticket
awk -F'\t' '$3=="fail" && $4>=2 {print $2}' .gym-history | sort | uniq -c | sort -rn
```
**Signal:** any ticket with 3+ such bounces = a card whose difficulty the fixed
ladder can't accommodate. A handful of bouncers → strong FSRS argument.

### (b) Wasted reps — cards passed repeatedly, never failed
Tickets with many consecutive `pass` and no `fail`.

```
awk -F'\t' '{c[$2]++; if($3=="fail")f[$2]++} END{for(k in c) if(!f[k]&&c[k]>=4) print c[k], k}' .gym-history | sort -rn
```
**Signal:** cards you've passed 4+ times with zero fails are over-scheduled for
you — SM-2 would stretch their interval. Many such cards = wasted hour time.

### (c) Per-box fail rate — is a whole interval mistuned?

```
awk -F'\t' '{tot[$4]++; if($3=="fail")bad[$4]++} END{for(b=1;b<=5;b++) if(tot[b]) printf "box %d: %d%% fail (%d reps)\n", b, 100*bad[b]/tot[b], tot[b]}' .gym-history
```
**Interpretation:**
- Fail rate climbs sharply with box number (e.g. box4/5 > ~35%) → intervals too
  long *across the board*. This is NOT an FSRS signal — just **retune the
  INTERVALS array** in `gym`. Cheap, stay Leitner.
- Fail rate is flat/low everywhere BUT bouncers + wasted-reps are common → the
  mistuning is **per-card, not global**. THAT is the FSRS signal.

## Step 3 — the verdict rule

Decide with this, not with vibes:

| Evidence | Verdict |
|---|---|
| Not enough data (Step 1) | Keep Leitner. Recheck. |
| High per-box fail rate, few bouncers | Keep Leitner, **retune intervals**. |
| Several bouncers AND/OR many wasted-reps cards, flat per-box rate | **Migrate to SM-2** (per-card ease). FSRS only if SM-2 also proves too coarse. |
| Everything healthy | Keep Leitner. It's working. Say so plainly. |

## Step 4 — if migrating

SM-2 is a localized change: replace `reschedule()` in `gym` with per-card ease
(store `ease` as a 4th ledger column, seed 2.5). **Replay `.gym-history`** to
backfill each card's ease — no data lost, that's the whole point of logging it.
FSRS = only if SM-2 still can't fit the data; it needs a param-fitting library,
so justify it against the portable-tools goal before pulling it in.

## Output

End with ONE recommendation and the numbers that drove it. Caveman style.
Then set the next reminder if the verdict was "recheck later."
