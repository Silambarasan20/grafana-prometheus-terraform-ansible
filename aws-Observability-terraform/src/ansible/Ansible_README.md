Quick Ansible guide for this Terraform project
=============================================

Overview
- After `terraform apply`, copy instance IPs (public IPs for external access, private IPs if running Ansible from inside the VPC) into `ansible/inventory.ini`.
- The playbooks are split into three installers (under `playbooks/`):
  - playbooks/node_exporter.yml  — installs Node Exporter on hosts in the node_exporter group
  - playbooks/prometheus.yml    — installs Prometheus on hosts in the prom_grafana (or separate prometheus) group
  - playbooks/grafana.yml       — installs Grafana as a standalone binary on hosts in the prom_grafana group
- Grafana playbook expects a vars file (../vars.yml) with at least grafana_version defined. Prometheus/Node Exporter playbooks use their own role/vars files; review them for required variables.

Prerequisites
- Ansible 2.9+ on the control host.
- SSH keypair and user (typical AMI user: ubuntu).
- Target instances must have Python or set ansible_python_interpreter in inventory.

Inventory
- Edit ansible/inventory.ini and add hosts from Terraform outputs.

Example inventory:
[prom_grafana]
prom1 ansible_host=3.21.45.68 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa

[node_exporter]
node1 ansible_host=3.22.33.44 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa

Running the playbooks
- From src/ansible run the full site (if site.yml orchestrates roles):
  ansible-playbook -i inventory.ini playbooks/site.yml --private-key /path/to/key -u ubuntu

- Run a single playbook:
  - Grafana:
    ansible-playbook -i inventory.ini playbooks/grafana.yml --private-key /path/to/key -u ubuntu
  - Prometheus:
    ansible-playbook -i inventory.ini playbooks/prometheus.yml --private-key /path/to/key -u ubuntu
  - Node Exporter:
    ansible-playbook -i inventory.ini playbooks/node_exporter.yml --private-key /path/to/key -u ubuntu

- Use --limit to restrict to a group defined in inventory:
  ansible-playbook -i inventory.ini playbooks/site.yml --limit node_exporter --private-key /path/to/key -u ubuntu

Notes from the playbooks
- Grafana playbook:
  - Installs prerequisites (wget, tar), creates grafana system user and directories, extracts Grafana binary to /etc/grafana, deploys configuration (/etc/grafana/conf/grafana.ini) and a systemd unit (/etc/systemd/system/grafana.service). The playbook relies on vars.yml for grafana_version.
  - A handler reloads systemd (systemctl daemon-reload) when the service unit is updated.
- Prometheus playbook templates Prometheus config to scrape the first host in the node_exporter group by default (see playbook templates).
- Node Exporter playbook will install and enable exporter on hosts in node_exporter group.

Networking / Security Groups
- Allow SSH (22) from control host.
- Allow Prometheus (9090) -> Node Exporter (9100) traffic (or use private IPs + SG-to-SG rules).
- Expose Grafana (3000) and Prometheus (9090) only as needed.

Troubleshooting
- If Ansible fails due to missing Python on targets, either install Python first or set ansible_python_interpreter to the appropriate path (e.g. /usr/bin/python3) in inventory host vars.
- Use -vvv with ansible-playbook for verbose debugging.
- Check systemd status and logs on target hosts:
  - systemctl status grafana
  - journalctl -u grafana -b

Customization
- Edit templates under ansible/templates and default variables in ansible/vars.yml or role defaults to change versions, scrape targets, or Grafana configuration.
- You can generate inventory automatically from `terraform output -json` if desired.

Keep this README in sync with playbooks/vars/templates when you update versions or add roles.
