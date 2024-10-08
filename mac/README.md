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

In the same Terminal window copy and paste into the following, and press Enter:

```bash
curl -fsSL https://rails.academy/install | bash -i
```

**NOTE: You will be prompted multiple times to enter your mac password.**

## Security

To build rails apps we'll need to authenticate with GitHub using SSH keys.

### Setup 1Password

1. Open 1Password from your Applications folder
2. Start a free trial (or login if you already have an account)
3. Select `1Password` from the menu bar and choose `Settings`
4. Navigate to the `Developer` tab and enable the following:

- :check: `Use the SSH agent`
- :check: `Integrate with 1Password CLI`

### Generate an SSH Key

1. Still in 1Password click "+ New Item"
2. Choose "SSH Key"
3. Enter the title "GitHub SSH Key"
4. Click "+ Add Private Key" -> "Generate a New Key"
5. Leave the default of "Ed25519" and click "Generate"
6. Click "Save"

### Add your SSH Key to GitHub

1. Visit [GitHub](https://github.com)
2. Create an account (or login if you already have one)
3. Login and click your profile in the top right
4. Choose "Settings" -> "SSH and GPG keys" -> "New SSH Key"
5. In 1Password find "GitHub SSH Key" and copy the **public key**
6. Paste the public key into the GitHub form and click "Add SSH Key"
7. Give it a title "1password SSH Key" and click "Add SSH Key"

Finally, test your SSH key by running the following in Alacritty:

```bash
ssh -T git@github.com
```

If that worked you should see:

```
Hi yourname! You've successfully authenticated, but GitHub does not provide shell access.
```

And if you made it this far, congratulations!

### Your Mac is ready :tada:


