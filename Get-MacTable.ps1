function Get-MacTable{
    
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
        [bool]$remove=$false,

        [Parameter(Mandatory=$false)]
        [bool]$SingleFile
    )

#Vars
$result = @()


#Build credential
$Credential = New-Object System.Management.Automation.PSCredential ($Login,(ConvertTo-SecureString $Password -AsPlainText -Force))


#SSH#
$Session = New-SSHSession -Credential $Credential -ComputerName $IP -Port $Port -AcceptKey:$true
$response = (Invoke-SSHCommand -SSHSession $Session -Command "sh mac-address-table").Output
Remove-SSHSession -SSHSession $Session



$device = $response[0] -replace ">sh mac-address-table"

for($i = 4; $i -lt $response.Length-1;$i++){
    $vlan = ($response[$i] -split " " | ? {$_})[0]
    $MAC = ($response[$i] -split " " | ? {$_})[1]
    $Interface = ($response[$i] -split " " | ? {$_})[4]
    $obj = Select-Object @{n='Device';e={"$device"}},@{n='VLAN';e={"$vlan"}},@{n='MAC-Address';e={"$MAC"}},@{n='Interface';e={"$Interface"}} -InputObject ''
    $result += $obj
}


if((Test-Path $DestinationFolder\$FileName) -and !$SingleFile){
    rm -Path $DestinationFolder\$FileName
    $result | Export-Excel -Path $DestinationFolder\$FileName -AutoSize
    }
elseif($SingleFile){
    $result | Export-Excel -Path $DestinationFolder\$FileName -AutoSize -Append
    }
else{
    $result | Export-Excel -Path $DestinationFolder\$FileName -AutoSize
    }
}




