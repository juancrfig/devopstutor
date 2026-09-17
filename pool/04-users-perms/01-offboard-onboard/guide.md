# Offboard / Onboard

## TICKET
HR just terminated the contract with `contractor`, effective immediately,
and the new hire `marina` starts today on the `devs` team. Compliance
requires a full audit trail before anything is destroyed.

1. Audit: find **every** file on the system owned by `contractor` —
   wherever it hides — and save the list with ownership details to
   `~/offboard-audit.txt`. Errors from unreadable system paths must not
   pollute the audit file or your terminal.
2. The project files under `/srv/project/api` must survive: hand their
   ownership to marina (create her first, with a proper home and the right
   team membership) while keeping the team's group on them.
3. Everything else the contractor owned outside the project is disposable —
   remove those leftovers.
4. Remove the contractor's account and home directory. Verify no file on
   the system references the dead account anymore (what does ownership
   even show, once the user is gone?).
5. Prove marina's access: become her, confirm her identity and groups, and
   confirm she can actually read the project's `.env` file.

## COMMANDS
find chown chgrp adduser deluser groups usermod su id ls

## QUESTIONS
1. Interview: what happens to a user's running processes and files when you delete the account? Why do offboarding runbooks kill sessions and reassign files *before* `deluser`?
2. Interview: difference between a user's primary group and supplementary groups? When a user creates a file, which group does it get?
3. Interview: `su - marina` vs `su marina` — what does the `-` change, and when has skipping it burned people in production?
4. Interview: why do shared-project directories often use the setgid bit? What problem from this very ticket does it prevent?
