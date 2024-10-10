Write-Host "Installing Rails Academy on Windows..."

function Write-Good {
    param([string]$Message)
    Write-Host "$Message" -ForegroundColor Green
}

function Write-Bad {
    param([string]$Message, [int]$ExitCode = 0)
    Write-Host "$Message" -ForegroundColor Red
    if ($ExitCode -ne 0) {
        exit $ExitCode
    }
}

if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Chocolatey is not installed. Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = 'Tls12'
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Refreshenv
    Write-Good "Chocolatey is installed."
} else {
    Write-Good "Chocolatey is installed."
}

$apps = @(
    'git',
    'alacritty',
    '1password',
    'rubymine',
    'nerd-fonts-jetbrainsmono',
    'docker-desktop'
)

# Get the list of installed applications
$installedApps = choco list

foreach ($app in $apps) {
    if ($installedApps -notmatch "^$app$") {
        Write-Host "Installing $app..."
        choco install $app -y
        Write-Host "$app is installed."
    } else {
        Write-Host "Application $app is already installed."
    }
}

# Set Git defaults
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global pull.rebase true

Write-Good "Git defaults are set."

# Install WSL and Ubuntu
if (!(Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux).State -eq 'Enabled') {
    Write-Host "WSL is not enabled. Enabling WSL..."
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
    Write-Good "WSL is enabled."
} else {
    Write-Good "WSL is already enabled."
}

if (!(Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform).State -eq 'Enabled') {
    Write-Host "Virtual Machine Platform is not enabled. Enabling..."
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
    Write-Good "Virtual Machine Platform is enabled."
} else {
    Write-Good "Virtual Machine Platform is already enabled."
}

# Install WSL2
wsl --set-default-version 2

# Check if Ubuntu is installed in WSL
$wslInstalledList = wsl --list --online
if ($wslInstalledList -notmatch 'Ubuntu') {
    Write-Host "Ubuntu is not installed. Installing Ubuntu..."
    Invoke-WebRequest -Uri https://aka.ms/wslubuntu2004 -OutFile $env:TEMP\Ubuntu.appx -UseBasicParsing
    Add-AppxPackage -Path $env:TEMP\Ubuntu.appx
    Write-Host "Ubuntu is installed."
} else {
    Write-Host "Ubuntu is already installed."
}

# Plant a fake .bashrc into the home directory of the current user in Ubuntu
$autoStartScript = @"
#!/bin/bash
echo "Continuing to install Rails Academy..."
> ~/.bashrc  # Wipe .bashrc so that this script runs only once.
wget -q0- https://rails.academy/install.sh | bash
"@

wsl echo $autoStartScript > /home/$env:USERNAME/.bashrc

# Restart is required after enabling WSL and Virtual Machine Platform
Write-Good "Part one of the installation is complete."
Write-Good "Restart your computer to apply changes."
exit


