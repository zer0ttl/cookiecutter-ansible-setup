# Cookiecutter PyPackage for an Ansible setup

## Quickstart using Cookiecutter

1. Install the latest Cookiecutter if you haven't installed it:

```bash
pip install -U cookiecutter
```

2. Generate a Python package project:

```bash
cookiecutter https://github.com/zer0ttl/cookiecutter-ansible-setup.git 
```

3. Use the Ansible setup

By default, the Ansible setup will run against localhost.

```bash
cd ansible
ansible-inventory -i inventories/production --list yml
ansible-playbook -i inventories/production main.yml
```

Modify hosts and playbooks as per your requirement.

Refer to README.md inside the generated folder.

## Bash Script

You can also use the bash script `ansible-project-skeleton.sh` to create the Ansible setup. 