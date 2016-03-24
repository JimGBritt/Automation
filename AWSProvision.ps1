#ToDO
#Change the default values for the following parameters if they do not match with yours:
#AWSRegion, EC2ImageName, MinCount, MaxCount,InstanceType
#Create an Azure Automation Asset called "AwsCred"
#Turn on Log verbose records and optionally Log progress records under the runbook settings to see verbose messages and progress

param (
    [Parameter(Mandatory=$true)]
    [string]$VMname,
    [ValidateNotNullOrEmpty()]
    [string]$AWSRegion = "us-west-2",
    [ValidateNotNullOrEmpty()]
    [string]$EC2ImageName = "WINDOWS_2012R2_BASE",
    [ValidateNotNullOrEmpty()]
    [string]$MinCount = 1,
    [ValidateNotNullOrEmpty()]
    [string]$MaxCount = 1,
    [ValidateNotNullOrEmpty()]
    [string]$InstanceType = "t2.micro"
    )

# Get credentials to authenticate against AWS
$AwsCredential = Get-AutomationPSCredential -Name "AwsCredential"
$AwsAccessKeyId = $AwsCredential.UserName
$AwsSecretKey = $AwsCredential.GetNetworkCredential().Password

# Set up the AWS environment
Write-Output "Authenticating against AWS..."
Set-AWSCredentials -AccessKey $AwsAccessKeyId -SecretKey $AwsSecretKey -StoreAs AWSProfile
Set-DefaultAWSRegion -Region $AWSRegion

Write-Output "Getting AWS Image..."
$ami = Get-EC2ImageByName $EC2ImageName -ProfileName AWSProfile -ErrorAction Stop

#Check if our AWS image is valid
If([string]::IsNullOrEmpty($ami)) {            
    throw "No Image has been found!"            
} else {            
    Write-Output ("The following image has been found: " + $ami.Name)            
}

#Creating new VM
Write-Output "Creating new AWS Instance..."
$NewVM = New-EC2Instance `
    -ImageId $ami.ImageId `
    -MinCount $MinCount `
    -MaxCount $MaxCount `
    -InstanceType $InstanceType `
    -ProfileName AWSProfile `
    -ErrorAction Stop
$InstanceID = $NewVM.Instances.InstanceID
$NewVM

#Applying VMName - also known as an AWS Tag
Write-Output "Applying new VM Name...."
New-EC2Tag -Resource $InstanceID -Tag @( @{ Key = "Name" ; Value = $VMname}) -ProfileName AWSProfile
Write-Output ("Successfully created AWS VM: " + $VMname)   
