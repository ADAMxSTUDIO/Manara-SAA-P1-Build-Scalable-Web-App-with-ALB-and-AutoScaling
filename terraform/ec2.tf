data "aws_ami" "amazon_linux" {

  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }
}

resource "aws_launch_template" "app" {

  name_prefix            = "web-"
  image_id               = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  update_default_version = true
  iam_instance_profile {
    name = aws_iam_instance_profile.ssm.name
  }

  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id
  ]

  user_data = base64encode(<<-EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent
systemctl start httpd
systemctl enable httpd
echo "Application Server" > /var/www/html/index.html
EOF
  )
}

resource "aws_iam_role" "ssm" {
  name = "production-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm" {
  name = "production-ec2-ssm-profile"
  role = aws_iam_role.ssm.name
}