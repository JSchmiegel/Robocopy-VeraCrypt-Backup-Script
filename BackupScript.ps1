#Parameters:
param([string]$pathconf)
Get-Content $pathconf | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }
$sourcelocation = $h.Get_Item("confSourceLocation")
$backuplocation = $h.Get_Item("confBackupLocation")
$logpath = $h.Get_Item("confLogPath")
$silentlyEndScript = $h.Get_Item("confSilentlyEndScript")
if($silentlyEndScript -eq "true"){
	$silentlyEndScript = $true
}
$deleteOldLogs = $h.Get_Item("confDeleteOldLogs")
if($silentlyEndScript -eq "true"){
	$silentlyEndScript = $true
}

$veraCryptBackup = $h.Get_Item("confVeraCryptBackup")
if($silentlyEndScript -eq "true"){
	$silentlyEndScript = $true
}
$veraCryptSource = $h.Get_Item("confVeraCryptSource")


$date = Get-Date -UFormat "%Y%m%d"
$lastbackuplocation = $backuplocation + $date

function robocopygeneral($sourcepath, $destinationpath) 
{
	$sourcename = $($sourcelocation.Replace("\","")).Replace(":","")
	$backupname = $($backuplocation.Replace("\","")).Replace(":","")
	$logpath = $($logpath + $date + "Backup(" + $sourcename + "to" + $backupname + ").log")
    robocopy $sourcepath $destinationpath /MIR /Z /MT:16 /Log:$logpath /NP /TEE
}

function decryptVeraCrypt ($veraCryptSource, $backuplocation){
	$veraCryptLetter = $($backuplocation.Replace("\","")).Replace(":","")
	#opens VeraCrypt Window
	C:\Instanzen\VeraCrypt\VeraCrypt.exe /quit /volume $veraCryptSource /letter $veraCryptLetter
	#wait until volume is decrypted
	Write-Host "Waiting for the decryption of a VeraCrypt volume ..."
	while(!(Test-Path $backuplocation)){
    	Start-Sleep -Milliseconds 50
	}
}

#MAIN
if($veraCryptBackup -and !(Test-Path $backuplocation))
{
	decryptVeraCrypt $veraCryptSource $backuplocation
}

if (Test-Path $backuplocation){
	Write-Host ""
	Write-Host "Today is the: " $($date[6] + $date[7] + "." + $date[4] + $date[5] + "." + $date[0] + $date[1] + $date[2] + $date[3])
	Write-Host ""
	try
	{
		Write-Host "The following backups exist on" $backuplocation":"
		$folders = Get-ChildItem $backuplocation| Sort-Object LastWriteTime -Descending
		
		#get counters
		$counteryear = 0
		$contermonth = 0
		foreach ($folder in $folders) {
			if($folder -like $($date[0] + $date[1] + $date[2] + $date[3] + "*"))
			{
				$counteryear++
			}
			if($folder -like $($date[0] + $date[1] + $date[2] + $date[3] + $date[4] + $date[5] + "*"))
			{
				$countermonth++
			}
		}
	}catch #first backup
	{
		Write-Host "There were no backups."
		Write-Host "This is the first backup."
	}
	
	#Ensure that there are only three backups of this month
	if($counteryear -gt 3){
		Remove-Item -path $($backuplocation + "\" + $folders[3])  
	}
	foreach ($folder in $folders) 
	{
		Write-Host $folder
	}

	#decide if full or diff
	if($countermonth -eq 1)
	{
		Write-Host "Do a differential backup"
		$Stopwatch = New-Object System.Diagnostics.Stopwatch
		$Stopwatch.Start()
		
		$lastbackuplocation = $backuplocation + $folders[0]
		
		robocopygeneral $sourcelocation $lastbackuplocation
		
		
		if ($lastbackuplocation -eq $($backuplocation + $date)){
			Write-Host "No name changes, because there was a backup of today"
		}else{
			Rename-Item -Path $lastbackuplocation -NewName $date
		}

	}elseif($contermonth -eq 0)
	{
		Write-Host "Do a full backup"
		$Stopwatch = New-Object System.Diagnostics.Stopwatch
		$Stopwatch.Start()

		#deleting old logs
		if($deleteOldLogs)
		{
			Remove-Item -path $($logpath + "*") -recurse
		}

		robocopygeneral $sourcelocation $lastbackuplocation
	}else
	{
		Write-Host "Error: Wasn't able to automatically choose what to do."
	}

}else 
{
	$volumes = @(Get-Volume | ForEach-Object {$_.DriveLetter})
	Write-Host "Volume" $backuplocation "does not exist."
	Write-Host "Existing Volumes are:"
	foreach ($volume in $volumes) {
		Write-Host $volume
	}
}

#encrypt VeraCrypt container/volume again
$veraCryptLetter = $($backuplocation.Replace("\","")).Replace(":","")
C:\Instanzen\VeraCrypt\VeraCrypt.exe /q /d $veraCryptLetter

if(!$silentlyendScript)
{
	Read-Host "Please enter a key to end the script"
}