@echo off
AT > NUL
IF %ERRORLEVEL% EQU 0 (
    ECHO you are Administrator
	c:\RailsInstaller\Ruby2.1.0\bin\ruby.exe  c:\bynet\tools\ruby\op.rb %1 %2 %3 %4 %5 %6 %7 %8 %9 
) ELSE (
    ECHO you are NOT Administrator. Elevating...
	PING 127.0.0.1 > NUL 2>&1
	Nircmd\NIRCMD.exe elevate cmd /k c:\RailsInstaller\Ruby2.0.0\bin\ruby.exe  c:\bynet\tools\ruby\op.rb %1 %2 %3 %4 %5 %6 %7 %8 %9 
    EXIT /B 1
)


