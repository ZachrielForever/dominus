# Dominus

Custom [bootc](https://github.com/bootc-dev/bootc) image for the Dominus
host: a single-purpose game server and file-share machine running a
container-first, immutable Fedora stack.

Built on [uCore](https://github.com/ublue-os/ucore) via the
[Universal Blue](https://projectbluefin.io) image tooling.

## Base Image

ghcr.io/ublue-os/ucore:stable-nvidia-lts

The `-nvidia-lts` variant is intentional: it ships the NVIDIA 580 LTS
driver branch, the last series to support Maxwell, Pascal, and Volta
GPUs. Dominus carries a GTX 1060 (Pascal). The standard `-nvidia` tags
track the 590+ open driver branches, which do not support this card.

## Host

- CPU: Intel i5-10400F
- GPU: NVIDIA GTX 1060 3GB (DisplayPort output, 1080p)
- Boot disk: 1TB SATA HDD (extended storage on NVMe/PCIe SSDs planned)
- Role: rootless Podman game server fleet, Tailscale networking,
  Cockpit administration

## Repository Layout

| Path | Purpose |
|------|---------|
| `Containerfile` | Image entrypoint; selects base image and build steps |
| `build_files/build.sh` | Package installation and service enablement |
| `system_files/` | Files copied verbatim into the image root (`/etc`, `/usr`) |
| `image.env` | Image identity and build parameters |
| `Justfile` | Local build and repo hygiene recipes |
| `.github/workflows/` | CI builds and publishes to GHCR |

## Build

Local (requires `just`, `podman`, `jq`):

just build

CI: pushes to the default branch trigger the GitHub Actions workflow,
which builds the image and publishes it to GHCR at:

ghcr.io/zachrielforever/dominus

Image signing uses cosign; the `SIGNING_SECRET` GitHub secret must be
set for CI builds to succeed (see the
[image-template documentation](https://github.com/blue-build/template)
for keypair setup).

## Deploy

On the host:

sudo bootc switch ghcr.io/zachrielforever/dominus:latest

Then reboot. Subsequent updates: `sudo bootc upgrade`.

## Design Notes

- **Packages**: curated in `build_files/build.sh`. Host tooling favors
  breadth over minimalism; full development environments are
  intentionally *not* included and live in Distrobox containers on
  workstations instead.
- **Cockpit**: full set (storaged, networkmanager, podman, terminal,
  sosreport), enabled via socket activation on TCP 9090.
- **SteamCMD**: not baked into the image. It self-updates and fights the
  immutable model; see the admin wiki for the install-on-`/var`
  procedure and containerization notes.
- **Tailscale**: daemon baked in; enrollment state persists in `/var`
  across image updates.

## Post-Install Checklist

- [ ] Verify NVIDIA driver loaded: `nvidia-smi`
- [ ] Cockpit reachable on port 9090 (firewall: `firewall-cmd
      --add-port=9090/tcp --permanent && firewall-cmd --reload`)
- [ ] Mosh ports if used remotely: UDP 60000-61000
- [ ] If Secure Boot is enabled, import the uBlue akmods signing key:
      `sudo mokutil --import /etc/pki/akmods/certs/akmods-ublue.der`

## Acknowledgements

Built on the Universal Blue
[image-template](https://github.com/blue-build/template) and the
[uCore](https://github.com/ublue-os/ucore) project.
