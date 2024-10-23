How to install Bridgecommand (https://www.bridgecommand.co.uk/) in flatpak. 
Note: it has also been compiled for Linux on PC and Raspbian on Pi4 (aarch64).

Install flatpak:

sudo apt install flatpak

Instal Bridgecommand:

sudo flatpak install -v https://vpelss.github.io/bridgecommand_flatpak/org.flathub.Bridgecommand.flatpakref

Run it:

flatpak run org.flathub.Bridgecommand

----------------------

Instructions for how the flatpak was built:

https://raw.githubusercontent.com/vpelss/bridgecommand_flatpak/refs/heads/main/Instructions.txt
