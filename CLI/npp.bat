<<<<<<< HEAD
"C:\Program Files (x86)\Notepad++\notepad++.exe" %1 %2 %3 %4
"C:\tools\Notepad++\notepad++.exe" %1 %2 %3 %4
=======
@echo off
if exist "C:\Program Files (x86)\Notepad++\notepad++.exe" (
    cmd /k "C:\Program Files (x86)\Notepad++\notepad++.exe" %1 %2 %3 %4
) else (
    rem file doesn't exist trying in d:
   cmd /k "d:\Program Files (x86)\Notepad++\notepad++.exe" %1 %2 %3 %4
)



>>>>>>> 9666bfcdacc24d7f51f17c8970889e9cd82ad0d1
