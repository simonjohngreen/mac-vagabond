#!/bin/zsh
#vars
source ./config/variables.sh

green='\e[32m'
blue='\e[34m'
clear='\e[0m'
ColorGreen(){
	echo -ne $green$1$clear
}
ColorBlue(){
	echo -ne $blue$1$clear
}

function menu(){
echo "************************************************************"
echo "Main Menu. Select an option:"
echo "************************************************************"

echo -ne "
$(ColorGreen '1)') Build an Ubuntu VM and run my cloud-init script inside it 
$(ColorGreen '2)') Delete all local files ready to download and build the VM again 
$(ColorGreen '3)') Delete just the VM disk and the cloud-init data ready to build the VM again 
$(ColorGreen '4)') Start up a pre-built VM (don't rebuild it just start it) 
$(ColorGreen '0)') Exit
$(ColorBlue 'Choose an option:') "
        read a
        case $a in
	        1) build_vm ; menu ;;
	        2) clean_up_directory ; menu ;;
	        3) clean_up_vm_disk ; menu ;;
	        4) start_vm ; menu ;;
	 	0) exit 0 ;;
		*) echo -e $red"Wrong option."$clear; WrongCommand ; menu ;;
        esac
}

function build_vm(){
	#install the ubuntu cloud image and ACVM SW locally
        echo "Building your VM"
	if test -d "$ACVMAPPNAME"; then
	    echo "ACVM.app already present so skipping download" 
	else
	    wget $ACVMLINK 
	    unzip $ACVMFILENAME
            rm $ACVMFILENAME 
	fi
	if test -f "disks/$CLOUDIMAGEFILENAME"; then
	    echo "Cloud disk image file disks/$CLOUDIMAGEFILENAME already present so skipping download." 
	else
            mkdir disks
	    wget $CLOUDIMAGELINK -O disks/$CLOUDIMAGEFILENAME 
	fi
	
	if test -f "disks/$VMIMAGEFILENAME"; then
	    echo "VM disk image file disks/$VMIMAGEFILENAME already present." 
	    echo "Note: If you were looking to create a fresh VM then delete the file and rerun" 
	else
	    echo "Creating the VM disk file" 
	    cp disks/$CLOUDIMAGEFILENAME disks/$VMIMAGEFILENAME
	    echo "increasing the VM image disk size" 
	    ./ACVM.app/Contents/Resources/qemu-img info disks/$VMIMAGEFILENAME 
	    ./ACVM.app/Contents/Resources/qemu-img resize disks/$VMIMAGEFILENAME $VMIMAGESIZE 
	    ./ACVM.app/Contents/Resources/qemu-img info disks/$VMIMAGEFILENAME 
	fi
	
	#make a seed iso disk image with the cloud-init data and other useful files 
	#cidata file
	rm -rf cidata
	mkdir cidata 
cat >cidata/meta-data <<EOF
local-hostname: MACM1VM 
EOF
	#ssh key for cloud-init
	if [ -f $HOME/.ssh/id_rsa.pub ] ; 
	then
	    export PUB_KEY=$(cat $HOME/.ssh/id_rsa.pub)
	else
	    echo "I can't find your ssh key in order to setup ssh access"
	    echo "I'll make a key for you in /cidata"
	    echo "But you need to remeber to use that pusblic key ssh -i ./cidata/id_rsa ubuntu@127.0.0.1"
	    echo "You might consider running \"ssh-keygen -t rsa\" to create your own ssh key and going again"
	    ssh-keygen -b 2048 -t rsa -f ./cidata/id_rsa -q -N ""
	fi
	
	#make the user-data file
cat >cidata/user-data <<EOF
#cloud-config
users:
  - name: ubuntu
    ssh-authorized-keys:
      - $PUB_KEY
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    groups: sudo
    shell: /bin/bash
runcmd:
  - echo "login=ubuntu password=password" >> /etc/issue
  - echo "AllowUsers ubuntu" >> /etc/ssh/sshd_config
  - restart ssh
  - mkdir /mnt/iso
  - mount /dev/vdb /mnt/iso
  - echo "/dev/vdb /mnt/iso iso9660 loop 0 0" >> /etc/fstab
  - echo 'ubuntu:password' | chpasswd
  - echo 'root:password' | chpasswd
  - /mnt/iso/build.sh | tee /dev/console /tmp/build.log > /dev/null
  - /mnt/iso/build.sh
EOF

	#copy the variables file over to the iso
	cp config/variables.sh cidata

	#copy the ubuntu build files over to the iso
	cp ubuntu-builder/* cidata

	#make the cidata files executable
	chmod a+x cidata/*
 
	#mac specific,  make the cidata iso
	rm disks/cidata.iso
	hdiutil makehybrid -o disks/cidata.iso cidata -iso -joliet

cat << EOF
************************************************************
Building the VM:
************************************************************

Build:

Go get a quick coffee while the VM builds itself

Next time around you can just start the VM, which only takes 10 seconds. 

Access:

I expose ports 2222 (ssh) and 8080 (http) you can add more in file ubuntu-builder/ubuntu-vm-boot.sh 

How to Login: 

	To Login via the console prompt user=ubuntu password=password
	To login using ssh in another terminal ssh ubuntu@127.0.0.1 -p 2222

Controlling the VM:

	To stop the VM from this console, [cntrl]+a x
	To shutdown the VM from inside >sudo shutdown -h now

	To start, rebuild, cleanup etc the VM. just use the menu

***************************************************************
Hit any key to launch and build  your VM
***************************************************************
EOF
	read
	./ubuntu-builder/ubuntu-vm-boot.sh
}

function clean_up_directory(){
        echo "************************************************************"
        echo "cleaning up your files ready to rebuild the VM:"
        echo "************************************************************"
        rm -rf $ACVMAPPNAME 
        rm $ACVMFILENAME 
        rm disks/$CLOUDIMAGEFILENAME 
	rm disks/cidata.iso
	rm -rf cidata
	rm disks/$VMIMAGEFILENAME
        rm -rf disks
}

function clean_up_vm_disk() {
        echo "************************************************************"
        echo "deleting the VM disk and cloud-init data:"
        echo "************************************************************"
	rm disks/$VMIMAGEFILENAME		
	rm disks/cidata.iso
        rm -rf cidata
}

function start_vm(){
        echo "************************************************************"
        echo "Starting up your pre-built VM:"
        echo "************************************************************"
	./ubuntu-builder/ubuntu-vm-boot.sh
}

#run the menu
menu
