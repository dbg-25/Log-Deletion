function remove-oldlogs {
    [cmdletbinding(supportsshouldprocess=$true)] #Enables cmdletbinding with -whatif and -confirm parameters
    param(
        [Parameter(mandatory=$true, ValueFromPipeline=$true)] #Takes logpath as a mandatory parameter and allows it to be piped in
        [string]$logpath,
        [Parameter(mandatory=$true)]#Takes daysold as a mandatory parameter
        [int]$daysold
    )

    begin { #Caluculates cutoff date
        write-Log -message "Starting Log deletion" -severity INFO
        $cutOffDate = (Get-Date).AddDays(-$daysold)
        Write-Host "Cutoff date is {$cutOffDate}"

    }

    process{
        $logArr = @()
        try{
            Get-Item $logpath -ErrorAction Stop
            $logArr = Get-ChildItem $logpath -Filter "*.log" #creates and array with all log files in the specified path

        }
        catch [System.Management.Automation.ItemNotFoundException] {
            write-Log -message "$logpath not found, Please rerun the command and enter a valid path" -severity WARNING
            return
        }
        catch {
            write-log -message "An error occured" -severity ERROR 
            Write-Error $_
            return 
        }

        foreach ($log in $logArr){
            Write-log -message "Checking date for {$log}" -severity INFO 
            if($log.LastWriteTime -lt $cutOffDate){ #Checks if the last write time of the log file is older than the cutoff date

                #variables to determine the target and action for the ShouldProcess method
                $target = $log.FullName 
                $action = "Delete the log file $log"

                #whatif and confirm support to safely delete log files
                if($PSCmdlet.ShouldProcess($target, $action)){
                Remove-Item -Path $target
                Write-log -message "Log file deleted" -severity INFO 
                }
            }

        }
    }
}

function write-Log {
    [cmdletBinding()] #binding
    param(
        [Parameter(Mandatory=$true)]
        [string] $message,
        [Parameter(Mandatory=$true)]
        [validateSet('INFO', 'WARNING', 'ERROR', 'DEBUG')]
        [string] $severity,
        [string] $logPath = "C:\Logs\ScriptLog_$(Get-Date -Format 'yyyyMMdd').log" #log file path with date in the name for logs
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

