#param
#(
#	$value
#)

#$ReturnValue = .\bar.ps1 -Variable $Value
#$ReturnValue

#$ErrorActionPreference = "Stop"
#$test = Get-blah
#$PSPrivateMetadata.jobid

#region Login to Azure account and select the subscription.
#Authenticate to Azure with SPN section
"Logging in to Azure..."
$Conn = Get-AutomationConnection -Name AzureRunAsConnection 
 Add-AzureRMAccount -ServicePrincipal -Tenant $Conn.TenantID `
 -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint

"Selecting Azure subscription..."
Select-AzureRmSubscription -SubscriptionId $Conn.SubscriptionID -TenantId $Conn.tenantid 
#endregion

$AAResourceGroup = "OaaSCSMADSF7K6DN7E6TOLTJCJKYN4K3XUHJTZI7FZG5LBBNSNSVLZ4USA-East-US"
$AAAccount = "AzureAutoEast"

$jobID = $PSPrivateMetadata.JobId.Guid
#write-output $psprivatemetadata.jobid

$Job = Get-AzureRmAutomationJob -ResourceGroupName $AAResourceGroup -AutomationAccountName $AAAccount -id $jobID  
$RunbookName = $Job.RunbookName

[int]$RunFrequency = 300
$ScheduleName = $RunbookName

$ErrorActionPreference = "SilentlyContinue"
#$ScheduleDetails = Get-AzureRmAutomationSchedule -ResourceGroupName $AAResourceGroup -AutomationAccountName $AAAccount -Name $ScheduleName 
$RemoveExistingSchedule = Remove-AzureRmAutomationSchedule -Name $ScheduleName -ResourceGroupName $AAResourceGroup -AutomationAccountName $AAAccount -Force | Out-Null


$RunbookStartTime = $([DateTime]::Now.Add([TimeSpan]::FromSeconds($RunFrequency+1)))
$Schedule = New-AzureRmAutomationSchedule -Name $ScheduleName -StartTime $RunbookStartTime -OneTime -AutomationAccountName $AAAccount -ResourceGroupName $AAResourceGroup
#$ScheduleSet = Set-AzureRmAutomationSchedule -Name "Test2" -AutomationAccountName "AzureAutoEast" -ResourceGroupName "OaaSCSMADSF7K6DN7E6TOLTJCJKYN4K3XUHJTZI7FZG5LBBNSNSVLZ4USA-East-US" -IsEnabled $true
#Get-AzureRmAutomationSchedule -Name "Test2" -AutomationAccountName "AzureAutoEast" -ResourceGroupName "OaaSCSMADSF7K6DN7E6TOLTJCJKYN4K3XUHJTZI7FZG5LBBNSNSVLZ4USA-East-US"
$Sch = Register-AzureRmAutomationScheduledRunbook -RunbookName $RunbookName -AutomationAccountName $AAAccount -ResourceGroupName $AAResourceGroup -ScheduleName $ScheduleName

#Finish up with a sleep for 10 mins
Write-output "Next run $RunbookStartTime"
