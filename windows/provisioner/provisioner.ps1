param ([String]$JDK_FILE, [String]$Git_version, [String]$Python_version, [String]$Nodejs_version, [String]$Maven_version)
$WORKING_DIRECTORY = "C:\Users\vagrant"
$Program_file_path = "C:\Program Files"

#Enable  remote desktop
(Get-WmiObject Win32_TerminalServiceSetting -Namespace root\cimv2\TerminalServices).SetAllowTsConnections(1, 1) | Out-Null
(Get-WmiObject -Class "Win32_TSGeneralSetting" -Namespace root\cimv2\TerminalServices -Filter "TerminalName='RDP-tcp'").SetUserAuthenticationRequired(0) | Out-Null
Get-NetFirewallRule -DisplayName "Remote Desktop*" | Set-NetFirewallRule -enabled true

#License validation off
Set-Service LicenseManager -StartupType Disabled
Set-Service wuauserv -StartupType Disabled


#disable user account control interface
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value "0"
#enable wget
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#tool urls
$Git_Url = "https://github.com/git-for-windows/git/releases/download/v$Git_version.windows.1/Git-$Git_version-64-bit.exe"
$Python_Url = "https://www.python.org/ftp/python/$Python_version/python-$Python_version-amd64.exe"
$Maven_Url = "https://www-us.apache.org/dist/maven/maven-3/$Maven_version/binaries/apache-maven-$Maven_version-bin.zip"
$Nodejs_Url = "https://nodejs.org/dist/v$Nodejs_version/node-v$Nodejs_version-x64.msi"

Write-Output "git url is: $Git_Url"
Write-Output "python url is: $Python_Url"
Write-Output "maven url is: $Maven_Url"
Write-Output "nodejs url is: $Nodejs_Url"

#Arguments passed
Write-Output "Git version is: $Git_version"
Write-Output "JDK file : $JDK_FILE"
Write-Output "Python version is: $Python_version"
Write-Output "nodejs version is: $Nodejs_version"
Write-Output "maven version is: $Maven_version"

#create files directory to place all the downloadables
mkdir $WORKING_DIRECTORY\files
mkdir $WORKING_DIRECTORY\files\git
mkdir $WORKING_DIRECTORY\files\python
mkdir $WORKING_DIRECTORY\files\maven
mkdir $WORKING_DIRECTORY\files\nodejs
Write-Output "directory's created!!"

$Files_path = "$WORKING_DIRECTORY\files"
$Git_path = "$WORKING_DIRECTORY\files\git"
$Python_path = "$WORKING_DIRECTORY\files\python"
$Maven_path = "$WORKING_DIRECTORY\files\maven"
$Nodejs_path = "$WORKING_DIRECTORY\files\nodejs"

#Default installation path
$Git_install_path = "$Program_file_path\Git"
$Java_path = "$Program_file_path\Java"

#import module to enable powershell to download
Write-Output "Import module BitTansfer..."
Import-Module BitsTransfer
Write-Output "Import module BitTansfer finished..."

#refresh env path
function refresh-path
{
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") +
        ";" +
        [System.Environment]::GetEnvironmentVariable("Path", "User")
}

#restart the computer
function restart
{
    Write-Output "Restarting the computer"
    Restart-Computer
}

#Install chocolatey
Write-Output "chocalatey installation"
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
Write-Output "chocolatey installed!!"

#jdk file check and version check
Write-Output "Checking JDK version and files..."
if (Test-Path $WORKING_DIRECTORY\$JDK_FILE)
{
    Write-Output "jdk archive is in place"
}
else
{
    Write-Output "jdk archive not in place"
    exit
}

Write-Output "Checking complete..."


#setup jdk
Write-Output "setup jdk"
Write-Output "$WORKING_DIRECTORY\$JDK_FILE"
Start-Process "$WORKING_DIRECTORY\$JDK_FILE" -ArgumentList 'INSTALL_SILENT=Enable' -Wait
Write-Output "JAVA_HOME setup is done!!"
$jdk_path = Get-ChildItem $Java_path\jdk*
Write-Output "Jdk installed in :$jdk_path"

