function Extract-Data{
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$MacTable,

        [Parameter(Mandatory=$true)]
        [string]$Leases,

        [Parameter(Mandatory=$true)]
        [string]$DestinationFolder,

        [Parameter(Mandatory=$true)]
        [string]$FileName
    )


#Vars
$result = @()

#Import
$MacFile = Import-Excel -Path $MacTable
$LeaseFile = Import-Excel -Path $Leases


#Parse
foreach($item in $LeaseFile){
    foreach($value  in $MacFile){
        if($item.Hostname -ne "" `
            -and ($item.'MAC-Address' -eq $value.'MAC-Address') `
            -and ($value.Interface -notlike '*Ethernet1/0/52*') `
            -and ($value.Interface -notlike '*Ethernet1/0/51*') `
            -and ($value.Interface -notlike '*Ethernet1/0/50*') `
            -and ($value.Interface -notlike '*Ethernet1/0/49*')){

            $obj = Select-Object @{n="Device";e={$value.Device}},@{n="Hostname";e={$item.Hostname}},@{n="Port";e={$value.Interface}},@{n="VLAN";e={$value.VLAN}}  -InputObject ''
            $result += $obj
        }
    }

}


#Export
$result | Export-Excel -Path $DestinationFolder\$FileName -AutoSize
}



