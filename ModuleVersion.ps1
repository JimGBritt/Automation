#Defined parameters for template
param
	(
	    [ValidateNotNullOrEmpty()]
	    [string]$AutomationAccountName = "AzureAutoEast",
		[ValidateNotNullOrEmpty()]
	    [string]$ResourceGroupName = "OaaSCSMADSF7K6DN7E6TOLTJCJKYN4K3XUHJTZI7FZG5LBBNSNSVLZ4USA-East-US"
    )

<#
Authenticate to Azure with SPN section
#>
$SPAppID = Get-AutomationVariable -Name "ApplicationID"
$TenantID = Get-AutomationVariable -Name "SPCertTenant"
$Certificate = Get-AutomationCertificate -Name "SPNAppCert"
$CertThumbprint = ($Certificate.Thumbprint).ToString()
$SubID = Get-AutomationVariable -Name "AzureSubscription"    

"Tenant ID is $TenantID"     
if ((Test-Path Cert:\CurrentUser\My\$CertThumbprint) -eq $false)
{
	"Installing the Service Principal's certificate..."
    $store = new-object System.Security.Cryptography.X509Certificates.X509Store("My", "CurrentUser") 
    $store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
    $store.Add($Certificate) 
    $store.Close() 
}

"Logging in to Azure..."

Login-AzureRmAccount -ServicePrincipal -TenantId $TenantID -CertificateThumbprint $CertThumbprint -ApplicationId $SPAppID 

"Selecting Azure subscription..."
$SubScription = Select-AzureRmSubscription -SubscriptionID $SubID -TenantId $TenantID

$ModulesOutput = Get-AzureRmAutomationModule -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName | Where-Object{$_.Name -like "*Azure*"} #|Select Name, ISGlobal, Version | Sort-Object -Property ISGlobal

foreach ($Module in $ModulesOutput)
{
     $ReturnMod = Get-AzureRmAutomationModule -Name $Module.Name -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName
     $ReturnMod.Name
     $ReturnMod.Version
     ""
}