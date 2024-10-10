#!/bin/bash
#
#
#

echo "======= Storage Uplift Script ======";echo " "
read -p "Enter the VG name on which storage uplift will be performed: " VGNAME
echo "######## lsblk output from server end ########";lsblk;echo "##############################################"
echo "Enter the Disk Names that will be used for storage uplift (Ex: /dev/sdb /dev/sdc): "
read DISKNAMES
read -p "Enter the number of mounts you want to Extend/Create: " NOOFMOUNTS
mounts_array=()
mountcount=1
while [[ $mountcount -le $NOOFMOUNTS ]]
do
   read -p "Enter Mountpoint$mountcount Name: " MOUNTNAME
   mounts_array+=($MOUNTNAME)
   (( mountcount = mountcount + 1 ))
done
echo "Checking the mountpoint already exists or not"
mount_status=()
mount_fs=()
mount_fstype=()
mount_fssize=()
for i in "${mounts_array[@]}"
do
   mountpoint -q $i
   if [[ $? -eq 0 ]]
   then
      echo "$i is a existing mountpoint"
      FSnamecomp=$(findmnt -n $i | awk '{print $2}')
      vgnamecomp=$(lvdisplay $FSnamecomp | grep "VG Name" | awk '{print $3}')
      if [[ $vgnamecomp != $VGNAME ]]
      then
          echo "$FSnamecomp belongs to different VG, Exiting..."
          exit 1
      fi
      mount_status+=(0)
      mount_fs+=($(findmnt -n $i | awk '{print $2}'))
      mount_fstype+=($(findmnt -n $i | awk '{print $3}'))
      read -p "Enter the Size to Extend (Ex: 10G): " SIZE
      mount_fssize+=($SIZE)
   else
      echo "$i is not mounted"
      mount_status+=(1)
      read -p "Enter LV name: " LVNAME
      lvdisplay $VGNAME/$LVNAME > /dev/null 2>&1
      while [[ $? -eq 0 ]]
      do
         echo "There is existing LV with the name $LVNAME, Please choose some other name"
         read -p "Enter LV name: " LVNAME
         lvdisplay $VGNAME/$LVNAME
      done
      mount_fs+=(/dev/mapper/$VGNAME-$LVNAME)
      read -p "Enter Filesystem Type (Ex: xfs): " FSTYPE
      mount_fstype+=($FSTYPE)
      read -p "Enter the Size to create the mountpoint (Ex: 10G): " SIZE
      mount_fssize+=($SIZE)
   fi
done
#### Confirmation

echo "Please read the below details carefully before proceeding further"
echo "The script will perform the storage uplift on $VGNAME"
echo "The disk names that are being used for this uplift are:"
for z in $DISKNAMES;do echo $z;done
echo "Total Mountpoint created/extended by the script will be = $NOOFMOUNTS"
loopcount=0
while [[ $loopcount -lt $NOOFMOUNTS ]]
do
   if [[ ${mount_status[$loopcount]} -eq 0 ]]
   then
     echo "${mounts_array[$loopcount]} having File system ${mount_fs[$loopcount]} will be extended by size ${mount_fssize[$loopcount]}"
   else
     echo "${mounts_array[$loopcount]} will be created and mounted as an ${mount_fstype[$loopcount]} type FS with ${mount_fssize[$loopcount]} Size and File system name as ${mount_fs[$loopcount]}"
   fi
   (( loopcount = loopcount + 1 ))
done
read -p "Provide Confirmation to proceed (y/n): " confirm
if [[ $confirm == y ]]
then
   echo "Proceeding with script"
   pvcreate $DISKNAMES 
   vgdisplay $VGNAME  > /dev/null 2>&1
   if [[ $? -eq 0 ]]
   then
       vgextend $VGNAME $DISKNAMES 
   else
       vgcreate $VGNAME $DISKNAMES 
   fi
   loopcount=0
   while [[ $loopcount -lt $NOOFMOUNTS ]]
   do
      if [[ ${mount_status[$loopcount]} -eq 0 ]]
      then
         lvextend -L +${mount_fssize[$loopcount]} ${mount_fs[$loopcount]} -r 
      else
         FSnametemp=${mount_fs[$loopcount]}
         echo $FSnametemp
         LVNAMEINP=$(echo "${FSnametemp}" | awk -F "${VGNAME}-" '{print $2}')
         lvcreate -L ${mount_fssize[$loopcount]} -n $LVNAMEINP $VGNAME 
         mkfs.${mount_fstype[$loopcount]} ${mount_fs[$loopcount]}
         mkdir -p ${mounts_array[$loopcount]}
         echo "${mount_fs[$loopcount]} ${mounts_array[$loopcount]} ${mount_fstype[$loopcount]} defaults 0 0" >> /etc/fstab
         mount -a
      fi
      (( loopcount = loopcount + 1 ))
   done
else
   echo "Exiting as per user confirmation"
   exit 1
fi
