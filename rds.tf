resource "aws_db_parameter_group" "default" {
  name   = "default"
  family = "mysql5.7"

  parameter {
    name  = "character_set_database"
    value = "utf8m64"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8m64"
  }
}

resource "aws_db_option_group" "default" {
  name                 = "default"
  engine_name          = "mysql"
  major_engine_version = "5.7"

  option {
    option_name = "MARIADB_AUDIT_PLUGIN"
  }
}

resource "aws_db_subnet_group" "default" {
  name = "default-group"
  subnet_ids = [
    aws_subnet.private_01.id,
    aws_subnet.private_02.id
  ]
}

resource "aws_db_instance" "default" {
  identifier            = "default"
  engine                = "mysql"
  engine_version        = "5.7.25"
  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp2"
  storage_encrypted     = true
  kms_key_id            = aws_kms_key.default.arn
  username              = "admin"
  # TODO:apply後パスワード変更する
  password                   = "VeryStrongPassword!"
  multi_az                   = true
  publicly_accessible        = false
  backup_window              = "09:10-09:40"
  backup_retention_period    = 30
  maintenance_window         = "mon:10:10-mon:10:40"
  auto_minor_version_upgrade = false
  deletion_protection        = false
  skip_final_snapshot        = true
  port                       = 3306
  apply_immediately          = false
  vpc_security_group_ids     = [module.mysql_sg.security_group_id]
  parameter_group_name       = aws_db_parameter_group.default.name
  option_group_name          = aws_db_option_group.default.name
  db_subnet_group_name       = aws_db_subnet_group.default.name

  lifecycle {
    ignore_changes = [password]
  }
}

module "mysql_sg" {
  source      = "./security_group"
  name        = "mysql-sg"
  vpc_id      = aws_vpc.default.id
  port        = 3306
  cidr_blocks = [aws_vpc.default.cidr_block]
}
