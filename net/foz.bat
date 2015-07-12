@echo off
@set foz_version=1.2
goto setup_time
:start
if "%1"=="log" goto display_log
if "%1"=="help" goto help
if "%1"=="/?" goto help
if "%1"=="-h" goto help
if "%1"=="--help" goto help
if "%1"=="--V"  goto version
if "%1"=="--Version" goto version
if "%1"=="-V" goto version
if "%1"=="v" goto version
if "%1"=="setup" goto setup
if "%1"=="set" goto setup
if "%1"=="s" goto setup
if "%1"=="-s" goto setup
if "%1"=="unset" goto unset
if "%1"=="nw" goto new_window
if "%1"=="sw" goto same_window
if "%1"=="dkw" goto dont_keep_window
if "%1"=="dump_env" goto dump_env
if "%1"=="dump" goto dump_env
if "%1"=="d" goto dump_env

if not "%fp_h%"=="" goto run_ping
if "%1"=="" goto help

rem #run default wrap
@echo Pinging %1 at %fp_date% >> c:\temp\fp_%fp_date%_%2.txt
@echo Pinging %1 at %fp_date%  into   c:\temp\fp_%fp_date%_%2.txt
@fping %1 -t 10 -w 300 -c %3 %4 %5 %6 %7 %8 %9 >>c:\temp\fp_%fp_date%_%2.txt
  if Errorlevel 1 goto fping_error 
goto end


:display_log
if not "%fp_ts%"=="true" goto ts_false1
:ts_true1
  set fp_log_file=%fp_p%-%fp_date%-%fp_f%.txt
  goto display11 
goto end

:ts_false1
  set fp_log_file=%fp_p%%fp_f%.txt
  goto display11 
goto end

:display11 
start baretail %fp_log_file%

goto end
'
:unset
  set fp_h=
  @Echo "Sucssefully removed automated run! Please Run 'foz setup <options>' for env run or 'Foz <host> <options>' one time run"
goto end

:new_window
  set fp_spawn_window=true
  @Echo "fp shall run in seperated window [make sure to run 'foz dump_env']"
goto end

:dont_keep_window
  set fp_spawn_window=dkeep
  @Echo "fp shall run in seperated window and auto close [make sure to run 'foz dump_env']"
goto end


:same_window
  set fp_spawn_window=false
  @Echo "fp shall run in same window"
goto end

:run_ping
@echo ping using env setup run 'set fp_h=' or 'foz unset'
if not "%fp_ts%"=="true" goto ts_false
:ts_true
  set fp_log_file=%fp_p%-%fp_date%-%fp_f%.txt
  goto ping1 
goto end

:ts_false
  set fp_log_file=%fp_p%%fp_f%.txt
  goto ping1
goto end

:ping1
  if "%fp_c%"=="true" goto con_ping
  if not "%fp_c%"=="true" goto non_con_ping 
goto end

:con_ping
  set fping_params=%fp_bp% -c   
  goto do_ping
goto end

:non_con_ping
  set fping_params=%fp_bp% 
  rem set fping_params= -j -T
  goto do_ping
goto end

:show_and_log
   
 rem   if "%2"=="t" goto set title="%3 %4 %5 %6 %7 %8 %9 %0"
   echo ***************************************************************************
   echo fping %fp_h% -t %fp_t% -w %fp_w% %fping_params% %1 %2 %3 %4 %5 %6 %7 %8 %9 -L %title%%fp_log_file% @ %fp_date%
   echo !!!!!!!!!! OVERWRITE FILE !!!!!!!!!!!!!!!!!!!!!!!!!!!! %fp_log_file%  !!!!!!!!!!!!! 
    fping %fp_h% -t %fp_t% -w %fp_w% %fping_params% %1 %2 %3 %4 %5 %6 %7 %8 %9 -L %title%%fp_log_file%
goto end

