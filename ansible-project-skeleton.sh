#!/bin/bash

# -------------------------- FOLDER STRUCTURE & FILES --------------------------------------

# main folder
mkdir -p ansible
touch ansible/main.yml \
    ansible/data.yml \
    ansible/playbook_group1.yml \
    ansible/playbook_group2.yml \
    ansible/requirements.yml \
    ansible/README.md \
    ansible/ansible.cfg

# inventories folder - production
mkdir -p ansible/inventories/production/group_vars
mkdir -p ansible/inventories/production/host_vars
touch ansible/inventories/production/hosts.yml
touch ansible/inventories/production/group_vars/all.yml
touch ansible/inventories/production/group_vars/group1.yml
touch ansible/inventories/production/group_vars/group2.yml
touch ansible/inventories/production/host_vars/host1.yml
touch ansible/inventories/production/host_vars/host2.yml

# inventories folder - staging
mkdir -p ansible/inventories/staging/group_vars
mkdir -p ansible/inventories/staging/host_vars
touch ansible/inventories/staging/hosts.yml
touch ansible/inventories/staging/group_vars/all.yml
touch ansible/inventories/staging/group_vars/group1.yml
touch ansible/inventories/staging/group_vars/group2.yml
touch ansible/inventories/staging/host_vars/host1.yml
touch ansible/inventories/staging/host_vars/host2.yml

# data folder
mkdir -p ansible/data
touch ansible/data/config.json

# roles
mkdir -p ansible/roles
mkdir -p ansible/roles/my-role/tasks
mkdir -p ansible/roles/my-role/vars
touch ansible/roles/my-role/tasks/main.yml
touch ansible/roles/my-role/vars/main.yml

# -------------------------- PLAYBOOKS --------------------------------------

# File contents: ansible/main.yml
cat <<EOF > ansible/main.yml
---
# file: main.yml
- ansible.builtin.import_playbook: playbook_group1.yml
- ansible.builtin.import_playbook: playbook_group2.yml
EOF

# File contents: ansible/playbook_group1.yml
cat <<EOF > ansible/playbook_group1.yml
---
# file: playbook_group1.yml
- name: Read data files
  ansible.builtin.import_playbook: data.yml

- name: Running play on group1
  hosts: group1 # change this as required
  gather_facts: false # change this as required
  roles:
    - { role: "my-role", tags: "my-tag" }
  vars:
    my_var: "{{ config.my_dict.key }}"
  tags:
    - tag-group1
EOF

# File contents: ansible/playbook_group2.yml
cat <<EOF > ansible/playbook_group2.yml
---
# file: playbook_group1.yml
- name: Read data files
  ansible.builtin.import_playbook: data.yml

# file: playbook_group2.yml
- name: Running play on group2
  hosts: group2 # change this as required
  gather_facts: false # change this as required
  roles:
    - { role: "my-role", tags: "my-tag" }
  vars:
    my_var: "{{ config.my_dict.key }}"
  tags:
    - tag-group2
EOF

# -------------------------- DATA --------------------------------------

# File contents: ansible/data.yml
cat <<EOF > ansible/data.yml
---
- name: Read data files
  hosts: all # change this as required
  gather_facts: false # change this as required
  connection: local # change this as required
  vars_files:
    - "{{ data_path }}/config.json"
  tasks:
    - name: Save the Json data to a Variable as a Fact
      ansible.builtin.set_fact:
        config: "{{ config }}"
        cacheable: true
EOF

# File contents: ansible/data/config.json
cat <<EOF > ansible/data/config.json
{
    "config": {
        "my_list": [
            {
                "key": "my-precious1"
            },
            {
                "key": "my-precious2"
            }
        ],
        "my_dict": {
            "key": "my-precious"
        }
    }
}
EOF

# -------------------------- MAIN FOLDER FILES --------------------------------------

# File contents: ansible/requirements.yml
cat <<EOF > ansible/requirements.yml
# ---
# collections:
  # Install a collection from Ansible Galaxy.
  # - name: ansible.windows
    # version: 1.11.0
  # - name: chocolatey.chocolatey
EOF

# File contents: ansible/README.md
cat <<EOF > ansible/README.md
# Ansible setup

This sample setup organizes playbooks, roles, inventory, and files with variables by function. Tags at the play and task level provide greater granularity and control.

## Folder Structure


