<#
All results captured will be dumped in a sepatate json file on the defined location in the script. The default location is c:\RefreshHistoryDump. 
For full details on the script and corresponding blogpost, please see: 
https://data-marc.com/2021/01/07/extract-refresh-metrics-for-your-entire-power-bi-workspace/
#>

# In case you do not have the PowerShell Cmdlets for Power BI installed yet, please uncomment below row and install the module first. 
# Install-Module -Name MicrosoftPowerBIMgmt

# =================================================================================================================================================
# Per One Workspace

# Define workspace to cature the results from - Find your Workspace ID in the URL
$WorkspaceId = ""
## Chose what to name the File
$WorkspaceName = ""


# Base API for Power BI REST API
$PbiRestApi = "https://api.powerbi.com/v1.0/myorg/"

# Export data parameters
$FolderName = "PBIRefresh"
$OutputLocation = "C:\Users\"
$DatePrefix = Get-Date -Format "yyyyMMdd_HHmm" 
$DefaultFilePath = $Fullpath + "\" + $DatePrefix + "_" + $WorkspaceName + "_"
# All exported files will be prefixed with above mentioned date and Workspace Id. 
# This allows you to run the script multiple times without overwriting history. 

# =================================================================================================================================================
# General tasks
# =================================================================================================================================================
# Sign in to the Power BI Service using OAuth
Write-Host -ForegroundColor White "Sign in to connect to the Power BI Service";
Connect-PowerBIServiceAccount

# Create folder to dump results
$Fullpath = $OutputLocation + $FolderName
if (-not (Test-Path $Fullpath)) {
    # Destination path does not exist, let's create it
    try {
        New-Item -Path $Fullpath -ItemType Directory -ErrorAction Stop
    }
    catch {
        throw "Could not create path '$Fullpath'!"
    }
}

# List all datasets in specified workspace
Write-Host "Collecting dataset metadata..."
$GetDatasetsApiCall = $PbiRestApi + "groups/" + $WorkspaceId + "/datasets"
$AllDatasets = Invoke-PowerBIRestMethod -Method GET -Url $GetDatasetsApiCall | ConvertFrom-Json
$ListAllDatasets = $AllDatasets.value

# Write dataset metadata json
$DatasetsMetadataOutputLocation = $DefaultFilePath + 'DatasetsMetadata.json'
$ListAllDatasets | ConvertTo-Json  | Out-File $DatasetsMetadataOutputLocation -ErrorAction Stop
Write-Host "Dataset metadata saved on defined location" -ForegroundColor Green

# Function to get dataset refresh results
Function GetDatasetRefreshResults {
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true)][string]$DatasetID
    )
    Write-Host "Collecting dataset refresh history..." $DatasetId
    $GetDatasetRefreshHistory = $PbiRestApi + "groups/" + $WorkspaceId + "/datasets/" + $DatasetId + "/refreshes"
    $DatasetRefreshHistory = Invoke-PowerBIRestMethod -Method GET -Url $GetDatasetRefreshHistory | ConvertFrom-Json
    return $DatasetRefreshHistory.value
}

# Create empty json array
$DatasetResults = @()

# Get refresh history for each dataset in defined workspace
foreach ($Dataset in $ListAllDatasets) {
    $DatasetHistories = GetDatasetRefreshResults -DatasetId $Dataset.id
    foreach ($DatasetHistory in $DatasetHistories) {
        Add-Member -InputObject $DatasetHistory -NotePropertyName 'DatasetId' -NotePropertyValue $Dataset.id
        $DatasetResults += $DatasetHistory
    }
}

# Write dataset refresh history json to output location
$DatasetRefreshOutputLocation = $DefaultFilePath + 'DatasetRefreshHistory.json'
$DatasetResults  | ConvertTo-Json  | Out-File $DatasetRefreshOutputLocation -ErrorAction Stop
