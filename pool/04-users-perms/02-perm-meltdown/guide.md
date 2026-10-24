# Permission Meltdown

## TICKET
A deploy change made `/srv/app` root-owned and world-accessible.
1. Save all current owners, groups and modes in `~/perm-audit.txt`.
2. Restore tree ownership to `appuser:app`.
3. Make secrets owner-only, config owner/group-readable only, both operational scripts executable only by owner/group, and `data` writable by the service. Apply shared changes in bulk.
4. Verify as appuser that config is readable, the start script runs and data is writable; verify an unrelated user cannot read secrets.

## COMMANDS
ls stat chmod chown chgrp su id find groups cat touch

## QUESTIONS
1. Interview: for a *directory*, what exactly do r, w, and x each allow? Why does `x` without `r` on a directory still work if you know a filename inside?
2. Interview: a file is mode 777 but its parent directory is 700 and owned by root — can a normal user read the file? Walk me through how the kernel evaluates the path.
3. Interview: why is a recursive 777 a security incident and not just sloppiness? Name two concrete attacks it enables on this exact app layout.
4. Interview: what is umask, and why did the junior's "fix" work at all — what was probably the original problem?

## ANSWERS
