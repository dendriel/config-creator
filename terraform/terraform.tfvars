region = "sa-east-1"

launch_configuration_key_name = "ec2-default"


vpc = {
    azs                 = ["sa-east-1a", "sa-east-1c"]
    cidr                = "10.0.0.0/16"
    public_subnets_cidr  = ["10.0.0.0/24","10.0.1.0/24"]
    private_subnets_cidr  = ["10.0.10.0/24","10.0.11.0/24"]
}

db = {
    name = "config_creator"
    user = "root"
    pass = "360f48034aef4b5394b0cbb9c390a7bc"
}

mongodb = {
    name = "config_creator"
    user = "root"
    pass = "bfcb2b71034c430c8d243772edae4361"
}

# TODO: make services get keys from secrets
service_auth_key = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJzZXJ2aWNlLnVzZXIwMSIsImV4cCI6MTYzNDA2OTQwMywiaWF0IjoxNjMxNDc3NDAzfQ.ZT3R7PSqQ2SmQ4vkyCxZb2BB7oObgl6cyGk0LtUBJZQ"