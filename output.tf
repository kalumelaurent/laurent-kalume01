
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
# Sortie affichant la map des noms groupés par initiale
output "grouped_by_initial" { value = local.grouped }

# Affiche la liste des nombres pairs
output "evens"   { value = local.evens }
# Affiche la liste des carrés des nombres pairs
output "squares" { value = local.squares }

# Output affichant la liste triée et dédoublonnée
output "unique_sorted" {
  value = local.unique_sorted
}
# Output affichant la chaîne CSV créée à partir de la liste
output "csv" {
  value = local.csv
}

# Sortie affichant la map des scores
# l’exercice apprend à manipuler et fiabiliser des données dans Terraform
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

# Output affichant l'histogramme des longueurs
# cette organisation rend votre code plus lisible, facile à maintenir et à comprendre pour une équipe
output "length_histogram" {
  value = local.histogram
}

# Affiche la nouvelle liste avec seulement "Hyatt" en majuscule
# C’est utile pour cibler spécifiquement une valeur dans une liste et lui appliquer un traitement particulier, garantissant que l’information importante
output "hotels_upper" {
  value = local.hotels_upper
}

# Output affichant la chaîne formatée avec les flèches
# Ce procédé est idéal pour transformer une liste en texte lisible ou en titre dynamique dans mes outputs Terraform
output "formatted_activities" {
  value = local.activities_string
}

# Utilise la fonction replace pour remplacer "bur" par "cheese" dans "burger".
# Le résultat sera "cheeseger"
# Cette technique est utile pour modifier dynamiquement des valeurs ou adapter des noms/textes dans vos outputs ou ressources
output "replace_burger" {
  value = replace("burger", "bur", "cheese")
  # Ici, la fonction remplace la première sous-chaîne trouvée ("bur") par "cheese",
  # ce qui transforme "burger" en "cheeseger".
}

# Utilise la fonction replace avec une expression régulière pour remplacer toutes les voyelles par "*"
# Le motif /[aeiou]/ indique une voyelle (a, e, i, o ou u)
output "marriott_vowels_masked" {
  value = replace("Marriott", "/[aeiou]/", "*")
  # Cette ligne recherche chaque voyelle dans la chaîne "Marriott"
  # et la remplace par "*". Résultat : "M*rr**tt"
}


# Output affichant le résultat de l'inversion de la chaîne "Hilton"
# Cela permet d’obtenir `"notliH"` en sortie, ce qui montre comment transformer dynamiquement les valeurs de vos variables sous forme de chaîne
output "reversed_hilton" {
  value = local.hilton_reversed
}

# Output affichant la liste des abréviations des noms d'hôtels
# Cette méthode est efficace pour créer des listes transformées en conservant la structure d’origine
output "hotels_abbreviated" {
  value = local.hotels_abbr
}


# Output affichant le nombre total de caractères dans toutes les chaînes de la liste
# De telles opérations sont utiles pour validations, métriques, ou conditions basées sur des propriétés agrégées
output "total_characters_in_foods" {
  value = local.total_characters
}

# Afficher la liste des premières lettres
output "premieres_lettres" {
  value = local.premieres_lettres
}

# Afficher l'abréviation finale
#c’est un exercice pour apprendre à transformer des données dans Terraform, de manière simple et pratique
#créer l’abréviation à partir des premières lettres de chaque élément
output "abbreviation" {
  value = local.abbreviation
}


#C’est un petit exercice pour apprendre à manipuler des listes et utiliser des fonctions comme length, max et index.
output "index_plus_long_nouriture" {
  value = local.index_max
}

output "nom_plus_long_nourriture" {
  value = local.nom_plus_long
}

#c’est un exercice pour apprendre à transformer des données dans Terraform, de manière simple et pratique
#créer l’abréviation à partir des premières lettres de chaque élément en majuscule 
# Afficher la liste des premières lettres en majuscule
output "premieres_lettres_upper" {
  value = local.premieres_lettres_upper
}

#c’est un exercice pour apprendre à transformer des données dans Terraform, de manière simple et pratique
#créer l’abréviation à partir des premières lettres de chaque élément en majuscule 
# Afficher l'abréviation finale
output "abbreviations" {
  value = local.abbreviation
}


# Output de l'emplacement du fichier généré
/*output "file_path" {
  value = local_file.top_5_list.filename
  description = "Chemin vers le fichier contenant les Top 5 listes"
}
/*
