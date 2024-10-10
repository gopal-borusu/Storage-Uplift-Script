# Storage-Uplift-Script

Bash Shell Script useful for creating new mountpoint (or) extending the size of existing mountpoint. The script will ask the input from the user on the mountpoint details, FS Type, Size, Disk names,..etc. 

The script will then create the mountpoint if it does not exists already and it will extend the size if it already exists.

# Usage:

Execution: ./upliftscript.sh

In below example, I am extending one existing mountpoint "/home/test1" with size 1.5GB and creating one new mountpoint "/home/test2" with size of 1GB. To perform this uplift i am using /dev/sdb disk in my server. 

![image](https://github.com/user-attachments/assets/164a88b4-2bfb-444e-990f-a1a94177b7e8)

The script will ask for input from user like below highlighted ones to get the required details to create/extend the mountpoints. You need to enter all the required details carefully. Once all the details are entered the script will show the summary of the actions that it is going to perform and ask for confirmation to proceed. If you are fine with the details mentioned in summary you can proceed with excution of script by giving "y", else give "n" to quit.

<img width="752" alt="Capture" src="https://github.com/user-attachments/assets/eb881f58-b985-4250-8975-e4071a7fbac1">

Once the user confirmed to proceed if it is an existing mount script will simply extend it by given size, If it is a new mountpoint then the script will create the File System first , updates the /etc/fstab and mounts it.

![image](https://github.com/user-attachments/assets/00a39ff3-9c0d-4be1-afab-31df94d1f312)

# Verification

![image](https://github.com/user-attachments/assets/27b9d13c-0cab-4c18-8198-07634b9075e4)


![image](https://github.com/user-attachments/assets/3afdcc1f-7466-4b14-9009-52ea17801f08)
