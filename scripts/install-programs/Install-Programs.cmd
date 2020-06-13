:: Setting up ::
@echo off
cls
@pushd %~dp0

IF NOT DEFINED localappdata Set localappdata=X:\users\Default\appdata\local

::extract powershell core
pushd "%cd%\..\consolez"
start /wait "" consolez.cmd nostart
popd

:: launch ps1 script
set PSScript=%~dpn0.ps1
if '%1'=='' goto Done
set args=%1
:More
shift
if '%1'=='' goto Done
set args=%args%, %1
goto More
:Done

pushd "%localappdata%\cb\consolez"
start "" "%localappdata%\cb\consolez\console.exe"  -t "Pwsh (admin)" -reuse -r "-executionpolicy bypass -noexit -Command  &'%PSScript%' %args%"
popd
exit
