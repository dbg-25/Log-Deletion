
function UserOnboardingData{
    [CmdletBinding(supportsshouldprocess=$true)] #cmdletbinding allowing whatif 
    param(
        [parameter(mandatory=$true, valueFromPipeline=$true)] #mandatory and allow piping
        [ValidateScript({
            if ([string]::IsNullOrEmpty($_.name) -or [string]::IsNullOrEmpty($_.email) -or [string]::IsNullOrEmpty($_.password)){#Validation block looking for nulls
                throw "The passed object must contain non-empty 'Username' and 'Email' properties."
            }else{
                $true
            }
        })]
        [PSCustomObject]$userData#user object
    )
        
begin{
    write-Log -message "Starting User Creation" -severity INFO
}

process{
    try{#try catch 
        foreach ($obj in $userData) {#loops object
            if($PSCmdlet.ShouldProcess("$($UserData.name)", "Provisioning new onboarding data")){#runs when what if is not used
            new-AdUser -DisplayName $userData.name -MailNickname $userData.email -UserPrincipalName $userdata.email -Password $userData.password -ErrorAction Stop
        }
        write-log -message "User created" -severity INFO
    }
    }catch{
        write-Log -message $_.Exception.Message -severity ERROR #logging error
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