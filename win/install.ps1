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
} else {
    Write-Good "Chocolatey is installed."
}

function Is-ProgramInstalled {
    param (
        [string]$programName
    )
    # Check both registry locations where installed applications are listed
    $registryPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    Write-Output "Checking for program: $programName"

    foreach ($path in $registryPaths) {
        Write-Output "Searching in registry path: $path"
        try {
            $installedPrograms = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue | Select-Object -ExpandProperty DisplayName -ErrorAction SilentlyContinue
            Write-Output "Found installed programs in path: $path"

            foreach ($program in $installedPrograms) {
                Write-Output "Installed program found: $program"
            }

            foreach ($program in $installedPrograms) {
                if ($program -match "(?i)$programName") {
                    Write-Output "Match found for: $programName in $program"
                    return $true
                }
            }
        }
        catch {
            Write-Output "Failed to read from path: $path"
        }
    }
    Write-Output "No match found for: $programName"
    return $false
}

Write-Output "Install utils.."
choco install git wget nerd-fonts-jetbrainsmono -y

Write-Good "Setting git defaults..."
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global pull.rebase true

if (-not (Is-ProgramInstalled -programName "alacritty")) {
    Write-Output "Install alacritty.."
    choco install -y alacritty
}

if (-not (Is-ProgramInstalled -programName "1password")) {
    Write-Output "Install 1password.."
    choco install -y 1password
} else {
    Write-Good "1Password is already installed."
}

if (-not (Is-ProgramInstalled -programName "rubymine")) {
    Write-Output "Install rubymine.."
    choco install -y rubymine
} else {
    Write-Good "RubyMine is already installed."
}

if (-not (Is-ProgramInstalled -programName "Google Chrome")) {
    Write-Output "Install Google Chrome.."
    choco install -y googlechrome
}
else {
    Write-Good "Google Chrome is already installed."
}

if (-not (Is-ProgramInstalled -programName "Docker")) {
    Write-Output "Install Docker.."
    choco install -y docker-desktop
}
else {
    Write-Good "Docker is already installed."
}

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

wsl --set-default-version 2

$wslInstalledList = wsl --list
if ($wslInstalledList -notmatch 'Ubuntu') {
    Write-Host "Ubuntu is not installed. Installing Ubuntu 24.04..."
    wsl --install -d Ubuntu-24.04
} else {
    Write-Host "Ubuntu is already installed."
}

$alacrittyConfig = @"
[window.padding]
x = 4
y = 0

[shell]
program = "wsl"

[window]
option_as_alt = "OnlyLeft"

[selection]
save_to_clipboard = true

[font]
size = 14

[font.normal]
family = "JetBrainsMono Nerd Font"
style = "Regular"

[colors.primary]
background = '#F7F7F7'
foreground = '#434343'

[colors.cursor]
text = '#F7F7F7'
cursor = '#434343'

[colors.normal]
black = '#000000'
red = '#AA3731'
green = '#448C27'
yellow = '#CB9000'
blue = '#325CC0'
magenta = '#7A3E9D'
cyan = '#0083B2'
white = '#BBBBBB'

[colors.bright]
black = '#777777'
red = '#F05050'
green = '#60CB00'
yellow = '#FFBC5D'
blue = '#007ACC'
magenta = '#E64CE6'
cyan = '#00AACB'
white = '#FFFFFF'
"@

$alacrittyConfigPath = "$env:APPDATA\alacritty\alacritty.toml"
if (!(Test-Path $alacrittyConfigPath)) {
    New-Item -ItemType Directory -Force -Path "$env:APPDATA\alacritty"
    Set-Content -Path $alacrittyConfigPath -Value $alacrittyConfig
    Write-Good "Alacritty configuration is set."
} else {
    Write-Good "Alacritty configuration is already set."
}
Write-Good "Rails Academy (part one) successfully installed."
Write-Host "\r\nRestart your computer to continue."
exit