:do_ping
   if "%1"=="l" goto show_and_log
   if not "%fp_l%"=="true" set fp_log_file=con
   if "%fp_l%"=="true" echo fping %fp_h% -t %fp_t% -w %fp_w% %fping_params% %1 %2 %3 %4 %5 %6 %7 %8 %9 into file %fp_log_file%
   echo *************************************************************************** >>%fp_log_file%
   echo * fping %fp_h% -t %fp_t% -w %fp_w% %fping_params% %1 %2 %3 %4 %5 %6 %7 %8 %9 @ %fp_date%  >>%fp_log_file%
   echo *************************************************************************** >>%fp_log_file%
   rem #### Run show & Log ###
   rem #### Run in new windows ###
   if "%fp_spawn_window%"=="true" start cmd /k "fping %fp_h% -t %fp_t% -w %fp_w% %fping_params% %1 %2 %3 %4 %5 %6 %7 %8 %9 >>%fp_log_file%"
     if "%fp_spawn_window%"=="true" goto end
   if "%fp_spawn_window%"=="dkeep" start "fping %fp_h% -t %fp_t% -w %fp_w% %fping_params% %1 %2 %3 %4 %5 %6 %7 %8 %9 >>%fp_log_file%"
      if "%fp_spawn_window%"=="dkeep" goto end
   rem #### Run in same windows ###
   fping %fp_h% -t %fp_t% -w %fp_w% %fping_params% %1 %2 %3 %4 %5 %6 %7 %8 %9 >>%fp_log_file%
   if Errorlevel 1 goto fping_error

goto end

:fping_error
  echo please intall fping inside your path from http://www.softpedia.com/get/Network-Tools/IP-Tools/Fping.shtml#download
goto end
:help
  @echo Fping  by Oz (Version %foz_version%) usage
  @echo " ***** The basic usage *****"
  @echo "foz <host> [file name in addtion to timestamp]"
  @echo "e.g. 'foz 127.0.0.1 test'  shall generate a fping every 10ms with 300ms timeout and logs the output into c:\temp\fp_<time_stamp>_test.txt"
  @echo " ***** The adavnce usage for multipile runs  *****"
  @echo "run 'foz setup'  for initial run defaults or to show curren setup options "
  @echo "run 'foz s h <host_ip_or_name>'  and then just run 'foz'                  "
  @echo "run 'fping'  for additonal paramters option e.g -b beep on success or -b- beep on failures, -n number of pings ..."
  @echo "run 'foz dump_env' to Presistently set current setup configuration for future runs (write to registery)"  
  @echo "run 'foz s bp <up to 6 fping paramters>' to setup fping base parameters [overides foz settings]"
  @echo "run 'foz s bp' to clean base paramters or 'foz s bp -T -j' to display jitter and timestamp for each line"
  @echo "run 'foz unset' to ignore setup configuration' 
  @echo "run 'foz d' to SAVE setup configuration to Registery ' 
goto no_setup_paramter
goto end
:version
  echo %foz_version%
goto end
:setup
  @echo setup is in effect until you close this cmd window
  
  if "%2"=="help" goto no_setup_paramter
  if "%fp_h%"=="" echo at least please set target host by running 'foz set h <host>'
  if "%fp_t%"=="" set fp_t=10
  if "%fp_w%"=="" set fp_w=500
  if "%fp_f%"=="" set fp_f=test
  if "%fp_p%"=="" set fp_p=c:\temp\fp_
  if "%fp_ts%"=="" set fp_ts=true
  if "%fp_c%"=="" set fp_c=true
  if "%fp_l%"=="" set fp_l=true
  if "%fp_bp%"=="" set fp_bp=-T -j  
  if "%fp_spawn_window%"=="" set fp_spawn_window=false
  if "%2"=="" goto no_setup_paramter
  if "%2"=="h" set fp_h=%3
  if "%2"=="host" set fp_h=%3
  if "%2"=="t" set fp_t=%3
  if "%2"=="w" set fp_w=%3
  if "%2"=="f" set fp_f=%3
  if "%2"=="ts" set fp_ts=%3
  if "%2"=="p" set fp_p=%3
  if "%2"=="c" set fp_c=%3
  if "%2"=="l" set fp_l=%3
  if "%2"=="bp" set fp_bp=%3 %4 %5 %6 %7 %8 %9 
  if "%4"=="t" set fp_t=%5
  if "%4"=="w" set fp_w=%5
  if "%4"=="f" set fp_f=%5
  if "%4"=="ts" set fp_ts=%5
  if "%4"=="p" set fp_p=%5
  if "%4"=="c" set fp_c=%5
  if "%6"=="t" set fp_t=%7
  if "%6"=="w" set fp_w=%7
  if "%6"=="f" set fp_f=%7
  if "%6"=="ts" set fp_ts=%7
  if "%6"=="p" set fp_p=%7
  if "%6"=="c" set fp_c=%7 
  if "%8"=="f" set fp_f=%9
  if "%8"=="ts" set fp_ts=%9
  if "%8"=="p" set fp_p=%9
  if "%8"=="c" set fp_c=%9
