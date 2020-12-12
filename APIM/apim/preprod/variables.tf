## apim\preprod\variables.tf

variable "environment" {
  type = string
}
variable "envshort" {
  type = string
}
variable "location" {
  type = string
}
variable "locshort" {
  type = string
}
variable "service" {
  type = string
}
variable "baseindex" {
  type = string
}
variable "baseprefix" {
  type = string
}
variable "subnetprefix" {
  type = string
}
variable "apimsku" {
  type = string
}
variable "servicedomain" {
  type = string
}
variable "aadid" {
  type = string
}
variable "aadsec" {
  type = string
}
variable "aadten" {
  type = string
}
variable "prdoverride" {
  type = string
  default = ""
}
variable "customdomain" {
  type = string
}
variable "keyvaultsecretid" {
  type = string
}
variable "userassignedidentity" {
  type = string
}
