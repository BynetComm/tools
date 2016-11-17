
@echo off
if exist "C:\Program Files (x86)\Notepad++\notepad++.exe" (
    cmd /k "C:\Program Files (x86)\Notepad++\notepad++.exe" %1 %2 %3 %4
) else (
    rem file doesn't exist trying in d:
   cmd /k "d:\Program Files (x86)\Notepad++\notepad++.exe" %1 %2 %3 %4
)
