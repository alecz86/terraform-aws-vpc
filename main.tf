module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "8.0.1"

  name                = "example-asg"
  min_size           = 1
  max_size           = 99
  desired_capacity   = 1
  vpc_zone_identifier = data.terraform_remote_state.vpc.outputs.private_subnets

  health_check_type = "EC2"
  
  # Define launch template correctly
  
    launch_template_name          = "example-asg"
    launch_template_description   = "Launch template example"
    image_id      = "ami-0952a345dcc6cd699"
    instance_type = "t3.micro"
    ebs_optimized = false
  

  tags = {
    Name        = "asg-instance"
    Environment = "dev"
  }
}

resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier      = var.identifier
  engine                 = var.engine
  engine_version         = var.engine_version
  database_name          = var.database_name
  master_username        = var.db_username
  master_password        = random_password.password.result
  skip_final_snapshot    = true
  backup_retention_period = 7
}

# Writer instance
resource "aws_rds_cluster_instance" "writer" {
  identifier         = "aurora-writer"
  cluster_identifier = aws_rds_cluster.aurora_cluster.id
  instance_class     = var.instance_class
  engine            = aws_rds_cluster.aurora_cluster.engine
  engine_version    = aws_rds_cluster.aurora_cluster.engine_version
  publicly_accessible = true
}

# Reader instances
resource "aws_rds_cluster_instance" "reader1" {
  identifier         = "aurora-reader"
  cluster_identifier = aws_rds_cluster.aurora_cluster.id
  instance_class     = var.instance_class
  engine            = aws_rds_cluster.aurora_cluster.engine
  engine_version    = aws_rds_cluster.aurora_cluster.engine_version
  publicly_accessible = true
}

resource "aws_rds_cluster_instance" "reader2" {
  identifier         = "aurora-reader"
  cluster_identifier = aws_rds_cluster.aurora_cluster.id
  instance_class     = var.instance_class
  engine            = aws_rds_cluster.aurora_cluster.engine
  engine_version    = aws_rds_cluster.aurora_cluster.engine_version
  publicly_accessible = true
}

resource "aws_rds_cluster_instance" "reader3" {
  identifier         = "aurora-reader"
  cluster_identifier = aws_rds_cluster.aurora_cluster.id
  instance_class     = var.instance_class
  engine            = aws_rds_cluster.aurora_cluster.engine
  engine_version    = aws_rds_cluster.aurora_cluster.engine_version
  publicly_accessible = true
}

resource "random_password" "password" {
  length  = 16
  special = false
}

resource "aws_elasticache_cluster" "redis_db" {
  cluster_id           = "redis-db"
  engine               = "redis"
  node_type            = "cache.m4.large"
  num_cache_nodes      = 1
  port                 = 6379
  tags = {
    Name = "DevOps October2024"
  }
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "bucket-terraform-${random_string.random.result}"  # Replace with a globally unique name

  tags = {
    Name        = "MyS3Bucket"
    Environment = "Dev"
  }
}

resource "aws_vpc" "task-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true 
  tags = {
    Name = "task-vpc"
  }
}

resource "aws_subnet" "private-1" {
  vpc_id            = aws_vpc.task-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.av-azs.names[0]
  tags = {
    Name = "private-1"
  }
}

resource "aws_subnet" "private-2" {
  vpc_id            = aws_vpc.task-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.av-azs.names[1]
  tags = {
    Name = "private-2"
  }
}

resource "aws_subnet" "private-3" {
  vpc_id            = aws_vpc.task-vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = data.aws_availability_zones.av-azs.names[2]
  tags = {
    Name = "private-3"
  }
}

resource "aws_subnet" "public-1" {
  vpc_id                  = aws_vpc.task-vpc.id
  cidr_block              = "10.0.101.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.av-azs.names[0]
  tags = {
    Name = "public-1"
  }
}

resource "aws_subnet" "public-2" {
  vpc_id                  = aws_vpc.task-vpc.id
  cidr_block              = "10.0.102.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.av-azs.names[1]
  tags = {
    Name = "public-2"
  }
}

resource "aws_subnet" "public-3" {
  vpc_id                  = aws_vpc.task-vpc.id
  cidr_block              = "10.0.103.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.av-azs.names[2]
  tags = {
    Name = "public-3"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.task-vpc.id

  tags = {
    Name = "task-igw"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.task-vpc.id

  tags = {
    Name = "public-rt"
  }
}

resource "aws_main_route_table_association" "mainflag" {
  vpc_id         = aws_vpc.task-vpc.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "public-ass1" {
  subnet_id      = aws_subnet.public-1.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "public-ass2" {
  subnet_id      = aws_subnet.public-2.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "public-ass3" {
  subnet_id      = aws_subnet.public-3.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route" "rigw" {
  route_table_id         = aws_route_table.public-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.task-vpc.id

  tags = {
    Name = "private-rt"
  }
}

resource "aws_route_table_association" "private-ass1" {
  subnet_id      = aws_subnet.private-1.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "private-ass2" {
  subnet_id      = aws_subnet.private-2.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "private-ass3" {
  subnet_id      = aws_subnet.private-3.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_eip" "eip" {
  depends_on = [aws_internet_gateway.igw]
  domain     = "vpc"
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public-1.id
}

resource "aws_route" "rngw" {
  route_table_id         = aws_route_table.private-rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw.id
}

