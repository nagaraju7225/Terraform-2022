resource "aws_instance" "appserver1" {
    ami = data.aws_ami.ubuntu.id
    associate_public_ip_address = false
    instance_type = var.webserverinstancetype
    key_name = "naga_pl"
    vpc_security_group_ids = [ var.appsgid ]
    subnet_id = var.app1subnetid
    tags = {
      "Name" = "appserver 1"
    }

}

resource "aws_instance" "webserver1" {
    ami = data.aws_ami.ubuntu.id
    associate_public_ip_address = true
    instance_type = var.webserverinstancetype
    key_name = "naga_pl"
    vpc_security_group_ids = [ var.websgid ]
    subnet_id = var.web1subnetid
    tags = {
      "Name" = "webserver 1"
    }

}

resource "null_resource" "nullprovisoning" {

    # ssh -i terraform.pem ubuntu@publicip
    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = file("./naga_pl.pem")
      host = aws_instance.webserver1.public_ip
    }
    provisioner "remote-exec" {
      inline = [
        "sudo apt update", 
        "sudo apt install apache2 -y", 
        ]
    }

    depends_on = [ aws_instance.webserver1 ]

}