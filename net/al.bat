
:start
@echo %time% >>c:\temp\al_text2.txt
@fping %1 -n 1 -w 150  -l >>c:\temp\al_text2.txt
@goto start