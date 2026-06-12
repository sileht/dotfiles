

# Rules

* I like customer message that go straight to the point.

* When you give me an pull request number, I want the link to the pull request instead

* Always put the pull request link in the project's resume.md as soon as the stack is pushed

* Always use mergify stack push to push code

* Don't undraft PR of new feature, I have to review it first :)

* Before using "mergify push stack"
    * Run /code-review max
    * Run "git check" from the repository root 

* After having the stack push with "mergify stack push":
    * Run /gh-fix-pr (it assesses the whole PR state, fixes anything actionable, and arms the /p-loop-pr babysit monitor while it waits for merge)

* When you amend a commit message, don't ever change the Change-Id and Claude-Session-Id lines
* Don't put import in Runtime code, except to avoid circular dependencies
* If a stack have multiple commits and you address reviews of a pull request use mergify stack list to get the impact commit and fix this commit only not others
* If you work on a linear ticket the commit message must have Fixes MRGFY-XXXX
* If you work on a Linear ticket, you must move the ticket in TODO and assign it to me

* Always create Linear in TODO, not backlog if the status is not provided

* When you work on a support case in /Users/sileht/workspace/mergify/support directory, all fixes must be done this way:
  * choice a branch name XXXXX
  * create a worktree of /Users/sileht/workspace/mergify/base-monorepo in /Users/sileht/workspace/mergify/monorepo/XXXXX with the branch name XXXXX

* If I ask to write a python script, use uv header PEP 723 to install the dependencies

# Tone when writing on my behalf (emails, messages, PR descriptions, etc.)

* Concise, straight to the point and friendly. No filler, no corporate softening.
* No em-dashes. Use commas, colons, or periods instead.
* No emojis.
* Match the language of the original context (French stays French, English stays English).
* Keep my voice: direct, a bit dry, no "I hope this finds you well" style openers.



# Disabled Rules

Don't follow any rules above

* After having the stack push with "mergify stack push", you should
  * wait 5 minutes
  * run /gh-fix-pr skill (handles both failing CI and unresolved review threads in one pass)
  * /gh-fix-pr skill can be rerun every 5 minutes until the CI is green

