These are my instructions for building a flatpak of:  
https://github.com/bridgecommand/bc/

I built it on Windows using Ubuntu WSL Linux for Windows.   
Important Note: When initiating some program changes/install, notably QEMU , I had to stop WSL service in the task manager and restart ubuntu to get it to work…. Very Odd.

Setting up up the build environment:

sudo apt update  
sudo apt upgrade  
sudo apt install git make cmake gcc  
sudo apt install flatpak  
sudo apt install flatpak-builder  
flatpak remote-add \--if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo  
sudo apt \-y install qemu-system-arm qemu-user-static \#if cross building flatpak for ARM / aarch64 (pi 4\) : this installs ARM aware qemu and will allow flatpak-builder to run cmake and gcc for ARM when required

Create manifest file  yaml file org.flathub.Bridgecommand.yml:

See: https://github.com/vpelss/bridgecommand\_flatpak/blob/main/org.flathub.Bridgecommand.yml  
Notes:  
To run make files in another directory: make \-C dir  
To cmake in other directories : cmake \-Bbin \-Ssrc  
To find runtime-versions : flatpak remote-ls \--**arch**\=\*  | grep \-n org.kde.Platform  
\--arch=x86\_64  
\--arch=aarch64

Build the flatpak:

My paths are the following. Yours will vary.  
/home/adsiltia/.flatpak-builder : where the modules are built  
/home/adsiltia/builddir : build directory  
/home/adsiltia/bridgecommand\_flatpak : git cloned manifest   
/home/adsiltia/bridgecommand\_flatpak/repo : repo files

I am building for ‘system’ not ‘user’, therefore I must use sudo

Install and place in local repository:

For x86\_64:  
sudo flatpak-builder \--force-clean \--install-deps-from=flathub \--repo=/home/adsiltia/bridgecommand\_flatpak/repo \--state-dir=/home/adsiltia/.flatpak-builder \--install \~/builddir  \~/bridgecommand\_flatpak/org.flathub.Bridgecommand.yml

For Pi4/aarch64:  
sudo flatpak-builder \-v \--arch=aarch64 \--force-clean \--install-deps-from=flathub \--repo=/home/adsiltia/bridgecommand\_flatpak/repo \--state-dir=/home/adsiltia/.flatpak-builder \--install \~/builddir  \~/bridgecommand\_flatpak/org.flathub.Bridgecommand.yml

To just install x86\_64:  
sudo flatpak-builder \--force-clean \--install-deps-from=flathub \--state-dir=/home/adsiltia/.flatpak-builder \--install \~/builddir  \~/bridgecommand\_flatpak/org.flathub.Bridgecommand.yml

To just create repo x86\_64: **fails**  
sudo flatpak-builder \--force-clean \--install-deps-from=flathub \--repo=/home/adsiltia/bridgecommand\_flatpak/repo \--state-dir=/home/adsiltia/.flatpak-builder \--export-only \~/builddir \~/bridgecommand\_flatpak/org.flathub.Bridgecommand.yml

Explanation during build process:

flatpak-builder creates .flatpak-builder/build where modules are built separately.  
flatpak-builder creates builddir (as per example) where built modules are merged.  
flatpak-builder creates repository (bridgecommand\_flatpak in above example). These will be the actual installed flatpak files.  
Modules are downloaded and compiled in .flatpak-builder/build/module\_name and will show if \-v is used, as /run/build/module\_name  
Compiled files go in builddir/files. These ago in /app in the actual flatpak. builddir, the local copy, will contain bin, include, lib, share and they are put into the flatpak.  
\-${FLATPAK\_DEST} in the manifest file is /app in the flatpak.

Test repository install locally:

Add local repo path to flatpak remotes (not gpg signed):

sudo flatpak \--no-gpg-verify remote-add bc\_local /home/adsiltia/bridgecommand\_flatpak\_repo

Then install from local repo using remote:

sudo flatpak install bc\_local org.flathub.Bridgecommand

Create org.flathub.Bridgecommand.flatpakref if you want a one line install (see example below)

See:  
https://github.com/vpelss/bridgecommand\_flatpak/blob/main/org.flathub.Bridgecommand.flatpakref

