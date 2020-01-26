#Parameters:
$sourcelocation = "J:\"
$backuplocation = "W:\"
$logpath = "J:\000Logs\"
$silentlyEndScript = $true
$deleteOldLogs = $true

$veraCryptBackup = $false
$veraCryptSource = "C:\Users\Test\Downloads\page2.backup"


$date = Get-Date -UFormat "%Y%m%d"
$lastbackuplocation = $backuplocation + $date

function robocopygeneral($sourcepath, $destinationpath) 
{
	$sourcename = $($sourcelocation.Replace("\","")).Replace(":","")
	$backupname = $($backuplocation.Replace("\","")).Replace(":","")
	$logpath = $($logpath + $date + "Backup(" + $sourcename + "to" + $backupname + ").log")
    robocopy $sourcepath $destinationpath /MIR /Z /MT:16 /Log:$logpath /NP /TEE
}

function getvalideInput ($inputmessage, $ControllRegex) 
{
	$invalidInput = $true
	while ($invalidInput) {
		$input = Read-Host -Prompt $inputmessage
		try
		{
			$input.ToLower
		}catch{}
		if ($input -match $ControllRegex) 
		{
			$invalidInput = $false
		}else
		{
			Write-Host "Please make a valide choice!"
		}
	}
	return $input
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
if($veraCryptBackup)
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
		
		foreach ($folder in $folders) {
			Write-Host $folder
		}
	}catch #first backup
	{
		Write-Host "There were no backups."
		Write-Host "This is the first backup."
	}
	
	$loop = $true
	while ($loop){
		Write-Host "_______________________________________________________________"
		Write-Host "Choose if you want to do a full backup or a differential backup."
		Write-Host "[If you need help: HELP | To exit: EXIT | To list" $sourcelocation": LIST ]" 
		#| To choose specific folder e.g.: FULL 001 or 200
		$input = getvalideInput "FULL or DIFF" "full|diff|help|exit|list"
		Write-Host ""
		
		#FULL
		if ($input -eq "full")
		{
			$loop = $false #ending of while loop
			
			$Stopwatch = New-Object System.Diagnostics.Stopwatch
			$Stopwatch.Start()

			#deleting old logs
			if($deleteOldLogs)
			{
				Remove-Item -path $($logpath + "*") -recurse
			}

            robocopygeneral $sourcelocation $lastbackuplocation
		}
		#DIFF
		elseif ($input -eq "diff")
		{
			$loop = $false

			$Stopwatch = New-Object System.Diagnostics.Stopwatch
			$Stopwatch.Start()
			
			$lastbackuplocation = $backuplocation + $folders[0]
			
			robocopygeneral $sourcelocation $lastbackuplocation
			
			
			if ($lastbackuplocation -eq $($backuplocation + $date)){
				Write-Host "No name changes, because there was a backup of today"
			}else{
				Rename-Item -Path $lastbackuplocation -NewName $date
			}
			
			#displayStopWatch
			
		
		}#HELP
		elseif ($input -eq "help")
		{
			$loop = $true
			Write-Host "FULL: A full backup means that " + $sourcepath + " gets a new backup folder in " + $backuplocation
			Write-Host "DIFF: A differential backup means that " + $sourcepath + " get only mirrowed to the last backup folder in W:\"
		
		
		}#Liste
		elseif ($input -eq "list")
		{
			$loop = $true
			$folders = Get-ChildItem $sourcelocation | Sort-Object LastWriteTime -Descending
			Write-Host "The following folders exist in" $sourcelocation
			foreach ($folder in $folders) {
				Write-Host $folder
			}
		
		}#CANCEL
		elseif ($input -eq "exit")
		{
			$loop = $false
		}
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

if(!$silentlyendScript)
{
	Read-Host "Please enter a key to end the script"
}