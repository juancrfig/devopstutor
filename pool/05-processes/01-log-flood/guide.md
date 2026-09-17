# Log Flood

## TICKET
Disk-growth alerts again — but this time it's not old files. Something on
this box is *actively* writing garbage into `/var/log/shop/debug.log`,
hundreds of lines a minute, right now. Nobody deployed a debug build.
There's also a report that one entry in the process table looks "undead."

1. Confirm the flood is live and measure it: how many lines arrive in ten
   seconds? Note the method and number in `~/flood-report.txt`.
2. Identify the writer process. Then map its full ancestry — what spawned
   what — because you'll need to explain the chain in the postmortem.
   Append the ancestry to the report.
3. Terminate the writer. Confirm the log stops growing and record the
   before/after evidence.
4. Hunt the "undead" entry: find it in the process table, explain in the
   report what state it's in, why it cannot be killed directly, and what
   would make it disappear.
5. Drill, for the report: start a slow task in the foreground, suspend it,
   resume it in the background, list your jobs, bring it back, and kill
   it. Note which keystroke and which commands did each step.

## COMMANDS
ps pgrep pstree kill fg bg wc tail grep

## QUESTIONS
1. Interview: what is a zombie process really — what resource does it still hold, who is responsible for cleaning it up, and when do thousands of zombies indicate an application bug?
2. Interview: explain the relationship between a process, its parent, and PID 1. What happens to children when their parent dies?
3. Interview: what does `&` at the end of a command actually do, and how is a background job different from a daemon?
