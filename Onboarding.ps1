
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
