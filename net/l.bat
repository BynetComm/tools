@rem @echo off
@if "%1"==""  ( 
   @echo  ## Lan ethernet grep version 1.0 by oz 28/6/15 ##
   echo running netsh interface ip show addresses
   netsh interface ip show addresses
   goto end
   )

@if "%2"=="" (
  echo running: netsh interface ip show addresses "%1"  - B 1
  netsh interface ip show addresses "%1"
  @goto end 
  )

@if "%3"=="" (
  @ netsh interface ip show addresses "%1" | grep -i "%1" -A %2
  @goto end
)

:end