variable "default_tags" {
  description = "The defaults tags, we will be adding to the these"
  type        = map(any)
  default = {
    project        = "devops-pipeline-test"
    environment    = "dev"
    deployed_using = "terraform"
  }
}


variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
}

variable "sku" {
}
