# minimal-slurm

This is my minimal setup to get slurm running both the compute and the controller node on the same machine.

Some useful references:
- a docker image for slurm: https://github.com/SciDAS/slurm-in-docker this image contains each node type of slurm separated
- a reference for setup in ubuntu: https://github.com/mknoxnv/ubuntu-slurm (they contain the systemd.service file)
- slurm download page: https://www.schedmd.com/downloads.php
- quickstart: https://slurm.schedmd.com/quickstart_admin.html
- slurm configuration: https://slurm.schedmd.com/slurm.conf.html
- gres (gpu etc) if needed: https://slurm.schedmd.com/gres.html

## The script

```
## Required packages
apt-get update && apt-get upgrade
# When installing mailutils you may set it as "Local only".
apt-get install build-essential python libmunge-dev libmunge2 mailutils
# We will create user, folders and change permissions
adduser slurm #any pass will suffice
mkdir -p /slurm/state
chown slurm /slurm/state
chgrp slurm /slurm/state
mkdir /slurm/state/slurmd
chown slurm /slurm/state/slurmd
chgrp slurm /slurm/state/slurmd
cd /slurm
# get the latest slurm on https://www.schedmd.com/downloads.php - PLEASE NOTE THAT THIS WILL CHANGE THE CONFIG FILE
wget https://download.schedmd.com/slurm/slurm-19.05.1-2.tar.bz2
# unzip the file
tar -xvf slurm*
cd slurm-19.05.1-2
# configure for compilation
./configure
# compile, instead of 6 use a number slightly higher than the number of cpu cores available
make -j 6 # bit heavy
make install #move the files to the preffixed folders defined in ./configure step. I'd expect /usr/local/bin/ and /usr/local/sbin by default
ldconfig -n /usr/local/lib/slurm # this is to link the used library
```

## Settings

The file /slurm/slurm-19.05.1-2/doc/html/configurator.html can be used to create the configuration file. If there is any issue setting it, check the bold names on the slurm configuration link above. The configuration for the default amount of memory per task needs to be defined manually (**DefMemPerCPU**), otherwise (value 0) it will use all the node memory. If using my sample slurm.conf, set the node name correctly in the beginning **SlurmctldHost=main-kek**. In the end fix the name and other settings as well: 

**NodeName**=main-kek **CPUs**=4 **RealMemory**=15500 **Sockets**=4 **CoresPerSocket**=1 **ThreadsPerCore**=1 State=UNKNOWN
PartitionName=showtime Nodes=**main-kek** Default=YES MaxTime=INFINITE State=UP

Move the files slurm.conf and cgroup.conf to /usr/local/etc/slurm.conf and /usr/local/etc/cgroup.conf

## Auto-startup

```
# get the .service files from this repository
cp slurmd.service /etc/systemd/system/
cp slurmctld.service /etc/systemd/system/

systemctl daemon-reload
systemctl enable slurmctld
systemctl start slurmctld
systemctl enable slurmd
systemctl start slurmd
# other useful commands are:
systemctl status slurmctld # show the status of the service
journalctl -u slurmctld.service -b #print the log since the boot
```

## Some useful slurm commands

```
sinfo
scontrol update NodeName=vvv-slurm State=RESUME
squeue
srun --pty /bin/bash
scancel -H jid
scontrol show node main-kek #show information the node "main-kek"
```
