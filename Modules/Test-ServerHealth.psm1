
function Test-serverHealth {
    [cmdletbinding()]
    param(
        [parameter(mandatory=$true,valuefrompipeline=$true)]
        [string[]]$ip,
        [int]$timeSec = 5
    )

    #Process to test connectivity
    process{
            foreach($add in $ip){#loops through each ip address passed in
            try{
                $result = Test-NetConnection $add #tests connectivity to the address and returns a result object
                $test = [pscustomobject]@{#custom object to format the test results
                    Result = $result.PingSucceeded;
                    Source = $result.sourceAddress.IpAddress;
                    RoundTripTime = $result.roundTripTime
                }
                if($result.PingSucceeded){#if the ping test is successful, log and output the results
                    write-log -message "Ping Test to $add successful" -severity INFO
                    Write-Host "PING SUCCEEDED: Source $($test.source) | Round trip time $($test.RoundTripTime)" -BackgroundColor cyan
                }else{#if the ping test fails, log and output the failure
                    throw "Ping to $add unsuccesful"
                }
        }
        catch{#catch block to handle failed ping tests and log the error
                write-Log -message $_ -severity ERROR
            }
    }
}
}