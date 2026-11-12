resource "aws_db_subnet_group" "db" {

  name = "db-subnet-group"

  subnet_ids = [
    aws_subnet.private_db_a.id,
    aws_subnet.private_db_b.id
  ]
}

resource "aws_db_instance" "mysql" {

  identifier = "production-db"

  allocated_storage = 20

  engine         = "mysql"
  engine_version = "8.0"

  instance_class = "db.t3.micro"

  username = var.db_username
  password = var.db_password

  db_subnet_group_name = aws_db_subnet_group.db.name

  vpc_security_group_ids = [
    aws_security_group.rds_sg.id
  ]

  multi_az = true

  storage_encrypted         = true
  backup_retention_period   = 7
  backup_window             = "03:00-04:00"
  maintenance_window        = "sun:04:00-sun:05:00"
  deletion_protection       = true
  copy_tags_to_snapshot     = true
  skip_final_snapshot       = false
  final_snapshot_identifier = "production-db-final"

  publicly_accessible = false
}