#
# spmt-auto.ps1 is a script that automates the process
# of running migration jobs with the Sharepoint Migration Tool (SPMT)
#
# Created: 2022-10-12
# Created By: Michael Gupton
#

Import-Module Microsoft.SharePoint.MigrationTool.PowerShell

$SPCredential = Get-Credential -Message "Please enter Sharepoint Server credentials"
$SPOCredential = Get-Credential -Message "Please enter Sharepoint Online credentials"

# Register the SPMT session with SharePoint credentials
Register-SPMTMigration -SPOCredential $SPOCredential -Force -ScanOnly $false -AutomaticUserMapping $false

$jsonSettings = Get-Content -Raw -Path  "spmt-auto.json" | ConvertFrom-Json
ForEach ($taskItem in $jsonSettings.Tasks)
{
    if ($taskItem.RunMigration) {
        #
        # The RunMigration is used to indicate the task should be ran.
        # It's not an actual setting for the SPMT task,
        # so it gets removed. It is just a setting for
        # this script.
        #
        $taskItem.PSObject.Properties.Remove("RunMigration")
        $jsonTask = ConvertTo-Json $taskItem -Depth 100
        Add-SPMTTask -JsonDefinition $jsonTask -SharePointSourceCredential $SPCredential
        Write-Host $jsonTask
    }
}

Start-SPMTMigration
