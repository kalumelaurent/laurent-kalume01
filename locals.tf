locals {
full_name = "${var.app_name}-prod"
}
locals {
  replaced = replace(var.original, "MCIT", "Montreal College")
}
 
