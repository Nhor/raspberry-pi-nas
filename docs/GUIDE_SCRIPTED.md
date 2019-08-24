# Scripted guide

## Executing the build script

1. The very first thing to do is to copy this whole project directory via `scp` onto your Raspberry Pi or install a Git client on the Raspberry Pi and clone this repository.

2. Copy the `config.sh.example` example configuration file and name it `config.sh`:

   ```
   cp config.sh.example config.sh
   ```

3. Make sure you have required permissions to execute the scripts:

   ```
   sudo chmod +rwx config.sh
   sudo chmod +rx build.sh
   ```

4. Edit the `config.sh` file with a preferred text editor and adjust the configuration variables to your environment.

5. Run the `build.sh` script with `sudo`:

   ```
   sudo ./build.sh
   ```

6. When the script finishes with no error everything should be set up. Now you should be able to connect to your network drive at `//{{raspberry_pi_ip_address}}/shared_directory` with `user` credentials.

    > On Windows use backslashes instead of slashes in the address - `\\{{raspberry_pi_ip_address}}\shared_directory`.

## Troubleshootig

7. If you're not able to establish a connection you can make double sure everything went fine with some sanity checks:

   - ##### Users and group were created and configured

     ```
     $ . ./config.sh grep $group_name /etc/group
     ```

     Should output something similar to:

     ```
     group:x:1003:admin,user
     ```

   - ##### USB flash drive(s) were correctly mounted and associated with configured `mount_points`:

     ```
     $ mount -l
     ```

     Should contain configured mount points and partitions in its output:

     ```
     /dev/sda1 on /mount-point vfat (rw,relatime,uid=1001,gid=1003,fmask=0007,dmask=0007,allow_utime=0020,codepage=437,iocharset=ascii,shortname=mixed,errors=remount-ro)
     ```

   - ##### `samba` is running and has correct configuration:

     ```
     $ service smbd status
     ```

     Should have similar output to:

     ```
     smbd.service - Samba SMB Daemon
        Loaded: loaded (/lib/systemd/system/smbd.service; enabled; vendor preset: enabled)
        Active: active (running)
     ```

     And

     ```
     tail -n 8 /etc/samba/smb.conf
     ```

     Should contain something like:

     ```
     # NAS
     [nas]
        comment = NAS (Network Attached Storage)
        path = /mount_point/shared_directory
        valid users = admin, user
        read only = no
     ```

   - ##### In case of using multiple USB flash drives you can also check if cron backups were configured correctly

     ```
     $ sudo su $admin_name <<EOT
     crontab -l
     EOT
     ```

     Should output:

     ```
     0 0 * * * /home/admin/cron/backup.sh > /dev/null
     ```
