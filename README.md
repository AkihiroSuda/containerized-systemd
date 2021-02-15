# Dockerfile examples for containerized systemd (mainly for test environments)

* `Dockerfile.archlinux`: Arch Linux (systemd 244, as of Feb 2020)
* `Dockerfile.centos-8.1`: CentOS 8.1 (systemd 239)
* `Dockerfile.debian-10`: Debian GNU/Linux 10 (systemd 241)
* `Dockerfile.fedora-31`: Fedora 31 (systemd 243)
* `Dockerfile.opensuse-tumbleweed`: openSUSE Tumbleweed (systemd 244, as of Feb 2020)
* `Dockerfile.ubuntu-20.04`: Ubuntu 20.04 (systemd 244)

## Demo 1: interactive shell with `systemctl`

* The command (`/bin/bash`) specified as the argument of `docker run` is executed as the foreground job in the container.
* Workdir (`--workdir /usr`) is propagated
* Env vars (`-e FOO=hello`) are propagated
* The container shuts down when the command exits. The exit status code (`42`) is propagated.

```console
host$ docker build -t foo -f Dockerfile.debian-10 .
host$ docker run -it --rm --privileged --workdir /usr -e FOO=hello foo /bin/bash
Created symlink /etc/systemd/system/docker-entrypoint.target.wants/docker-entrypoint.service → /etc/systemd/system/docker-entrypoint.service.
Created symlink /etc/systemd/system/systemd-firstboot.service → /dev/null.
Created symlink /etc/systemd/system/systemd-udevd.service → /dev/null.
/docker-entrypoint.sh: starting /lib/systemd/systemd --show-status=false --unit=docker-entrypoint.target
systemd 241 running in system mode. (+PAM +AUDIT +SELINUX +IMA +APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD -IDN2 +IDN -PCRE2 default-hierarchy=hybrid)
Detected virtualization docker.
Detected architecture x86-64.
Set hostname to <4608072355e2>.
+ /bin/bash
root@4608072355e2:/usr# systemctl status
● 4608072355e2
    State: running
     Jobs: 0 queued
   Failed: 0 units
    Since: Mon 2020-02-10 21:41:37 UTC; 3s ago
   CGroup: /system.slice/docker-4608072355e222fd25bdfa4b74e48c3f087f4d8128814a29d4035e7a8e42a364.scope
           ├─init.scope
           │ └─1 /lib/systemd/systemd --show-status=false --unit=docker-entrypoint.target
           └─system.slice
             ├─systemd-journald.service
             │ └─26 /lib/systemd/systemd-journald
             └─docker-entrypoint.service
               ├─38 /bin/sh -xec /bin/bash
               ├─39 /bin/bash
               ├─40 systemctl status
               └─41 pager
root@4608072355e2:/usr# pwd
/usr
root@4608072355e2:/usr# echo $FOO
hello
root@4608072355e2:/usr# exit 42
exit
host$ echo $?
42
```

## Demo 2: `journalctl -f`

```console
host$ docker run -it --rm --privileged foo journalctl -f
Created symlink /etc/systemd/system/docker-entrypoint.target.wants/docker-entrypoint.service → /etc/systemd/system/docker-entrypoint.service.
Created symlink /etc/systemd/system/systemd-firstboot.service → /dev/null.
Created symlink /etc/systemd/system/systemd-udevd.service → /dev/null.
/docker-entrypoint.sh: starting /lib/systemd/systemd --show-status=false --unit=docker-entrypoint.target
systemd 241 running in system mode. (+PAM +AUDIT +SELINUX +IMA +APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD -IDN2 +IDN -PCRE2 default-hierarchy=hybrid)
Detected virtualization docker.
Detected architecture x86-64.
Set hostname to <827af95def7e>.
+ journalctl -f
-- Logs begin at Wed 2020-02-12 06:20:22 UTC. --
Feb 12 06:20:22 827af95def7e systemd[1]: Started Flush Journal to Persistent Storage.
Feb 12 06:20:22 827af95def7e systemd[1]: Starting Create Volatile Files and Directories...
Feb 12 06:20:22 827af95def7e systemd[1]: Started Create Volatile Files and Directories.
Feb 12 06:20:22 827af95def7e systemd[1]: Condition check resulted in Network Time Synchronization being skipped.
Feb 12 06:20:22 827af95def7e systemd[1]: Reached target System Time Synchronized.
Feb 12 06:20:22 827af95def7e systemd[1]: Starting Update UTMP about System Boot/Shutdown...
Feb 12 06:20:22 827af95def7e systemd[1]: Started Update UTMP about System Boot/Shutdown.
Feb 12 06:20:22 827af95def7e systemd[1]: Reached target System Initialization.
Feb 12 06:20:22 827af95def7e systemd[1]: Started docker-entrypoint.service (journalctl -f).
Feb 12 06:20:22 827af95def7e systemd[1]: Startup finished in 410ms.
^Cgot signal INT
host$ echo $?
130
```

## Bugs
* `docker run` needs `-t`

## About --privileged

The examples above specify `--privileged`, but it's also possible to run these by "just" passing some other flags. These flags are: `--tmpfs /tmp --tmpfs /run --tmfs /run/lock -v /sys/fs/cgroup:/sys/fs/cgroup:ro`

If you pass `--privileged` in, then you're requiring that this container has full system privileges, which is often not required or wanted.

Some details are provided in [this post](https://developers.redhat.com/blog/2016/09/13/running-systemd-in-a-non-privileged-container/) but don't contain all the required tmpfs paths to mount.
