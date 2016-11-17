@echo off
:setup
set /a index = 0
if "%1" =="help" @echo "usage:pathtest.bat <BW> <packets> <direction> <Serverhost> <#loops> <fileoutputindex> <fileoutputpath>"
if "%1" =="help" goto end
if "%5" == "" (if "%maxpathtest%"=="" set maxpathtest= 100000) else (set maxpathtest=%5)
if "%4" == "" (if "%pathtesthost%"=="" set pathtesthost= 172.17.50.1) else (set pathtesthost=%4) 
if "%3" == "" (if "%pathtestdirecton%"=="" set pathtesdirecton=--inbound) else (set pathtestdirecton=%3)
if "%2" == "" (if "%pathtestpackets%"=="" set pathtestpackets=1000) else (set pathtestpackets=%2)
if "%1" == "" (if "%pathtestbw%"=="" set pathtestbw= 35m) else (set pathtestbw=%1)
if "%pathtestfileindex%" == "" (if "%pathtestfileindex%"=="" set /a pathtestfileindex=1) else (set /a pathtestfileindex=%6)
if "%pathtestfilepathname%" == "" (if "%pathtestfilepathname%"=="" set pathtestfilepathname=c:\temp\pathtest) else (set pathtestfilepathname=%7)
:start
echo [%index%/%maxpathtest%{%time%}] c:\pathtest %pathtesthost% -b %pathtestbw% --packets %pathtestpackets% %pathtestdirecton%  %8 %9 > %pathtestfilepathname%%pathtestfileindex%.txt
c:\bynet\tools\net\pathtest.exe %1 %2 %3 %4 %5 %6 %7 %8 %9
remark  > %pathtestfilepathname%%pathtestfileindex%.txt
set /a index=%index% +1
set /a pathtestfileindex=%pathtestfileindex%+1
if %index% LSS  %maxpathtest% goto start
:end  