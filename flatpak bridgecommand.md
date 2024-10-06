These are my instructions for building a flatpak of:  
https://github.com/bridgecommand/bc/

I built it on Windows using Ubuntu WSL Linux for Windows but it will build on any linux.

Setup build environment:

sudo apt update  
sudo apt install git cmake gcc  
sudo apt install flatpak  
flatpak remote-add \--if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo  
flatpak remote-add \--if-not-exists \--user flathub https://dl.flathub.org/repo/flathub.flatpakrepo

Build manifest yaml file org.flathub.Bridgecommand.yml:

See:  
https://github.com/vpelss/bridgecommand\_flatpak/blob/main/org.flathub.Bridgecommand.yml

Notes:  
To make in another directory: make \-C dir  
To cmake in other directories : cmake \-Bbin \-Ssrc

Build the flatpak

Install and place in local repository:

flatpak-builder \--force-clean \--user \--install-deps-from=flathub \--repo=bridgecommand\_flatpak \--install builddir  bridgecommand\_flatpak/org.flathub.Bridgecommand.yml

Just install:

flatpak-builder \--force-clean \--user \--install-deps-from=flathub \--install builddir  bridgecommand\_flatpak/org.flathub.Bridgecommand.yml

Just create repo:

flatpak-builder \--force-clean \--user \--install-deps-from=flathub \--repo=bridgecommand\_flatpak  builddir bridgecommand\_flatpak/org.flathub.Bridgecommand.yml

Explanation during build process

flatpak-builder creates .flatpak-builder/build where modules are built separately.  
flatpak-builder creates builddir (as per example) where built modules are merged.  
flatpak-builder creates remository (bridgecommand\_flatpak in above example). These will be the actual installed flatpak files.  
Modules are downloaded and compiled in .flatpak-builder/build/module\_name and will show if \-v is used, as /run/build/module\_name  
Compiled files go in builddir/files. These ago in /app in the actual flatpak. builddir, the local copy, will contain bin, include, lib, share and they are put into the flatpak.  
\-${FLATPAK\_DEST} in the manifest file is /app in the flatpak.

Test repository install locally:

Add local repo path to flatpak remotes (not gpg signed):

flatpak \--user \--no-gpg-verify remote-add bc\_local /home/adsiltia/bridgecommand\_flatpak

Then install from local repo using remote:

flatpak \--user install bc\_local org.flathub.Bridgecommand

Create org.flathub.Bridgecommand.flatpakref if you want a one line install (see example below)

See:  
https://github.com/vpelss/bridgecommand\_flatpak/blob/main/org.flathub.Bridgecommand.flatpakref

Important note:  no trailing line spaces in org.flathub.Bridgecommand.flatpakref or the following will fail.  
install github repo 

Distribute:

create single file to distribute and install locally:

flatpak build-bundle \~/bridgecommand\_flatpak bridgecommand.flatpak org.flathub.Bridgecommand

Test install:

flatpak \--user install bridgecommand.flatpak

Download and install from internet from emogic.com:

curl \-O [https://emogic.com/bridgecommand.flatpak](https://emogic.com/bridgecommand.flatpak)

flatpak install \--user bridgecommand.flatpak

Using emogic.com as a flatpak remote repository:

flatpak \--user \--no-gpg-verify remote-add emogicRemote https://emogic.com/bc

flatpak \--user install emogicRemote org.flathub.Bridgecommand

or

flatpak install \--user \-v https://emogic.com/bc/org.flathub.Bridgecommand.flatpakref

Run it:

flatpak run org.flathub.Bridgecommand

Run flatpak environment and go to terminal:

flatpak run \--allow=devel \--command=bash org.flathub.Bridgecommand

flatpak run \-d \--command=bash org.flathub.Bridgecommand

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
ssh-keygen \-t github \-C "vpelss@gmail.com"

run everytime if you don’t set up environment:  
eval "$(ssh-agent \-s)"  
ssh-add \~/.ssh/github

take filename.pub and add it to github ‘deploy keys’

test access:  
ssh \-T git@github.com

git remote set-url origin git@github.com:vpelss/bridgecommand\_flatpak.git  
git remote \-v

then we can   
git clone https://github.com/vpelss/bridgecommand\_flatpak.git

change files  
git add \-f \*  
git commit \-a  
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
gpg \--export vpelss@gmail.com \> key.gpg  
base64 key.gpg | tr \-d '\\n'