locals {
full_name = "${var.app_name}-prod"
}
locals {
  movie_lower = lower(var.movie) # "inception"
}
