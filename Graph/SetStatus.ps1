Connect-MgGraph -Scopes "User.Read.All", "Presence.Read.All", "Presence.ReadWrite.All"

$userId = (Get-MgUser -userId "joh.doe@email.com").id
$userStatus = Get-MgUserPresence -UserId $userId 


try{
    If ($userStatus.Availability -ne "Available"){
        $params = @{
        sessionId = "Your-App-Client-ID"
        availability = "DoNotDisturb"
        activity = "OutOfOffice"
        expirationDuration = "PT1H"
        }
        Set-MgUserPresence -UserId $userId -BodyParameter $params
        Write-Host "Successfully updated user presence to Out of Office (OOF)."
    }else{
        Write-Host "User is currently Available. No changes made." -ForegroundColor Yellow
        return
    }
}catch{
    write-error $_
}

