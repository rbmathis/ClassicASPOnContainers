# escape=`

#grab the latest IIS image from our web team. 
#It's totally locked-down and secure
FROM myiisimage:latest

#setup PowerShell so that we can run commands (PowerShell catches "run" commands)
SHELL ["powershell", "-command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Download the com components and test pages from github
RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
    Invoke-WebRequest -Uri https://github.com/nzregs/vb6MathLib/raw/master/MathLibNZRegs.dll -OutFile c:\inetpub\wwwroot\MathLibNZRegs.dll; `
    Invoke-WebRequest -Uri https://github.com/nzregs/vb6MathLib/raw/master/msvbvm60.dll -OutFile c:\inetpub\wwwroot\msvbvm60.dll; `
    $regsvr = [System.Environment]::ExpandEnvironmentVariables('%windir%\SysWOW64\regsvr32.exe'); `
    Start-Process $regsvr  -ArgumentList '/s', "c:\inetpub\wwwroot\msvbvm60.dll" -Wait; `
    Start-Process $regsvr  -ArgumentList '/s', "c:\inetpub\wwwroot\MathLibNZRegs.dll" -Wait

#Install Chocolatey because it's yum-my. (Get it?)
RUN Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'));

#Install Git so that we can pull code from the repo
RUN choco install git.install --params "/GitAndUnixToolsOnPath" -y --force;

#Pull additional sample code into the container
RUN git clone https://github.com/rbmathis/learn-classic-asp.git c:\inetpub\wwwroot\learn;

#Copy config - this has our DB connection string inside
COPY global.asa C:\inetpub\wwwroot

#allow port 80 traffic into the container
EXPOSE 80

#Set startup EXE (it's already there on the base IIS image)
ENTRYPOINT ["C:\\ServiceMonitor.exe", "w3svc"]





