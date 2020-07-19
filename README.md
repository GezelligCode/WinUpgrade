# WinUpgrade
Powershell script for upgrading Windows

This script works in a distributed infrastructure wherein software updates are distributed from server to endpoints.

The prerequisite for this script is the download of the latest Windows upgrade package that can be saved to the source/distribution folder.

This script begins with establishing basic environment variables, such as source and destination filepaths, folder names, etc. 

After all variables are established, the script can be executed. 

The execution first removes any folders on targeted endpoints that may be leftover from previous upgrade deployments. Then it checks the following:

- Whether a minimum of 10 GB of space is available on the endpoints, and
- Whether the endpoint can access the source distribution folder.

If both criteria above are met, the script initiates the download and installation of the upgrade executable on the targeted endpoint. 

Otherwise, the script will output logs according to the specific point of failure. 

