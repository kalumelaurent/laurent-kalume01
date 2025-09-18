module "example_user" {
  source   = "./modules/user"
  username = "kalume"       # Valeur obligatoire à passer
  # email_domain est optionnel (exemple.com par défaut)
}
