
function write-Log {
    [cmdletBinding()] #binding
    param(
        [Parameter(Mandatory=$true)]
        [string] $message,
        [Parameter(Mandatory=$true)]
        [validateSet('INFO', 'WARNING', 'ERROR', 'DEBUG')]
        [string] $severity,
        [string] $logPath = "C:\Logs\onboardLog_$(Get-Date -Format 'yyyyMMdd').log" #log file path with date in the name for logs
    )
    #custom object to format log entry
    $logEntry = [PSCustomObject]@{
        Message = $message
        Severity = $severity
        Time = Get-Date
        Script = $MyInvocation.ScriptName
    }

    $logJson = $logEntry | ConvertTo-Json -Compress #converts to JSON

    #Log path handling to ensure the directory exists before writing logs
    $LogDir = Split-Path -Path $LogPath
    if (-not (Test-Path -Path $LogDir)) {
        New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
        Write-host "Created log directory at $LogDir"
    }

    #Write to the log file
    "$LogJson`r`n" | Out-File -FilePath $LogPath -Append -Encoding utf8

    #Output log message to console based on severity
    switch ($severity) {
        'WARNING' { Write-Warning $Message }
        'ERROR'   { Write-Error $Message }
        'DEBUG'   { Write-Debug $Message }
        Default   { Write-Output $Message }
    }
}