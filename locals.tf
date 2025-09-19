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

# Extraire l'ensemble des initiales (premières lettres) uniques des noms
locals {
  initials = toset([for n in var.names : substr(n, 0, 1)])
  grouped  = {
    for i in local.initials :
    i => [for n in var.names : n if substr(n, 0, 1) == i]
  }
}

# Filtre la liste pour ne garder que les nombres pairs
# Calcule le carré de chaque nombre pair
locals {
  evens   = [for n in var.nums : n if n % 2 == 0]
  squares = [for n in local.evens : n * n]
}

# # Crée une nouvelle liste unique (sans doublons) et triée par ordre alphabétique
locals {
  unique_sorted = sort(distinct(var.magne))
  csv           = join(",", local.unique_sorted)
}



locals {
  # Transformer chaque élément string en un objet avec name et score (number)
  # l’exercice apprend à manipuler et fiabiliser des données dans Terraform 
  score_pairs = [
    for s in var.raw_scores : {
      name  = split(":", s)[0]
      score = tonumber(split(":", s)[1])
    }
  ]

  # Construire la map nom => score
  # l’exercice apprend à manipuler et fiabiliser des données dans Terraform
scores_map = { for p in local.score_pairs : p.name => p.score }

  # Calculer la moyenne des scores
  # l’exercice apprend à manipuler et fiabiliser des données dans Terraform
  average = length(local.score_pairs) == 0 ? 0 : sum([for p in local.score_pairs : p.score]) / length(local.score_pairs)
} 



locals {
  lengths_unique1 = toset([for w in var.words : length(w)])
}
locals {
  average2 = length(local.score_pairs) == 0 ? 0 : sum([for p in local.score_pairs : p.score]) / length(local.score_pairs)
}

# Construit un map des adresses email à partir des noms d'utilisateur et du domaine
locals {
  emails = [for u in var.usernames : "${u}@${var.domain}"]
}

# labels_upper stocke la version en majuscules de chaque label
locals {
  labels_upper = toset([for s in var.labels : upper(s)])
}

locals {
  # Ensemble des longueurs uniques des mots
  # cette organisation rend votre code plus lisible, facile à maintenir et à comprendre pour une équipe
  # Extraire toutes les longueurs uniques des mots afin de définir les catégories de l’histogramme
  lengths_unique = toset([for w in var.words : length(w)])

  # Histogramme map: longueur (clé) => nombre de mots ayant cette longueur (valeur)
  histogram = {
    for L in local.lengths_unique :
    tostring(L) => length([for w in var.words : w if length(w) == L])
  }
}

locals {
  # Reconstruit la liste en passant uniquement "Hyatt" en majuscule, les autres restent inchangés
  # C’est utile pour cibler spécifiquement une valeur dans une liste et lui appliquer un traitement particulier, garantissant que l’information importante
  hotels_upper = [for h in var.hotels : h == "Hyatt" ? upper(h) : h]
}


locals {
  # On utilise la fonction join pour combiner tous les éléments de la liste en une seule chaîne,
  # chaque activité étant séparée par " → " afin de recréer la séquence demandée
  # Ce procédé est idéal pour transformer une liste en texte lisible ou en titre dynamique dans mes outputs Terraform
  activities_string = join(" → ", var.activities)
}

locals {
  # Utilise la fonction strrev pour inverser la chaîne "Hilton".
  # Cette fonction parcourt la chaîne caractère par caractère en partant de la fin vers le début,
  # ce qui transforme "Hilton" en "notliH"
  # Cela permet d’obtenir `"notliH"` en sortie, ce qui montre comment transformer dynamiquement les valeurs de vos variables sous forme de chaîne
  hilton_reversed = strrev(var.hotels[0])
}
