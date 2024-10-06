This are my instructions for building a flatpak of:
https://github.com/bridgecommand/bc/

I built it on Windows using Ubuntu WSL Linux for Windows but it will build on any linux.

Setup build environment:

sudo apt update
sudo apt install git cmake gcc
sudo apt install flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo

Build manifest yaml file org.flathub.Bridgecommand.yml:

Notes:
To make in another directory: make -C dir
To cmake in other directories : cmake -Bbin -Ssrc


id: org.flathub.Bridgecommand
runtime: org.freedesktop.Platform
runtime-version: "23.08"
sdk: org.freedesktop.Sdk
command: wrapperBridgecommand 

modules:
  - name: portaudio
    buildsystem: cmake
    build-commands:
    sources:
      - type: git
        url: https://github.com/PortAudio/portaudio.git
        commit: 242a024
  - name: OpenXR
    buildsystem: cmake
    build-commands:
    sources:
      - type: git
        url: https://github.com/KhronosGroup/OpenXR-SDK.git
        commit: main
  - name: bc
    buildsystem: simple
    build-commands:
      - mkdir /app/bin
      - cmake -Bbin -Ssrc
      - make -C bin
      - cp -r /run/build/bc/bin/* ${FLATPAK_DEST}/bin/
    sources:
      - type: git
        url: https://github.com/bridgecommand/bc.git
        commit: main
  - name: wrapperBridgecommand
    buildsystem: simple
    build-commands:
      - install -Dm755 wrapperbc.sh /app/bin/wrapperBridgecommand
    sources:
      - type: script
        dest-filename: wrapperbc.sh
        commands:
          - cd /app/bin
          - ./bridgecommand

finish-args:  
  - --socket=fallback-x11
  - --share=ipc
  - --device=dri 
  - --share=network 
  - --persist=. 
  - --socket=pulseaudio 

cleanup:
  - /bin/BridgeCommand.app
  - /bin/CMakeFiles
  - /bin/controller
  - /bin/createDeb
  - /bin/editor
  - /bin/iniEditor
  - /bin/launcher
  - /bin/libs
  - /bin/multiplayerHub
  - /bin/repeater
  - /bin/*.exe
  - /bin/*.dll
  - /bin/*.bat



Build the flatpak

Install and place in local repository:

flatpak-builder --force-clean --user --install-deps-from=flathub --repo=bridgecommand_flatpak --install builddir  bridgecommand_flatpak/org.flathub.Bridgecommand.yml

Just install:

flatpak-builder --force-clean --user --install-deps-from=flathub --install builddir  bridgecommand_flatpak/org.flathub.Bridgecommand.yml

Just create repo:

flatpak-builder --force-clean --user --install-deps-from=flathub --repo=bridgecommand_flatpak  builddir bridgecommand_flatpak/org.flathub.Bridgecommand.yml

Explanation during build process

-flatpak-builder creates .flatpak-builder/build where modules are built separately
-flatpak-builder creates builddir (as per example) where built modules are merged
-flatpak-builder creates remository (bridgecommand_flatpak in above example). These will be the actual installed flatpak files
-modules are downloaded and compiled in .flatpak-builder/build/module_name and will show if -v is used, as /run/build/module_name
-compiled files go in builddir/files. These ago in /app in the actual flatpak. builddir, the local copy, will contain bin, include, lib, share and they are put into the flatpak
-${FLATPAK_DEST} in the manifest file is /app in the flatpak

Test repository install locally:

Add local repo path to flatpak remotes (not gpg signed):

flatpak --user --no-gpg-verify remote-add bc_local /home/adsiltia/bridgecommand_flatpak

Then install from local repo using remote:

flatpak --user install bc_local org.flathub.Bridgecommand

Create org.flathub.Bridgecommand.flatpakref if you want a one line install (see example below)

Important note:  no trailing line spaces in org.flathub.Bridgecommand.flatpakref or the following will fail.
install github repo 

[Flatpak Ref]
Title=Bridgecommand
Name=org.flathub.Bridgecommand
Branch=main
Url=https://emogic.com/bc/
SuggestRemoteName=BridgecommandRemoteEmogic
RuntimeRepo=https://dl.flathub.org/repo/flathub.flatpakrepo
IsRuntime=false


Distribute:

create single file to distribute and install locally:

flatpak build-bundle ~/bridgecommand_flatpak bridgecommand.flatpak org.flathub.Bridgecommand

Test install:

flatpak --user install bridgecommand.flatpak

Download and install from internet from emogic.com:

curl -O https://emogic.com/bridgecommand.flatpak

flatpak install --user bridgecommand.flatpak

Using emogic.com as a flatpak remote repository:

flatpak --user --no-gpg-verify remote-add emogicRemote https://emogic.com/bc

flatpak --user install emogicRemote org.flathub.Bridgecommand

or

flatpak install --user -v https://emogic.com/bc/org.flathub.Bridgecommand.flatpakref

Run it:

flatpak run org.flathub.Bridgecommand

Run flatpak environment and go to terminal:

flatpak run --allow=devel --command=bash org.flathub.Bridgecommand

flatpak run -d --command=bash org.flathub.Bridgecommand

---------------------------------

Make sure remotes are clean

flatpak remotes
flatpak remote-delete

---------------------------------

Reduce repo size

flatpak repair --user
flatpak uninstall --unused

---------------------

Setting up git:

generate :
ssh-keygen -t github -C "vpelss@gmail.com"

run everytime if you don’t set up environment:
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/github

take filename.pub and add it to github ‘deploy keys’

test access:
ssh -T git@github.com
git remote set-url origin git@github.com:vpelss/bridgecommand_flatpak.git
git remote -v

then we can 
git clone https://github.com/vpelss/bridgecommand_flatpak.git

change files
git add -f *
git commit -a
git push -f -v --mirror

-------------------
Create gpg keys:

gpg --quick-gen-key vpelss@gmail.com
gpg --export vpelss@gmail.com > key.gpg
base64 key.gpg | tr -d '\n'
gpg --armor --export

Sign it (if required):
flatpak-builder --gpg-sign=<key> --repo=bridgecommand_flatpak bridgecommand_flatpak/org.flathub.Bridgecommand.yml
GPG signing. Do ALL even the first ‘associating email with key’
https://docs.github.com/en/authentication/managing-commit-signature-verification/telling-git-about-your-signing-key
gpg --quick-gen-key vpelss@gmail.com
gpg --export vpelss@gmail.com > key.gpg
gpg --list-secret-keys --with-keygrip
gpg --list-secret-keys --keyid-format=long
gpg --list-signatures

public key:
 gpg --list-keys

private key:
gpg --output private.pgp --armor --export-secret-key vpelss@gmail.com
generate the base64 encoded GPGKey:
gpg --export vpelss@gmail.com > key.gpg
base64 key.gpg | tr -d '\n'