goto current_setup
:current_setup
  @echo in curent config include time stamp in filename is set to [ts]: %fp_ts%
  @echo in curent config continues ping set to [c]: %fp_c% 
  @echo in curent config log to file is set to [l]: %fp_l%
  @echo in curent config basic parmeters  set to [bp]: %fp_bp%
  if not "%fp_l%"=="true" echo current config for next run is: host=%fp_h% time=%fp_t% wait=%fp_w% to Console
  if not "%fp_l%"=="true" goto end
  if "%fp_ts%"=="true" @echo 'current config for next run is: host=%fp_h% time=%fp_t% wait=%fp_w% into file "%fp_p%-<time_stamp>-%fp_f%.txt"
  if not "%fp_ts%"=="true" @echo 'current config for next run is: host=%fp_h% time=%fp_t% wait=%fp_w% into file "%fp_p%%fp_f%.txt"
goto end
:no_setup_paramter
  @echo "*********************** setup help ******************************************"
  @echo please fill in at least paramters (h)ost , [w]ait_timeout , [t]ime            "
  @echo "'foz setup h <host  for e.g. 10.0.0.1>'                                      "
  @echo "'foz setup t <time between 2 pings in ms up to 1000000  default 10>'         "
  @echo "'foz setup w <timeout in ms to wait for each reply  default 500>'            "
  @echo "'foz s ts true'  shall generate new filename with timestamp per run          "
  @echo "'foz s ts false' shall write to the same file [adds timestamp header inside] "
  @echo "'foz setup c <true/false>' means run continusly in each new run              "
  @echo "'foz setup l <true/false>' means log to file per run (false >> Console)      "
  @echo "'foz setup f <test_name>'                                                    "
  @echo "'foz setup p <path prefix e.g c:\temp\fp_>'				      "
  @echo "you may setup 1 parameter or up to  4 at the same time examples [without ""] "
  @echo "'foz s l true'                                                               "
  @echo "'foz setup ts false c false p c:\temp\fping-test-                            "
  @echo "'foz s h <target_ip> t <time_in_ms> w <wait_up_to_in_ms> f <test_name>'      "
  @echo "after initial setup just run: foz [optional fping options]                   "
  @echo "for e.g.: foz -T -l -j -n 10  means Timestamp jitter no-stats for 10 times   " 
  @echo "for e.g.: foz -o -n 1000  means just show stats for 1000 runs                " 
  @echo "you may save fping paramters with: 'foz s bp [paramters]' e.g 'foz s bp -o -A'" 
  @echo "*****************************************************************************"
goto current_setup
goto end

:dump_env
@echo dumping current setup into registery this setup shall be availalbe next time you start cmd (you must run this cmd as administrator)
echo setting fp_h = "%fp_h%"
setx fp_h  "%fp_h%"
echo setting fp_t = "%fp_t%"
setx fp_t  "%fp_t%"
echo setting fp_w = "%fp_w%"
setx fp_w  "%fp_w%"
echo setting fp_f = "%fp_f%"
setx fp_f  "%fp_f%"
echo setting fp_p = "%fp_p%"
setx fp_p  "%fp_p%"
echo setting fp_ts = "%fp_ts%"
setx fp_ts "%fp_ts%"
echo setting fp_c = "%fp_c%"
setx fp_c  "%fp_c%"
echo setting fp_l = "%fp_l%"
setx fp_l  "%fp_l%"
echo setting fp_bp = "%fp_bp%"
setx fp_bp  "%fp_bp%"
echo setting fp_spawn_window = "%fp_spawn_window%"
setx fp_spawn_window %fp_spawn_window%

goto end

:setup_time
set hour=%time:~0,2%
if "%hour:~0,1%" == " " set hour=0%hour:~1,1%
rem echo hour=%hour%
set min=%time:~3,2%
if "%min:~0,1%" == " " set min=0%min:~1,1%
rem echo min=%min%
set secs=%time:~6,2%
if "%secs:~0,1%" == " " set secs=0%secs:~1,1%
rem echo secs=%secs%

set year=%date:~-4%
rem echo year=%year%
set month=%date:~4,2%
if "%month:~0,1%" == " " set month=0%month:~1,1%
rem echo month=%month%
set day=%date:~7,2%
if "%day:~0,1%" == " " set day=0%day:~1,1%
rem echo day=%day%

set datetimef=%year%%month%%day%_%hour%%min%%secs%
@set fp_date=D%day%-%month%-%year%_T%hour%-%min%-%secs%
goto start

:end
