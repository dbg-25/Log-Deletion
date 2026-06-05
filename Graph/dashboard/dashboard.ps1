

#get calendar data for upcoming day

function get-dashboard{
    [cmdletbinding]
    param(
        [parameter(Mandatory=$true)]
        [string]$name
    )
    
    connect-mggraph -scopes "Calendars.Read.All"

    begin{

    }

    process{
        foreach ($user in $name) {
            Get-MgUserCalendarView -UserId $user -StartDateTime $((Get-Date).Date) -EndDateTime $((Get-Date).AddHours(16)) -All
            
        }
    }

}