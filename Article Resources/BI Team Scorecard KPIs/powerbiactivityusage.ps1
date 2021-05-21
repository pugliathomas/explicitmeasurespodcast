Login-PowerBI
## $a is the starting Day. Start with the you want it run and subtract 1
$a = 17
Do {
    "Starting Run $a"
    $a
    $a++
    $ab = "{0:00}" -f $a
    "Running Day $a"
    $daytype = "$ab"

    ## Update monthly the 05 for start date for the current month
    $startdate = '2021-05-' + $daytype + 'T00:00:00'

    ## Update monthly the 05 for end date for the current month
    $enddate = '2021-05-' + $daytype + 'T23:59:59'
    $activities = Get-PowerBIActivityEvent -StartDateTime $startdate -EndDateTime $enddate | ConvertFrom-Json

    ## Update the 05 with the current month
    $FileName = '2021' + '05' + $daytype + 'Export.csv'

    ## Add where you want the files to go
    $FolderLocation = 'C:\Users\tpuglia\PBIActivity\'
    $FullPath = Join-Path $FolderLocation $FileName
    $activities | Export-Csv -Path $FullPath -NoTypeInformation

    ## Change the number for what day of the month you want it to run until
} Until ($a -gt 19)