# Connect to Microsoft Graph with required permissions
Connect-MgGraph -Scopes "UserAuthenticationMethod.Read.All", "User.Read.All"

#Fetch Users
try {
    Write-Host "Fetching user directory..." -ForegroundColor Cyan
    #Filter out disabled accounts
    $allUsers = Get-MgUser -All -Property Id, DisplayName, UserPrincipalName -Filter "accountEnabled eq true"
} catch {
    Write-Error $_
}

#Array to hold users who have NO auth methods
$UsersWithNoAuthMethod = [System.Collections.Generic.List[PSObject]]::new()

try {
    foreach ($User in $allUsers) {
        Write-Host "Checking registration methods for: $($User.UserPrincipalName)" -ForegroundColor Gray
        
        #method to pull authentication user ID
        $AuthMethods = Get-MgUserAuthenticationMethod -UserId $User.Id -ErrorAction SilentlyContinue | 
            #Where-Object { $_.OdataType -ne "#microsoft.graph.passwordAuthenticationMethod" }
            Where-Object { $_.AdditionalProperties["@odata.type"] -ne "#microsoft.graph.passwordAuthenticationMethod" }

        # If empty no secondary MFA
        if (-not $AuthMethods) {
            $UsersWithNoAuthMethod.Add($User)
            Write-Host "NO MFA DETECTED: $($User.UserPrincipalName)" -BackgroundColor DarkRed -ForegroundColor White
        }
       
    }
} catch {
    Write-Error $_
}

# Output result count to console
Write-Host "`nDone!" -ForegroundColor Cyan
Write-Host "Found $($UsersWithNoAuthMethod.Count) active users with NO authentication methods configured." -ForegroundColor Green

# Export the final filtered results to a CSV file
if ($UsersWithNoAuthMethod.Count -gt 0) {
    # Ensure directory exists before exporting
    if (-not (Test-Path "C:\temp")) { 
        $null = New-Item -ItemType Directory -Path "C:\temp" 
    }

    $UsersWithNoAuthMethod | Select-Object Id, DisplayName, UserPrincipalName | 
        Export-Csv -Path "C:\temp\NoAuthMethodUsers.csv" -NoTypeInformation

    Write-Host "Report exported to C:\temp\NoAuthMethodUsers.csv" -ForegroundColor Cyan
} else {
    Write-Host "All checked users have at least one authentication method configured. CSV export skipped." -ForegroundColor Yellow
}
