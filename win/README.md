# How to setup a Window PC for Rails

### 1. Update Windows

1. Press the Windows key
2. Type `Update`
3. Click `Check for updates`
4. Install any updates (avoid windows 11 upgrades for now)

### 2. Open PowerShell as Administrator

1. Press the Windows key
2. Type `PowerShell`
3. Right-click on `Windows PowerShell` and choose `Run as administrator`

### 3. Install Rails Academy (part one)

In PowerShell window copy and paste this command to allow Rails Academy to install:

```powershell
Set-ExecutionPolicy Unrestricted
```

Then copy and paste this command to install Rails Academy:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/justintanner/rails-academy/stable/win/install.ps1'))
```

#### 4. Restart your PC

After restarting **Ubuntu** and **Docker** should open automatically.

**Important:**: Let **Ubuntu** finish installing first, then continue with the Docker setup.

### 5. Docker

You should now see a "Docker" icon on your Desktop, please click it, then:

1. Click the gear icon in the top right and choose `Settings`
2. Click `General` and check `Start Docker Desktop when you log in`

### 6. Install Rails Academy (part two)

1. Press the Windows key
2. Type `Alacritty`
3. Paste in the following to complete the install

```bash
wget -qO- https://rails.academy/install | bash
```

## :tada: Congratulations :tada:

Your Windows PC is ready for Rails development! 🚀
