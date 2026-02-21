# Busybox for Bare Minimal Linux System

(c) 2026, Roberto A. Foglietta <roberto.foglietta@gmail.com>, CC BY-NC-ND 4.0

> [!NOTE]
>
> The `full` config cannot work in full with the current `bzImage` which has not the network
> support compiled in, but it can with the 6.17.0 kernel image from `mkroot` by Rob Landley.
> Or alternatively, the 6.17.0 kernel config can be used to compile a vanilla LTS version.

Configuration developed for the master::HEAD as publicly available on 2026-02-21
tagged bmls-v0.2 on the github fork of the official busybox.net git repository.

- [busybox tag:bmls-v0.2](https://github.com/robang74/busybox/releases/tag/bmls-v0.2) `HEAD` at commit #`ef892681f967` on official `master` branch

The configuration `-full` isn't aimed at absolute minimalism but to a full operating
system by cutting down the size of it and not the features/functionality like the
networking (and the `full` config also supports `httpd` for being a micro-server).
It can be compiled with `musl-gcc` on Ubuntu in native architecture but has serious
limitations (in 22.04, at least) when `-m32` is used for a different arch.

Therefore, a more replicable procedure (aka less dependent by the dev's host) is
verified and it relies on the [musl.cc](https://musl.cc/) 2021-11-23 binary release.

- `1.` download your selected musl tool-chain archive
- `2.` unzip it creating a folder and jump into it
- `3.` download the busybox archive and extract it
- `4.` prepare the your environment for compiling

At this point the working directory is the musl tool-chain path and in this case

- `path=$PWD   # would perfectly fine to declare and use`

while the busybox folder would be a subfolder of that path, hence

- `cd $path/busybox*/  # will change the working path for cross-compiling`

In more general terms:

- `type="native"  # or cross, depending the host vs target`
- `arch="x86_64-linux"  # or any other available and suitable`
- `path="$HOME/Downloads/$arch-musl-$type/"  # example, default for Ubuntu`

At this point, we are ready to download, configure and build a musl-static bb:

- `5.` download the configure file and properly rename it
- `6.` clean the building environment and build busybox

Supposing to use `wget` but `curl` is fine as well:

```sh
make clean # to reset a previous compilation products, just in case

ref="refs/heads/main/busybox/"
url="raw.githubusercontent.com/robang74/bare-minimal-linux-system/"
wget $url/$ref/bmls-v0.2-bb-full.config -O .config

make oldconfig # to adapt the config for current busybox version
make -j$(nproc) CFLAGS="-Os -static -s --fast-math -flto -fPIC -I$path" \
  CC="$path/bin/$arch-musl-gcc" LDFLAGS="-Wl,-z,notext -Wl,-rpath=$path" 
```

The `make` command shows that `.config` has been developed agnostic in relation
to the tool-chain that it will set by defining proper variables values. While
the `-j` setting is going to use all the processors available to speed-up the
building as fast as possible (rarely fails, but in case try again or skip `-j`).

Compiling for the native system using the `gnulibc` for the static link is easier

- `CFLAGS="-Os -static -s --fast-math -flto -fPIC"` # and nothing else

but the product will be near under or above 2.2MB instead of less than 800KB. So,
it makes sense to use musl even when the target architecture is 1:1 with the host.
By converse, it makes also sense to have an isolated VM which has no code for even
networking with the host, as every security expert, a sane configuration for testing
in a safe environment everything we like to investigate.

In the `full` configuration some of the advanced networking features are disabled
like `ip` and the IPv6 support, both indispensable for a modern network management.
The main reason is that while https/d makes sense for a local micro-server, it
should be put into a secure DMZ network and not left directly exposed on the
internet and also behind a load-balancing network edge for large infrastructures
which can spawn multiple instances on demand. 

Despite `ip` and IPv6 support are almost
essential also in a cloud-like DMZ, those who require to manage such infrastructure
will provide themselves their own configuration while IPv4 and ifconfig are fine
for those who instead are likely to make tests on a local network in which IPv4 is
way more human friendly than IPv6 and `ifconfig` still fulfills the basic needs.

With `dhcp`/`d` the idea of self-configuring the local subnetwork by a specific 
micro-server instance isn't a bad idea in terms of scalability but only up to a
certain level which doesn't fit with professional usage. This limitation forces
companies to hire or employ skilled people, not relying on shared "free" stuff.

