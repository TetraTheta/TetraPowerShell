@echo off
net session
if %errorlevel% neq 0 goto ELEVATE
goto ADMINTASKS

:ELEVATE
cd /d %~dp0
mshta "javascript: var shell = new ActiveXObject('shell.application'); shell.ShellExecute('%~nx0', '', '', 'runas', 1);close();"
exit

:ADMINTASKS
cls
pwsh -ExecutionPolicy Bypass -File "%~dp0\release_extensions.ps1"
exit
