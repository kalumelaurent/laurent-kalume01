output "firstoutput"{ 
value =var.firstname
}

output "lasnameoutput"{
value =var.lastname
}


output "restaurant1output"{ 
value =var.restaurant1
}

output "restaurant2output"{
value =var.restaurant2
}

output "restaurant3output"{ 
value =var.restaurant3
}

output "restaurant4output"{
value =var.restaurant4
}

output "restaurant5output"{
value =var.restaurant5
}

output "listoffruits"{
value =var.listoffruits
}

output "Favorite_top_list_of_each_things"{
value =var.Favorite_top_list_of_each_things
}

output "application_name" {
value =local.full_name
}

output "csv_items" {
  value = join(",", var.items)
}
output "server_name_parts" {
  value = split("-", var.server_name)
}

output "csv_items1" {
  value = join(",", var.items)
}
output "movie_lower" {
value = "inception"
