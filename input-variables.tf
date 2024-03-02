variable "env" {
  type = string
}

variable "common_tags" {
  type    = map(string)
  default = { "CostingGroup" : "Airlink", "Owner" : "Supply PM&E - Airlink" }
}
