# Configure our AWS Connection
provider "aws" {
   region = "ap-south-1"
}

#Get the list of availability zones in the current region

data "aws_availability_zones" "all" {
  
}

#Create a security group that controls what traffic an go in and out of the ELB

resource "aws_security_group" "elb" {
  name = "vensara-elb"
  #Allow all outbound (-1)
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  #Inbound HTTP from anywhere
  ingress {
    from_port = var.elb_port
    to_port = var.elb_port
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

#Create the security group that's applied to each ec2 instance in the a SG

resource "aws_security_group" "instance" {
  name = "vensara-instance"
  
  #Inbound HTTP from anywhere
  ingress {
    from_port = var.server_port
    to_port = var.server_port
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

#Create an application ELB to route traffic across the auto scaling group

resource "aws_elb" "example" {
  name = "vensara-elb"  
  security_groups = [ aws_security_group.elb.id ]
  availability_zones = data.aws_availability_zones.all.names

  health_check {
    target = "HTTP:${var.server_port}/"
    interval = 30
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }

  # This adds a listener for incoming HTTP requests 

  listener {
    lb_port = var.elb_port
    lb_protocol = "http"
    instance_port = var.server_port
    instance_protocol = "http"
  }
}
# Create a launch configuration that defines each 
resource "aws_launch_configuration" "example" {
  name = "vensara-launchconfig"

  #ubuntu server 20.04 LTS(HVM) , SSD Volume Type in ap-south-01
  image_id = "ami-006d3995d3a6b963b" 
  instance_type = "t2.micro"
  security_groups = [aws_security_group.instance.id]

  user_data = <<-EOF
              #!/bin/bash
              echo '<html><body><h1 style="font-size:50px;color:blue;"'> VENSARA TECHNOLOGIES <br> <font style="color:red;"> www.vensara.info <br> <font style="color:green;"> +91 9581326233 </h1> </body> </htm>' > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF
  #Whenever using a launch configuration with an auto scaling group , you must set below
  lifecycle {
    create_before_destroy = true
  }
}

#Create the auto scaling group

resource "aws_autoscaling_group" "example" {
  name = "vensara-asg"
  launch_configuration = aws_launch_configuration.example.id
  availability_zones = data.aws_availability_zones.all.names 

  min_size = 2
  max_size = 10
  load_balancers = [aws_elb.example.name]
  health_check_type = "ELB"

  tag {
    key = "Name"
    value = "Vensara-ASG-Project"
    propagate_at_launch = true
  }
}