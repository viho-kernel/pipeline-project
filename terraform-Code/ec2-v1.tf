resource "aws_instance" "demo-server" {
    ami = "ami-02d26659fd82cf299"
    instance_type = "t2.micro"
    key_name = "Project_Pair"
}

