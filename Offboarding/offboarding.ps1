#Need to connect to graph with following scopes
Connect-MgGraph -Scopes "User.ReadWrite.All"


       function set-UserOffboard {
        [cmdletbinding(SupportsShouldProcess=$true)]
        param(
            [Parameter(Mandatory=$true)]
            [string[]]$UPN
        )

        begin{
            $SuccessfulUsers = [System.Collections.Generic.List[object]]::new()
            $FailedUsers     = [System.Collections.Generic.List[string]]::new()
            try{
                foreach ($user in $UPN){
                    Write-Host "Searching for $user"
                    $userData = get-mguser -UserId $user -ErrorAction Continue -ErrorVariable CmdError
                    if ($CmdError) {
                        $FailedUsers.Add($User)
                        Write-Host "User could not be found: $user"
                    } 
                    # If $CmdError is empty AND we actually got data back, it succeeded
                    elseif ($UserData) {
                        $SuccessfulUsers.Add($UserData)
                        Write-Host "User found: $User"
                    }
                }
            }catch{
                Write-Error("Unable to retrieve user: $($_)")
            }
        }

        Process{
            try{
                foreach ($user in $SuccessfulUsers){
                    update-mguser -UserId $user -AccountEnabled $false -ErrorAction continue -ErrorVariable CmdError
                    Revoke-MgUserSignInSession -UserId $user
                    if($CmdError){
                        $FailedUsers.Add($User)
                    }
                }
            }catch{
                Write-Error $_
            }
        }

        end{
            foreach ($user in $FailedUsers){
                Write-Host "Failed User: $User" -BackgroundColor Red
            }
        }
    }