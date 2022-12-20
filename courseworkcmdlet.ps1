function Get-FileorDirectorySize($item){
if($item/1GB -ge 1){
$item = [string]([math]::round(($item/1GB),2)) + " GB"
}elseif($item/1MB -ge 1)
{$item = [string]([math]::round(($item/1MB),2)) + " MB"}
else{$item = [string]([math]::round(($item/1KB),2)) + " KB"}
return $item
}

function Count-FileExtensions($items){
ForEach ($item in $items){
    if($item.Extension -like ""){
        if(".dir"  -notin $filetypes.keys){
            $filetypes[".dir"] = 1 
        }else{
            $filetypes[".dir"] += 1}
    }
    elseif($item.Extension  -notin $filetypes.keys){
        $filetypes[$item.Extension] = 1 
    }else{
        $filetypes[$item.Extension] += 1
    }
}
return $filetypes
} 

function Get-DirectoryContent($items){
$array = @()
foreach ($name in $items){
    $innername = $name.name 
    $innerpath = ($path + "\${innername}")
    $innerpath = [string]$innerpath
    $itemsize = 0
    Get-ChildItem -Path $innerpath -Depth 1 -File  -ErrorAction SilentlyContinue -Force|ForEach {$itemsize += $_.Length}
    #$itemsize
    #$toout = $name.name + "${itemsize}"
    #$toout
    if($name.Extension -like ""){
    $extensionname = ".dir"
    }else{
    $extensionname = $name.Extension
    }
    $row = ""|Select Name, FileDirectoryExtension, FileDirectorySize
    $Row.Name = $name.name
    $Row.FileDirectoryExtension = $extensionname
    $Row.FileDirectorySize = Get-FileorDirectorySize($itemsize)
    $array += $Row
}
return $array
}


function global:Scan-UserFiles{
<#
 .SYNOPSIS
 Commandlet for scanning local user files and getting user files size
 .DESCRIPTION
 Commandlet allows user to get info about userfiles virtual size,
 get info about content of general user folder, similiar to command Get-ChildItem,
 get what extension files are in user files and amount of each extension type,
 and get info about general user folder items and sizes of them, that Get-ChildItem can't do.
 Every output is stored in C:\report.txt if none other report-file name is given.
 .EXAMPLE  
 PS C:\> Scan-UserFiles
 Outputs Usernames in C:\report.txt
 .EXAMPLE 
 PS C:\> Scan-UserFiles -FilePath C:\Users\admin\log.txt
 Outputs Usernames in C:\Users\admin\log.txt
 .EXAMPLE 
 PS C:\> Scan-UserFiles -UserFilesSize
 Outputs Usernames and userfiles size in C:\report.txt
 .EXAMPLE 
 PS C:\> Scan-UserFiles -GetUserFilesNames
 Outputs Usernames and user folder content in C:\report.txt
 .EXAMPLE 
 PS C:\> Scan-UserFiles -CountExtensions
 Outputs Usernames and user files extensions amount in C:\report.txt
 .EXAMPLE 
 PS C:\> Scan-UserFiles -GetUserFilesAndSizes
 Outputs Usernames and user folder items and sizes of every item in C:\report.txt
 .EXAMPLE 
 PS C:\> Scan-UserFiles -GetUserFilesNames -CountExtensions -FilePath C:\Users\admin\log.txt
 Outputs Usernames, user folder content and sizes of every item and user files extensions amount in C:\Users\admin\log.txt
 .NOTES
 -GetUserFilesAndSizes processes really long time due to scanning folders over and over, it can take up to 20 minutes to get the result.
#>

param(
[switch]$UserFilesSize,
[switch]$GetUserFilesNames,
[switch]$CountExtensions,
[switch]$GetUserFilesAndSizes,
[parameter(Mandatory =$false)]$FilePath
)

begin{
$name = "C:\users"
$starter = get-childitem -Path $name
if($Filepath -notmatch ".txt"){
$Filepath = "c:\report.txt"
}
Remove-Item $FilePath -ErrorAction SilentlyContinue
$count = 0
$executequeue = @(0,0,0,0,0)
$noParameterCheck = !($UserFilesSize -or $GetUserFilesNames -or $CountExtensions -or $GetUserFilesAndSizes)
$buffer = @($UserFilesSize,$GetUserFilesNames,$CountExtensions,$GetUserFilesAndSizes, $noParameterCheck)
for($num = 0; $num -le 5;$num++){
if($buffer[$num] -eq $true){
$executequeue[$num] = $num+1
}
}
}

process{
foreach($executecheck in $executequeue){

foreach ($directory in $starter){
#$debugoutuser = '("--"+$directory.name+" user files--").ToUpper()'
$outuser = '("--"+$directory.name+" user files--").ToUpper()|Out-File -FilePath $Filepath -Append'
$name = $directory.name
$path = ($first+"\${name}")
$path = [string]$path 
if($executecheck -eq 1){
Invoke-Expression $outuser
#Invoke-Expression $debugoutuser
$sum = 0
Get-ChildItem -Path $path -Depth 20 -File  -ErrorAction SilentlyContinue -Force|ForEach {$sum += $_.Length}
$size = Get-FileorDirectorySize($sum)
$size|Out-File -FilePath $FilePath -Append
#$size
""|Out-File -FilePath $FilePath -Append
}
if($executecheck -eq 2){
""|Out-File -FilePath $FilePath -Append
Invoke-Expression $outuser
$insideDir = ""
Get-ChildItem -Path $path -ErrorAction SilentlyContinue -Force|Format-Table LastWriteTime, Name|Out-File -FilePath $FilePath -Append
}
if($executecheck -eq 3){
Invoke-Expression $outuser
""|Out-File -FilePath $FilePath -Append
$filetypes = @{}
$items = Get-ChildItem -Path $path -Depth 20 -ErrorAction SilentlyContinue -Force
$out = Count-FileExtensions($items)
$out.GetEnumerator()|Sort-Object -property Value -Descending|Out-File -FilePath $FilePath -Append
}
if($executecheck -eq 4){
Invoke-Expression $outuser
""|Out-File -FilePath $FilePath -Append
$names = Get-ChildItem -Path $path -ErrorAction SilentlyContinue -Force
$array = Get-DirectoryContent($names)
$array|Out-File -FilePath $FilePath -Append
}
if($executecheck -eq 5){
Invoke-Expression $outuser
""|Out-File -FilePath $FilePath -Append
}
}}
Start-Process -FilePath $FilePath
}
}