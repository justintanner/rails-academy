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

## RubyMine

We'll use RubyMine to write our Ruby code.

1. Download and install [RubyMine](https://www.jetbrains.com/ruby/download/)
2. Open RubyMine from your Applications folder
3. Sign in with your JetBrains account (or create one if you don't have one)

## 1Password

We'll use 1Password to securely authenticate to our servers.

1. Download and install [1Password](https://1password.com/)
2. Open 1Password from your Applications folder
3. Sign up for a free account (or login if you already have one)
4. Open 1Password and goto the Settings
5. Select "Use the SSH Agent"
6. And "Integrate with 1Password CLI"

## Alacritty

A fast and beautiful terminal emulator.

1. Download and install [Alacritty](https://alacritty.org/)

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
wget -o0- rails.academy/install | bash
```

## Your Mac is ready :tada:

Close Alacritty and open it again and you should be ready to start building.


## Verify your setup

To double check everything is good to go run the following command:

```bash
bash ~/.local/share/rails-academy/mac/verify.sh
```
