# Manual guide

This guide uses example data wrapped around double curly brackets - `{{example_data}}`. You should replace it with valid values of your own choice.

## NAS setup

1. Connect to Raspberry Pi through SSH (using `ssh`, `putty` or some other SSH client of choice).

2. Create new users - `{{admin}}` (an administrator) and `{{user}}` (a shared user) with passwords of choice:

   ```
   $ sudo useradd -m {{admin}} -p {{admin_password}}
   $ sudo useradd -m {{user}} -p {{user_password}}
   ```

3. Create a new group `{{group}}` for both adminisitrator and shared user:

   ```
   $ sudo groupadd {{group}}
   ```

4. Add `{{admin}}` and `{{user}}` to the newly created group `{{group}}`:

   ```
   $ sudo usermod -a -G {{group}} {{admin}}
   $ sudo usermod -a -G {{group}} {{user}}
   ```

5. Make sure everything went fine with:

   ```
   $ grep {{group}} /etc/group
   {{group}}:x:1003:{{admin}},{{user}}
   ```

6. Locate plugged USB flash drive(s) paritions with:

   ```
   $ sudo fdisk -l
   ```

7. There will likely be many disks and partitions shown but the ones relevant can be labeled somewhat similarly to `Disk model: Flash Drive` or simply matched by their storage size.

   > In my case the partitions were `/dev/sda1` and `/dev/sdb1` because I was using two USB flash drives.

8. Format the disk(s) to `vfat` format:

   > In case you're using more than one USB flash drive you should run this command for all of them.

   ```
   $ sudo mkfs -t vfat {{partition}}
   ```

9. Create a `{{mount_point}}` directory for USB flash drive(s) at any fitting location. It's a good practice to place them in `/mnt`:

   > For multiple flash drives make sure to create a unique mount point for each of them - In my case `/mnt/usb-flash-drive-01` and `/mnt/usb-flash-drive-02`.

    ```
    $ sudo mkdir {{mount_point}}
    ```

10. Mount the drives at newly created mount points, it's very important to set group and user permissions at mount with `uid`, `gid`, `dmask` and `fmask`:

    > For more than one USB flash drive you should run this command for all the drives.

    ```
    sudo mount -t vfat -o rw,uid={{admin}},gid={{group}},dmask=0007,fmask=0007 {{partition}} {{mount_point}}
    ```

11. Login as `{{admin}}` user:

    ```
    $ sudo su {{admin}}
    ```

12. Create a `{{nas_directory}}` directory on the USB flash drive(s):

    > If using more than one drive, create a `{{nas_directory}}` directory on each of them.

    ```
    mkdir {{mount_point}}/{{nas_directory}}
    ```

13. Go back to the root user.

    ```
    exit
    ```

14. Install `samba`:
    ```
    sudo apt-get install samba
    ```

15. Add `{{user}}` to `samba`:
    ```
    sudo smbpasswd -a {{user}}
    ```

16. Make a backup of `smb.config` in home directory:

    ```
    cp /etc/samba/smb.conf ~
    ```

17. Set up file sharing through `samba` - use text editor of choice to edit `/etc/samba/smb.config`:

    ```
    sudo nano /etc/samba/smb.config
    ```

    And add necessary config section at the end of file:

    ```
    # NAS
    [nas]
       comment = NAS (Network Attached Storage)
       path = {{mount_point}}/{{nas_directory}}
       valid users = {{admin}}, {{user}}
       read only = no
    ```

18. Restart `samba`:

    ```
    sudo service smbd restart
    ```

19. You can now connect to your network drive at `//{{raspberry_pi_ip_address}}/{{nas_directory}}` with `{{user}}` credentials.

    > On Windows use backslashes instead of slashes in the address - `\\{{raspberry_pi_ip_address}}\{{nas_directory}}`.

## Backup setup

This part of the guide is fully **optional** and it **requires more than one USB flash drive**.

20. Login as `{{admin}}` again:

    ```
    $ sudo su {{admin}}
    ```

21. Go to `{{admin}}` home directory:

    ```
    $ cd ~
    $ pwd
    /home/{{admin}}
    ```

22. Create a new `cron` directory:

    ```
    mkdir cron
    ```

23. Go to the newly created `cron` directory:

    ```
    $ cd cron
    ```

24. Create a `backup.sh` file and edit it with a preferred text editor:

    ```
    $ nano backup.sh
    ```

25. Enter the following content into the `backup.sh` file:

    > If using more than two USB flash drives repeat this line for all of them.

    ```
    rsync -a {{mount_point_01}}/{{nas_directory}}/* {{mount_point_02}}/{{nas_directory}}
    ```

26. Create a `crontab.txt` file and edit it with a preferred text editor:
    ```
    $ nano crontab.txt
    ```

27. Enter the following content into the `crontab.txt` file:

    > You can use any cron expression of choice. This default `0 0 * * *` will make sure the backups run every day at midnight (00:00 a.m.).

    ```
    0 0 * * * /home/{{admin}}/cron/backup.sh > /dev/null
    ```

28. Register a new cron job to backup files from the main USB flash drive to the rest of them:
    ```
    $ crontab crontab.txt
    ```

29. Make sure the crontab was registered correctly:
    ```
    $ crontab -l
    0 0 * * * /home/{{admin}}/cron/backup.sh > /dev/null
    ```

30. Now the backups should run periodically at chosen time.
