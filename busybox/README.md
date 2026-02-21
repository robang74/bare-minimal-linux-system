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

The configuration `-full` isn't aim to absolute minimalism but to a full operative
system by cutting down the size of it and not the features/functionality like the
networking (and the `full` config also support `httpd` for being a micro-server).
It can be compiled with `musl-gcc` on Ubuntu in native architecture but serious
limitations (in 22.04, at least) when `-m32` is used for a different arch.

Therefore, a more replicable procedure (aka less dependant by the dev's host) is
verified and it rely on the [musl.cc](https://musl.cc/) 2021-11-23 binary release.

- 1. download your selected musl tool-chain archive
- 2. unzip it creating a folder and jump into it
- 3. download the busybox archive and extract it
- 4. prepare the your enviroment for compiling

At this point the working directory is the musl tool-chain path and in this case

- `path=$PWD`  # would perfecty fine to declare and use
- `path="../"` # or even simpler for this specific case

while the busybox folder would be a subfolder of that path, hence

- `cd $path/busybox*/` # will change the working path for cross-compiling

In more general terms:

- `type="cross"` # or native
- `arch="i686-linux"` # or any other available and suitable
- `path="$HOME/Downloads/$arch-musl-$type/"` # example, default for Ubuntu

At this point, we are ready to download, configure and build a musl-static bb:

- 5. download the configure file and properly rename it
- 6. clean the building enviroment and build busybox

Supposing to use `wget` but `curl` is fine as well:

```sh
make clean # to reset a previous compilation products, just in case

ref="refs/heads/main/busybox/"
url="raw.githubusercontent.com/robang74/bare-minimal-linux-system/"
wget $url/$ref/bmls-v0.2-bb-full.config -O .config

make oldconfig # to adapt the config for current busybox version
make -j$(nproc) CFLAGS="-Os -static -s --fast-math -flto -fPIC -I/$path" \
  CC="$path/bin/$arch-musl-gcc" LDFLAGS="-Wl,-z,notext -Wl,-rpath=/$path" 
```

The `make` command shows that `.config` has been develped agnostic in relation
to the tool-chain that it will set by defining proper variables values. While
the `-j` setting is going to use all the processors available to speed-up the
building as fast as possible (rarely fails, but in case repeat or skip `-j`).

Compiling for the native system using the `gnulibc` for the static link is easier

- `CFLAGS="-Os -static -s --fast-math -flto -fPIC"` # and nothing else

but the product will be near under or above 2.2MB instead of less than 800KB. So,
it makes sense to use musl even when the target architecture is 1:1 with the host.
By converse, it makes also sense to have an isolated VM which has no code for even
networking with the host, as every security expert, a sane configuration for testing
in a safe enviroment every stuff we like to investigate.
