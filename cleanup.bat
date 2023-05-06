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
where /Q pwsh
if %ERRORLEVEL% NEQ 0 (
	echo Powershell 7 not found. Installing...
	winget install --id Microsoft.Powershell --source winget
	exit
)
pwsh -ExecutionPolicy Bypass -File "%~dp0\cleanup.ps1"
exit