\`\`\`text
├── ansible.cfg             # 
├── data                    # data folder for extra config
│   └── config.json         # extra config
├── data.yml                # load extra config from data folder
├── inventories             # inventory files
│   ├── production          # inventory and var files for production hosts
│   │   ├── group_vars      # group vars
│   │   │   ├── all.yml     # here we assign variables to all production hosts
│   │   │   ├── group1.yml  # here we assign variables to group1
│   │   │   └── group2.yml  # here we assign variables to group1
│   │   ├── hosts.yml       # inventory file for production hosts
│   │   └── host_vars       # host vars
│   │       ├── host1.yml   # here we assign variables specific to host1
│   │       └── host2.yml   # here we assign variables specific to host1
│   ├── staging             # inventory and var files for staging hosts
│   │   ├── group_vars      # group vars
│   │   │   ├── all.yml     # here we assign variables to all staging hosts
│   │   │   ├── group1.yml  # here we assign variables to group1
│   │   │   └── group2.yml  # here we assign variables to group1
│   │   ├── hosts.yml       # inventory file for staging hosts
│   │   └── host_vars       # host vars
│   │       ├── host1.yml   # here we assign variables specific to host1
│   │       └── host2.yml   # here we assign variables specific to host1
├── main.yml                # main playbook
├── playbook_group1.yml     # playbook for group1
├── playbook_group2.yml     # playbook for group1
├── README.md               # 
├── requirements.yml        # here we list required roles and modules
└── roles                   # roles
    └── my-role             # role: my-role
        ├── tasks           #
        │   └── main.yml    # main task file for role
        └── vars            # 
            └── main.yml    # variables associated with this role
\`\`\`

#### \`inventories\`

This folder contains inventory files for different environments; \`production\` and \`staging\`.

All the hosts are localhost. They are grouped as follows:

\`\`\`text
@all:
  |--@ungrouped:
  |--@group1:
  |  |--host1
  |--@group2:
  |  |--host2
\`\`\`

Modify the hosts and grouping as per your requirement.

Set host specific vars in \`inventories/environment/host_vars/my-host.yml\`
Set group specific vars in \`inventories/environment/grou_vars/my-group.yml\`

#### \`data\`

\`data/config.json\` contains additional data that you might require for your plays/tasks.

## Run playbook patterns:

### Environment Specific

\`\`\`bash
ansible-playbook main.yml -i inventories/production
ansible-playbook main.yml -i inventories/staging
\`\`\`

### Group specific

\`\`\`bash
ansible-playbook main.yml -i inventories/production --limit group1
ansible-playbook main.yml -i inventories/staging --limit group2
\`\`\`

### Host specific

\`\`\`bash
ansible-playbook main.yml -i inventories/production --limit host1
ansible-playbook main.yml -i inventories/staging --limit host2
\`\`\`

### Tag Specific

\`\`\`bash
ansible-playbook main.yml -i inventories/production -t my-tag1
ansible-playbook main.yml -i inventories/production -t tag-group1
\`\`\`

## References

Sample Ansible Setup [https://docs.ansible.com/ansible/latest/tips_tricks/sample_setup.html](https://docs.ansible.com/ansible/latest/tips_tricks/sample_setup.html)
EOF

# File contents: ansible/ansible.cfg
cat <<EOF > ansible/ansible.cfg
[defaults]
host_key_checking = false
EOF

# -------------------------- PRODUCTION INVENTORY --------------------------------------

# hosts
# File_contents: ansible/inventories/production/hosts.yml
cat <<EOF > ansible/inventories/production/hosts.yml
---
all:
  hosts:
    host1:
    host2:

group1:
  hosts:
    host1:

group2:
  hosts:
    host2:
EOF

# -------------------------- STAGING INVENTORY --------------------------------------

# hosts
# File_contents: ansible/inventories/staging/hosts.yml
cat <<EOF > ansible/inventories/staging/hosts.yml
---
all:
  hosts:
    host1:
    host2:

group1:
  hosts:
    host1:

group2:
  hosts:
    host2:
EOF

# -------------------------- ROLE --------------------------------------

# File contents: ansible/roles/my-role/tasks/main.yml
cat <<EOF > ansible/roles/my-role/tasks/main.yml
---
- name: Access and use hostvars on {{ inventory_hostname }}
  ansible.builtin.debug:
    msg:
      - "host_var1 is of type: {{ host_var1 | type_debug }}"
      - "host_var1 is        : {{ host_var1 }}"
  tags: my-tag1

- name: Access and use groupvars on {{ inventory_hostname }}
  ansible.builtin.debug:
    msg:
      - "my_environment is of type: {{ my_environment | type_debug }}"
      - "my_environment is        : {{ my_environment }}"
      - "all_var1 is of type      : {{ all_var1 | type_debug }}"
      - "all_var1 is              : {{ all_var1 }}"
      - "group_var1 is of type    : {{ group_var1 | type_debug }}"
      - "group_var1 is            : {{ group_var1 }}"
  tags: my-tag1

- name: Access and custom config vars on {{ inventory_hostname }}
  ansible.builtin.debug:
    msg:
      - "my_var is of type: {{ my_var | type_debug }}"
      - "my_var is        : {{ my_var }}"
  tags: my-tag2

- name: Access default role vars on {{ inventory_hostname }}
  ansible.builtin.debug:
    msg:
      - "role_var is of type: {{ role_var | type_debug }}"
      - "role_var is        : {{ role_var }}"
  tags: my-tag2
EOF

# File contents: ansible/roles/my-role/vars/main.yml
cat <<EOF > ansible/roles/my-role/vars/main.yml
---
role_var: role-var-value
config:
  my_dict:
    key: role-key-value
EOF

# -------------------------- PRODUCTION GROUPVARS & HOSTVARS --------------------------------------

# group_vars
# File contents: ansible/inventories/production/group_vars/all.yml
cat <<EOF > ansible/inventories/production/group_vars/all.yml
---
# Variables here are applicable to all host groups.
# These don't have to be explicitly imported by vars_files: they are autopopulated.

all_var1: all_var1_value1
all_var2: all_var2_value2
data_path: data
my_environment: production
EOF

# File contents: ansible/inventories/production/group_vars/group1.yml
cat <<EOF > ansible/inventories/production/group_vars/group1.yml
---
# The variables file used by the playbooks in the group1 group.
# These don't have to be explicitly imported by vars_files: they are autopopulated.

group_var1: group1_var1_value1
group_var2: group1_var2_value2
EOF

# File contents: ansible/inventories/production/group_vars/group2.yml
cat <<EOF > ansible/inventories/production/group_vars/group2.yml
---
# The variables file used by the playbooks in the group2 group.
# These don't have to be explicitly imported by vars_files: they are autopopulated.

group_var1: group2_var1_value1
group_var2: group2_var2_value2
EOF

# host_vars
# File contents: ansible/inventories/production/host_vars/host1.yml
cat <<EOF > ansible/inventories/production/host_vars/host1.yml
---
# The variables file used by the playbooks for the host2 system.
# These don't have to be explicitly imported by vars_files: they are autopopulated.

host_var1: host1_var1_value1
host_var2: host1_var2_value2
ansible_connection: local
EOF

# File contents: ansible/inventories/production/host_vars/host1.yml
cat <<EOF > ansible/inventories/production/host_vars/host2.yml
---
# The variables file used by the playbooks for the host2 system.
# These don't have to be explicitly imported by vars_files: they are autopopulated.

host_var1: host2_var1_value1
host_var2: host2_var2_value2
ansible_connection: local
EOF

# -------------------------- STAGING GROUPVARS & HOSTVARS --------------------------------------

# group_vars
# File contents: ansible/inventories/staging/group_vars/all.yml
cat <<EOF > ansible/inventories/staging/group_vars/all.yml
---
# Variables here are applicable to all host groups.
# These don't have to be explicitly imported by vars_files: they are autopopulated.

all_var1: all_var1_value1
all_var2: all_var2_value2
data_path: data
my_environment: staging
EOF

# File contents: ansible/inventories/staging/group_vars/group1.yml
cat <<EOF > ansible/inventories/staging/group_vars/group1.yml
---
# The variables file used by the playbooks in the group1 group.
# These don't have to be explicitly imported by vars_files: they are autopopulated.

group_var1: group1_var1_value1
group_var2: group1_var2_value2
EOF

# File contents: ansible/inventories/staging/group_vars/group2.yml
cat <<EOF > ansible/inventories/staging/group_vars/group2.yml
---
# The variables file used by the playbooks in the group2 group.
# These don't have to be explicitly imported by vars_files: they are autopopulated.

group_var1: group2_var1_value1
group_var2: group2_var2_value2
EOF

# host_vars
# File contents: ansible/inventories/staging/host_vars/host1.yml
cat <<EOF > ansible/inventories/staging/host_vars/host1.yml
---
# The variables file used by the playbooks for the host2 system.
# These don't have to be explicitly imported by vars_files: they are autopopulated.

host_var1: host1_var1_value1
host_var2: host1_var2_value2
ansible_connection: local
EOF

# File contents: ansible/inventories/staging/host_vars/host1.yml
cat <<EOF > ansible/inventories/staging/host_vars/host2.yml
---
# The variables file used by the playbooks for the host2 system.
# These don't have to be explicitly imported by vars_files: they are autopopulated.

host_var1: host2_var1_value1
host_var2: host2_var2_value2
ansible_connection: local
EOF
