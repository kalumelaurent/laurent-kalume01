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
  default = ["one", "two", "three"]
}
variable "server_name" {
  type    = string
  default = "app-prod-01"
}

variable "items2" {
  type    = list(string)
  default = ["football","basketball","gaming","badminton","food"]
}
