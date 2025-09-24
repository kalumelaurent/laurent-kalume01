# Variables paramétrables SKU et OS
variable "sku_name" {
  type    = string
  default = "P1v2"
}
variable "windows" {
  type    = string
  default = "Windows"
}
variable "linux" {
  type    = string
  default = "Linux"
}
