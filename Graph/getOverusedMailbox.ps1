
Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -ShowBanner:$false

#Retrieve mailboxes 
Write-Host "Retrieving user mailboxes..." -ForegroundColor Cyan
$mailboxes = Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox

Write-Host "Found $($mailboxes.Count) mailboxes. Checking quota status..." -ForegroundColor Cyan
$results = [System.Collections.Generic.List[PSCustomObject]]::new()
$i = 0
foreach ($mbx in $mailboxes) {
    $i++
    Write-Progress -Activity "Checking quota status" `
                   -Status "$i of $($mailboxes.Count): $($mbx.UserPrincipalName)" `
                   -PercentComplete (($i / $mailboxes.Count) * 100)
    try {
        $stats = Get-MailboxStatistics -Identity $mbx.UserPrincipalName -ErrorAction Stop
        # Exchange sets this value directly — no math needed
        $quotaStatus = $stats.QuotaIssueWarning  # informational only
        $isProhibited = $stats.DatabaseIssueWarningQuota -or
                        $stats.ProhibitSendQuota -or
                        $stats.ProhibitSendReceiveQuota
        # The reliable field is DisplayName of the quota status
        $statusValue = $stats.StorageLimitStatus
        if ($statusValue -in @("ProhibitSend", "ProhibitSendReceive")) {
            $results.Add([PSCustomObject]@{
                UserPrincipalName        = $mbx.UserPrincipalName
                MailboxType              = $mbx.RecipientTypeDetails
                StorageLimitStatus       = $statusValue
                CurrentSize              = $stats.TotalItemSize
                ItemCount                = $stats.ItemCount
                ProhibitSendQuota        = $mbx.ProhibitSendQuota
                ProhibitSendReceiveQuota = $mbx.ProhibitSendReceiveQuota
            })
        }
    }
    catch {
        Write-Warning "Skipped $($mbx.UserPrincipalName): $_"
    }
}

Write-Progress -Activity "Checking quota status" -Completed
#Output

if ($results.Count -eq 0) {
    Write-Host "`nNo mailboxes are currently in a prohibited send/receive state." -ForegroundColor Green
} else {
    Write-Host "`n--- Mailboxes Requiring License Upgrade ($($results.Count) found) ---" -ForegroundColor Yellow
    $results | Sort-Object StorageLimitStatus |
               Format-Table DisplayName, UserPrincipalName, MailboxType,
                             StorageLimitStatus, CurrentSize, ProhibitSendQuota,
                             ProhibitSendReceiveQuota -AutoSize
    # Export to CSV
    $csvPath = ".\LicenseUpgradeAudit_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
    $results | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
    Write-Host "`nExported to: $csvPath" -ForegroundColor Green
}
# Disconnect

Disconnect-ExchangeOnline -Confirm:$false
Write-Host "Disconnected." -ForegroundColor Cyan
 