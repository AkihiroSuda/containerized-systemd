# Dockerfile examples for containerized systemd

* `Dockerfile.archlinux`: Arch Linux (systemd 244, as of Feb 2020)
* `Dockerfile.centos-8.1`: CentOS 8.1 (systemd 239)
* `Dockerfile.debian-10`: Debian GNU/Linux 10 (systemd 241)
* `Dockerfile.fedora-31`: Fedora 31 (systemd 243)
* `Dockerfile.opensuse-tumbleweed`: openSUSE Tumbleweed (systemd 244, as of Feb 2020)
* `Dockerfile.ubuntu-20.04`: Ubuntu 20.04 (systemd 244)

## Demo

* The command specified as the argument of `docker run` is executed as the foreground job in the container.
* The container shuts down when the command exits. The exit status code is propagated.

```console
host$ docker build -t foo -t Dockerfile.debian-10 .
host$ docker run -it --rm --privileged foo /bin/bash
/docker-entrypoint.sh: starting /sbin/init --show-status=false --unit=docker-entrypoint.target
systemd 241 running in system mode. (+PAM +AUDIT +SELINUX +IMA +APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNUTLS +AC
L +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD -IDN2 +IDN -PCRE2 default-hierarchy=hybrid)
Detected virtualization docker.
Detected architecture x86-64.
Set hostname to <d706a1efa101>.
root@d706a1efa101:/# systemctl status
● d706a1efa101
    State: running
     Jobs: 0 queued
   Failed: 0 units
    Since: Mon 2020-02-10 18:22:03 UTC; 31s ago
   CGroup: /system.slice/docker-d706a1efa10104a81a2a696737be3492baa811e2b5e9b1c06a2f1ab89b2c70da.scope
           ├─init.scope
           │ └─1 systemd --show-status=false --unit=docker-entrypoint.target
           └─system.slice
             ├─systemd-journald.service
             │ └─23 /lib/systemd/systemd-journald
             └─docker-entrypoint.service
               ├─36 /bin/bash
               ├─37 systemctl status
               └─38 pager
root@d706a1efa101:/# exit 42
exit
host$ echo $?
42
```

## Bugs
* `docker run` needs `-t`
