provider "aws" {
region = "ap-south-1"
profile = "default"
}

resource "aws_instance" "MyWebserver" {
  ami           = "ami-010aff33ed5991201"
  instance_type = "t2.micro"
  security_groups = ["allow-All"]
  key_name = "awsclass2020key"
  tags = {
    Name = "my web server"
  }

}

resource "aws_ebs_volume" "web_volume"{
	availability_zone = aws_instance.MyWebserver.availability_zone
	size = 5
	tags = {
		Name = "myWebvolume"
	}	
}

resource "aws_volume_attachment" "vol_att" {
	device_name = "/dev/sdc"
	volume_id = aws_ebs_volume.web_volume.id
	instance_id = aws_instance.MyWebserver.id
}


resource "null_resource" "nullres1"{

	connection{
	type = "ssh"
	user = "ec2-user"
	private_key = file("C:/Users/89606/Downloads/awsclass2020key.pem")
	host = aws_instance.MyWebserver.public_ip
	}
	provisioner "remote-exec" {
		inline = [
		"sudo yum  install httpd  -y",
		"sudo  yum  install php  -y",
		"sudo systemctl start httpd",
		"sudo mkfs.ext4 /dev/xvdh",
		"sudo  mount /dev/xvdh  /var/www/html",
		"sudo yum install git -y",
		"sudo git clone https://github.com/dileep-hub/Terraform-configure_apache_WebServer.git   /var/www/html/web"
		
		]
	}
}