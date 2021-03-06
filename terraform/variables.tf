variable region {
    type        = string
    description = "Region in which to deploy Config Creator application."
}

variable storage_bucket_name {
    type        = string
    description = "Bucket to save exported configurations."
}

variable vpc {
    type = object({
        cidr                 = string
        azs                  = list(string)
        public_subnets_cidr  = list(string)
        private_subnets_cidr = list(string)
    })
}

# Used by rest_service to post on sqs. To remove the need of this input, update
# rest_service EXPORTER_ENABLED env var to false.
variable aws_access_key_id {
    type = string
    description = "Used by REST and Storage services to connect to SQS and S3."
    sensitive = true
}

variable aws_secret_key {
    type = string
    description = "Used by REST and Storage services to connect to SQS and S3."
    sensitive = true
}

variable launch_configuration_key_name {
    type = string
    description = "Key name used by launch configuration (see 'Key Pairs' on EC2 console)"
}

variable db {
    type = object({
        name = string
        user = string
        pass = string
    })
}

variable mongodb {
    type = object({
        name = string
        user = string
        pass = string
    })
}

variable sqs {
    type = object({
        name = string
    })
}

variable service_auth_key {
    type = string
}