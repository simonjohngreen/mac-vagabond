# MAC Vagabond #

### Current Status ###

* Seems to work fine on my Mac Pro M1 

### What is MAC Vagabond? ###

* While I really like my new Mac M1 (ARM Chip) and found it very well integrated from day 1 
* I sometime like to fire up Ubuntu VM's using Virtualbox and Vagrant, to test out code that typically ends up in public clouds
* Frustrated I was to find that Vagrant and Virtualbox are not supported on the ARM M1 chip, with no plans..
* 
* So I've put together a non Vagrant, or Vagrant like tool that everyone can use for free if they are frustrated like me
* Its cloudy.. I use the Ubuntu cloud images and cloud-init to send your configuration scriptsss
* mac-vagabond has a menu
* All files in  ubuntu-builder/[00-99]-[anything]  are passed into the VM and executed in numberical order automatically during the build, I've included an example file 10-*
* It seems to work..
* Good Luck

ps: thanks to Khaos Tian for ACVM, saved me a job patching QEMU.  

### How do I install and run MAC Vagabond ? ###

Simple..  

git clone xxxxx   
chmod a+x mac-vagrant.sh    
./mac-vagrant.sh    
  
you will see a menu like this...  
  
1) Build an Ubuntu VM and run my cloud-init script inside it 
2) Delete all local files ready to download and build the VM again   
3) Delete just the VM disk and the cloud-init data ready to build the VM again   
4) Start up a pre-built VM (don't rebuild it just start it) 
0) Exit  
  
Pick 1)  to start. The tool will do the rest.   


# mac-vagabond
