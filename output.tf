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


output "replaced_string" {
  value = local.replaced 
}

output "first_word" {
  value = local.first_word # "Inception"
}

output "citation_modifiee" {
  value = local.citation_hash
}

output "grouped_by_initial" { value = local.grouped }

output "evens"   { value = local.evens }
output "squares" { value = local.squares }

output "unique_sorted" {
  value = local.unique_sorted
}

output "csv" {
  value = local.csv
}


output "scores_map" {
  value = local.scores_map
}

output "avg_score" {
  value = local.average
}


# Exporte le map des emails générés 
output "emails" {
  value = local.emails
}

output "average2"{
value = local.average2
}


# Export du set transformé en output
output "labels_upper" {
  value = local.labels_upper
}
