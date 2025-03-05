read -p "Enter User's login :" inputuser

echo "Your Login User : $inputuser "
sudo 7z x -y /home/User.Settings.zip -o/home/"$inputuser"

sudo chown -R "$inputuser":user /home/"$inputuser"

sudo nala update && sudo apt upgrade -y

sudo nala clean

sudo dpkg-reconfigure sddm

echo "Plz Reboot by : sudo reboot"