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

if (-not (Is-ProgramInstalled -programName "1password")) {
    Write-Output "Install 1password.."
    choco install 1password -y
} else {
    Write-Good "1Password is already installed."
}

if (-not (Is-ProgramInstalled -programName "RubyMine")) {
    Write-Output "Install rubymine.."
    choco install rubymine -y
} else {
    Write-Good "RubyMine is already installed."
}

if (-not (Is-ProgramInstalled -programName "Google Chrome")) {
    Write-Output "Install Google Chrome.."
    choco install googlechrome -y
}
else {
    Write-Good "Google Chrome is already installed."
}

if (-not (Is-ProgramInstalled -programName "Visual Studio Code")) {
    Write-Output "Install Visual Studio Code.."
    choco install -y vscode
}
else {
    Write-Good "VS Code is already installed."
}

if (-not (Is-ProgramInstalled -programName "Alacritty")) {
    Write-Output "Install Alacritty.."
    choco install -y alacritty
}
else {
    Write-Good "Alacritty is already installed."
}

$alacrittyConfigPath = "$env:APPDATA\Roaming\alacritty\alacritty.toml"

$alacrittyConfig = @"
[shell]
program = "wsl"
args = ["--cd", "~"]

[window]
option_as_alt = "OnlyLeft"
startup_mode = "Maximized"

[selection]
save_to_clipboard = true

[font]
size = 12

[font.normal]
family = "JetBrainsMono Nerd Font"

# Colors (PaperColor - Light)

# Default colors
[colors.primary]
background = '#eeeeee'
foreground = '#444444'

[colors.cursor]
text = '#eeeeee'
cursor = '#444444'

# Normal colors
[colors.normal]
black   = '#eeeeee'
red     = '#af0000'
green   = '#008700'
yellow  = '#5f8700'
blue    = '#0087af'
magenta = '#878787'
cyan    = '#005f87'
white   = '#444444'

# Bright colors
[colors.bright]
black   = '#bcbcbc'
red     = '#d70000'
green   = '#d70087'
yellow  = '#8700af'
blue    = '#d75f00'
magenta = '#d75f00'
cyan    = '#005faf'
white   = '#005f87'
"@

$alacrittyConfigPath = "$env:APPDATA\Roaming\alacritty\alacritty.toml"
if (!(Test-Path $alacrittyConfigPath)) {
    New-Item -ItemType Directory -Force -Path "$env:APPDATA\Roaming\alacritty"
    Set-Content -Path $alacrittyConfigPath -Value $alacrittyConfig
    Write-Good "Alacritty configuration is set."
} else {
    Write-Good "Alacritty configuration is already set."
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

$wslInstalledList = wsl --list | Out-String
if ($wslInstalledList -notmatch '.*Ubuntu.*') {
    Write-Host "Ubuntu is not installed. Installing Ubuntu 24.04..."
    wsl --install -d Ubuntu-24.04
    # wsl --set-version Ubuntu-24.04 2
} else {
    Write-Host "Ubuntu is already installed."
}

if (-not (Is-ProgramInstalled -programName "Docker")) {
    Write-Output "Install Docker.."
    choco install -y docker-desktop
}
else {
    Write-Good "Docker is already installed."
}

Write-Good "Rails Academy (part one) successfully installed."
Write-Host "\r\nPlease Restart your computer..."
