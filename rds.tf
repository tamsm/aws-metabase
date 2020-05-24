resource "random_password" "password" {
  length = 16
  special = false
  // override_special = "/@\" "
}

// Defining an DB parameter group here
// AWS implementation of pg_hba.conf
resource "aws_db_parameter_group" "postgresql" {
  name   = "${var.project}-rds"
  family = "postgres11"

  parameter {
    name  = "application_name"
    value = var.project
  }
  tags = {
    Name = var.project
  }
}


// See DOCs https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html
resource "aws_db_instance" "postgresql" {
  allocated_storage               = "20" // The amount of storage (in gibibytes) to allocate for the DB instance.
  engine                          = "postgres"
  engine_version                  = "11"
  identifier                      = "${var.env}-${var.project}-rds-instance"
  // https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
  instance_class                  = "db.t3.micro"
  storage_type                    = "gp2"
  // iops for OLTP workloads
  // iops                         = var.iops
  name                            = var.project
  password                        = trimspace(random_password.password.result)
  username                        = var.project
  backup_retention_period         = 14 // In Days
  // No overlaps in maintenance windows
  backup_window                   = "02:30-03:30" // Number of days to keep database backups
  maintenance_window              = "sun:01:00-sun:02:00" // 60 minute time window to reserve for maintenance
  auto_minor_version_upgrade      = true // Indicates that minor version patches are applied automatically
  // copy_tags_to_snapshot           = var.copy_tags_to_snapshot
  multi_az                        = false // Specifies if the RDS instance is multi-AZ
  port                            = "5432" // Postgres default
  vpc_security_group_ids          = [aws_security_group.db.id]
  db_subnet_group_name            = aws_db_subnet_group.postgres.name
  parameter_group_name            = aws_db_parameter_group.postgresql.name
  storage_encrypted               = true
  deletion_protection             = false // Default is false, to be enables for OLTP app like workload
  skip_final_snapshot = true
  // RDS dependencies
  depends_on = [aws_db_parameter_group.postgresql, aws_db_subnet_group.postgres]
  tags = {
    Name = var.project,
    Environment = var.env
  }
}
