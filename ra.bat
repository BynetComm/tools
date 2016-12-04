@echo off

goto version2

AT > NUL
IF %ERRORLEVEL% EQU 0 (
    ECHO you are Administrator
	%1 %2 %3 %4 %5 %6 %7 %8 %9 
) ELSE (
    ECHO you are NOT Administrator. Elevating...
	PING 127.0.0.1 > NUL 2>&1
	Nircmd\NIRCMD.exe elevate cmd /k %1 %2 %3 %4 %5 %6 %7 %8 %9 
    EXIT /B 1
)


:version2
@echo off
goto check_Permissions

:check_Permissions
    echo Administrative permissions required. Detecting permissions...

    net session >nul 2>&1
    if %errorLevel% == 0 (
        echo Success: Administrative permissions confirmed. running %1 %2 %3 %4 %5 %6 %7 %8 %9 
		%1 %2 %3 %4 %5 %6 %7 %8 %9 
    ) else (
        rem echo Failure: Current permissions inadequate.
		ECHO you are NOT Administrator. Elevating...
     	PING 127.0.0.1 > NUL 2>&1
	    NIRCMD.exe elevate cmd /k %1 %2 %3 %4 %5 %6 %7 %8 %9 

    )
