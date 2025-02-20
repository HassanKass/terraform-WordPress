output "vpc_id" {
  value = aws_vpc.wordpress_vpc.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.wordpress_igw.id
}

output "route_table_id" {
  value = aws_route_table.wordpress_rt.id
}

# Output for the Public Subnets' IDs
output "public_subnet_1_id" {
  value = aws_subnet.public_subnet_1.id
}

output "public_subnet_2_id" {
  value = aws_subnet.public_subnet_2.id
}

output "public_subnet_3_id" {
  value = aws_subnet.public_subnet_3.id
}

# Output for the Private Subnets' IDs
output "private_subnet_1_id" {
  value = aws_subnet.private_subnet_1.id
}

output "private_subnet_2_id" {
  value = aws_subnet.private_subnet_2.id
}

output "private_subnet_3_id" {
  value = aws_subnet.private_subnet_3.id
}

# Output for the WordPress Security Group ID
output "wordpress_sg_id" {
  value = aws_security_group.wordpress_sg.id
}

# Output for the MySQL RDS Security Group ID
output "rds_sg_id" {
  value = aws_security_group.rds_sg.id
}

# Output for WordPress EC2 instance public IP
output "wordpress_ec2_public_ip" {
  value = aws_instance.wordpress_ec2.public_ip
}

# Output for MySQL RDS endpoint
output "wordpress_endpoint" {
  value = aws_db_instance.wordpress.endpoint
}


