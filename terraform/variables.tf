# Region to work in. Due to seattle living, us-west-2
# shall remain default forever.
variable "region" {
  default = "us-west-2"
}

variable "az_count" {
  description = "Number of AZs to cover in a given AWS region"
  default     = "3"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 3000
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 1
}

variable "app_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "adongy/hostname-docker:latest"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "256"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "512"
}

# Tag is a concept I pulled over from my aws times
# where you essentially need a unique prefix to identify
# your concurrently running app, with everyone elses. It
# helps a lot, though in a fate of ironic justice, I made
# it so tags were randomly generated pet names like:
# "flying-bashful-yeti"
variable "tag" {
  type = "string"
}

variable "stage" {
  type    = "string"
  default = "dev" # Other one is prod
}

variable "default_domain" {
  # I already own this domain in aws.
  default = "iph.io"
}