variable "default_tags" {
  description = "The defaults tags, we will be adding to the these"
  type        = map(any)
  default = {
    project        = "devops-pipeline-test"
    environment    = "dev"
    deployed_using = "terraform"
  }
}

variable "sku" {
}
