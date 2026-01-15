# NixOS on the OnePlus 6T!

Custom configuration based on [mobile-nixos](https://gitlab.com/sdm845-mainline/linux), itself using the [SDM845 Mainline kernel](https://gitlab.com/sdm845-mainline/linux) (Linux patches for the Qualcomm Snapdragon 845 support).

I use a non-default of the kernel in the hope of bringing additional features/patches, mainly for stability reasons because the default one
has many problems.

It is my first time hacking & patching the Linux Kernel, so let's do it while cross-compiling aarch64 on x86_64 with NixOS :D

The patches are mainly fiddling around with the ath\[10k\] driver to solve mac randomization issues and regulatory channels configuration issues, making it unable to scan certain SSIDs, like here in France & Switzerland.

## 🎯 Project goal

Build a Home Assistant dashboard display (kiosk) + host webservices.

Integrate & merge with my [other systems global config](https://github.com/BlueskyFR/dotfiles) to manage everything from a single repo across different architectures.

All of that for just a couple of Watts! ⚡

## Rebuild/update system

**Using a remote builder:**
```shell
nixos-rebuild switch --flake .#tacos --build-host hugo@yurt.wow --no-reexec |& nom
```
> `--fast` skips the rebuild of nix itself, making cross-compilation work!

> Problem: this recompiles everything from scratch, not using the NixOS cache so it's not that good anymore :D

## Build the boot partition (`boot.img`) and update the kernel

The kernel isn't updated through `nixos-rebuild` as on regular NixOS installations, but is part of `boot.img`.

This flake re-exports the image for convenience. Build it & flash it with:

```bash
# Produces ./result (simlink to boot.img)
nix build .#images.android-bootimg
# Reboot to bootloader/fastboot mode, then flash it:
fastboot flash --slot=all boot ./result
fastboot reboot
```