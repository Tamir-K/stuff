# Persistent rclone mounts with systemd --user

Create a user‑scoped, automatically managed rclone mount.  
The mount point lives in the systemd runtime directory (`%t`), so it is cleaned up when you log out and never clutters your home folder.

## Prerequisites
- **rclone** installed and a remote configured (e.g., `gdrive:`).  
- **systemd user services** enabled (`systemctl --user` works).

## Service unit
Save the following file as `~/.config/systemd/user/rclone-mount-gdrive.service`:
```ini
[Unit]
Description=rclone mount for gdrive
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
# Ensure the mount directory exists in the user runtime dir (%t)
ExecStartPre=/usr/bin/mkdir -p %t/rclone/gdrive
# Mount the remote; VFS cache is required for most operations
ExecStart=/usr/bin/rclone mount gdrive: %t/rclone/gdrive --vfs-cache-mode full
# Cleanly unmount on stop
ExecStop=/usr/bin/fusermount -u %t/rclone/gdrive
# Remove the empty directory after unmounting
ExecStopPost=/bin/rmdir -p %t/rclone/gdrive
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal
SyslogIdentifier=rclone-mount-gdrive
```

## Install, enable and start
1. Reload user units: 
   `systemctl --user daemon-reload`
2. Enable to start at login and start service:
   `systemctl --user enable --now rclone-mount-gdrive.service`
3. Check status/logs:  
   `systemctl --user status rclone-mount-gdrive.service`  
   `journalctl --user -u rclone-mount-gdrive.service`

## Why %t for mount points
- `%t` expands to the user runtime directory (e.g., `/run/user/1000`).
- It is a tmpfs‑backed location managed by systemd, automatically removed when the user session ends.
- Keeps mount points out of your home directory and avoids orphaned folders after a crash or logout.

## Troubleshooting tips
- **Mount fails:** check the remote name (`gdrive:`) and network connectivity.
- **Permissions errors:** ensure the user has execute rights on `/usr/bin/rclone` and `fusermount`.
- **Cache issues:** try different `--vfs-cache-mode` values (`writes`, `minimal`) depending on workload.

Now the mount will appear under `/run/user/<uid>/rclone/gdrive` whenever you log in, and it will disappear cleanly when you log out.

## Sufficient Google Drive remote setup
Rclone allows for many different configurations for various cloud storage providers, but a sufficient remote configuration for Google Drive can be made using the following command:
```bash
rclone config create gdrive drive scope=drive
```

This command creates a remote named **gdrive** that uses the `drive` backend with the `drive` scope (full access to the user's Drive).
A browser tab prompting authentication to your Google account will open.

After it runs, you’ll have a `~/.config/rclone/rclone.conf` entry similar to:
```ini
[gdrive]
type = drive
scope = drive
token = {"access_token":"...","token_type":"Bearer","refresh_token":"...","expiry":"..."}
```

You can now use `gdrive:` in the mount service above.
