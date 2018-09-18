# escape=`

#Let's use our custom base image as our base layer, because it's already 
#locked-down and secured.  The server team promised...
FROM mybaseimage:latest

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

#More magic that locks-down the IIS host could be put here
#actually do nothing.  What, me worry?

#Create a custom welcome page
RUN echo "This is a totally secure web server now..." > c:\inetpub\wwwroot\index.html

#Download ServiceMonitor to act as minder for W3SVC
RUN powershell -Command `
    Add-WindowsFeature Web-Server; `
    Invoke-WebRequest -UseBasicParsing -Uri "https://dotnetbinaries.blob.core.windows.net/servicemonitor/2.0.1.2/ServiceMonitor.exe" -OutFile "C:\ServiceMonitor.exe"

#allow port 80 traffic into the container
EXPOSE 80

#Set startup EXE
ENTRYPOINT ["C:\\ServiceMonitor.exe", "w3svc"]





