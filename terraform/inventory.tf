# Terraform generates inventory via a templatefile

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/../ansible/inventory.tpl", {
    ansible_master_ip = aws_instance.ec2-ansible-param.private_ip
    frontend_ip        = aws_instance.ec2-frontend-param.private_ip
    backend_ips         = { for k, v in aws_instance.ec2-backend-param : k => v.private_ip }
  })

  filename = "${path.module}/../ansible/inventory.yml"
}