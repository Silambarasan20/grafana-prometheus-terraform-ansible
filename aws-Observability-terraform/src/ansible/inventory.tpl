[prom_grafana]
prom_host ansible_host=${prom_ip} ansible_user=${ssh_user}

[node_exporter]
node_exporter_host ansible_host=${node_ip} ansible_user=${ssh_user}


