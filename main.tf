provider "aws" {
region= "ap-southeast-1"
access_key= "AKIA2YIB77KPI4VEA2EB"
secret_key= "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"
}
resource "aws_instance" "instance" {
    ami = "ami-0b5a4445ada4a59b1"
    instance_type = "t2.micro"
    associate_public_ip_address = true
}
