---
name: wsl-remote-access
description: Triggers when the user works with the Mac-to-WSL remote setup — ssh-ing from the Mac into this WSL machine, running GPU/CUDA jobs remotely, Tailscale connectivity or node issues, the on-demand Windows proxy (proxy-on/proxy-off), or anything that touches the network assumptions behind them (WSL NAT mode, the Windows gateway, sshd, tailscaled).
---

# WSL Remote Access (Mac → WSL over Tailscale)

This WSL machine is set up so the user's Mac (and AI agents running on it) can ssh in from any network and run GPU workloads here. This skill records the configuration so Agents can troubleshoot or extend it without rediscovering everything.

## Architecture

```
Mac (MAC_HOSTNAME, MAC_NODE_IP)
  └─ ssh over Tailscale tunnel (encrypted, direct when possible)
       └─ WSL2 (WSL_HOSTNAME, WSL_NODE_IP) — NAT mode
            ├─ GPU: RTX 5060 Laptop via nvidia-smi / CUDA
            ├─ sshd: systemd service, listening on 0.0.0.0:22
            └─ outbound proxy: on-demand, via the Windows host
```

The actual IPs, hostnames, and tailnet identity of both nodes are kept out of the repo in `~/.config/secrets/tailscale` (a git-ignored backup lives in the dotfiles repo under `secret/wsl/`); read that file whenever a real value is needed. Placeholders below (`WSL_NODE_IP` etc.) are the variable names in that file.

SSH traffic rides the Tailscale interface, so it never touches the Windows firewall and needs no port forwarding. WSL's outbound internet (the proxy layer) is independent of the inbound SSH path.

## Tailscale

- Tailnet account and MagicDNS suffix: `TAILNET_ACCOUNT` / `MAGICDNS_SUFFIX` in the secrets file (so the FQDN is `<WSL_HOSTNAME>.<MAGICDNS_SUFFIX>`).
- This node: `WSL_HOSTNAME`, IPv4 `WSL_NODE_IP`. Tailscale IPs are bound to the node key and do not change, so this address may be hardcoded anywhere.
- The Mac node is `MAC_HOSTNAME` at `MAC_NODE_IP`.
- `tailscaled` is a systemd service (`systemctl status tailscaled`) and reconnects automatically at boot using the node key stored in `/var/lib/tailscale/`. Key expiry is disabled for this node in the admin console. Never wipe `/var/lib/tailscale/` — losing the node key forces re-registration with a fresh auth key (`sudo tailscale up --auth-key=tskey-auth-... --hostname=<WSL_HOSTNAME>`), and auth keys are one-time credentials that only matter at registration.

## SSH

`ssh.service` is enabled and active; both pubkey and password auth are allowed.

Naming trap: the file `~/.ssh/id_ed25519_wsl` exists on BOTH machines but means different things. On the Mac it is the pair whose public key sits in this machine's `~/.ssh/authorized_keys` (comment `mac-to-wsl`) and is used to log in here. On this WSL machine it is WSL's own GitHub key (comment is the `TAILNET_ACCOUNT` email, see `~/.ssh/config`). Agents must not copy, overwrite, or "sync" these files across the machines.

The Mac's `~/.ssh/config` has a `Host wsl` alias pointing at the WSL node IP with user `razer_ubuntu` and `IdentityFile ~/.ssh/id_ed25519_wsl`, so agents on the Mac can simply run `ssh wsl '<command>'` non-interactively.

## Proxy (outbound only)

WSL2 runs in NAT mode, so the Windows host is the default gateway (`ip route show default | awk '{print $3}'`). The Windows proxy apps listen on `10808` (v2ray) and `7892` (clash/mihomo) with "Allow LAN connections" enabled.

Proxy variables are loaded on demand, NOT in `.bashrc`, by sourcing scripts:

```bash
source ~/bin/proxy-on    # probes gateway ports 10808 then 7892, exports http_proxy/https_proxy/no_proxy
source ~/bin/proxy-off   # unsets them
```

They must be sourced because a child process cannot export variables into the calling shell. This design exists for a reason: an earlier always-on `.bashrc` version used bash's `/dev/tcp` probe without a timeout, and Windows silently drops SYN packets to closed proxy ports, so every new shell hung for tens of seconds when no proxy was running. The scripts use `timeout 1` per probe and stay out of shell startup entirely.

## Typical workflow

1. Windows boots → systemd starts `tailscaled` and `sshd` → the machine is reachable. No manual steps on the WSL side.
2. From the Mac: `ssh wsl`, then work normally; `nvidia-smi` and CUDA jobs run on the GPU as usual.
3. `source ~/bin/proxy-on` only when a task needs proxied internet access (GitHub raw downloads, blocked package registries, etc.); Ubuntu archives and tailscale.com are reachable without it.
4. Disconnect with `exit` or Ctrl+D; if a session hangs (dead network), type Enter then `~.` to kill it.

## Troubleshooting checklist

- `tailscale status` — both nodes should appear; `tailscale ping <MAC_HOSTNAME>` should pong.
- `systemctl status ssh tailscaled` — both active.
- If the Mac cannot reach the WSL node IP at all, check the Tailscale admin console: the node may have been deleted or key expiry re-enabled.
- If `proxy-on` reports no proxy, the Windows proxy app is off or "Allow LAN" got disabled. Verify from WSL via interop: `/mnt/c/Windows/System32/netstat.exe -ano | grep -E ':(7892|10808).*LISTENING'` — the listener must be `0.0.0.0:<port>`, not `127.0.0.1:<port>`.
- Toggling "Allow LAN" in the app UI only writes the config; the mihomo/v2ray core binds its socket at startup, so the running core keeps listening on `127.0.0.1` until the app is **fully quit (tray → Exit) and restarted** — just closing the window or toggling the switch does not rebind.
- The current Windows proxy app is **BoostNet** (mihomo core, mixed port 7892; config in `C:\Users\Yolan\AppData\Roaming\BoostNet\BoostNet\`, `shared_preferences.json` holds `allow-lan`/`mixed-port`). A silent timeout (SYN dropped, not refused) after the listener is on `0.0.0.0` points to the Windows firewall blocking the WSL vEthernet subnet.
