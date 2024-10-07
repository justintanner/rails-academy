# How to setup a Mac for Rails

## Xcode

We need [Xcode](https://developer.apple.com/xcode/) to help install Homebrew.

1. Open the App Store from your Applications folder
2. Search for Xcode
3. Click the Get button to install Xcode
4. Open Xcode from your Applications folder
5. Accept the license agreement

## Docker

We will use Docker to deploy our rails app's and run databases locally.

1. Download and install [Docker Desktop](https://www.docker.com/products/docker-desktop)
2. Open Docker Desktop from your Applications folder
3. Open the setting by clicking the gear icon in the top right corner
4. Check "Start Docker Desktop when you sign in to your computer"

## Command Line Tools

1. Open Alacritty by pressing `Cmd + Space` and typing `Alacritty`
2. Install the [Xcode Command Line Tools](https://mac.install.guide/commandlinetools/)

By running:

```bash
xcode-select --install
```

## All the other tools

Finally we can install all the other tools we need by running:

```bash
bash <(curl -fsSL https://rails.academy/install || wget -qO- https://rails.academy/install)
```

## Your Mac is ready :tada:

Close Alacritty and open it again and you should be ready to start building.
