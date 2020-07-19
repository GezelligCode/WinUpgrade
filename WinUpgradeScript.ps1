####VARIABLES####

# Base version number of target upgrade
$WinVerRoot = "10.0.18362"

# Full version number of target upgrade
$WinVerBranch = "10.0.18362.418"

$DistrFolder = "Your main distribution folder name goes here"

$Logs = "Filepath to the applicable logs folder"

$WinVerCheck = "Microsoft Windows NT ${WinVerBranch}"

# Used to identify the available space on destination endpoints, expressed in GBs
$FreeSpace = [int]("{0:n2}" -f ((Get-WmiObject -Class win32_logicaldisk -Filter 'DeviceID = "C:"').FreeSpace/1GB))

# File containing the upgrade executable
$SourceFile = "\\$DistrFolder\$WinVerRoot\$WinVerBranch\setup.exe"

$SourceFolder = "\\$DistrFolder\$WinVerRoot\$WinVerBranch\"

# Targeted destination folder on endpoints
$TargetFolder = "C:\W10Update\"

# Targeted executable to run on endpoints, with arguments
$TargetFile = "C:\W10Update\Setup.exe"
$SetupArgs = "/auto:upgrade"

$LogFolder = "\\$Logs\$WinVerRoot"

####EXECUTION####

#Check PC's WinVer. If not equal to target WinVer, proceed.
If([Environment]::OSVersion.VersionString -ne $WinVerCheck) {

    #Delete previous update folders on endpoints.
    Remove-Item -path $TargetFolder -Recurse -ErrorAction Ignore

    #Check free space on C: drive. If 10gb or more available, proceed. 
    If($FreeSpace -ge 10) {

        #Check for access to source path. If accessible, proceed.
        If(Test-Path $SourceFolder) {

            #Log initiation of file copy operation and begin the operation.
            New-Item -path $LogFolder -name "${env:COMPUTERNAME}_BEGIN_${WinVerBranch}_FileCopy.txt" -ItemType File
            New-Item -Path $TargetFolder -ItemType Directory
            ROBOCOPY $SourceFolder $TargetFolder /E      

            #Test access to setup.exe on local PC. If accessible, proceed.
            If(Test-Path $TargetFile) {

                #Log the initiation of the upgrade operation and begin the operation. Log the completion.
                New-Item -path $LogFolder -name "${env:COMPUTERNAME}_BEGIN_${WinVerBranch}_Upgrade.txt" -ItemType File
                Start-Process $TargetFile $SetupArgs -Wait
                New-Item -path $LogFolder -name "${env:COMPUTERNAME}_END_${WinVerBranch}_Upgrade.txt" -ItemType File

            } Else {

                #If setup.exe is not present on local PC, output log.
                New-Item -path $LogFolder -name "${env:COMPUTERNAME}_FAIL_${WinVerBranch}_SetupFileMissing.txt" -ItemType File
                Exit
            }

        } Else {
            #If source file is not available, output log.
            New-Item -path $LogFolder -name "${env:COMPUTERNAME}_FAIL_${WinVerBranch}_SourceFilesMissing.txt" -ItemType File
            Exit
        }

    } Else {
        #If not enough space available, output log.
        $SpaceNeeded = 10 - $FreeSpaceGB
        New-Item -path $LogFolder -name "${env:COMPUTERNAME}_FAIL_${WinVerBranch}_${SpaceNeeded}_GB_NEEDED.txt" -ItemType File
        Exit
    }
} Else {
    #If PC is already up to latest version, output log.
    New-Item -path $LogFolder -name "${env:COMPUTERNAME}_FAIL_${UpgradeVersionFull}_NoNeedUpdate.txt" -ItemType File
    Exit

}
