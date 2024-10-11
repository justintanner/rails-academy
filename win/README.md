# How to setup a Window PC for Rails

## Open PowerShell as Administrator

1. Press the Windows key
2. Type `PowerShell`
3. Right-click on `Windows PowerShell` and choose `Run as administrator`

## PowerShell

In PowerShell window copy and paste this command to allow Rails Academy to install:

```powershell
Set-ExecutionPolicy Unrestricted
```

Then copy and paste this command to install Rails Academy:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/justintanner/rails-academy/stable/win/install.ps1'))
```

**Note: You may be asked to restart your computer, you can re-run the script above with no issue.**

## Alacritty

1. Press the Windows key
2. Type `Alacritty`
3. Paste in the following to complete the install

```bash
wget -qO- https://rails.academy/install | bash
```

## Docker

Almost there, one more thing.

1. Press the Windows key
2. Type `Docker Desktop`
3. Click `Docker Desktop` to open it
4. Click the gear icon in the top right and choose `Settings`
5. Click `General` and check `Start Docker Desktop when you log in`

**Note: If Docker warns about WSL2 not being installed, please try re-installing with [PowerShell](#powershell).**

## :tada: Congratulations :tada:

Your Windows PC is ready for Rails development! 🚀

