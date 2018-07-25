# escape=`

#grab the latest IIS image
#FROM microsoft/iis
FROM microsoft/windowsservercore:ltsc2016

#setup PowerShell so that we can run commands (PowerShell catches "run" commands)
SHELL ["powershell", "-command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Install ContainerTools
ENV ContainerToolsVersion=0.0.1
RUN Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force; `
    Set-PsRepository -Name PSGallery -InstallationPolicy Trusted; `
    Install-Module -Name ContainerTools -MinimumVersion $Env:ContainerToolsVersion -Confirm:$false

# Install IIS, add features, enable 32bit on AppPool
RUN Install-WindowsFeature -name Web-Server; `
    Add-WindowsFeature Web-Static-Content, Web-ASP, WoW64-Support; `
    Import-Module WebAdministration; `
    set-itemProperty IIS:\apppools\DefaultAppPool -name "enable32BitAppOnWin64" -Value "true"; `
    Restart-WebAppPool "DefaultAppPool"

# Download the com components and test pages from github
RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
    Invoke-WebRequest -Uri https://github.com/nzregs/vb6MathLib/raw/master/MathLibNZRegs.dll -OutFile c:\inetpub\wwwroot\MathLibNZRegs.dll; `
    Invoke-WebRequest -Uri https://github.com/nzregs/vb6MathLib/raw/master/msvbvm60.dll -OutFile c:\inetpub\wwwroot\msvbvm60.dll; `
    Invoke-WebRequest -Uri https://github.com/nzregs/vb6MathLib/raw/master/default.asp -OutFile c:\inetpub\wwwroot\default.asp; `
    Invoke-WebRequest -Uri https://github.com/nzregs/vb6MathLib/raw/master/test.asp -OutFile c:\inetpub\wwwroot\test.asp; `
    Invoke-WebRequest -Uri https://www.nano-editor.org/dist/win32-support/nano-git-0d9a7347243.exe -OutFile c:\nano.exe; `
    $regsvr = [System.Environment]::ExpandEnvironmentVariables('%windir%\SysWOW64\regsvr32.exe'); `
    Start-Process $regsvr  -ArgumentList '/s', "c:\inetpub\wwwroot\msvbvm60.dll" -Wait; `
    Start-Process $regsvr  -ArgumentList '/s', "c:\inetpub\wwwroot\MathLibNZRegs.dll" -Wait

#Install Chocolatey
RUN Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'));

#Install Git
RUN choco install git.install --params "/GitAndUnixToolsOnPath" -y --force;

RUN git clone https://github.com/superpikar/learn-classic-asp.git c:\inetpub\wwwroot\learn;

RUN powershell -Command `
    Add-WindowsFeature Web-Server; `
    Invoke-WebRequest -UseBasicParsing -Uri "https://dotnetbinaries.blob.core.windows.net/servicemonitor/2.0.1.2/ServiceMonitor.exe" -OutFile "C:\ServiceMonitor.exe"

EXPOSE 80

ENTRYPOINT ["C:\\ServiceMonitor.exe", "w3svc"]





