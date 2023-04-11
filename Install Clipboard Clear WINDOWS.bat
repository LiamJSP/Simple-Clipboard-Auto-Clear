@echo off
:begin
cls
echo The clipboard clear command can cause a command prompt window to open for a brief second while it runs, do you want to hide this window so it never shows? Doing so may require you to have administrator rights on this computer. If you say no, admin is not required.
echo.
set /p choice="yes or no? "
if /i "%choice%"=="yes" goto yes
if /i "%choice%"=="no" goto no
echo yes or no
goto begin

:yes
echo "You will be prompted to allow this program to run as admin, and it will re-launch. You may choose 'yes' again and proceed. Press enter to continue!
REM NOTE: the following is a script to request administrator rights in order to set a background scheduled task that doesn't show a command window.
pause
:init
 setlocal DisableDelayedExpansion
 set cmdInvoke=1
 set winSysFolder=System32
 set "batchPath=%~dpnx0"
 for %%k in (%0) do set batchName=%%~nk
 set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
 setlocal EnableDelayedExpansion

:checkPrivileges
  NET FILE 1>NUL 2>NUL
  if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
  if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)

  ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
  ECHO args = "ELEV " >> "%vbsGetPrivileges%"
  ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
  ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
  ECHO Next >> "%vbsGetPrivileges%"
  
  if '%cmdInvoke%'=='1' goto InvokeCmd 

  ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
  goto ExecElevation

:InvokeCmd
  ECHO args = "/c """ + "!batchPath!" + """ " + args >> "%vbsGetPrivileges%"
  ECHO UAC.ShellExecute "%SystemRoot%\%winSysFolder%\cmd.exe", args, "", "runas", 1 >> "%vbsGetPrivileges%"

:ExecElevation
 "%SystemRoot%\%winSysFolder%\WScript.exe" "%vbsGetPrivileges%" %*
 exit /B

:gotPrivileges
 setlocal & cd /d %~dp0
 if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)

goto inputFrequency

:no
goto inputFrequency

:inputFrequency
set /p frequency="Please enter how frequently the command should run in minutes: "
if %frequency% LSS 1 goto inputFrequency

if /i "%choice%"=="yes" (
SCHTASKS /Create /SC MINUTE /MO %frequency% /RU "SYSTEM" /TN "Clear Clipboard" /TR "cmd /c 'echo off | clip'"
) else (
SCHTASKS /Create /SC MINUTE /MO %frequency% /TN "Clear Clipboard" /TR "cmd /c 'echo off | clip'"
)

:end
pause
exit