#set environment variable for java
[Environment]::SetEnvironmentVariable("JAVA_HOME", "$jdk_path", [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";$jdk_path\bin;", [EnvironmentVariableTarget]::Machine)

#refresh env path
refresh-path
refreshenv

#Git installation
Write-Output "git download"
wget $Git_Url -OutFile "$Git_path\git.exe"
if ($?)
{
    Write-Output "Git url is valid"
    Write-Output "Git installing begin!!"
    $git_file = Get-ChildItem $Git_path\*.exe
    Write-Output "Git file is :$git_file"
    Start-Process "$git_file" -ArgumentList '/VERYSILENT' -Wait
    Write-Output "Git installed"
    [Environment]::SetEnvironmentVariable("Path", $env:Path + ";$Git_install_path\bin;", [EnvironmentVariableTarget]::Machine)
    Write-Output "Git environment variable setted"
}
else
{
    Write-Output "Git url not valid, installing with default options"
    choco install -y git
}
Write-Output "Git installed Successfully!!"

#refresh env path
refresh-path
refreshenv

#Python download and install
Write-Output "python download"
Start-BitsTransfer -source "$Python_Url" -Destination "$Python_path\python.exe"
if ($?)
{
    Write-Output "python url is valid"
    Write-Output "python installation started!!"
    $python_file = Get-ChildItem $Python_path\*.exe
    Write-Output "python file is: $python_file"
    Start-Process "$python_file" -ArgumentList "/quiet PrependPath=1" -Wait
    Write-Output "python installed"
}
else
{
    Write-Output "Pyhton url not valid, installing with default options"
    choco install -y python --version "$Python_version"
}

Write-Output "python installed successfully!!"

#refresh env path
refresh-path
refreshenv

#Maven Download and installation
Write-Output "maven download"
Start-BitsTransfer -source "$Maven_Url" -Destination "$Maven_path\maven.zip"
if ($?)
{
    Write-Output "maven url is valid"
    Write-Output "maven setup start"
    $maven_file = Get-ChildItem $Maven_path\*.zip
    Write-Output "maven file is: $maven_file"
    Expand-Archive -Path "$maven_file" -DestinationPath "$Maven_path"
    $maven = Get-ChildItem -Path "$Maven_path" -Exclude *.zip
    [Environment]::SetEnvironmentVariable("MAVEN_HOME", "$maven", [EnvironmentVariableTarget]::Machine)
    [Environment]::SetEnvironmentVariable("M2_HOME", "$maven", [EnvironmentVariableTarget]::Machine)
    [Environment]::SetEnvironmentVariable("Path", $env:Path + "$maven\bin;", [EnvironmentVariableTarget]::Machine)
    Write-Output "maven setup done!!!"
}
else
{
    Write-Output "Maven url not valid, installing with default options"
    choco install -y maven
}
Write-Output "Maven installed successfully!!!"

#refresh env path
refresh-path
refreshenv

#pip upgarde
Write-Output "pip upgrade"
python -m pip install --upgrade pip
if ($?)
{
    "pip upgraded successfully"
}
else
{
    "pip not upgraded!!"
}

#install virtualenv
Write-Output "installing virtualenv"
pip install virtualenv
Write-Output "virtualenv installed"

#refresh env path
refresh-path
refreshenv

#nodejs download and install
Write-Output "nodejs download"
Start-BitsTransfer -source "$Nodejs_Url" -Destination "$Nodejs_path\nodejs.msi"
if ($?)
{
    Write-Output "Nodejs  url is valid"
    Write-Output "nodejs installing started"
    $nodejs_file = Get-ChildItem $Nodejs_path\*.msi
    Write-Output "nodejs file is: $nodejs_file"
    Start-Process msiexec.exe -ArgumentList /i,$nodejs_file, '/passive', 'ACCEPT_EULA=1' -Wait
    Write-Output "nodejs and npm installed!!"
}
else
{
    Write-Output "Nodejs url not valid, so installing with default options"
    choco install -y nodejs
}

Write-Output "Nodejs downloaded successfully!!"

#refresh env path
refresh-path
refreshenv

#python vesion verification
$python_version = python -V
if ($python_version -like "*$Python_version")
{
    Write-Output "python version is matched"
}
else
{
    Write-Output "python version mismatch!!"
}

#maven vesion verification
$maven_version = mvn -version
if ($Maven_version -like "*$Maven_version")
{
    Write-Output "maven version is matched"
}
else
{
    Write-Output "maven version mismatch!!"
}

#Git vesion verification
$git_version = git --version
if ($git_version -like "*$Git_version")
{
    Write-Output "git version is matched"
}
else
{
    Write-Output "git version mismatch!!"
}

#maven vesion verification
$nodejs_version = node -v
if ($nodejs_version -like "*$Nodejs_version")
{
    Write-Output "nodejs version is matched"
}
else
{
    Write-Output "nodejs version mismatch!!"
}


if ($?)
{
    Write-Output "setting up done!!"
}
else
{
    Write-Output "setting up failed!! "
}

#restarting
restart