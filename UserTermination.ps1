Param (

    [Parameter(Mandatory=$true)][string]$UserPrincipalName,
    [Parameter(Mandatory=$true)][string]$Manager,
    [Parameter(Mandatory=$true)][string]$Credential

)

$Username = "itnow@peakliving.com"
$Pass = "$Credential"
$Password = $Pass | ConvertTo-SecureString -AsPlainText -Force
$UserCredential = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username,$Password
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session
Connect-MsolService -Credential $UserCredential

$FirstName = Get-MsolUser -UserPrincipalName $UserPrincipalName | select -ExpandProperty FirstName
$LastName = Get-MsolUser -UserPrincipalName $UserPrincipalName | select -ExpandProperty LastName
$NewUPN = $FirstName + $LastName + '.' + $UserPrincipalName
$NewPrimarySmtp = 'SMTP:' + $NewUPN
$OldPrimarySmtp = 'smtp:' + $UserPrincipalName
Write-Output $UserPrincipalName
Write-Output $NewUPN
Write-Output $OldPrimarySmtp

Set-MsolUserPrincipalName -UserPrincipalName $UserPrincipalName -NewUserPrincipalName $NewUPN
Set-Mailbox -Identity $UserPrincipalName -EmailAddress $NewPrimarySmtp -Type Shared -HiddenFromAddressListsEnabled $True

Start-Sleep 120

$UserPrincipalName = $NewUPN
$EmailAddresses = get-mailbox $UserPrincipalName | select -ExpandProperty emailaddresses
$EmailAddresses
$EmailAddresses | ForEach-Object{
    if ($_ -ne $NewPrimarySmtp)
    {
        Write-Output 'removing email address'
        Write-Output $_
        Set-Mailbox -Identity $UserPrincipalName -EmailAddresses @{remove=$_}
    }
    }

$Licenses = Get-MsolUser -UserPrincipalName $NewUPN | select -ExpandProperty licenses
$Licenses
$Licenses | ForEach-Object{
    Set-MsolUserLicense -UserPrincipalName $NewUPN -RemoveLicenses $_.AccountSkuId}

If ($Manager)
{
    Start-Sleep 5

    Set-Mailbox -Identity $Manager -EmailAddresses @{add=$OldPrimarySmtp}
}

Remove-PSSession $Session
