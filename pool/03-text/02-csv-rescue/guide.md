# CSV Rescue

## TICKET
Marketing exported the user base from a legacy Windows tool and the import
into the new CRM keeps rejecting it. The dump is at
`/srv/export/users_dump.csv`. Known damage: Windows line endings, semicolons
instead of commas, emails in FULL SHOUTING CASE, duplicated rows, and blank
lines. The CRM wants: lowercase emails, one per line, deduplicated,
alphabetically sorted, no header, no blanks.

1. First, prove the line endings are broken without opening an editor
   (hint: something in your toolkit reveals what a file really is, and
   byte counts don't lie either).
2. Build the clean email list into `~/emails.txt` with a single pipeline.
3. The ops side wants a scaffold: one directory under `~/teams/` per team
   in the dump, created in bulk by feeding the team list into the
   directory-creation step — no loop, no manual list.
4. Some rows are for a team file that may not exist yet; when you check
   for per-team config files under `/etc/crm/`, errors for missing ones
   must be silenced, not sprayed on the terminal.

## COMMANDS
cat file wc tr cut sort grep xargs echo head tail

## QUESTIONS
1. Interview: what actually is a "line" to Unix tools? What are `\n` and `\r` at the byte level, and why does a stray `\r` make `grep pattern$` mysteriously fail?
2. Interview: everything in Unix is "text streams" — why is that composability the core design idea of the shell? Contrast piping with writing intermediate files: when is each the right call?
3. Interview: `xargs` exists because pipes connect streams, not arguments. Explain that distinction — what breaks if you pipe a file list straight into a command that ignores stdin?
