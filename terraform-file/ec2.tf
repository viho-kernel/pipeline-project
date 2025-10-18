resource "aws_instance" "demo-server" {
    ami = "ami-0341d95f75f311023"
    instance_type = "t2.micro"
    key_name = "project-pair"
    security_groups = [aws_security_group.demo-sg.name]
   # Replace with your actual key pair name
    tags = {
        Name = "DemoServer"
        Environment = "Development"
    }
  
}

resource "aws_security_group" "demo-sg" {
    name        = "demo-security-group"
    description = "Security group for demo server"

    ingress {
        description = "Allow SSH access"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

}