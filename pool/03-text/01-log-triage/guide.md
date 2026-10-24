# Log Triage

## TICKET
Checkout is degraded during a live incident. Requests continue arriving in `/var/log/shop/access.log`. Customer support needs an evidence-based report.

Build `~/storm-report.txt` section by section, preserving earlier sections:
1. Observe new log entries arriving. Determine whether HTTP 500 responses are still occurring during your observation, and record the evidence.
2. Record the total number of requests and the number returning HTTP 500.
3. Identify every endpoint returning HTTP 500. Rank endpoints by error count, highest first.
4. Rank client IPs by request count, highest first, and identify the busiest. Complete steps 1–4 using pipelines, without editors or temporary files.
5. Save the busiest IP's full log entries in `~/evidence.log` and record the number of saved lines in the report. Repeating extraction must not duplicate evidence.

## COMMANDS
tail head cat grep cut sort uniq wc echo tr

## QUESTIONS
1. Interview: explain what a pipe actually connects, in terms of stdin/stdout/stderr. If the first command in a pipeline dies halfway, what does the second one see?
2. Interview: a service writes both useful output and error noise. Show the difference between `>`, `2>`, `2>&1`, and why `cmd > file 2>&1` and `cmd 2>&1 > file` behave differently.
3. Interview: your log is 200G and you need "how many 500s in the last hour" — why is streaming it through filters fine, but opening it in an editor a career mistake? What does that imply about how pipes use memory?

## ANSWERS
