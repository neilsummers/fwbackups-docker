# fwbackups-docker
A wrapper around fwbackups using a Docker container to run fwbackups with Python2

## fwbackups
A feature-rich user backup program that allows you to backup your documents on a one-off or recurring scheduled basis.
Note: fwbackups is in maintenance only mode. Development of new features are on hold, and only bugfixes are applied.
It requires Python 2 and PyGTK 2 to launch, which recent distributions may no longer include by default.
https://github.com/stewartadam/fwbackups

### Why fwbackups-docker ?
Python2 support is being deprecated and since Ubuntu 20.04 Focal Fossa, I could no longer have a working Python2
environment alongside the default Python3, which could have all the packages needed to run fwbackups.
I tried to quickly port it to Python3, but Gtk2 -> Gtk3 conversion is non-trivial and was beyond the time I had.
So I came up with a Docker solution to run fwbackups using an older version of Ubuntu 18.04 with all the packages needed
to run fwbackups installed. There were other fwbackups-docker solutions out there, but they did not meet my needs,
so I build my own. I also could not find other backup solutions that I liked, so I wanted to be able to continue using
this after Python2 is deprecated.

## Features
* Installs fwbackups-1.43.7 in a Docker container with an Ubuntu 18.04 base image
* Usage and appearance should be as before with no changes needed to run fwbackups except a modifcation to the paths in
the backup sets (see below)
* Installs all dependencies needed to run `fwbackups` inside the container
* Installs dependencies needed to run Docker on the localhost
* Creates the `$USER` who builds and installs `fwbackups-docker` inside the container so the files have the same
ownership and permissions as if the `fwbackups` was installed from source
* Provides wrappers to replace the scripts installed by `fwbackups` (which are now only installed in the Docker
container) which run the Docker container with the required options
* Provides `Makefile` for easy build and install/uninstall
* Installs the `fwbackups.desktop` and `fwbackups` directory in the shared directory so that fwbackups appears in the start
menu
* Fixes bug in these files which did not take into account install destination
* Docker image mounts the files needed to run the X11 app and display it on the localhosts display
* Docker image mounts the `~/.fwbackups` directory in the users `$HOME` so that all configuration files can be modified
within the app and changes appear in the users home
* Docker image mounts the `~/.config/autostart` directory so that when the autostart option in the Preferences is selected
the file is added to the users `$HOME` config so autostart will work
* Docker image mounts the localhost root file system (`/`) at `/filesystem` in the Docker image
  * This means that any configurations currently used under a previous install will need to be updated to prepend
  `/filesystem` to both the Paths and Destination paths in the app.
    * A script `update_sets` is provided to make this change to the sets defined in `~/.fwbackups/Sets/*.conf`
  * Unfortunately this means that the first run will not be incremental from the old backups
  * This could be hacked to remove the top level `/filesystem` path but this was deemed to much effort
* Docker image mounts timezone information so it matches the localhost
* Only works for Linux and local backup
  * Could be extended for remote backup but would need to open ports in Docker image
* Contains a script to start a Docker bash shell for debugging
* All settings and configurations within the `fwbackups` app should function as described in fwbackups except for the
extra path issue described above
* The `fwbackups` tray icon still works as before

## Building & Installation
To build and install `fwbackups-docker` run
```commandline
$ sudo make build-env    # optional step to install docker-ce-cli autotools-dev in local enviroment via apt
$ make build
$ sudo make install
```
To uninstall run
```commandline
$ sudo make uninstall
```
To remove Docker image run
```commandline
$ make clean
```
## Usage
fwbackups installs a menu entry under `Applications > System Tools` to start the backup administrator, a GUI tool to manage sets or perform one-time backups and restore operations. It can also be started from the CLI:

```commandline
$ fwbackups
```
The installed wrappers allow `fwbackups-docker` to run in exactly the same way as `fwbackups` and are installed in `/usr/local/bin`, so this needs to be in your `$PATH`.

## TODO
This is not a working version yet. While the app runs, and can make and edit the Backup Sets, the interaction with cron
is not working yet. Modifications to the Sets which should change the crontabs entry do not appear to change the crontab
which resides on the local host (not in the docker container).
Also have issues with being able to write to files mounted read-only in the docker which makes the way the local filesystem
is mounted unsafe. My aim was to have only the backup locations mounted write along with any files that are needed for configurations
and the rest mounted read-only for safety, but there seems to be a bug in docker which allows me to write to read-only volumes. Still investigating.
