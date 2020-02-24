####VARIABLES####

$WinVerRoot = "10.0.18362"

$WinVerBranch = "10.0.18362.418"

$WinVerCheck = "Microsoft Windows NT ${WinVerBranch}"

$FreeSpace = [int]("{0:n2}" -f ((Get-WmiObject -Class win32_logicaldisk -Filter 'DeviceID = "C:"').FreeSpace/1GB))

$SourceFile = "\\whcpm\$WinVerRoot\$WinVerBranch\setup.exe"

$SourceFolder = "\\whcpm\$WinVerRoot\$WinVerBranch\"

$TargetFolder = "C:\WHCW10Update\"

$TargetFolderII = "C:\Windows10Update\"

$TargetFile = "C:\WHCW10Update\Setup.exe"
$SetupArgs = "/auto:upgrade"

$LogFolder = "\\whcdocs\deploy$\MS\$WinVerRoot"

####EXECUTION####

#Check PC's WinVer. If not equal to target WinVer, proceed.
If([Environment]::OSVersion.VersionString -ne $WinVerCheck) {

    #Delete previous update folders.
    Remove-Item -path $TargetFolder -Recurse -ErrorAction Ignore
    Remove-Item -path $TargetFolderII -Recurse -ErrorAction Ignore

    #Check free space on C: drive. If 10gb or more available, proceed. 
    If($FreeSpace -ge 10) {

        #Check for access to source path. If accessible, proceed.
        If(Test-Path $SourceFolder) {

            #Log initiation of file copy operation and begin the operation.
            New-Item -path $LogFolder -name "${env:COMPUTERNAME}_BEGIN_${WinVerBranch}_FileCopy.txt" -ItemType File
            New-Item -Path $TargetFolder -ItemType Directory
            ROBOCOPY $SourceFolder $TargetFolder /E      
            write-host "Awesome!"

            #Test access to setup.exe on local PC. If accessible, proceed.
            If(Test-Path $TargetFile) {

                #Log the initiation of the upgrade operation and begin the operation. Log the completion.
                New-Item -path $LogFolder -name "${env:COMPUTERNAME}_BEGIN_${WinVerBranch}_Upgrade.txt" -ItemType File
                Start-Process $TargetFile $SetupArgs -Wait
                New-Item -path $LogFolder -name "${env:COMPUTERNAME}_END_${WinVerBranch}_Upgrade.txt" -ItemType File

            } Else {

                #If setup.exe is not present on local PC.
                New-Item -path $LogFolder -name "${env:COMPUTERNAME}_FAIL_${WinVerBranch}_SetupFileMissing.txt" -ItemType File
                Exit
            }

        } Else {
            #If source file is not available.
            New-Item -path $LogFolder -name "${env:COMPUTERNAME}_FAIL_${WinVerBranch}_SourceFilesMissing.txt" -ItemType File
            Exit
        }

    } Else {
        #If not enough space available.
        $SpaceNeeded = 10 - $FreeSpaceGB
        New-Item -path $LogFolder -name "${env:COMPUTERNAME}_FAIL_${WinVerBranch}_${SpaceNeeded}_GB_NEEDED.txt" -ItemType File
        Exit
    }
} Else {
    #If PC is already up to latest version.
    New-Item -path $LogFolder -name "${env:COMPUTERNAME}_FAIL_${UpgradeVersionFull}_NoNeedUpdate.txt" -ItemType File
    Exit

}