# Release Day Wreckage

## TICKET
Release day for checkout. Your working repository is `~/infra` and the shared remote is `/srv/git/infra.git`. An unreviewed healthcheck change was pushed to remote `master`; teammates have since added commits. Your working tree contains an unfinished memory change.
1. Before editing anything, record in `~/postmortem.txt` which remote branch `feature/healthcheck-timeout` tracked, which setting directed ordinary pushes there, and where that setting is defined.
2. Publish the feature branch under its own remote name and ensure future ordinary pushes target that branch.
3. Undo the healthcheck change on shared `master` without rewriting published history. Keep the memory change local, uncommitted and off `master`.
4. Integrate approved `feature/replicas` into `master`. Resolve conflicts in vim so the final deployment uses image `v1.5.0` and four replicas, without conflict markers.
5. Stop tracking the committed `.env` while retaining the local file and preventing future accidental additions.
6. Recover the TLS rotation script committed on Monday but no longer on any branch. Publish it on `feature/cert-rotation`.
7. Record in `~/blame.txt` the commit, author and stated reason for setting surge pods to zero.
8. Publish a message-bearing `v1.5.0` release marker on final `master`.
9. Return to the feature branch with the memory change still uncommitted. Verify local and remote branch history.

## COMMANDS
git status git log git branch git switch git config git fetch git pull
git push git stash git revert git merge git diff git add git commit git rm
git reflog git tag git blame git show vim cat echo

## QUESTIONS
1. Interview: when you run a plain `git push`, how does git decide which remote branch gets your commits? Explain upstream tracking, and compare `push.default` `simple`, `upstream` and `current`. How did `git checkout -b x origin/master` set the trap here? Why did even `git push -u origin feature/healthcheck-timeout` try to go to `master`? How would you stop this across a whole team (hint: the server side)?
2. Interview: reset vs revert. When do you use each one, and why is a force-push to a shared `master` dangerous? Follow-up: you reverted the healthcheck commit on `master`. Later, merging `feature/healthcheck-timeout` into `master` brings in nothing. Why? How do you get the change back?
3. Interview: fetch vs pull, and merge vs rebase. What is a fast-forward? When would you rebase, and when must you never rebase?
4. Interview: what is the reflog? Is it shared with the remote? How long does it keep entries? What work can `reset --hard` destroy that the reflog cannot bring back?
5. Interview: a password was committed and pushed. Why is untracking the file not enough? List everything you would do, in order.

## ANSWERS
