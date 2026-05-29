function set-fileOrganizer{
    [cmdletbinding()]
    param(
        [Parameter(mandatory=$true,ValueFromPipeline=$true)]
        [string]$filePath
    )

    begin{
        write-Host -message "Testing file path: $filepath" -BackgroundColor Cyan
        write-Log -message "Testing file path: $filepath" -severity INFO
        $count = 0
        try{
            test-path -path $filepath -ErrorAction Stop
            $files = Get-ChildItem -Path $filePath -file -ErrorAction Stop

            $txtFiles = New-Item -Path "$filePath/txt files" -ItemType "Directory" -Force
            $pdfFiles = New-Item -Path "$filePath/pdf files" -ItemType "Directory" -Force
            $wordFiles = New-Item -Path "$filePath/word files" -ItemType "Directory" -Force
            $excelFiles = New-Item -Path "$filePath/excel files" -ItemType "Directory" -Force

        }catch{
            write-log -message $_ -severity ERROR
            Write-Host "Error: Please try command again" -BackgroundColor Red
        } 
        

    }

    process{
        
        foreach ($file in $files){
            try{
                switch ($file.Extension) {
                    ".txt" {
                        Move-Item -Path $file.FullName -Destination $txtFiles -Force -ErrorVariable myError -ErrorAction SilentlyContinue
                        $count++
                    }
                    ".pdf" {
                        Move-Item -Path $file.FullName -Destination $pdfFiles -Force -ErrorVariable myError -ErrorAction SilentlyContinue
                        $count++
                    }
                    ".docx" {
                        Move-Item -Path $file.FullName -Destination $wordFiles -Force -ErrorVariable myError -ErrorAction SilentlyContinue
                        $count++
                    
                    }
                    ".xlsx" {
                        Move-Item -Path $file.FullName -Destination $excelFiles -Force -ErrorVariable myError -ErrorAction SilentlyContinue
                        $count++
                    }
                    default {}
                }
                if ($myError) {
                    $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - ERROR: $myError"
                    write-Log -message $logMessage -severity WARNING
                }
                $myError = false
            }catch{
                write-Log -message $_ -severity ERROR
            }
        }
                    try{
                $folders = Get-ChildItem -Path $filePath -Directory -ErrorAction Stop
                foreach($folder in $folders){
                    if ((Get-ChildItem -path $folder.FullName -force).Count -eq 0){
                        remove-item -Path $folder.FullName 
                        Write-Host "Removed empty folder: $($folder.FullName)"
                        write-Log -message "Removed empty folder: $($folder.FullName)" -severity INFO
                    }
                }
            }catch{
                write-Log -message $_ -severity ERROR
            }
    }
}