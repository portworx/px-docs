Once you install the PX OCI bundle and systemd configuration from the steps above, you can start and control PX runC directly via systemd:

```bash
# Reload systemd configurations, enable and start Portworx service
sudo systemctl daemon-reload
sudo systemctl enable portworx
sudo systemctl start portworx
```