Important note:  no trailing line spaces in org.flathub.Bridgecommand.flatpakref or the following will fail:  
sudo flatpak install \--user \-v https://emogic.com/bc/org.flathub.Bridgecommand.flatpakref

Distribute:

1\. create single file to distribute and install locally:

mkdir \~/bridgecommand\_flatpak/bundle/  
sudo flatpak build-bundle \~/bridgecommand\_flatpak/repo bridgecommand.flatpak org.flathub.Bridgecommand

Test install:

sudo flatpak install bridgecommand.flatpak

2\. Download and install single file bundle from internet (old version. demonstration only):

curl \-O https://emogic.com/bridgecommand.flatpak

sudo flatpak install \--user bridgecommand.flatpak

3\. Using gthub.com as a flatpak remote repository

To host on github:

You must turn on Actions-\>Deployments-\>Github Pages to make github act like a web host server. eg: https://vpelss.github.io/bridgecommand\_flatpak/

sudo flatpak \--no-gpg-verify remote-add emogicRemote https://vpelss.github.io/bridgecommand\_flatpak/repo

sudo flatpak install emogicRemote org.flathub.Bridgecommand

Or a one line install. I have also copied org.flathub.Bridgecommand.flatpakref there:

sudo flatpak install \-v https://vpelss.github.io/bridgecommand\_flatpak/org.flathub.Bridgecommand.flatpakref

Run it:

flatpak run org.flathub.Bridgecommand

For Pi4

flatpak run \--arch=aarch64 org.flathub.Bridgecommand

Run flatpak environment and go to terminal (for troubleshooting):

flatpak run \--allow=devel \--command=bash org.flathub.Bridgecommand

flatpak run \-d \--command=bash org.flathub.Bridgecommand

Note: You can run and try different permissions from command line:

flatpak run \-d \--socket=fallback-x11 \--command=bash org.flathub.Bridgecommand

\---------------------------------

Make sure remotes are clean

flatpak remotes  
flatpak remote-delete

\---------------------------------

Reduce repo size

flatpak repair \--user  
flatpak uninstall \--unused

\---------------------

Setting up git:

generate :

ssh-keygen \-t ed25519 \-C "vpelss@gmail.com"

rename to github and github.pub

run everytime if you don’t set up environment:

git config \--global user.email "vpelss@gmail.com"  
git config \--global user.name "Vince Pelss"  
git remote add origin git@github.com:vpelss/bridgecommand\_flatpak.giy  
git remote set-url origin git@github.com:vpelss/bridgecommand\_flatpak.git  
eval "$(ssh-agent \-s)"  
ssh-add \~/.ssh/github

take filename.pub and add it to github ‘deploy keys’

test access:  
ssh \-T git@github.com  
git remote \-v

then we can:

git clone \--depth 1 https://github.com/vpelss/bridgecommand\_flatpak.git

change files  
git add \-f \*  
git commit \-m ‘new’ \-a  
git push \-f \-v \--mirror

\-------------------

Ignore the following. Signing is the devils work.  
Create gpg keys:

gpg \--quick-gen-key vpelss@gmail.com  
gpg \--export vpelss@gmail.com \> key.gpg  
base64 key.gpg | tr \-d '\\n'  
gpg \--armor \--export

Sign it (if required):  
flatpak-builder \--gpg-sign=\<key\> \--repo=bridgecommand\_flatpak bridgecommand\_flatpak/org.flathub.Bridgecommand.yml  
GPG signing. Do ALL even the first ‘associating email with key’  
https://docs.github.com/en/authentication/managing-commit-signature-verification/telling-git-about-your-signing-key  
gpg \--quick-gen-key vpelss@gmail.com  
gpg \--export vpelss@gmail.com \> key.gpg  
gpg \--list-secret-keys \--with-keygrip  
gpg \--list-secret-keys \--keyid-format=long  
gpg \--list-signatures

public key:  
 gpg \--list-keys

private key:  
gpg \--output private.pgp \--armor \--export-secret-key vpelss@gmail.com  
generate the base64 encoded GPGKey:  
gpg \--export vpelss@gmail.com \> key.gpga  
base64 key.gpg | tr \-d '\\n'