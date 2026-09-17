# Amnesia Shift

## TICKET
You're paged onto a server you've never touched. The previous admin, Dana,
left for vacation and is unreachable. Their handover note (it greets you at
login) claims: CentOS 7, 64 cores, 128G RAM, rebooted an hour ago, everyone
uses zsh, "nothing weird in my session history."

Trust nothing. Verify every single claim against the box itself, and dig
through the session history dana left behind — decide if anything in it
deserves escalation.

## COMMANDS
uname uptime free lscpu

## QUESTIONS
1. Interview: you SSH into a box during an outage. What are the first five things you check before changing anything, and why in that order?
2. Interview: `uptime` shows load average `12.0, 3.0, 0.5` on a 4-core machine. Walk me through what that tells you and what you'd look at next.
3. Interview: what's the difference between the kernel and the distribution? Where did each of your verification commands get its answer from?
