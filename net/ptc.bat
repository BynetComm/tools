@echo off
:setup
set /a index = 0
set mode=time
Rem set mode=packets
<<<<<<< HEAD
if "%1" =="help" @echo "PTC Ver 0.3 usage:pathtest.bat <BW> <Serverhost[fp_h]> <Serverport[D:3236]> <time>    <#loops [D:100000]> <Layer4_mode[D:TCP]> <direction [D:outbound]> ..."
if "%1" =="help" goto end
if "%5" == "" (if "%maxpathtest%"=="" set maxpathtest= 100000) else (set maxpathtest=%5)
if "%fp_h%"=="" (set fp_h = 172.17.40.155) else (set fp_h= %pathtesthost%)
if "%2" == "" (if "%pathtesthost%"=="" set pathtesthost= %fp_h%  ) else (set pathtesthost= %2) 
if "%3" == "" (if "%pathtestcontrolport%"=="" set pathtestcontrolport=3236) else (set pathtestcontrolport=%3) 
if "%7" == "" (if "%pathtestdirecton%"=="" set pathtesdirecton=) else (set pathtestdirecton=%7)
if "%6" == "" (if "%pathtestpmode%"=="" set pathtestpmode=--tcp ) else (set pathtestpmode=%6)
if "%4" == "" (if "%pathtestpackets%"=="" set pathtestpackets=1000) else (set pathtestpackets=%4)
if "%4" == "" (if "%pathtesttime%"=="" set pathtesttime=10) else (set pathtesttime=%4)
rem if "%1" == "" (if "%pathtestbw%"=="" set pathtestbw= 35m) else (set pathtestbw=%1)
if  "%1" == "MaxBW" goto no_bw
=======
if "%1" =="help" @echo "usage:pathtest.bat <BW> <Serverhost[fp_h]> <Serverport[D:3236]> <time>    <#loops [D:100000]> <Layer4_mode[D:TCP]> <direction [D:outbound]> ..."
if "%1" =="help" goto end
if "%5" == "" (if "%maxpathtest%"=="" set maxpathtest= 100000) else (set maxpathtest=%5)
if "%fp_h%"=="" (set fp_h = 172.17.50.11) else (set fp_h= %pathtesthost%)
if "%2" == "" (if "%pathtesthost%"=="" set pathtesthost= %fp_h%  ) else (set pathtesthost= %2) 
if "%3" == "" (if "%pathtestcontrolport%"=="" set pathtestcontrolport=3236) else (set pathtestcontrolport=%3) 
if "%7" == "" (if "%pathtestdirecton%"=="" set pathtesdirecton=) else (set pathtestdirecton=)
<<<<<<< HEAD
rem if "%6" == "" (if "%pathtestpmode%"=="" set pathtestpmode=--TCP ) else (set pathtestpmode=)
=======
<<<<<<< HEAD
if "%6" == "" (if "%pathtestpmode%"=="" set pathtestpmode=--TCP ) else (set pathtestpmode=)
=======
if "%6" == "" (if "%pathtestpmode%"=="" set pathtestpmode=--tcp ) else (set pathtestpmode=)
>>>>>>> 3dc254a01d631745b263ecaebd97f73569b74b4c
>>>>>>> 9666bfcdacc24d7f51f17c8970889e9cd82ad0d1
if "%4" == "" (if "%pathtestpackets%"=="" set pathtestpackets=1000) else (set pathtestpackets=%4)
if "%4" == "" (if "%pathtesttime%"=="" set pathtesttime=10) else (set pathtesttime=%4)
if "%1" == "" (if "%pathtestbw%"=="" set pathtestbw= 35m) else (set pathtestbw=%1)
>>>>>>> 8d128d001a0f8a165fd2384bd601799ea4f028f6
if "%pathtestfileindex%" == "" (if "%pathtestfileindex%"=="" set /a pathtestfileindex=1) else (set /a pathtestfileindex=%6)
if "%pathtestfilepathname%" == "" (if "%pathtestfilepathname%"=="" set pathtestfilepathname=c:\temp\pathtest) else (set pathtestfilepathname=%7)
:start
goto %mode%
:packets
@echo PTC Ver 0.2 Running [%index%/%maxpathtest%{@%time%}] pathtest  -c %pathtesthost%:%pathtestcontrolport% -b %pathtestbw% --packets %pathtestpackets% %pathtestdirecton%   %6 %7 %8 %9 
c:\bynet\tools\net\pathtest.exe  -c %pathtesthost%:%pathtestcontrolport% -b %pathtestbw% --packets %pathtestpackets%  %6 %7 %8 %9 
<<<<<<< HEAD
goto next_index

:time

@echo PTC Ver 0.2 Running [%index%/%maxpathtest%{@%time%}] -c %pathtesthost%:%pathtestcontrolport% -b %pathtestbw% --time %pathtesttime% %5 %6 %7 %8 %9 
c:\bynet\tools\net\pathtest.exe  -c %pathtesthost%:%pathtestcontrolport% -b %pathtestbw% --time %pathtesttime% %5 %6 %7 %8 %9 
goto next_index

:no_bw
@Echo ************************* MAX Bandwidth detection mode **********************
@echo PTC Ver 0.2 Running [MaxBW] [%index%/%maxpathtest%{@%time%}] pathtest -c %pathtesthost%:%pathtestcontrolport% --time %pathtesttime% %pathtestdirecton%  %pathtestpmode%
@c:\bynet\tools\net\pathtest.exe  -c %pathtesthost%:%pathtestcontrolport% --time %pathtesttime% %pathtestdirecton%  %pathtestpmode%
goto next_index

:next_index
REM  > %pathtestfilepathname%%pathtestfileindex%.txt
set /a index=%index% +1
set /a pathtestfileindex=%pathtestfileindex%+1
if %index% LSS  %maxpathtest% (
  if  "%1" == "MaxBW" (goto no_bw)
  goto start )
=======

:time
@echo PTC Ver 0.2 Running [%index%/%maxpathtest%{@%time%}] pathtest  -c %pathtesthost%:%pathtestcontrolport% -b %pathtestbw% --time %pathtestpackets% %pathtestdirecton%   %6 %7 %8 %9 
<<<<<<< HEAD
c:\bynet\tools\net\pathtest.exe  -c %pathtesthost%:%pathtestcontrolport% -b %pathtestbw% --time %pathtesttime%  %6 %7 %8 %9 
=======
<<<<<<< HEAD
c:\bynet\tools\net\pathtest.exe  -c %pathtesthost%:%pathtestcontrolport% -b %pathtestbw% --time %pathtesttime% %pathtestpmode% %pathtestdirecton%  %5 %6 %7 %8 %9 
=======
c:\bynet\tools\net\pathtest.exe  -c %pathtesthost%:%pathtestcontrolport% -b %pathtestbw% --time %pathtesttime% %5 %6 %7 %8 %9 
>>>>>>> 3dc254a01d631745b263ecaebd97f73569b74b4c
>>>>>>> 9666bfcdacc24d7f51f17c8970889e9cd82ad0d1

REM  > %pathtestfilepathname%%pathtestfileindex%.txt
set /a index=%index% +1
set /a pathtestfileindex=%pathtestfileindex%+1
if %index% LSS  %maxpathtest% goto start
>>>>>>> 8d128d001a0f8a165fd2384bd601799ea4f028f6
:end  