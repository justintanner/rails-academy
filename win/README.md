# How to setup a Window PC for Rails

## Open PowerShell as Administrator

1. Press the Windows key
2. Type `PowerShell`
3. Right-click on `Windows PowerShell` and choose `Run as administrator`

## Rails Academy

In the same PowerShell copy and paste this command to allow Rails Academy to install:

```powershell
Set-ExecutionPolicy Unrestricted
```

Then copy and paste this command to install Rails Academy:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/justintanner/rails-academy/stable/win/install.ps1'))
```

## Docker

Almost there, one more thing.

1. Press the Windows key
2. Type `Docker Desktop`
3. Click `Docker Desktop` to open it
4. Click the gear icon in the top right and choose `Settings`
5. Click `General` and check `Start Docker Desktop when you log in`

### Your Windows PC is ready :tada:


