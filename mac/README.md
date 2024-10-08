# How to setup a Mac for Rails

## Xcode

We need [Xcode](https://developer.apple.com/xcode/) to help install Homebrew.

1. Open the App Store from your Applications folder
2. Search for Xcode
3. Click the Get button to install Xcode
4. Open Xcode from your Applications folder
5. Accept the license agreement

## Install XCode Command Line Tools

1. Open Terminal from your Applications folder
2. Copy and paste the following into the Terminal window

```bash
xcode-select --install
```

3. Follow the prompts to install the command line tools

## Homebrew

1. Open Terminal from your Applications folder
2. Copy and paste the following into the Terminal window

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Rails Academy

#### 1. In the same Terminal window copy and paste into the following:

```bash
curl -fsSL https://rails.academy/install | bash -i
```
#### 3. Press Enter

**NOTE: You will be prompted multiple times to enter your password. This is the same password you use to login to your Mac.**

#### 4. Quit the Terminal

## Security

To build rails app we'll need to authenticate with GitHub using SSH keys for the best security.

#### 1. Open 1Password from your Applications folder
#### 2. Start a free trial (or login if you already have an account)
#### 3. Cick 

#### 3. Visit [GitHub](https://github.com)
#### 2. Create an account (or login if you already have one)

#### 3. Add your SSH key to GitHub


## Your Mac is ready :tada:

Close Alacritty and open it again and you should be ready to start building.
