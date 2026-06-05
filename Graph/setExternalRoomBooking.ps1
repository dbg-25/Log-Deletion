function Set-RoomCalendarViewing{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$rooms
    )


    begin{
        Connect-ExchangeOnline
    }

    process{

        try{
            if ($PSCmdlet.ShouldProcess($rooms, "updating rooms")) {
                foreach($room in $rooms){
                    Write-Host "Updating Room viewing permissions for: $room" -BackgroundColor Green
                    Set-mailboxFolderPermission -Identity "${room}:\Calendar" -User Default -AccessRights Reviewer -ErrorAction Continue -ErrorVariable myErrors
                    if($myErrors){
                        Write-Host "Error setting permissions for: $room"
                    }
                }
            }
        }catch{
            Write-Error $_
        }
    }
}


function Set-ExternalRoomBooking{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$rooms
    )


    begin{
        Connect-ExchangeOnline
    }

    process{

        try{
            if ($PSCmdlet.ShouldProcess($rooms, "updating rooms")) {
                foreach($room in $rooms){
                    Write-Host "Updating Room booking permissions for: $room" -BackgroundColor Green
                    Set-CalendarProcessing -Identity $room -ProcessExternalMeetingMessages $true -AutomateProcessing AutoAccept
                    if($myErrors){
                        Write-Host "Error setting permissions for: $room"
                    }
                }
            }
        }catch{
            Write-Error $_
        }
    }
}
  