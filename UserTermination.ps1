Set-ExecutionPolicy RemoteSigned
$Username = "itnow@peakliving.com"
$Pass = "$Credential"
$Password = $Pass | ConvertTo-SecureString -AsPlainText -Force
$UserCredential = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username,$Password
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session
Connect-MsolService -Credential $UserCredential

Import-Csv C:\scripts\ToBeTerminated.csv | ForEach-Object{
    $FirstName = Get-MsolUser -UserPrincipalName $_.UserPrincipalName | select -ExpandProperty FirstName
    $LastName = Get-MsolUser -UserPrincipalName $_.UserPrincipalName | select -ExpandProperty LastName
    $NewUPN = $FirstName + $LastName + '.' + $_.UserPrincipalName
    $NewPrimarySmtp = 'SMTP:' + $NewUPN
    $Forward = $_.Forward
    $OldPrimarySmtp = 'smtp:' + $_.UserPrincipalName
    Write-Output $_.UserPrincipalName
    Write-Output $NewUPN
    Write-Output $OldPrimarySmtp
    
    Set-MsolUserPrincipalName -UserPrincipalName $_.UserPrincipalName -NewUserPrincipalName $NewUPN
    Set-Mailbox -Identity $_.UserPrincipalName -EmailAddress $NewPrimarySmtp -Type Shared -HiddenFromAddressListsEnabled $True
    
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
    
    If ($Forward)
    {
        Start-Sleep 5

        Set-Mailbox -Identity $Forward -EmailAddresses @{add=$OldPrimarySmtp}
    }
    }

Remove-PSSession $Session