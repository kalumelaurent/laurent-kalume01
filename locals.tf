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
  hilton_reversed = strrev(var.hotels2[0])
}

locals {
  # Pour chaque hôtel, on extrait une sous-chaîne des 2 premiers caractères.
  # La fonction substr prend 3 arguments : la chaîne, la position de départ (0-index), et la longueur
  # Cette méthode est efficace pour créer des listes transformées en conservant la structure d’origine
  hotels_abbr = [for h in var.hotels3 : substr(h, 0, 2)]
}

locals {
  # Calculer la longueur de chaque chaîne dans la liste
  # De telles opérations sont utiles pour validations, métriques, ou conditions basées sur des propriétés agrégées
  lengths = [for food in var.foods1 : length(food)]

  # Additionner toutes les longueurs pour obtenir le total des caractères
  total_characters = sum(local.lengths)
}

locals {
  # Étape 1 : Extraire la première lettre de chaque mot
  # Ici on utilise une boucle "for" pour créer une nouvelle liste
  #c’est un exercice pour apprendre à transformer des données dans Terraform, de manière simple et pratique
#créer l’abréviation à partir des premières lettres de chaque élément
  premieres_lettres = [for activity in var.activities2 : substr(activity, 0, 1)]
  # substr(activity, 0, 1) prend le premier caractère de chaque mot

  # Étape 2 : Combiner toutes les premières lettres en une seule chaîne
  # join("", ...) concatène tous les éléments de la liste sans espace
  abbreviation = join("", local.premieres_lettres)
}


# C’est un petit exercice pour apprendre à manipuler des listes et utiliser des fonctions comme length, max et index.
locals {
  longueurs = [
    length(var.nouriture[0]),
    length(var.nouriture[1]),
    length(var.nouriture[2]),
    length(var.nouriture[3]),
    length(var.nouriture[4])
  ]

  max_longueur = max(
    local.longueurs[0],
    local.longueurs[1],
    local.longueurs[2],
    local.longueurs[3],
    local.longueurs[4]
  )

  index_max = index(local.longueurs, local.max_longueur)
  nom_plus_long = var.nouriture[local.index_max]
}


locals {
  # Étape 1 : Extraire la première lettre de chaque mot
  #c’est un exercice pour apprendre à transformer des données dans Terraform, de manière simple et pratique
#créer l’abréviation à partir des premières lettres de chaque élément en majuscule 
  premieress_lettress = [for activity in var.activities01 : substr(activity, 0, 1)]
  # substr(activity, 0, 1) prend le premier caractère de chaque mot

  # Étape 2 : Mettre chaque lettre en majuscule
  premieres_lettres_upper = [for letter in local.premieres_lettres : upper(letter)]
  # upper() transforme chaque lettre en majuscule

  # Étape 3 : Combiner toutes les lettres pour former l'abréviation
  abbreviations = join("", local.premieres_lettres_upper)
  # join("", ...) concatène toutes les lettres sans espace
}


