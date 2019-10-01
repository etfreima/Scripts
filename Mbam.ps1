#Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0

$mbDir = "C:\ScriptMBDL"
$mbamVer = "mb3-setup-consumer-3.8.3.2965-1.0.627-1.0.12703.exe"

#Check if script has been run before

if (Test-Path $mbDir -PathType Container)
{Write-Host "$mbDir already exists" -ForegroundColor Red}
ELSE
{New-Item -ItemType directory -Path $mbDir}

#Check if mbam is already installed (without need for admin)

if (Test-Path "C:\ProgramData\Malwarebytes" -PathType Container)
{
    Write-Host "Malware Bytes is already installed" -ForegroundColor Red

    #Write IPv4 address of system that already has mbam installed
    $ipv4 = (Test-Connection -ComputerName $env:COMPUTERNAME -Count 1).IPV4Address.IPAddressToString
        Write-Host "$ipv4 already installed" -ForegroundColor Red

        if (Test-Path "$mbDir\log.txt" -PathType Leaf)
        {
            
            Write-Host "Log file already exists" -ForegroundColor Red
        }
        else
        {
            Out-File $mbDir\log.txt
        }
        Add-Content $mbDir\log.txt "$ipv4 : Already Installed"
    Start-Sleep -s 10
}

#Download installer using Invoke-WebRequest if available, or WebClient if <= Win7

else
{
$url = "https://data-cdn.mbamupdates.com/web/mb3-setup-consumer/$mbamVer"
$output = "$mbDir/mbam.exe"
$startTime = Get-Date

if (Get-Command 'Invoke-WebRequest')
{
    Invoke-WebRequest $url -OutFile $output
}
else
{
    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile($url, $output)
}

#Begin silent installation and remove installer

Start-Process -FilePath "$mbDir\mbam.exe" -ArgumentList "/NOCANCEL /NORESTART /VERYSILENT /SUPPRESSMSGBOXES"

Start-Sleep -s 35

rm -Force $mbDir/mbam*

if (Test-Path $mbDir\mbam* -PathType Leaf)
{
    Write-Host "Error in removing installer." -ForegroundColor Red
    return
}

}

#Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 1