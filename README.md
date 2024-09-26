# HA runner script trough ASWT (Advanced SSH & Web Terminal)

As the title says, awst.sh is a wrapper script that can be used to run shell_commands within the AWST container.

Few examples where I use it which might be helpful for the community:
- Automate fetching of ssl certificates to be used with the core_nginx_proxy
- Automate backups cleanup (see backups_clean.sh)
- Run ha cli commands (which is not available in the homeassistant docker container)


### Prerequsites
- Advanced SSH & Web Terminal Addon

### Installation:
ssh into ASWT container and run following command:

```
curl -sS -L https://raw.githubusercontent.com/zamolxe/homeassistant-aswt/refs/heads/main/aswt.sh | bash
```
The script will self install under /config/aswt, generate am ssh key pair, and will output the public key required later for the configuration.

```
/config/aswt
├── aswt.key
├── aswt.pub
├── aswt.sh
├── run -> aswt.sh
└── update -> aswt.sh
```

### Configuration
In the Advanced SSH & Web Terminal addon configuration:
- change the ssh username to root.
- add the public key you got earlier to the authorized_keys list.

```
ssh:
  username: root
  password: ""
  authorized_keys:
    - ssh-ed25519 AASDJKJKJFWJFAFLCNALCMLAK234234.....
```

### Usage:

configuration.yaml:
```
shell_command:
  backups_clean: /config/aswt/run /config/aswt/backups_clean.sh
```

### Example automations:
Automated daily backups:
```
alias: Auto backup_full
description: ""
trigger:
  - platform: time
    at: "12:00:00"
condition: []
action:
  - data:
      compressed: true
      location: hassio_backup
    action: hassio.backup_full
mode: single
```

Automated daily backups clean:

```
alias: Auto backups_clean
description: ""
trigger:
  - platform: time
    at: "12:30:00"
condition: []
action:
  - action: shell_command.backups_clean
    metadata: {}
    data: {}
mode: single
```
