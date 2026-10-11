# Phantom Full

## TICKET
The app reports “No space left on device” under `/var/lib/sessions`, while its storage dashboard says the volume is only 70% used. Ops also attached a new sessions volume.

**Safety:** this privileged lab can see the host's real disks. Never format or mount any device except the named lab volume `/dev/disk/by-gym/sessions-vol`. Do not choose a device by scanning the disks; this stable path names the attached lab volume.

1. Reproduce the write failure. Save the error and evidence that ordinary space remains to `~/storage-report.txt`.
2. Find what resource is exhausted and which directory contains the session files. Record both block and inode availability, and explain the mismatch in the report.
3. Count files older than 7 days before deleting only those session files in bulk. Exactly 1000 files are older than that threshold; append the count and cleanup evidence to the report.
4. Create a filesystem on **only** `/dev/disk/by-gym/sessions-vol`, mount it at `/srv/sessions`, and make it mount by UUID at boot without blocking boot if the volume is absent. Verify the fstab entry without rebooting.
5. Unmount the old `/var/lib/sessions` filesystem. It refuses because a live process is using it. Find that process, resolve the holder, and unmount cleanly; do not use a lazy unmount.

## COMMANDS
df du find wc lsblk blkid mkfs.ext4 mount umount findmnt lsof ps kill grep sudo cat

## QUESTIONS
1. Why identify a volume by UUID rather than `/dev/sdX`? What can go wrong with an fstab entry at boot, and how does `nofail` change the outcome?
2. What are a disk, partition, filesystem, and mount point? What does filesystem creation initialize, and why can ext4 not gain more inodes after creation?
3. Why does the kernel refuse an unmount when the target is busy? How can you find the holder, and what can go wrong with a lazy unmount?

## ANSWERS
