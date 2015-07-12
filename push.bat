@echo push bynet tools to remote git Repo
cd c:\bynet\tools
git add --all
git rm Gemfile.lock
git commit -m "updating tools %DATE% %TIME%"
git push
