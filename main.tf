resource "aws_vpc" "mynewvpc" {
  cidr_block = var.Net_work.vpccidr
  tags = {
    Name = var.Net_work.vpcname
  }
}
resource "aws_subnet" "pubsubnet" {
  count = local.pub_subnets_value
  vpc_id = aws_vpc.mynewvpc.id
  cidr_block = var.Net_work.pubsub_info[0].pubsubcidr[count.index]
  availability_zone = var.Net_work.pubsub_info[0].pubsubaz[count.index]
  tags = {
    Name = var.Net_work.pubsub_info[0].pubsubname[count.index]
  }
}
resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.mynewvpc.id
  tags = {
    Name = "myownigw"
  }
}

resource "aws_route_table" "pubroute" {
  vpc_id = aws_vpc.mynewvpc.id
  count = local.pub_subnets_value
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "mypubrtasso" {
  count = local.pub_subnets_value
  subnet_id = aws_subnet.pubsubnet[count.index].id
  route_table_id = aws_route_table.pubroute[count.index].id
}
resource "aws_security_group" "my-sg" {
  vpc_id = aws_vpc.mynewvpc.id
  name = "my-sg"
  description = "my security group"
  tags = {
    Name = "my-sg"
  }
}

 resource "aws_vpc_security_group_ingress_rule" "myingress_SSH" {
  security_group_id = aws_security_group.my-sg.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 22
  ip_protocol = "tcp"
  to_port = 22
 } 
 resource "aws_vpc_security_group_ingress_rule" "myingress_HTTP" {
  security_group_id = aws_security_group.my-sg.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 80
  ip_protocol = "tcp"
  to_port = 80
 }

 resource "aws_vpc_security_group_egress_rule" "myegress" {
  security_group_id = aws_security_group.my-sg.id
  ip_protocol      = "-1"
  cidr_ipv4      = "0.0.0.0/0"
 } 
  
 
 data "aws_ami" "myalreadyami" {
  most_recent = true
  owners = ["099720109477"]
    filter {
      name = "name"
      values = ["ubuntu-pro-server/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-pro-server-20250919"]
    }
 }
 resource "aws_key_pair" "myownkey" {
   public_key = file("~/.ssh/id_ed25519.pub")
   key_name = "nov-key"
 }
 resource "aws_instance" "myec2" {
   count = local.pub_subnets_value
   ami = data.aws_ami.myalreadyami.id
   instance_type = "t3.micro"
   key_name = aws_key_pair.myownkey.key_name
   associate_public_ip_address = true
   vpc_security_group_ids = [aws_security_group.my-sg.id]
   subnet_id = aws_subnet.pubsubnet[count.index].id
   tags = {
     Name = "myec2"
   }
 }

   resource "null_resource" "mysomechanges" {
    count = length(aws_instance.myec2)
    triggers ={
      always-update = timestamp()
    }

   connection {
     type = "ssh"
     user = "ubuntu"
     private_key = file("~/.ssh/id_ed25519")
     host = aws_instance.myec2[count.index].public_ip
   }
   provisioner "file" {
     source = "./webapp.sh"
     destination = "/home/ubuntu/webapp.sh"
   }
   provisioner "remote-exec" {
     inline = [ "sudo chmod +x /home/ubuntu/webapp.sh", "./webapp.sh" ]
   }
   }
 
    
  
  
  
  
