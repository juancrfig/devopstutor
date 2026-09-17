# Mystery Artifacts

## TICKET
Security flagged anomalous activity on this box between **02:00 and 03:00
on 2026-07-25**. The deploy tree at `/srv/deploy` is the suspected target.
The deploy pipeline itself last ran well before 02:00, and a legitimate
cron job wrote one file after 03:00 — everything else touched inside the
window is hostile until proven otherwise.

Forensics, without modifying any evidence:
1. Build a timeline: every file under `/srv/deploy` — including anything
   hidden — with its exact modification time, saved to `~/timeline.txt`.
2. Isolate the files modified strictly inside the incident window. Tip:
   you can fabricate reference files carrying any timestamp you want, and
   compare against them.
3. One planted file masquerades as an image. Prove what it actually is,
   and append the proof plus the full list of planted paths to
   `~/timeline.txt`.

## COMMANDS
find stat ls file touch wc

## QUESTIONS
1. Interview: what's the difference between a file's mtime and ctime, and why does a forensics team care about files where mtime is older than ctime?
2. Interview: why do `ls` and shell globs miss dotfiles by default, and why does that make hidden-file conventions a favorite hiding spot? How do you enumerate a tree so nothing can hide?
3. Interview: a script named `logo.jpg` — what actually decides whether Linux will execute a file: its extension, its content, or something else?
