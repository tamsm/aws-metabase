// Env/Project vars
variable "project" {
  default     = "metabase"
  description = "The project name"
}

variable "env" {
  default     = "dev"
  description = "The environment var"
}

variable "aws_region" {
  default     = "eu-west-3"
  description = "The AWS region to create things in."
}
variable "profile" {
  description = "The shared credentials used for provisioning"
}

variable "vcp_ip_range" {
  default     = "10.0.0.0/16"
  description = "The default VPC's ip range"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 3000
}

variable "app_count" {
  description = "The desired count of docker containers/task to run"
  default     = 1
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "1024"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "2048"
}
