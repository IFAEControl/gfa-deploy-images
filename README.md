## How to

### Client side

To install client components of a release use the next script:

`utils/deploy_client.sh <dir> <release>`

where **dir** is the directory where the python virtual environment will be created and release the release folder, for example: `utils/deploy_client.sh /tmp 201810160939`

This script will install all the libraries and dependencies. To activate this virtual environment we simply have to execute `source <dir>/gfa_venv/bin/activate`


### Server side

Copy tar file with the firmware to the remote system: `scp <release>/*.tar root@<ip>:/tmp/yocto.tar` 

Then, once we get a shell in the remote system we should copy the firmware files to the appropriate place.

If we are using an SD card then we will use the next script:
```bash
mount /dev/mmcblk0p1 /mnt
/bin/rm -f /mnt/*
tar --no-same-owner -xvf /tmp/yocto.tar -C /mnt/
umount /mnt
```

If we are using the QSPI flash memory (if there are some error fix it before rebooting):
```bash
tar --no-same-owner -xvf /tmp/yocto.tar -C /tmp/
cd /tmp
flashcp -v boot.bin /dev/mtd0
flashcp -v uImage /dev/mtd1
flashcp -v devicetree.dtb /dev/mtd2
flashcp -v uramdisk /dev/mtd5
```

Once copied the system must be rebooted: `reboot`
