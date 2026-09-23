# project
Tripare.ai

Terraform Infrastructure Design
Thie is the basic structure for the project

Internet
   ↓
Internet-facing ALB
   ↓
ECS Fargate (Private Subnet)
   ↓
RDS MySQL (Private Subnet)
-------------------------------------------------------------------------------------
Below structure will show the required tf files

terraform-ecs-rds/
│
├── provider.tf
├── variables.tf
├── vpc.tf
├── security-groups.tf
├── alb.tf
├── ecs.tf
├── rds.tf
├── outputs.tf
└── terraform.tfvars

NOTE- We are keeping passwords in terraform.tfvars which is never recommended in production. We are keeping for this project only.

SECURITY_GROUP- As per instruction RDS must be private and should only be accessible from ECS/Fargate so we are allowing from the access from the ECS only.
                The structure will will be-
                Internet
   ↓ 80
ALB SG
   ↓ 80
ECS SG
   ↓ 3306
RDS SG

The above structure is defining that from ECS only with port 3306, we can access database.
For safer side - security_groups = [aws_security_group.ecs.id]
We first provide the security_group_name.ecs.id

ELASTIC CONTAINER SERVICE-
We are keeping the ecs in private subnet so that it will not directly accessible from the internet. We only allow the ecs access from the application load balancer. The port we are defining for ECS is 80 because we are keeping nginx server. 

assign_public_ip = false (ECS will not get public IP)

---------------------------------------------------------------------------------------------
DATABASE- To keep our database(mysql) secure 

db_subnet_group_name = aws_db_subnet_group.mysql.name 

vpc_security_group_ids = [
  aws_security_group.rds.id
]
publicly_accessible = false

------------------------------------------------------------------------------------------------

Final Output for the teraform file after apply will look like this-


 Here we can easily understand that the traffic will reach to the internet then we are providing applicaiton load balancer which is in public subnet with port number 80. Every user will reach to our server from this applicaiton load balancer.

 Next the ALB sends the signal to ECS fargate on private subnet with port number 80 which is allow to the ALB. 

 And, the final fargate will communicate with our database which is mysql.
                         INTERNET
                            │
                            │ :80
                            ▼
                  ┌──────────────────┐
                  │       ALB        │
                  │  Public Subnets  │
                  └────────┬─────────┘
                           │
                           │ :80
                           ▼
              ┌─────────────────────────┐
              │       ECS FARGATE       │
              │                         │
              │     Nginx Container     │
              │    Private Subnets      │
              └────────────┬────────────┘
                           │
                           │ :3306
                           ▼
                  ┌──────────────────┐
                  │       RDS        │
                  │      MySQL       │
                  │  Private Subnets │
                  └──────────────────┘

  Flow for security 
  Internet
   │
   │ 80
   ▼
ALB-SG
   │
   │ 80
   ▼
ECS-SG
   │
   │ 3306
   ▼
RDS-SG


terraform commands-

terraform init     → Initialize the Terraform project
terraform fmt      → Format the Terraform code properly
terraform validate → Validate or check the Terraform code
terraform plan     → Show what changes Terraform will make
terraform apply    → Create/update the actual infrastructure

After apply
terraform output alb_dns_name
Open that ALB DNS in the browser and Nginx should appear.

Note: NAT Gateway is included because ECS is private and needs outbound access to pull nginx:latest. NAT Gateway incurs AWS charges, so after testing the final command for destroy the application
terraform destroy
