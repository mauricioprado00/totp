## Setup
Create a gpg key following steps of [**How to generate Two-Factor authentication code from your Linux CLI**](#information-about-system-requirements-and-the-encryption)
[Install dependencies](#dependencies)
After the key creation create a file .env (from .env.sample) where

- uid: is the email you put in the key
- kid: is the number that appears when you run the command:
`gpg --list-secret-keys --keyid-format LONG`
e.g.: ssb   rsa4096/XX1X11XX11X1X11X
*kid* would be XX1X11XX11X1X11X


create accounts using either:

`./create.sh <accountid> <totp_key>`

or

`./create.sh <accountid> <qr-code-file>`

Where qr-code-file is the png file that contains the QR code that application offers to scan the totp key.


## Obtain a code for an account:

use:

`./decrypt.key.sh <accountid>`

# dependencies
- oathtool (or oath-toolkit)
- gpgv2
- zbar (or zbar-tools)

# Information about system requirements and the encryption
I do not wish to use Google Authenticator or Authy app that generates 2 step verification (2FA) codes on my iOS/Android phone. Is there any way I can produce 2FA codes from Linux command line for popular sites such as Gmail, Twitter, Facebook, Amazon and more?  

The mobile apps generate secure 2 step verification codes to protect your online accounts from hackers. You get an additional layer of security. In addition to your password, you need to input 2FA codes for each login. This page explains how to use oathtool OTPs (one-time password) on Linux to secure your Gmail and other online accounts. Instead of waiting for text messages, get verification codes for free from the oathtool Linux command.


## How to install oathtool Linux command line tool

oathtool is a command line tool for generating and validating OTPs and gpg2 is an OpenPGP encryption and signing tool for encrypting private keys used by oathtool. Type the commands as per your Linux distro to install the same.

### Fedora Linux install oathtool

Open the terminal application and type the following dnf command:  
`$ sudo dnf install oathtool gnupg2`

### CentOS Linux/RHEL install oathtool

First enable EPEL repo on RHEL or CentOS 7 and run the following yum command:  
`$ sudo yum install oathtool gnupg2`

### Debian/Ubuntu Linux install oathtool

Simply use the apt command or apt-get command to install the same:  
`$ sudo apt update  
$ sudo apt upgrade  
$ sudo apt install oathtool gpgv2`

### SUSE/OpenSUSE Linux install oathtool

Simply run the following [nixcmd name=”zypper”:  
`$ sudo zypper ref  
$ sudo zypper in oath-toolkit gpg2`

## Linux 2 step verification (2FA) using oathtool

The syntax to generate totp is as follows:  
`oathtool -b --totp 'private_key'`  
Typically private_key only displayed once when you enable 2FA with online services such as Google/Gmail, Twitter, Facebook, Amazon, Bank accounts and so on. You must keep private_key secrete and never share with anyone. Here is a sample session that creates code for my Twitter account.  
`$ oathtool -b --totp 'N3V3R G0nn4 G1v3 Y0u Up'`  
Sample outputs:

<pre>944092</pre>

## How to generate Two-Factor authentication code from your Linux CLI

Generate a new key pair for encryption if you don’t have a gpg key, run:  
`$ gpg2 --full-gen-key`  
![Generate two-factor authentication code from your Linux CLI](https://techolac.com/wp-content/uploads/2019/05/Generate-two-factor-authentication-code-from-your-Linux-CLI.png)  
Next, create some directories and helper scripts:  
`$ mkdir ~/.2fa/  
$ cd ~/.2fa/`  
You can list GPG keys including GnuPG user id and key id, run:  
`$ gpg --list-secret-keys --keyid-format LONG`

### Shell script helper script to encrypt the totp secret (keys)

Create a shell script named **encrypt.key.sh**:

```
#!/bin/bash  
# Purpose: Encrypt the totp secret stored in $dir/$service/.key file  
# Author: Vivek Gite {https://www.cyberciti.biz/} under GPL v 2.x or above  
# ————————————————————————–  
# Path to gpg2 binary  
_gpg2=”/usr/bin/gpg2″ ## run: gpg –list-secret-keys –keyid-format LONG to get uid and kid ##  
# GnuPG user id  
uid=”YOUR-EMAIL-ID” # GnuPG key id  
kid=”YOUR-KEY” # Directory that stores encrypted key for each service  
dir=”$HOME/.2fa” # Now build CLI args  
s=”$1″  
k=”${dir}/${s}/.key”  
kg=”${k}.gpg” # failsafe stuff  
[ “$1” == “” ] && { echo “Usage: $0 service”; exit 1; }  
[ ! -f “$k” ] && { echo “$0 – Error: $k file not found.”; exit 2; }  
[ -f “$kg” ] && { echo “$0 – Error: Encrypted file “$kg” exists.”; exit 3; } 
# Encrypt your service .key file  
$_gpg2 -u “${kid}” -r “${uid}” –encrypt “$k” && rm -i “$k”
```

### Shell script helper script to decrypt the totp secret and generate 2FA code

Create a shell script named **decrypt.key.sh**:

```
#!/bin/bash  
# Purpose: Display 2FA code on screen  
# Author: Vivek Gite {https://www.cyberciti.biz/} under GPL v 2.x or above  
# ————————————————————————–  
# Path to gpg2 binary  
_gpg2=”/usr/bin/gpg2″  
_oathtool=”/usr/bin/oathtool” ## run: gpg –list-secret-keys –keyid-format LONG to get uid and kid ##  
# GnuPG user id  
uid=”YOUR-EMAIL-ID” # GnuPG key id  
kid=”YOUR-KEY” # Directory  
dir=”$HOME/.2fa” # Build CLI arg  
s=”$1″  
k=”${dir}/${s}/.key”  
kg=”${k}.gpg” # failsafe stuff  
[ “$1” == “” ] && { echo “Usage: $0 service”; exit 1; }  
[ ! -f “$kg” ] && { echo “Error: Encrypted file “$kg” not found.”; exit 2; } # Get totp secret for given service  
totp=$($_gpg2 –quiet -u “${kid}” -r “${uid}” –decrypt “$kg”) # Generate 2FA totp code and display on screen  
echo “Your code for $s is …”  
$_oathtool -b –totp “$totp” # Make sure we don’t have .key file in plain text format ever #  
[ -f “$k” ] && echo “Warning – Plain text key file “$k” found.”
```

## 2FA using oathtool in the Linux command line for Gmail account

Let us see a complete example for Google/Gmail account. To enable 2FA visit and login:  
`https://www.google.com/landing/2step/`  
Visit 2-Step Verification > Get Started:  
![Gmail 2-Step Verification](https://techolac.com/wp-content/uploads/2019/05/Gmail-2-Step-Verification.png)  
You may have to verify your mobile phone number. Once verified, scroll down and choose Authenticator app:  
![Set up Authenticator app](https://techolac.com/wp-content/uploads/2019/05/Set-up-Authenticator-app.png)  
What kind of phone do you have? Choose iPhone or Android as we are going to use our CLI app and click Next:  
![Get codes from the Linux authenticator cli app](https://techolac.com/wp-content/uploads/2019/05/Get-codes-from-the-Linux-authenticator-cli-app.png)  
Make sure you click on “CAN’T SCAN IT” to see totp secret key and copy it:  
![Can](https://techolac.com/wp-content/uploads/2019/05/Cant-scan-the-barcode-for-Linux-2FA-app.png)  
Cd into ~/.2fa/ directory and run the following commands:  
`cd ~/.2fa/  
### Step 1\. create service directory ###  
### vivek@gmail.com also act as service name for encrypt.key.sh ###  
mkdir vivek@gmail.com  
### Step 2\. Store totp secret key ###  
echo -n 'hilp zs6i c5qu bx7z akiz q75e wk5z z66b' > ~/.2fa/vivek@gmail.com/.key`  
Encrypt the totp secret key file named ~/.2fa/vivek@gmail.com/.key with gpg and password protect it for security and privacy reasons using our **<kbd>encrypt.key.sh</kbd>** helper script:  
`### Step 3\. Secure totp secret key for service named vivek@gmail.com ###  
./encrypt.key.sh vivek@gmail.com`  
![Linux 2 step verification 2FA totp key file](https://techolac.com/wp-content/uploads/2019/05/Linux-2-step-verification-2FA-totp-key-file.png)  
Finally click on the Next button:  
![Set up Linux oathtool as authenticator app](https://techolac.com/wp-content/uploads/2019/05/Set-up-Linux-oathtool-as-authenticator-app.png)  
It is time to create your first 6-digit code using oathtool command. However, we automated this process using **<kbd>decrypt.key.sh</kbd>** shell script that decrypts the totp secret and generates the 6-digit 2FA code. Simply run:  
`./decrypt.key.sh vivek@gmail.com`  
You need to type the gpg passphrase to unlock the secrete key for service named vivek@gmail.com:  
![oathtool Linux command line with shell script helper](https://techolac.com/wp-content/uploads/2019/05/oathtool-Linux-command-line-with-shell-script-helper.png)  
Finally you will see the 6-digit code as follows on screen:  
![Generate Two-Factor Authentication Codes on Linux](https://techolac.com/wp-content/uploads/2019/05/Generate-Two-Factor-Authentication-Codes-on-Linux.png)  
Withing 30 seconds you need to type the 330197 code and click on the verify button:  
![Enter 6 digit code for Gmail from Linux command line](https://techolac.com/wp-content/uploads/2019/05/Enter-6-digit-code-for-Gmail-from-Linux-command-line.png)  
And you are done:  
![totp linux set up](https://techolac.com/wp-content/uploads/2019/05/totp-linux-set-up.png)

## How to add another service

The syntax is pretty simple:

1.  Log in to online service such as Twitter, Facebook, Bank account and look for Authenticator 2FA app. For example, let us set up Twitter account 2FA using Linux command line app.
2.  Copy the totp secret from Twitter account.
3.  Create a new service directory: <kbd>**mkdir ~/.2fa/twitter.com/**</kbd>
4.  Make a new .key file: <kbd>**echo -n 'your-twitter-totp-secret-key' > ~/.2fa/twitter.com/.key**</kbd>
5.  Generate a new PGP encrypted file for security and privacy reasons: <kbd>**~/.2fa/encrypt.key.sh twitter.com**</kbd>
6.  Decrypts the totp secret and generates the 6-digit 2FA code when you need to log in into Twitter: <kbd>**~/.2fa/decrypt.key.sh twitter.com**</kbd>

You can repeat the above process for any services that display the totp secret along with QR code.

## Conclusion

The main advantage of Linux command line is that you can easily backup your ~/.2fa/ directory and keys. Your totp secrets/keys are always encrypted and password protected by gpg2\. Mobile apps such as Google Authenticator usually do not allow you to sync or copy secrets/keys for security reasons. So if you lost phone or switch phone, you wouldn’t be able to login into the account. This set up is simple and easy to backup/restore as long as you remember your gpg2 passphrase. I strongly recommend that you enable full disk encryption (FDE) too. Next time I will show you how to use GUI apps for the same purpose.



## info 

- https://www.techolac.com/linux/use-oathtool-linux-command-line-for-2-step-verification-2fa/
- https://www.techinformant.in/create-read-qrbarcode-linux-terminal/
