# Repository 
Script for a basic Robocopy Backup.

## How to use?
This scripts performes on the base of the parameters at the beginning of the script.
```Powershell
#Parameters:
$sourcelocation = "J:\"
$backuplocation = "W:\"
$logpath = "J:\000Logs\"
$silentlyEndScript = $true
$deleteOldLogs = $true
```

1. The first parameter `$sourcelocation` is the location for which you want to make a backup. **Please keep in mind, that we need the `\` at the end of the path!!**

2. The second paramert `$backuplocation` is the location of your backup. **Please keep in mind, that we need the `\` at the end of the path!!**

3. The third parameter `$logpath` is the location of the log. **Please keep in mind, that we need the `\` at the end of the path!!**

4. The forth parameter `$silentlyendScript` decides if the script is asking after an user input to end or not. If you want to make a user input to end the script set `$silentlyendScript` to `$false`. **Default is `$true`.**

5. The fifth parameter `$deleteOldLogs`decides if all old logs are deleted when you make a full backup. If old logs should not be deleted set `$deleteOldLogs` to `$false`. **Default is `$true`.** 

## Notes
* I programmed the script to back up a full volume to another volume, nevertheless the script can back up from one folder to another, but keep in mind that the logpath may be al little bit long.
* Only a full backup deletes the logs. A differential backup keeps the logs in every case.