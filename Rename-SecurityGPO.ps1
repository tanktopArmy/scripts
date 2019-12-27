#Windows Manifest XML GPO Reader
#2019 tanktopLogger via tanktop.army or @tanktopLogger
#tanktop GitHub https://github.com/tanktopArmy

#this script's purpose is to pass the butter 
#the script can also rename GPOs provided by SCT and DOD that contain XML manifests
#it will iterate the XML file and rename the folder name based on its GPO ID

#region Credits
#I used the following articles for the basis of this script:
#https://stackoverflow.com/questions/38776341/need-help-to-get-xml-values-in-array-using-powershell
#https://community.spiceworks.com/topic/2207673-script-powershell-to-rename-files-names

#endregion


#region Setup
$GPOPath = Read-Host "Enter the path the to GPO Folder"
$folders = Get-ChildItem  -Path $GPOPath | Select-Object -ExpandProperty FullName

#setup XML
$manifestFullPath = Get-ChildItem -Path $GPOPath -Force | Where-Object {$_.Extension -eq ".xml"} | Select-Object -ExpandProperty FullName

[xml]$xml = Get-Content -Path $manifestFullPath
$xmlExpanded = $xml.DocumentElement.BackupInst

#endregion

#region Do Stuff

#create new array
$arr=@()

#loop through XMl and create array
$xmlExpanded | ForEach-Object {
    $arr += New-Object PSObject -Property  @{
        GPOID = $_.ID.InnerXML.Trim("<![CDATA[").TrimEnd("]]>");
        GPODisplayName = $_.GPODisplayName.InnerXML.Trim("<![CDATA[").TrimEnd("]]>")
    }
 }

foreach($GPO in $arr){
    foreach($folder in $folders){
        [string]$folderTrim = $folder.TrimStart("$GPOPath")
        if($GPO.GPOID -like $folderTrim){
            Write-Host "Renaming "$folderTrim""
            Rename-Item -Path $folder -NewName "$($GPO.GPODisplayName)" -Verbose
        }
    }
}

#endregion
