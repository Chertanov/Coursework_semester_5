Add-Type -assembly System.Windows.Forms

$name = "C:\users"
$starter = get-childitem -Path $name


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
    Get-ChildItem -Path $innerpath -Depth 20 -File  -ErrorAction SilentlyContinue -Force|ForEach {$itemsize += $_.Length}
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


function Get-UsersSize{

$progressbar.Maximum = $starter.Count;
$progressbar.Step = 1;
$progressbar.Value = 0;


$textBoxDisplay.Text = ""
foreach ($directory in $starter){
$outuser = ("--"+$directory.name+" user files--").ToUpper()
$name = $directory.name
$path = ($first+"\${name}")
$path = [string]$path 
$textBoxDisplay.Text = $textBoxDisplay.Text + ("--"+$outuser+" user files--"+ [Environment]::NewLine)
$sum = 0
Get-ChildItem -Path $path -Depth 20 -File  -ErrorAction SilentlyContinue -Force|ForEach {$sum += $_.Length}
$size = Get-FileorDirectorySize($sum)
$textBoxDisplay.Text = $textBoxDisplay.Text + ($size.ToString()+ [Environment]::NewLine)
$progressbar.PerformStep();
}

}


function Get-CountUsersExtensions{
$progressbar.Maximum = $starter.Count;
$progressbar.Step = 1;
$progressbar.Value = 0;

$textBoxDisplay.Text = ""
foreach ($directory in $starter){
$outuser = ("--"+$directory.name+" user files--").ToUpper()
$name = $directory.name
$path = ($first+"\${name}")
$path = [string]$path 
$textBoxDisplay.Text = $textBoxDisplay.Text + ("--"+$outuser+" user files--"+ [Environment]::NewLine)

$filetypes=@{}
$items = Get-ChildItem -Path $path -Depth 20 -ErrorAction SilentlyContinue -Force
$out = Count-FileExtensions($items)
$output = $out.GetEnumerator()|Sort-Object -property Value -Descending|Select Value,Name|Out-String

$textBoxDisplay.Text = $textBoxDisplay.Text + ($output+ [Environment]::NewLine)

$progressbar.PerformStep();
}
}


function Get-UsersFiles{
$textBoxDisplay.Text = ""
$progressbar.Maximum = $starter.Count;
$progressbar.Step = 1;
$progressbar.Value = 0;
foreach ($directory in $starter){
$outuser = ("--"+$directory.name+" user files--").ToUpper()
$name = $directory.name
$path = ($first+"\${name}")
$path = [string]$path 
$textBoxDisplay.Text = $textBoxDisplay.Text + ("--"+$outuser+" user files--"+ [Environment]::NewLine)
$insideDir = ""
$output = Get-ChildItem -Path $path -ErrorAction SilentlyContinue -Force|Select Name|Out-String 
$textBoxDisplay.Text = $textBoxDisplay.Text + ("ok"+ [Environment]::NewLine)
$textBoxDisplay.Text = $textBoxDisplay.Text + ($output+ [Environment]::NewLine)
$progressbar.PerformStep();
}
}


function Get-FolderSize{
$textBoxDisplay.Text = ""
$progressbar.Maximum = $starter.Count;
$progressbar.Step = 1;
$progressbar.Value = 0;
$counter = 5
foreach ($directory in $starter){
$counter -= 1
if ($counter -gt 0){
$outuser = ("--"+$directory.name+" user files--").ToUpper()
$name = $directory.name
$path = ($first+"\${name}")
$path = [string]$path 
$textBoxDisplay.Text = $textBoxDisplay.Text + ("--"+$outuser+" user files--"+ [Environment]::NewLine)


$names = Get-ChildItem -Path $path -ErrorAction SilentlyContinue -Force
$output = Get-DirectoryContent($names)|Format-List Name,FileDirectoryExtension, FileDirectorySize |Out-String
$textBoxDisplay.Text = $textBoxDisplay.Text + ($output+ [Environment]::NewLine)
$progressbar.PerformStep();
}}}



$ProgressBar = New-Object System.Windows.Forms.ProgressBar
$ProgressBar.Location = "250, 20"
$ProgressBar.Size = "650, 30"

$textBoxDisplay = New-Object System.Windows.Forms.TextBox
$textBoxDisplay.Location = '250, 50'
$textBoxDisplay.Multiline = $true
$textBoxDisplay.Name = "textBoxDisplay"
$textBoxDisplay.Size = '650, 350'
$textBoxDisplay.Scrollbars = "Both" 
$textBoxDisplay.TabIndex = 1
$textBoxDisplay.Readonly = $true

$Size_button = New-object System.windows.forms.button
$Size_button.text = "Get userfiles size"
$Size_button.location = '40,50'
$Size_button.size = '200,40'
$Size_button.Add_Click({Get-UsersSize})

$GetUserFiles_button = New-object System.windows.forms.button
$GetUserFiles_button.text = "Get userfolder content"
$GetUserFiles_button.location = '40,100'
$GetUserFiles_button.size = '200,40'
$GetUserFiles_button.Add_Click({Get-UsersFiles})

$CountExtensions_button = New-object System.windows.forms.button
$CountExtensions_button.text = "Count extensions"
$CountExtensions_button.location = '40,150'
$CountExtensions_button.size = '200,40'
$CountExtensions_button.Add_Click({Get-CountUsersExtensions})

$GetFolderSize_button = New-object System.windows.forms.button
$GetFolderSize_button.text = "Get userfolders size"
$GetFolderSize_button.location = '40,200'
$GetFolderSize_button.size = '200,40'
$GetFolderSize_button.Add_Click({Get-FolderSize})

$Label = New-Object System.Windows.Forms.Label
$Label.Location = "60, 20"
$Label.Size = "200, 40"
$Label.Text = "Choose option to analyze"

$main_form = New-Object System.Windows.Forms.Form
$main_form.Text ='User file scanner'
$main_form.Width = 900
$main_form.Height = 400
$main_form.AutoSize = $true
$main_form.Controls.Add($textBoxDisplay)
$main_form.Controls.Add($Size_button)
$main_form.Controls.Add($CountExtensions_button)
$main_form.Controls.Add($GetUserFiles_button)
$main_form.Controls.Add($GetFolderSize_button)
$main_form.Controls.Add($ProgressBar);
$main_form.Controls.Add($Label);
$main_form.ShowDialog()