# **Robocopy - VeraCrypt - Backup-Script** 
This script is a short powershell script. It is intended to use it every week as part of a regularly backup routine. The script is based on robocopy. The script mirrors the source location into the backup location. Every month there will be a full backup (means a completely new copy of the source). If you did already a backup in the current month the script performs a differential backup (only mirrors the changes). 
The scirpt keeps only the last three backups of a year. So, your backup directory shout look, for example, like the following.
```
201910
201911
201912
202002
202003
202004
```
## **How to use?**
### **How to start the script with a command:**
Start the script with the parameter: `-pathconf "param.conf"`

### **How to start the script with a shortcut:**
1. Create a shortcut
2. Edit the `Properties` of the shortcut:
```
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File "<filepath>" -pathconf "publicparam.conf"
```
3. Define the `Start in` path. Set for example the path of the script

### **Parameters:**
Before using you must set the parameters in the parameter file: `param.conf`
```Powershell
#publicparam.conf:

#Source location
confSourceLocation=C:\
#Backup location
confBackupLocation=W:\
#Log location
confLogPath=C:\000Logs\
#silently end the script.
confSilentlyEndScript=true
#delete old logs (only on full backup)
confDeleteOldLogs=true
#are the volumes encrypted with VeraCrypt?
confVeraCryptBackup=false
#path of encrypted volume
confVeraCryptSource=C:\Users\Test\Downloads\page2.backup
```

1. The first parameter `confSourceLocation` is the location for which you want to make a backup. <br>
For example: `C:\`<br>
**Please keep in mind, that we need the `\` at the end of the path!!**

2. The second paramert `confBackupLocation` is the location of your backup. <br>
For example, a new drive like: `W:\`<br>
**Please keep in mind, that we need the `\` at the end of the path!!**

3. The third parameter `confLogPath` is the location of the log. <br>
For example: `C:\000Logs\`<br>
**Please keep in mind, that we need the `\` at the end of the path!!**

4. The fourth parameter `confSilentlyEndScript` decides if the script is asking after a user input at the end of the script or not. <br>
If you want to make a user input at the end of the script set `$silentlyendScript` to `false`. <br>
**Default is `true`.**

5. The fifth parameter `confDeleteOldLogs`decides if all old logs will be deleted when the script makes a full backup. <br>
If old logs should not be deleted set `$deleteOldLogs` to `false`. <br>
**Default is `true`.** 

6. The sixth parameter `confVeraCryptBackup` activates decryption of a VeraCrypt contianer. So, by setting it to `true` you can back up to a VeraCrypt container. <br>
**Default is `false`.**<br>
**If you set `true` you must set the right `confVeraCryptSource` (next parameter)**

7. The seventh parameter `confVeraCryptSource` is the path of the VeraCrypt container. You only must enter something if `confVeraCryptSource` is set to `true`.<br>
For example: `C:\Users\Test\Downloads\page2.backup`

## **Notes**
* I programmed the script to backup a full volume to another volume, nevertheless the script can backup from one folder to another, but keep in mind that in this case the file name of the log may be a very long.
* Only a full backup deletes the logs. A differential backup keeps the logs in every case.