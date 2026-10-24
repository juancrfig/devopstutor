# Log Flood

## TICKET
The shop debug log at `/var/log/shop/debug.log` is growing by over a thousand lines per minute. A process appears "undead." Record evidence in `~/flood-report.txt`.
1. Measure new lines in ten seconds.
2. Identify the writer and full ancestry.
3. Stop it and prove growth ceased.
4. Identify the unusual process state and explain why direct killing will not remove it and what will.
5. Demonstrate foreground suspension, background resume, job listing, foreground return and termination of a harmless slow task; record the keystroke and commands.

## COMMANDS
ps pgrep pstree kill fg bg jobs sleep wc tail grep

## QUESTIONS
1. Interview: what is a zombie process really — what resource does it still hold, who is responsible for cleaning it up, and when do thousands of zombies indicate an application bug?
2. Interview: explain the relationship between a process, its parent, and PID 1. What happens to children when their parent dies?
3. Interview: what does `&` at the end of a command actually do, and how is a background job different from a daemon?

## ANSWERS
