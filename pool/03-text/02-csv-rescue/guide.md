# CSV Rescue

## TICKET
Marketing's Windows export at `/srv/export/users_dump.csv` is rejected by the CRM. It has Windows line endings, semicolon-separated fields, uppercase emails, duplicate rows and blank lines. The CRM requires a clean email list.

1. Inspect the file without an editor. Establish which line-ending format it uses and show evidence.
2. Create `~/emails.txt` using one pipeline. It must contain only lowercase email addresses, one per line, alphabetically sorted, without a header, duplicates or blanks. Preserve the source file.
3. Create an empty directory under `~/teams/` for every distinct team in the export. Derive names from the CSV and create directories in bulk, without a manual list or loop.
4. For every distinct team in the CSV, attempt to display `/etc/crm/<team>.conf`. Show existing file contents but suppress missing-file errors. Derive filenames from the CSV rather than listing them manually.

## COMMANDS
cat file wc tr cut sort grep xargs mkdir echo head tail

## QUESTIONS
1. Interview: what actually is a "line" to Unix tools? What are `\n` and `\r` at the byte level, and why does a stray `\r` make `grep pattern$` mysteriously fail?
2. Interview: everything in Unix is "text streams" — why is that composability the core design idea of the shell? Contrast piping with writing intermediate files: when is each the right call?
3. Interview: `xargs` exists because pipes connect streams, not arguments. Explain that distinction — what breaks if you pipe a file list straight into a command that ignores stdin?

## ANSWERS
