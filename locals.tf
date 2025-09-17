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

locals {
  evens   = [for n in var.nums : n if n % 2 == 0]
  squares = [for n in local.evens : n * n]
}

locals {
  unique_sorted = sort(distinct(var.items))
  csv           = join(",", local.unique_sorted)
}



locals {
  # Transformer chaque élément string en un objet avec name et score (number)
  score_pairs = [
    for s in var.raw_scores : {
      name  = split(":", s)[0]
      score = tonumber(split(":", s)[1])
    }
  ]

  # Construire la map nom => score
  scores_map = { for p in local.score_pairs : p.name => p.score }

  # Calculer la moyenne des scores
  average = length(local.score_pairs) == 0 ? 0 :
    sum([for p in local.score_pairs : p.score]) / length(local.score_pairs)
}
