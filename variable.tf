variable "subscription_id"{
  type=string
}
variable "client_id"{
  type=string
}
variable "client_secret"{
  type=string
}
variable "tenant_id"{
  type=string
}
variable "firstname" {
type=string
default="kalume"
}

variable "lastname" {
type=string
default="laurent"
}

variable "restaurant1" {
type=string
default="kfc"
}

variable "restaurant2" {
type=string
default="wendys"
}

variable "restaurant3" {
type=string
default="fortier"
}

variable "words" {
  type    = list(string)
  default = ["hi", "cat", "car", "tree", "hi", "car"]
}


variable "restaurant4" {
type=string
default="mcdo"
}

variable "restaurant5" {
type=string
default="harvys"
}

variable "listoffruits"{
type=list(string)
default=["banana" , "poteto" , "tomato"]
}

variable "Favorite_top_list_of_each_things"{
type=list(string)
default=["workout" , "movies" , "travel" , "songs" ,"affirmations"]
}

variable "app_name" {
type = string
default = "myapp"
}
variable "items" {
  type    = list(string)
  default = ["football","basketball","gaming","badminton","food"]
}
variable "server_name" {
  type    = string
  default = "app-prod-01"
}

variable "items1" {
  type    = list(string)
  default = ["one", "two", "three"]
}

variable "original" {
  default = "Hello MCIT World"
}


variable "phrase" {
  default = "InceptionMovie"
}

variable "citation" {
type = string
  default = "Une nation qui produit de jour en jour des hommes stupides achète à crédit sa propre mort spirituelle"
}

# Variable contenant une liste de noms
# Cette méthode sert à trier ou filtrer du texte par critère (ex. première lettre) en utilisant des for imbriqués dans Terraform
variable "names" {
  type    = list(string)
  default = ["amy", "adam", "bob", "brian", "carol"]
}

# Variable contenant une liste de nombres
# Écris un filtre Terraform avec for et if pour garder seulement les nombres pairs
variable "nums" {
  type    = list(number)
  default = [1, 2, 3, 4, 5, 6]
}

# Déclare une variable contenant une liste de chaînes avec des doublons
variable "magne" {
  type    = list(string)
  default = ["b", "a", "c", "a", "b"]
}


# Variable contenant une liste de chaînes au format "nom:score"
# l’exercice apprend à manipuler et fiabiliser des données dans Terraform"
variable "raw_scores" {
  type    = list(string)
  default = ["alice:90", "bob:75", "carol:85"]
}

# Déclaration de la variable labels contenant un ensemble de chaînes à convertir en majuscules
variable "labels" {
  type    = set(string)
  default = ["alpha", "beta", "gamma"]
}


# Déclare une liste de noms d'utilisateur à utiliser pour générer les adresses email
variable "usernames" {
  type    = list(string)
  default = ["alice", "bob", "carol"]
}

# Déclare le domaine à utiliser pour construire les emails
variable "domain" {
  type    = string
  default = "example.com"
}

# Variable contenant la liste des hôtels
# C’est utile pour cibler spécifiquement une valeur dans une liste et lui appliquer un traitement particulier, garantissant que l’information importante
variable "hotels" {
  default = ["Marriott", "Hilton", "Sheraton", "Hyatt"]
}


