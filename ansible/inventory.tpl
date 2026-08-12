all:
  children:
    master: # group-1
      hosts:
        master-node:
          ansible_host: ${ansible_master_ip}
          ansible_user: ubuntu
          ansible_ssh_private_key_file: /home/ubuntu/.ssh/aws-ssh-key.pem  # To connect via SSH to master, use this key file

    slaves: # group-1
      children:
        frontend: # group-1
          hosts:
            frontend-node:
              ansible_host: ${frontend_ip}
              ansible_user: ansible
              ansible_ssh_private_key_file: /home/ubuntu/.ssh/aws-ssh-key.pem  # To connect via SSH to (frontend), use this key file
        backend: # group-1
          hosts:
%{ for key, ip in backend_ips ~}
            backend-node-${key}:
              ansible_host: ${ip}
              ansible_user: ansible
              ansible_ssh_private_key_file: /home/ubuntu/.ssh/aws-ssh-key.pem  # To connect via SSH to (backend), use this key file
%{ endfor ~}