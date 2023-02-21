# Debian Chroot

## `create.sh`

Creates a chroot of Debian's unofficial architecture (debian-ports, default to riscv64) for packaging and debugging. Official ones can be supported by replacing the mmdebstrap sources.

Before running the script, make sure necessary packages are installed:

```console
$ sudo apt install mmdebstrap qemu-user-static binfmt-support debian-ports-archive-keyring
```

This script does a handful of things:

- Basic chroot is installed using `mmdebstrap`, with packages useful for contributing.
- Edits hostname in accordance with directory path
- Creates a normal user `debian` with sudo `NOPASSWD` permission, and sets the root password to `root`.
- Adds Debian quilt shorthand `dquilt` according to [Guide for Debian Maintainers](https://www.debian.org/doc/manuals/debmake-doc/ch03.en.html#quilt-setup).

### Caveat

Unfortunately `sudo` inside Debian chroot on Arch Linux seems broken, for it always returns "effective uid is not 0". It works fine on Debian, and Arch chroot works fine, so it shouldn't be my problem. I had decided to use Debian VM for my work.

## `start.sh`

Starts a previously-created chroot using `systemd-nspawn`. It requires `systemd-containers` to be installed on Debian, for example.
