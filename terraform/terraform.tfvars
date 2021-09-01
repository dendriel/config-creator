region = "sa-east-1"

launch_configuration_key_name = "ec2-default"


vpc = {
    azs                 = ["sa-east-1a", "sa-east-1b", "sa-east-1c"]
    cidr                = "10.0.0.0/16"
    public_subnets_cidr  = ["10.0.0.0/24","10.0.1.0/24"],
}