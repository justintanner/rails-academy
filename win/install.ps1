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

    #Write-Host "Checking for program: $programName"

    foreach ($path in $registryPaths) {
        #Write-Host "Searching in registry path: $path"
        try {
            $installedPrograms = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue | Select-Object -ExpandProperty DisplayName -ErrorAction SilentlyContinue
            #Write-Host "Found installed programs in path: $path"

            foreach ($program in $installedPrograms) {
                #Write-Host "Installed program found: $program"
            }

            foreach ($program in $installedPrograms) {
                if ($program -match "(?i)$programName") {
                    #Write-Host "Match found for: $programName in $program"
                    return $true
                }
            }
        }
        catch {
            #Write-Host "Failed to read from path: $path"
        }
    }
    #Write-Host "No match found for: $programName"
    return $false
}

Write-Output "Install nerd fonts and git.."
choco install nerd-fonts-jetbrainsmono git -y

if (Is-ProgramInstalled "RubyMine") {
    Write-Good "RubyMine is already installed."
} else {
    Write-Output "Install rubymine.."
    choco install rubymine -y
}

if (Is-ProgramInstalled "Visual Studio Code") {
    Write-Good "VS Code is already installed."
}
else {
    Write-Output "Install Visual Studio Code.."
    choco install -y vscode
}

if (Is-ProgramInstalled "Alacritty") {
    Write-Good "Alacritty is already installed."
}
else {
    Write-Output "Install Alacritty.."
    choco install -y alacritty
}

$alacrittyConfigPath = "$env:APPDATA\Roaming\alacritty\alacritty.toml"

$alacrittyConfig = @"
[shell]
program = "wsl"
args = ["--cd", "~"]

[window]
option_as_alt = "OnlyLeft"
startup_mode = "Maximized"

[[mouse.bindings]]
mouse = "Right"
action = "Paste"

[selection]
save_to_clipboard = true

[font.normal]
family = "JetBrainsMono Nerd Font"

[font]
size = 11

# THEME_START
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
# THEME_END
"@

$alacrittyConfigDir = Join-Path -Path $env:APPDATA -ChildPath 'alacritty'
$alacrittyConfigPath = Join-Path -Path $alacrittyConfigDir -ChildPath 'alacritty.toml'

if (!(Test-Path -Path $alacrittyConfigDir)) {
    New-Item -ItemType Directory -Force -Path $alacrittyConfigDir
    Write-Host "Directory created: $alacrittyConfigDir"
} else {
    Write-Host "Directory already exists: $alacrittyConfigDir"
}

# Write the configuration file
Set-Content -Path $alacrittyConfigPath -Value $alacrittyConfig
Write-Host "Configuration written to: $alacrittyConfigPath"

if ((Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux).State -eq 'Enabled') {
    Write-Good "WSL is already enabled."
} else {
    Write-Host "WSL is not enabled. Enabling WSL..."
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
    Write-Good "WSL is enabled."
}

if ((Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform).State -eq 'Enabled') {
    Write-Good "Virtual Machine Platform is already enabled."
} else {
    Write-Host "Virtual Machine Platform is not enabled. Enabling..."
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
    Write-Good "Virtual Machine Platform is enabled."
}

# By default wsl --list produces non-ascii characters breaking pattern matching below.
$env:WSL_UTF8=1
$wslInstalled = wsl --list

if ($wslInstalled -Match '.*Ubuntu-24.*') {
    Write-Host "Ubuntu 24 is already installed."
} else {
    Write-Host "Ubuntu 24 is not installed. Installing Ubuntu 24.04..."
    wsl --install -d Ubuntu-24.04
    wsl --set-version Ubuntu-24.04 2
}

if (Is-ProgramInstalled "Docker") {
    Write-Good "Docker is already installed."
} else {
    Write-Output "Install Docker.."
    choco install -y docker-desktop
}

Write-Good "Rails Academy (part one) successfully installed."
Write-Host "Please Restart your computer..."
