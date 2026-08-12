#!/bin/bash
#
# check-aws-leftovers.sh
#
# Scans common AWS resource types and prints anything that still exists,
# so you can spot leftovers after `terraform destroy` (including anything
# created manually outside of Terraform).
#
# Usage:
#   chmod +x check-aws-leftovers.sh
#   ./check-aws-leftovers.sh [region]
#
# If no region is given, defaults to us-east-1.

REGION="${1:-us-east-1}"

echo "=================================================================="
echo " AWS Resource Audit — region: $REGION"
echo " Account: $(aws sts get-caller-identity --query Account --output text 2>/dev/null)"
echo "=================================================================="

section() {
  echo ""
  echo "------------------------------------------------------------"
  echo "  $1"
  echo "------------------------------------------------------------"
}

# --- EC2 Instances -----------------------------------------------------
section "EC2 Instances (running/stopped)"
aws ec2 describe-instances --region "$REGION" \
  --query 'Reservations[].Instances[?State.Name!=`terminated`].{ID:InstanceId,Name:Tags[?Key==`Name`]|[0].Value,State:State.Name,Type:InstanceType}' \
  --output table

# --- VPCs (non-default) -------------------------------------------------
section "VPCs (non-default)"
aws ec2 describe-vpcs --region "$REGION" \
  --query 'Vpcs[?IsDefault==`false`].{ID:VpcId,Name:Tags[?Key==`Name`]|[0].Value,CIDR:CidrBlock}' \
  --output table

# --- Subnets -------------------------------------------------------------
section "Subnets (non-default VPC)"
aws ec2 describe-subnets --region "$REGION" \
  --query 'Subnets[?DefaultForAz==`false`].{ID:SubnetId,Name:Tags[?Key==`Name`]|[0].Value,VPC:VpcId}' \
  --output table

# --- Internet Gateways ----------------------------------------------------
section "Internet Gateways"
aws ec2 describe-internet-gateways --region "$REGION" \
  --query 'InternetGateways[].{ID:InternetGatewayId,Name:Tags[?Key==`Name`]|[0].Value,VPC:Attachments[0].VpcId}' \
  --output table

# --- NAT Gateways ----------------------------------------------------------
section "NAT Gateways (not deleted)"
aws ec2 describe-nat-gateways --region "$REGION" \
  --filter "Name=state,Values=available,pending" \
  --query 'NatGateways[].{ID:NatGatewayId,State:State,VPC:VpcId}' \
  --output table

# --- Elastic IPs -------------------------------------------------------------
section "Elastic IPs (cost money even if unused!)"
aws ec2 describe-addresses --region "$REGION" \
  --query 'Addresses[].{IP:PublicIp,AllocId:AllocationId,AssocId:AssociationId,InstanceId:InstanceId}' \
  --output table

# --- Security Groups (non-default) -------------------------------------------
section "Security Groups (non-default)"
aws ec2 describe-security-groups --region "$REGION" \
  --query 'SecurityGroups[?GroupName!=`default`].{ID:GroupId,Name:GroupName,VPC:VpcId}' \
  --output table

# --- Route Tables (non-main) --------------------------------------------------
section "Route Tables (non-main)"
aws ec2 describe-route-tables --region "$REGION" \
  --query 'RouteTables[?Associations[0].Main!=`true`].{ID:RouteTableId,Name:Tags[?Key==`Name`]|[0].Value,VPC:VpcId}' \
  --output table

# --- Key Pairs -----------------------------------------------------------------
section "Key Pairs"
aws ec2 describe-key-pairs --region "$REGION" \
  --query 'KeyPairs[].{Name:KeyName,ID:KeyPairId}' \
  --output table

# --- EFS File Systems -----------------------------------------------------------
section "EFS File Systems"
aws efs describe-file-systems --region "$REGION" \
  --query 'FileSystems[].{ID:FileSystemId,Name:Tags[?Key==`Name`]|[0].Value,State:LifeCycleState}' \
  --output table

# --- ELB / ALB -------------------------------------------------------------------
section "Load Balancers (ALB/NLB)"
aws elbv2 describe-load-balancers --region "$REGION" \
  --query 'LoadBalancers[].{Name:LoadBalancerName,DNS:DNSName,State:State.Code}' \
  --output table 2>/dev/null

section "Target Groups"
aws elbv2 describe-target-groups --region "$REGION" \
  --query 'TargetGroups[].{Name:TargetGroupName,Port:Port}' \
  --output table 2>/dev/null

# --- ECR Repositories --------------------------------------------------------------
section "ECR Repositories"
aws ecr describe-repositories --region "$REGION" \
  --query 'repositories[].{Name:repositoryName,URI:repositoryUri}' \
  --output table

# --- IAM Roles (excluding AWS service-linked roles) ---------------------------------
section "IAM Roles (customer-managed, excluding AWS service-linked)"
aws iam list-roles \
  --query 'Roles[?!starts_with(Path, `/aws-service-role/`)].{Name:RoleName,Created:CreateDate}' \
  --output table

# --- IAM Instance Profiles -------------------------------------------------------------
section "IAM Instance Profiles"
aws iam list-instance-profiles \
  --query 'InstanceProfiles[].{Name:InstanceProfileName,Roles:Roles[0].RoleName}' \
  --output table

# --- SSM Parameters (non-AWS-managed) -----------------------------------------------------
section "SSM Parameters (custom, non /aws/ paths)"
aws ssm describe-parameters --region "$REGION" \
  --query 'Parameters[?!starts_with(Name, `/aws/`)].{Name:Name,Type:Type}' \
  --output table

# --- S3 Buckets (account-wide, not region-specific) --------------------------------------
section "S3 Buckets"
aws s3 ls

echo ""
echo "=================================================================="
echo " Audit complete. Anything listed above still exists in your account."
echo " Cross-check against your Terraform state / config to see what's"
echo " managed vs. manually created."
echo "=================================================================="