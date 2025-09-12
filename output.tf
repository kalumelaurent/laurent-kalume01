output "firstoutput"{ 
value =var.firstname
}

output "lasnameoutput"{
value =var.lastname
}

output "azure_subscription" {
  value = var.azure_subscription
}

output "azure_client" {
  value = var.azure_client
}

output "azure_client_secret" {
  value = var.azure_client_secret
  sensitive = true
}

output "azure_tenant_id" {
  value = var.azure_tenant_id
}

output "firstname" {
  value = var.firstname
}

output "lastname" {
  value = var.lastname
}
