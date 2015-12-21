@echo push bynet tools to remote git Repo
rem cd c:\bynet\tools
git add --all
Rem git rm Gemfile.lock
git commit -m "updating tools %DATE% %TIME%"
git push
