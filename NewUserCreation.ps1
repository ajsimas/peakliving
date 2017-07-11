﻿#Connect to Office 365 and Exchange Online

Set-ExecutionPolicy RemoteSigned
$Username = "itnow@peakliving.com"
$Pass = "$Credential"
$Password = $Pass|ConvertTo-SecureString -AsPlainText -Force
$UserCredential = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username,$Password
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session
Connect-MsolService -Credential $UserCredential

$FirstName = Read-Host -Prompt 'First Name'
$LastName = Read-Host -Prompt 'Last Name'
$Department = Read-Host -Prompt 'Property'
$Title = Read-Host -Prompt 'Title'
$UserPrincipalName = Read-Host -Prompt 'Email Address'

$DisplayName = $FirstName + ' ' + $LastName

New-MsolUser -FirstName $FirstName -LastName $LastName -DisplayName $DisplayName -UserPrincipalName $UserPrincipalName -Password 'Changeme1' -UsageLocation US -Department $Department -Title $Title -LicenseAssignment PeakCapitalPartners:O365_BUSINESS_PREMIUM

Remove-PSSession $Session