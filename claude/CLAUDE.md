

# Rules

* Always run "git check" before using "mergify push stack"
* When you amend a commit message, don't ever change the Change-Id and Claude-Session-Id lines
* Don't put import in Runtime code, except to avoid circular dependencies
* Always run npm run test with env CI=true
