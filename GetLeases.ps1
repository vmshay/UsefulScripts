function Get-Lease{

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Login,

        [Parameter(Mandatory=$true)]
        [string]$Password,

        [Parameter(Mandatory=$true)]
        [string]$IP,

        [Parameter(Mandatory=$true)]
        [string]$Port,

        [Parameter(Mandatory=$true)]
        [string]$DestinationFolder,

        [Parameter(Mandatory=$true)]
        [string]$FileName,

        [Parameter(Mandatory=$false)]
        [bool]$remove=$false

    )

#make creds
$Credential = New-Object System.Management.Automation.PSCredential ($Login, (ConvertTo-SecureString $Password -AsPlainText -Force))


#Make SSH/SFTP connect
$ssh = New-SSHSession -Credential $Credential -ComputerName $IP -Port $Port -AcceptKey:$true
$sftp = New-SFTPSession -Credential $Credential -ComputerName $IP -Port $Port -AcceptKey:$true

#Make & download file
Invoke-SSHCommand -Command " /ip dhcp-server lease print terse file=leases.txt" -SSHSession $ssh
Get-SFTPItem -SFTPSession $sftp -Path leases.txt -Destination $DestinationFolder -Force

#Disconnect
Remove-SFTPSession -SFTPSession $sftp -InformationAction SilentlyContinue
Remove-SSHSession -SSHSession $ssh -InformationAction SilentlyContinue

#Parse lease file to object
$leases = @()
$file = Get-Content $DestinationFolder\leases.txt
$file = $file -split '\n'

for($i = 0; $i -lt $file.Length;$i++){
    $tmp = $file[$i] -split " "
    foreach($val in $tmp){
        if($val -like "mac-address=*"){$mac = $val -replace "mac-address=","" -replace ":","-"}
        elseif($val -like "host-name=*"){$name = $val -replace "host-name=",""}
        elseif($val -like "address=*"){$ip = $val -replace "address=",""}
        }
    $obj = Select-Object @{n='Hostname';e={"$name"}},`
                         @{n='MAC-Address';e={"$mac"}},`
                         @{n='IP';e={"$ip"}} -InputObject ''
    $leases += $obj

    $mac = ""
    $name = ""
    $ip = ""
}

#Remove lease file
if($remove -eq $true){
    rm $DestinationFolder\leases.txt
}

#Export leases to xlsx
if(Test-Path $DestinationFolder\$FileName){
    rm -Path $DestinationFolder\$FileName
    $leases | Export-Excel -Path $DestinationFolder\$FileName -AutoSize
    }
else{
    $leases | Export-Excel -Path $DestinationFolder\$FileName -AutoSize
}
}
