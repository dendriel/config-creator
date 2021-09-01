variable region {
    type        = string
    description = "Region in which to deploy Config Creator application."
}

variable vpc {
    type = object({
        cidr                = string
        azs                 = list(string)
        public_subnets_cidr  = list(string)
    })
}

variable launch_configuration_key_name {
    type = string
    description = "Key name used by launch configuration (see 'Key Pairs' on EC2 console)"
}