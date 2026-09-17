# Log Triage

## TICKET
Checkout is degraded and customer support is on fire. The shop's access log
lives at `/var/log/shop/access.log` — and it's still growing, because the
incident is live right now.

Triage it and write an incident report to `~/storm-report.txt`, building it
up section by section (append — don't clobber your own report):
1. Watch the log grow in real time for a moment. Confirm whether errors are
   still being produced *right now*.
2. How many requests total, and how many returned status 500?
3. Which endpoint is producing the 500s? Prove it with a count per endpoint,
   highest first.
4. One client IP is hammering the service far harder than everyone else.
   Produce a ranked "requests per IP" table. Everything so far must be done
   with pipelines only — no editors, no temporary files.
5. Extract the top offender's full request lines into `~/evidence.log` for
   the abuse desk, and record how many lines that is in the report.

## COMMANDS
tail head cat grep cut sort wc echo tr

## QUESTIONS
1. Interview: explain what a pipe actually connects, in terms of stdin/stdout/stderr. If the first command in a pipeline dies halfway, what does the second one see?
2. Interview: a service writes both useful output and error noise. Show the difference between `>`, `2>`, `2>&1`, and why `cmd > file 2>&1` and `cmd 2>&1 > file` behave differently.
3. Interview: your log is 200G and you need "how many 500s in the last hour" — why is streaming it through filters fine, but opening it in an editor a career mistake? What does that imply about how pipes use memory?
