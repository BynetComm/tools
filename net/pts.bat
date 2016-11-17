@echo off
@if "%pt_last_control_port%"=="" (set /a pt_last_control_port=3236 ) else (
 set /a pt_last_control_port=%pt_last_control_port% +1
)
set /a pts=0   
:start_server
@pathtest -s --control-port %pt_last_control_port%
 if %errorlevel% neq 0 (
   set /a pt_last_control_port=%pt_last_control_port% +1
   set /a pts =%pts% +1
   if %pts% LSS 10 (goto start_server) else (echo EEEEEEEEEE  More then 10 server starts attempts EEEEEE
    goto end)
 ) else (echo started Pathtest server on port: %pt_last_control_port% 
         goto end)
		 
 :end