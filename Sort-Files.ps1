<#
 .Synopsis
  Sort files in directory on extension.
 .Description
  Сreates the _SORT folder in the selected
  directory and sorts all files by extension
  into the corresponding directory in _SORT.
 .Parameter Directory
  Directory to sort.
 .Example
   # Sort C:\Temp\.
   Sort-Files -Directory C:\Temp\
#>



function Sort-Files
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True)]
        [string]$Directory)
    $files = dir $Directory

    if(!(Test-Path -Path $Directory\_SORT)){mkdir $Directory\_SORT}
    cd $Directory\_SORT

    $extensions = $files | foreach {
        if(($_.Extension -ne "") -and !$_.Mode.StartsWith('d')){
            ($_.Extension).Trim('.')          
        }
    }

    $extensions = $extensions | select -Unique
    $extensions | foreach {if(!(Test-Path -Path $Directory\_SORT\$_)){mkdir $directory\_SORT\$_}}

    0..($files.Length-1) | foreach {
        if(($files[$_].Extension -ne "") -and (!$files[$_].Mode.StartsWith('d'))){
            move $files[$_].FullName ($Directory + "\_SORT\" + ($files[$_].Extension.Trim('.'))).ToString() -Force
        }
    }
}
