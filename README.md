# 🚀 Mini Project – AWS + Terraform + Ansible

## Extension for Terraform format in files

The solution is to install the official HashiCorp Terraform extension:   
```
1. Open Extensions (the cube icon on the left, or Ctrl+Shift+X)
2. Search for: HashiCorp Terraform
3. Install the HashiCorp extension (created by HashiCorp, not a third-party one)—it's called "HashiCorp Terraform."
4. After installation, restart VS Code (Ctrl+Shift+P → Developer: Reload Window)
```
Also useful: enable autoformatting and validation on the fly:   
```
In settings.json (Ctrl+Shift+P → Preferences: Open User Settings (JSON)):
json{
      "[terraform]": {
      "editor.defaultFormatter": "hashicorp.terraform",
      "editor.formatOnSave": true
      },
      "terraform.languageServer.enable": true
}
```

## 🖥️ EC2 Instances

Terraform must create all required EC2 instances.  
```
How to check what LTS (Long Term Support) version currently relevant:
aws ec2 describe-images \
  --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd-gp3/ubuntu-*-amd64-server-*" \
            "Name=state,Values=available" \
  --query 'sort_by(Images, &CreationDate)[-5:].[Name,CreationDate]' \
  --output table \
  --region eu-west-1

Output:
-------------------------------------------------------------------------------------------------------
|                                           DescribeImages                                            |
+------------------------------------------------------------------------+----------------------------+
|  ubuntu/images/hvm-ssd-gp3/ubuntu-resolute-26.04-amd64-server-20260714 |  2026-07-14T07:27:11.000Z  |  [v]
|  ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20260714    |  2026-07-14T11:54:28.000Z  |
|  ubuntu/images/hvm-ssd-gp3/ubuntu-resolute-26.04-amd64-server-20260722 |  2026-07-22T08:12:24.000Z  |
|  ubuntu/images/hvm-ssd-gp3/ubuntu-resolute-26.04-amd64-server-20260731 |  2026-07-31T06:23:36.000Z  |
|  ubuntu/images/hvm-ssd-gp3/ubuntu-resolute-26.04-amd64-server-20260806 |  2026-08-06T07:34:13.000Z  |
+------------------------------------------------------------------------+----------------------------+
```

---

## 🐳 Backend Application

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 111314928072.dkr.ecr.us-east-1.amazonaws.com

docker build -t backend -f ./backend/Dockerfile .
docker tag backend:latest 111314928072.dkr.ecr.us-east-1.amazonaws.com/backend-img-tf:latest
docker push 111314928072.dkr.ecr.us-east-1.amazonaws.com/backend-img-tf:latest

---

## 🌐 Frontend Application

ssh -i aws-ssh-key.pem ubuntu@3.82.104.29

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 111314928072.dkr.ecr.us-east-1.amazonaws.com

docker build -t frontend -f ./frontend/Dockerfile .
docker tag frontend:latest 111314928072.dkr.ecr.us-east-1.amazonaws.com/frontend-img-tf:latest
docker push 111314928072.dkr.ecr.us-east-1.amazonaws.com/frontend-img-tf:latest

---




## EC2 + IAM

Frontend (public), 2x Backend (private, via ALB Target Group), Ansible Master (public)
Ubuntu 26.04 LTS via SSM Parameter (instead of hardcoding the AMI ID)
Separated IAM roles by responsibility: ec2-ecr-role-param (ECR access for frontend/backend) separate from ansible-role-param (access only to the SSM parameter with the key)

## 🗄️ Amazon EFS

File system + mount targets + overcome a failure with amazon-efs-utils (incompatibility of Rust versions in Ubuntu 26.04) → reverted to a simple nfs4 mount
in ec2.tf in ec2-backend-tf-${each.key} instances  
```
Troubleshooting : sudo cat /var/log/cloud-init-output.log | grep "mount\|efs|error"

terraform taint 'aws_instance.ec2-backend-param["1b"]'
terraform apply

ssh -o ProxyCommand="ssh -i ./aws-ssh-key.pem -W %h:%p ubuntu@3.93.212.251" -i /mnt/e/DevOps/GIT/miniproj-aws-terraform-ansible/terraform/aws-ssh-key.pem ubuntu@10.0.4.107       -  ec2-tf-backend-1b
touch /mnt/efs/test.txt
ssh -o ProxyCommand="ssh -i ./aws-ssh-key.pem -W %h:%p ubuntu@3.93.212.251" -i /mnt/e/DevOps/GIT/miniproj-aws-terraform-ansible/terraform/aws-ssh-key.pem ubuntu@10.0.3.252      -  ec2-tf-backend-1a
cat /mnt/efs/test.txt
```
## ECR

Two repositories (frontend/backend) with lifecycle policies
Added force_delete for Terraform destroy when the repository is not empty

## SSH Access Security 
tls_private_key + aws_key_pair — a single key for all instances

## Ansible 

For Ansible Master add ansible installation in ec2-ansible and SSH Private key
      in key-pair.tf created SSM SecureString with Private key
      in iam.tf added ansible-role to allow read Private key from SSM_Parameter
      in ec2.tf added permissions by "iam_instance_profile" what have ansible-role

Ansible user on frontend/backend with SSH Public key in authorized_keys (not a password)
      Take "public_key" from local terraform parameters in key-pair.tf

Ansible Inventory
      Designed a master → slave → structure Frontend/Backend (nested children), corellated with group_vars.
      Auto-generating inventory.yaml from Terraform via templatefile + local_file, populated with real IPs, at time "terraform apply" execution 
            Create an ansible/inventory.tpl template in your Terraform project.
            Created inventory.tf with "local_file" + templatefile. Take IP from local terraform parameters and fill /ansible/inventory.yaml from ansible/inventory.tpl

### Ansible check 
From Master
```
ssh -i /mnt/e/DevOps/GIT/miniproj-aws-terraform-ansible/terraform/aws-ssh-key.pem ubuntu@< ansible-public-ip >

ssh -i ~/.ssh/aws-ssh-key.pem ansible@10.0.4.107
ssh -i ~/.ssh/aws-ssh-key.pem ansible@10.0.3.252

git clone https://github.com/evgeny-kor-m/miniproj-aws-terraform-ansible.git
cd miniproj-aws-terraform-ansible/ansible
ansible all -i inventory.yml -m ping

```