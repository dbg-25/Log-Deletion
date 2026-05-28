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
