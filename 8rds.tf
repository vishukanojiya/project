# ==========================================
# RDS SUBNET GROUP
# ==========================================

resource "aws_db_subnet_group" "mysql" {
  name = "${var.project_name}-db-subnet-group"

  subnet_ids = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}


# ==========================================
# RDS MYSQL
# ==========================================

resource "aws_db_instance" "mysql" {
  identifier = "${var.project_name}-mysql"

  engine = "mysql"

  engine_version = "8.0"

  instance_class = "db.t3.micro"

  allocated_storage = 20

  storage_type = "gp3"

  db_name = "applicationdb"

  username = var.db_username

  password = var.db_password

  port = 3306

  db_subnet_group_name = aws_db_subnet_group.mysql.name

  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]

  # VERY IMPORTANT
  publicly_accessible = false

  multi_az = false

  backup_retention_period = 7

  skip_final_snapshot = true

  deletion_protection = false

  tags = {
    Name = "${var.project_name}-mysql"
  }
}
