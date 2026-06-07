$ErrorActionPreference = "Stop"

$ProjectDir = Resolve-Path (Join-Path $PSScriptRoot "..")
$HostName = if ($env:WEBUI_HOST) { $env:WEBUI_HOST } else { "127.0.0.1" }
$Port = if ($env:WEBUI_PORT) { [int] $env:WEBUI_PORT } else { 8000 }
$Url = "http://${HostName}:${Port}"

function Test-PortOpen {
    param(
        [string] $HostName,
        [int] $Port
    )

    $client = New-Object Net.Sockets.TcpClient
    try {
        $connect = $client.BeginConnect($HostName, $Port, $null, $null)
        if (-not $connect.AsyncWaitHandle.WaitOne(500, $false)) {
            return $false
        }
        $client.EndConnect($connect)
        return $true
    }
    catch {
        return $false
    }
    finally {
        $client.Close()
    }
}

if (Test-PortOpen -HostName $HostName -Port $Port) {
    Start-Process $Url
    exit 0
}

$PythonPath = Join-Path $ProjectDir ".venv\Scripts\python.exe"
if (-not (Test-Path $PythonPath)) {
    $PythonPath = "python"
}

$serverCommand = @"
Set-Location -LiteralPath '$ProjectDir'
& '$PythonPath' main.py --webui-only --host $HostName --port $Port
"@

Start-Process powershell -WorkingDirectory $ProjectDir -ArgumentList @(
    "-NoExit",
    "-ExecutionPolicy",
    "Bypass",
    "-Command",
    $serverCommand
)

Start-Sleep -Seconds 10
Start-Process $Url
