# Offboard / Onboard

## TICKET
HR has ended `contractor`'s access; `marina` joins `devs`.
1. Audit all contractor-owned files system-wide, with ownership details, in `~/offboard-audit.txt`, suppressing permission errors.
2. Create marina with a home and team membership; transfer `/srv/project/api` files to her without changing their group.
3. Remove contractor-owned files outside that project.
4. Remove the account and home; check for orphaned numeric ownership.
5. As marina, prove identity, memberships and ability to read the project's `.env`.

## COMMANDS
find chown chgrp adduser deluser groups usermod su id ls rm cat

## QUESTIONS
1. Interview: what happens to a user's running processes and files when you delete the account? Why do offboarding runbooks kill sessions and reassign files *before* `deluser`?
2. Interview: difference between a user's primary group and supplementary groups? When a user creates a file, which group does it get?
3. Interview: `su - marina` vs `su marina` — what does the `-` change, and when has skipping it burned people in production?
4. Interview: why do shared-project directories often use the setgid bit? What problem from this very ticket does it prevent?

## ANSWERS
