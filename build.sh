#!/usr/bin/env bash

############################## Utility functions ###############################

echo "Setting the environment up..."
echo ""

# Based on an answer by miken32 at: https://stackoverflow.com/a/50938224

is_array() {
    # No argument passed
    [[ $# -ne 1 ]] && echo "Supply a variable name as an argument">&2 && return 2

    var=$1
    # Use a variable to avoid having to escape spaces
    regex="^declare -[aA] ${var}(=|$)"
    [[ $(declare -p $var 2> /dev/null) =~ $regex ]] && return 0
}

################################ Configuration #################################

echo "Preparing the configration..."
echo ""

# Define default values

format_drives="true"
mount_points="/mnt/usb-flash-drive"
partitions="/dev/sda1"
shared_directory="nas"
admin_name="nas_admin"
admin_pass="nas_admin1"
user_name="nas_user"
user_pass="nas_user1"
group_name="nas_group"
cron_backup_frequency="0 0 * * *"

# Source user defined `config.sh` file

. ./config.sh


################################ Initial checks ################################

echo "Running initial checks..."
echo ""

# Ensure that the script is executed by root

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
  echo "Error: you need to be root to execute this script"
  exit
fi

# Check if `format_drives` has a correct value - "true", "false" or empty

if [ "$format_drives" != "true" ] && [ "$format_drives" != "false" ] && [ "$format_drives" != "" ]; then
  echo "Error: format_drives must either be \"true\", \"false\" or empty"
  exit
fi

# Make sure that `mount_points` and `partitions` are matching arrays or strings

if is_array mount_points; then
  if ! is_array partitions; then
    echo "Error: partitions must be an array"
    exit
  fi
fi

if is_array partitions; then
  if ! is_array mount_points; then
    echo "Error: mount_points must be an array"
    exit
  fi
fi

if [[ ${#mount_points[@]} -ne ${#partitions[@]} ]]; then
  echo "Error: mount_points and partitions must be of the same length"
  exit
fi

# Check if shared_directory does not start and end with a slash or backslash

if [[ ${shared_directory:0:1} == "/" ]]; then
  echo "Error: shared_directory should not start with a slash character \"/\""
  exit
elif [[ ${shared_directory:0:1} == "\\" ]]; then
  echo "Error: shared_directory should not start with a backslash character \"\\\""
  exit
elif [[ ${shared_directory: -1} == "/" ]]; then
  echo "Error: shared_directory should not end with a slash character \"/\""
  exit
elif [[ ${shared_directory: -1} == "\\" ]]; then
  echo "Error: shared_directory should not end with a backslash character \"\\\""
  exit
fi

# Check if mount_points do not end with a slash or backslash

if is_array mount_points; then
  for mount_point in ${mount_points[@]}
  do
    if [[ ${mount_point: -1} == "/" ]]; then
      echo "Error: mount_points must not end with a slash character \"/\""
      exit
    elif [[ ${mount_point: -1} == "\\" ]]; then
      echo "Error: shared_directory should not end with a backslash character \"\\\""
      exit
    fi
  done
else
  if [[ ${mount_points: -1} == "/" ]]; then
    echo "Error: mount_points must not end with a slash character \"/\""
    exit
  elif [[ ${mount_points: -1} == "\\" ]]; then
    echo "Error: mount_points must not end with a backslash character \"\\\""
    exit
  fi
fi

################################## NAS Setup ###################################

echo "Starting NAS setup..."
echo ""

# Create administrator, shared user and a group for both of them

echo "Creating users \"$admin_name\" and \"$user_name\" and \"$group_name\" group..."
echo ""

useradd -m $admin_name -p $admin_pass
useradd -m $user_name -p $user_pass
groupadd $group_name

# Add users to the group

usermod -a -G $group_name $admin_name
usermod -a -G $group_name $user_name

# Format the USB flash drive(s) to `vfat` format:

if [ "$format_drives" == "true" ]; then
  echo "Formatting USB flash drive(s)..."
  echo ""

  if is_array partitions; then
    for partition in ${partitions[@]}
    do
      mkfs -t vfat $partition
    done
  else
    mkfs -t vfat $partitions
  fi
else
  echo "Skipping formatting USB flash drives(s)..."
  echo ""
fi

# Create mount points for USB flash drive(s)

echo "Creating mount point(s)..."
echo ""

if is_array mount_points; then
  for mount_point in ${mount_points[@]}
  do
    mkdir $mount_point
  done
else
  mkdir $mount_points
fi

# Mount the drives at defined mount points

echo "Mounting the drive(s)..."
echo ""

if is_array mount_points; then
  for ((i=0; i < ${#mount_points[@]}; ++i)); do
    mount -t vfat -o rw,uid=$admin_name,gid=$group_name,dmask=0007,fmask=0007 ${partitions[i]} ${mount_points[i]}
  done
else
  mount -t vfat -o rw,uid=$admin_name,gid=$group_name,dmask=0007,fmask=0007 $partitions $mount_points
fi

# As an administrator create shared directories on USB flash drive(s)

echo "Creating shared directory \"$shared_directory\"..."
echo ""

if is_array mount_points; then
  for mount_point in ${mount_points[@]}
  do
    su $admin_name <<EOT
mkdir $mount_point/$shared_directory
EOT
  done
else
  su $admin_name <<EOT
mkdir $mount_points/$shared_directory
EOT
fi

# Install and configure `samba`

echo "Installing and configuring samba..."
echo ""

apt-get -y update
DEBIAN_FRONTEND=noninteractive apt-get -y install samba

(echo $user_pass; echo $user_pass) | smbpasswd -s -a $user_name

cp /etc/samba/smb.conf ~

if is_array mount_points; then
  nas_samba_path="${mount_points[0]}/$shared_directory"
else
  nas_samba_path="$mount_points/$shared_directory"
fi

tee -a /etc/samba/smb.conf > /dev/null <<EOT
# NAS
[nas]
   comment = NAS (Network Attached Storage)
   path = $nas_samba_path
   valid users = $admin_name, $user_name
   read only = no

EOT

service smbd restart

# Optionally register backups if multiple USB flash drives were configured

if is_array mount_points; then
  echo "Configuring periodic backups..."

  su $admin_name <<EOT
mkdir ~/cron

touch ~/cron/backup.sh

cat <<EOF >> ~/cron/backup.sh
$(for mount_point in ${mount_points[@]:1}; do echo "rsync -a ${mount_points[0]}/$shared_directory/* $mount_point/$shared_directory"; done)
EOF

touch ~/cron/crontab.txt

cat <<EOF >> ~/cron/crontab.txt
$cron_backup_frequency /home/$admin_name/cron/backup.sh > /dev/null
EOF

crontab ~/cron/crontab.txt
EOT
fi
