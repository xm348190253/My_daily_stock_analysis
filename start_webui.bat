@echo off
setlocal

set "PROJECT_DIR=%~dp0"
set "SCRIPT=%PROJECT_DIR%scripts\start-webui-local.ps1"

powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%"

endlocal
