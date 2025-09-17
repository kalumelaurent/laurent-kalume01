locals {
full_name = "${var.app_name}-prod"
}
locals {
  replaced = replace(var.original, "MCIT", "Montreal College")
}
 
locals {
  first_word = substr(var.phrase, 0, 9) # start at index 0, length 9
}

locals {
  citation_hash = replace(var.citation, " ", "#")
}

locals {
  initials = toset([for n in var.names : substr(n, 0, 1)])
  grouped  = {
    for i in local.initials :
    i => [for n in var.names : n if substr(n, 0, 1) == i]
  }
}
