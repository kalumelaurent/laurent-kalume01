module "user_creation" {
  source   = "./modules/user_creation"  # chemin relatif vers le module
  username = "alice"           # valeur obligatoire
  # email_domain est optionnelle, prise par défaut si non précisée
}
