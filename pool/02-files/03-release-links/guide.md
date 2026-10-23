# Release Links

## TICKET

After cleanup, the site is serving a 404. The active release link points to a
release directory that no longer exists. The nginx-style configuration tree
also has stale links. A teammate says deleting the archived API log name freed
no space; the live and archived names are still visible on this box.

1. Find every broken symlink under `/srv` and `/etc/nginx`. Save the paths to
   `~/broken-links.txt`. Self-check: exactly 2 broken links.
2. Restore the active release. The application uses `/srv/app/current` as a
   symbolic link to select which release directory is active. Available releases
   are stored under `/srv/app/releases/`, including `/srv/app/releases/v2`.
   Currently, `/srv/app/current` points to a release directory that no longer
   exists, causing the application to fail.

   Update `/srv/app/current` so that it points to `/srv/app/releases/v2`.
   Replace the existing symlink **atomically**, in a single filesystem operation,
   without an intermediate state where `/srv/app/current` is missing. Prove
   that `/srv/app/current` remains a symlink and resolves to release v2.
   Do not modify or copy the contents of the release directories.
3. Compare the live and archived API log names and record the inode, link count,
   and starting filesystem usage in `~/release-report.txt`. Remove the archived
   name and prove usage does not change; find the remaining name for that same
   inode, then remove it. Append the final usage. Self-check: at least 20M
   becomes available after the final link is removed.

## COMMANDS

ln readlink ls -li find (-xtype l -samefile -links -size) stat df rm mv -T

## QUESTIONS

1. In inode terms, what does a hard link share with its other names, and how
   does that differ from a symbolic link? Which kind can cross filesystems,
   and what happens to each when another name is removed?
2. Why do deployments switch a `current` link instead of copying files into a
   live directory? What failure can an in-place update expose, and how does a
   same-filesystem rename make the switch atomic to readers?
3. A cleanup removes one filename but filesystem usage stays the same. What
   relationship between directory entries, link counts, open file descriptors,
   and allocated blocks could explain the result?

## ANSWERS
