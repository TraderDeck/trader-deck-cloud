locals {
  subnet_ids = [
    //Public Subnets
    aws_subnet.subnet_1.id,
    aws_subnet.subnet_2.id,
    aws_subnet.subnet_3.id,
    //Private Subnets
    aws_subnet.subnet_4.id,
    aws_subnet.subnet_5.id,
    aws_subnet.subnet_6.id,
    aws_subnet.subnet_7.id,
    aws_subnet.subnet_8.id
  ]
}