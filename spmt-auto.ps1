#
# spmt-auto
#
# Created: 2022-10-12
# Created By: Michael Gupton
#
# spmt-auto.ps1 is a script that automates the process
# of running site migration jobs/tasks with the Sharepoint
# Migration Tool (SPMT).
#
# This script reads the file spmt-auto.json in the current directory
# that defines the tasks (sites that should be migrated) and the related
# migration settings.
# 
# A custom boolean setting is added to each Task item called RunMigration
# that is used to indicate whether the specific task should be ran.
# This is not a setting for SPMT, it's just a setting for the script.
# It provides the flexibility of being able to add many Tasks to the file,
# but only running the ones that are needed at a given time.
#
# Dependencies:
#
# The module Microsoft.SharePoint.MigrationTool.PowerShell that comes
# with SPMT.
#
#

Import-Module Microsoft.SharePoint.MigrationTool.PowerShell

$SPCredential = Get-Credential -Message "Please enter Sharepoint Server credentials"
$SPOCredential = Get-Credential -Message "Please enter Sharepoint Online credentials"

Register-SPMTMigration -SPOCredential $SPOCredential -Force

$jsonSettings = Get-Content -Raw -Path  "spmt-auto.json" | ConvertFrom-Json
foreach ($taskItem in $jsonSettings.Tasks)
{
    if ($taskItem.RunMigration) {
        #
        # The RunMigration setting is used to indicate the task should be ran.
        # It's not an actual setting for the SPMT tool,
        # so it gets removed once it's served its purpose.
        # It is just a setting for the logic of this script.
        #
        $taskItem.PSObject.Properties.Remove("RunMigration")
        $jsonTask = ConvertTo-Json $taskItem -Depth 100
        Add-SPMTTask -JsonDefinition $jsonTask -SharePointSourceCredential $SPCredential
    }
}

Start-SPMTMigration
Remove-SPMTTask -TaskId (Get-SPMTMigration).Id
