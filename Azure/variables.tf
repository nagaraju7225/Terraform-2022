variable "location" {
  type = string
  description = "location where resource are to created "
  default = "eastus"
}

variable "subnets" {
  type = list(string)
  description = "subnets to be created"
  default = [ "web" , "app" , "db" ]
}

variable "ntiervnetrange" {
  type = string
  description = "range of the vnet"
  default = "192.168.0.0/16"
}