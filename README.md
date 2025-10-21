# grafana-prometheus-terraform-ansible
Infrastructure as Code setup for Grafana and Prometheus using Terraform and Ansible

# aws-Observability-terraform

Simple consolidated guide for this repo (Terraform + Ansible).

What this repo does
- Provision AWS instances with Terraform and configure Prometheus, Grafana and Node Exporter with Ansible.

Quick start
1. Terraform (provision infra)
   - From the src/ folder:
     cd src
     terraform init
     terraform apply
2. Generate inventory
   - Collect instance IPs from Terraform outputs (or use `terraform output -json` to script it).
   - Populate src/ansible/inventory.ini (or copy inventory.ini.example).
3. Ansible (configure instances)
   - From src/ansible:
     cd src/ansible
     ansible-playbook -i inventory.ini playbooks/site.yml -u <user> --private-key /path/to/key
   - Or run individual playbooks:
     ansible-playbook -i inventory.ini playbooks/grafana.yml ...
     ansible-playbook -i inventory.ini playbooks/prometheus.yml ...
     ansible-playbook -i inventory.ini playbooks/node_exporter.yml ...

Key file locations
- Terraform: src/ (main.tf, provider.tf, variables.tf, outputs.tf, userdata.sh)
- Ansible: src/ansible/ (playbooks/, templates/, vars.yml, inventory.ini.example, ansible.cfg)

Notes
- Ensure target instances have Python or set ansible_python_interpreter in inventory.
- Use --limit with ansible-playbook to target specific groups (node_exporter, prom_grafana).
- Use -vvv for verbose Ansible output when troubleshooting.

Detailed documentation
- Terraform: see the Terraform README at the top level of the repo (top-layer Terraform README.md).
- Ansible: see src/ansible/README.md for full Ansible instructions and playbook details.

License / Contributing
- Add license and contribution guidelines as needed.
