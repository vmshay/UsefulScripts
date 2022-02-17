$Fail=0;
$count = 0;
While($true)
{
[string]$URI = (48..57) + (97..122) | Get-random -Count 5 | foreach{[char[]]$_}
$URI = $URI.Replace(" ","")
Try {wget -Uri (curl https://prnt.sc/$URI).Images[0].src -OutFile "F:\prtscr\$URI.jpg"}
Catch { $Fail += 1;}
$URI
}
