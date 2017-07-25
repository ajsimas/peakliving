param (
  [Parameter(Mandatory=$true)][string]$FirstName,
  [Parameter(Mandatory=$true)][string]$LastName,
  [Parameter(Mandatory=$true)][string]$Department,
  [Parameter(Mandatory=$true)][string]$Title,
  [Parameter(Mandatory=$true)][string]$UserPrincipalName,
  [Parameter(Mandatory=$true)][string]$Credential
 )

#Connect to Office 365 and Exchange Online

$Username = "itnow@peakliving.com"
$Pass = "$Credential"
$Password = $Pass|ConvertTo-SecureString -AsPlainText -Force
$UserCredential = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username,$Password
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session
Connect-MsolService -Credential $UserCredential

$AliasOwner = get-mailbox | where emailaddresses -like smtp:$UserPrincipalName

If ($AliasOwner){
    Set-Mailbox -Identity $AliasOwner -EmailAddresses @{remove=smtp:$UserPrincipalName}
    }

$DisplayName = $FirstName + ' ' + $LastName

If ($Title -eq "Service Manager"){
    New-MsolUser -FirstName $FirstName -LastName $LastName -DisplayName $DisplayName -UserPrincipalName $UserPrincipalName -Password 'Changeme1' -UsageLocation US -Department $Department -Title $Title -LicenseAssignment PeakCapitalPartners:EXCHANGESTANDARD
}

Else {
    New-MsolUser -FirstName $FirstName -LastName $LastName -DisplayName $DisplayName -UserPrincipalName $UserPrincipalName -Password 'Changeme1' -UsageLocation US -Department $Department -Title $Title -LicenseAssignment PeakCapitalPartners:O365_BUSINESS_PREMIUM
}

Remove-PSSession $Session
