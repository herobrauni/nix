# Debian 12/13 VPS → NixOS Migration Plan

## 1. Use Debian as the staging OS

- Verify the VPS is a real VM with custom kernel and bootloader support.
- Ensure you have serial, VNC, or rescue access before changing boot.
- Record:
    - firmware mode: UEFI or BIOS
    - disk device names
    - network config: interface, IP, gateway, DNS
    - current partition UUIDs if doing an in-place migration

## 2. Choose migration style

### Fresh install from a provider image

- Treat Debian as disposable.
- Use `nixos-anywhere` to install NixOS from the flake.

### In-place conversion

- Reuse the current Debian filesystem and convert the machine without repartitioning.
- Use this when you want to preserve the existing disk layout or data.

## 3. Model the host in this repo

Include the shared aspects needed for the host:

- always: `den.aspects.base-server`, `den.aspects.networkd-base`, `den.aspects.impermanence`
- UEFI: `den.aspects.boot-limine-efi`
- BIOS: `den.aspects.boot-limine-bios`
- fresh single-disk BIOS VPS: set `singleDisk.device = "/dev/sdX"` and include `den.aspects.single-disk-bios-vps`

Relevant files:

- `modules/aspects/boot-limine-efi.nix`
- `modules/aspects/boot-limine-bios.nix`
- `modules/aspects/impermanence.nix`

## 4. Boot and disk layout

### UEFI

- Keep or create a FAT32 EFI system partition mounted at `/efi`.
- Use the durable ext4 filesystem as `/persist`.
- Make `/` a tmpfs.
- Bind-mount `/persist/nix` to `/nix`.
- Enable Limine via `boot-limine-efi`.

### BIOS

- Prefer:
    - GPT disk
    - 1 MiB BIOS boot partition
    - FAT32 `/boot`
    - ext4 persistent partition
- Make `/` a tmpfs.
- Bind-mount `/persist/nix` to `/nix`.
- Set `boot.loader.limine.biosDevice = "/dev/sdX"`.
- Treat BIOS bootloader changes as higher risk than EFI; use console access.

## 5. Impermanence cutover

This repo’s impermanence pattern is:

- `/` on tmpfs
- persistent state under `/persist`
- home persistence under `/persist/home`

Persist at least:

- `/var/log`
- `/var/lib/nixos`
- `/var/lib/systemd`
- `/var/lib/acme`
- `/etc/ssh`
- `/etc/machine-id`
- `/etc/adjtime`
- `/root`
- user home state such as `.ssh`, `.config`, `.local/share`, `.cache`, `.bash_history`

Also ensure mountpoints like `/persist`, `/nix`, and, if needed, `/boot` are created early in initrd.

## 6. Install

### Fresh install

- Run `nixos-anywhere` against the Debian host and let the flake install NixOS.
- Some provider Debian images use a non-standard SSH port before conversion; AlphaVPS/Debian hosts may listen on port `666`, so pass `--ssh-port 666` when needed.

### In-place install

- Reuse the existing Debian root as `/persist`.
- Switch NixOS to:
    - `/` = tmpfs
    - `/persist` = old root
    - `/nix` = bind mount from `/persist/nix`
    - `/efi` or persistent `/boot` as needed
- Install Limine.
- Reboot with serial or VNC open.

## 7. First-boot validation

- Limine boots successfully.
- Networking comes up.
- `/` is tmpfs.
- `/persist` is mounted.
- `/nix` is bind-mounted from `/persist/nix`.
- Reboot twice to confirm persistence works and root is ephemeral.

## Repo examples

- `modules/hosts/crunchbits1/default.nix` — BIOS + Limine + in-place impermanence
- `modules/hosts/gc5/default.nix` — BIOS + Limine + in-place impermanence
- `modules/hosts/gigahost1/default.nix` — fresh single-disk BIOS VPS

## Rule of thumb

- Prefer UEFI when the provider supports it.
- Prefer `nixos-anywhere` for a brand-new Debian image.
- Use in-place conversion only when you want to preserve the current disk layout.
