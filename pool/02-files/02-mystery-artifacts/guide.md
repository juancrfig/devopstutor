# Mystery Artifacts

## TICKET
Security detected suspicious changes to `/srv/deploy` strictly between 02:00 and 03:00 on 2026-07-25. Preserve evidence.
1. Save exact modification times for every file, including hidden files, in `~/timeline.txt`.
2. Identify only files modified strictly inside the incident window.
3. Determine the actual format of the suspicious file disguised as an image; append that evidence and all incident-window paths. Do not modify evidence.

## COMMANDS
find stat ls file touch wc

## QUESTIONS
1. Interview: what's the difference between a file's mtime and ctime, and why does a forensics team care about files where mtime is older than ctime?
2. Interview: why do `ls` and shell globs miss dotfiles by default, and why does that make hidden-file conventions a favorite hiding spot? How do you enumerate a tree so nothing can hide?
3. Interview: a script named `logo.jpg` — what actually decides whether Linux will execute a file: its extension, its content, or something else?

## ANSWERS
