$vms = @()
$collection = @()
$User = "root"
$OldPassword = ""
$VMGroup = 111
$ViServerIP = "1.1.1.1"
$File = "C:\Temp\result.csv"
$Passlength = 8 

#Generate Password
function GeneratePass(){
$password=-join ("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz".tochararray() | ForEach-Object {[char]$_} | Get-Random -Count $Passlength)
if($password -match '\d'){
return $password
}
else{
GeneratePass
}
}


#Generate collection for CSV
Connect-VIServer  $ViServerIP -Credential (Get-Credential) 
Get-vm $VMGroup* | % {$vms += New-Object psobject -Property @{VM=$_.Name;IP=$_.Guest.IPAddress[0]}}
$vms | % {$collection += New-Object psobject -Property @{VM=$_.VM;IP=$_.IP;User="root";Password=GeneratePass; Compettitor=""}}
Disconnect-VIServer * -Confirm:$false

#Change password
$collection | % {
Connect-VIServer $_.IP -User $User -Password $OldPassword
Set-VMHostAccount -Password $_.Password -UserAccount root
Disconnect-VIServer $_.IP -Confirm:$false
}

#Export
$collection | Export-Csv -Path $File -NoTypeInformation
