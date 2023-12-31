## Provision a Nessus Scanner ##

variable "scanner_name" {
  description = "The name of your Nessus scanner as it will appear in the Tenable.io web UI. Defaults to the AWS instance name."
  type        = string
  default     = null
}

variable "tenable_linking_key" {
  description = "The linking code from tenable.io — Go to Scans > Scanners in the web UI and find the Linking Key there"
  type        = string
}

variable "vpc_id" {
  description = "The VPC with which security groups will be associated"
  type        = string
}

variable "subnet_id" {
  description = "Subnet in which the server and related objects will be created"
  type        = string
}

variable "instance_type" {
  description = "The type of instance, e.g. m3.large, c3.2xlarge, etc. to be spun up"
  type        = string
  default     = "m5.xlarge"
}

variable "instance_name" {
  description = "The name of the instance as it appears in the aws instance list. Overrides any name passed in instance_tags."
  type        = string
  default     = null
}

variable "instance_tags" {
  description = "A map of tags to apply to the instance"
  type        = map(string)
  default     = {}
}

variable "use_eip" {
  description = "Whether or not to use an Elastic IP address with the Nessus scanner. Defaults to true because the documentation says it is required."
  type        = bool
  default     = true
}

variable "nessus_version" {
  description = "Version of the Nessus scanner to install."
  type        = string
  default     = "latest"
}
