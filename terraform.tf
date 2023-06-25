provider "aws" {
  region     = "us-east-1"
}

resource "aws_instance" "my_ec2_instance" { 
 ami = "ami-0261755bbcb8c4a84" 
 instance_type = "t2.medium" 
 key_name = "raju" 
  
  tags ={ 
 name="Terraform hands-on" 
} 
 user_data  = <<-EOF
 #!/bin/bash
     sudo apt-get update -y
     sudo apt install docker.io -y
     sudo systemctl enable docker
     sudo docker run -itd -p 8084:8081 adhi7862/docker-pipeline
     sudo docker start $(docker ps -aq)
EOF
}
