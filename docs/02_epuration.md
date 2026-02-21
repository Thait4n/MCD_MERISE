# 02 – Épuration et normalisation des données

## Objectif

L'épuration consiste à analyser le dictionnaire des données brut afin d'en supprimer les redondances, d'harmoniser les noms, de regrouper les attributs dans les bonnes entités et de garantir la cohérence du modèle avant de construire le MCD.

---

## 1. Suppressions des redondances

### 1.1 Attributs redondants identifiés et supprimés

| Attribut redondant | Entité initiale | Décision | Justification |
|--------------------|-----------------|----------|---------------|
| `pays_ville` (texte dans VILLE) | VILLE | Remplacé par FK → PAYS | Séparation en entité PAYS pour éviter la répétition du nom du pays dans chaque ville |
| `nom_hotel_dans_etape` | ETAPE | Supprimé | L'hôtel est déjà référencé par `id_hotel` (FK → HOTEL) |
| `ville_hotel` (texte dans HOTEL) | HOTEL | Remplacé par FK → VILLE | La ville est déjà une entité autonome |
| `prix_total_reservation` | RESERVATION | Supprimé | Valeur calculée = `montant_acompte + montant_solde`, non stockée |
| `nom_circuit_dans_voyage` | VOYAGE | Supprimé | Accessible via FK → CIRCUIT |
| `adresse_client_dans_reservation` | RESERVATION | Supprimé | Déjà présente dans CLIENT |

### 1.2 Entités fusionnées ou séparées

| Décision | Entités concernées | Justification |
|----------|--------------------|---------------|
| **Séparation** de `ville_depart` et `ville_arrivee` | ETAPE, VOYAGE | Une ville de départ (dans VOYAGE) et une ville d'étape (dans ETAPE) répondent à des rôles distincts. Ce sont toutes deux des références à VILLE, mais via des associations sémantiquement différentes. |
| **Séparation** PAYS de VILLE | VILLE | Normalisation : le pays est une entité propre, évitant la répétition de `nom_pays` dans chaque tuple de VILLE. |
| **Maintien** de ETAPE comme entité associative | CIRCUIT / VILLE / HOTEL | ETAPE modélise la relation ternaire "le circuit C passe la nuit N dans la ville V à l'hôtel H", avec son propre attribut `numero_nuit`. |

---

## 2. Harmonisation des noms

### Règles d'harmonisation appliquées

- **Minuscule avec underscore** pour tous les noms d'attributs (snake_case).
- **Préfixe `id_`** pour tous les identifiants techniques (clés primaires et étrangères).
- **Préfixe de l'entité** pour les attributs portant le même nom dans plusieurs entités (ex. `nom_client` vs `nom_accompagnateur`), ramené simplement à `nom` dans chaque entité pour clarté.
- **Types homogènes** : tous les identifiants sont `INT`, tous les montants sont `DECIMAL(10,2)`, toutes les dates sont `DATE`.

### Table de correspondance avant / après épuration

| Nom initial (brut) | Entité | Nom retenu (normalisé) | Remarque |
|--------------------|--------|------------------------|----------|
| `NuméroClient` | CLIENT | `id_client` | Normalisation snake_case + préfixe id_ |
| `NomCompletClient` | CLIENT | `nom` + `prenom` | Décomposition atomique |
| `TelClient` | CLIENT | `telephone` | Harmonisation |
| `PaysVoyage` (texte) | VOYAGE | supprimé | Porté par VILLE → PAYS |
| `DateDépart` | VOYAGE | `date_depart` | Suppression accent, snake_case |
| `NbJoursCircuit` | CIRCUIT | `duree_nuits` | Renommage sémantique (nuits = étapes) |
| `PrixCircuit` | CIRCUIT | `prix_base` | Clarification : tarif de base |
| `NuitNuméro` | ETAPE | `numero_nuit` | Normalisation |
| `CatégorieHotel` | HOTEL | `categorie` | Suppression accent |
| `StatutRéservation` | RESERVATION | `statut` | Valeurs ENUM définies |

---

## 3. Gestion des clés

### 3.1 Clés primaires

Toutes les entités disposent d'une clé primaire technique de type `INT AUTO_INCREMENT`, préfixée par `id_`. Ce choix garantit :
- L'indépendance vis-à-vis des données métier (un nom de ville peut changer, son identifiant technique reste stable).
- La simplicité des jointures.

### 3.2 Contraintes d'unicité métier

Certains attributs ou combinaisons d'attributs doivent être uniques au-delà de la clé primaire :

| Entité | Attribut(s) UNIQUE | Règle de gestion |
|--------|-------------------|-----------------|
| VILLE | `nom_ville` | RG03 : noms de villes distincts |
| HOTEL | `id_ville` | RG02 : une ville = un seul hôtel |
| PAYS | `nom_pays`, `code_iso` | Unicité naturelle du pays |
| VOYAGE | `(id_circuit, id_ville_depart, date_depart)` | RG10 : pas deux départs identiques le même jour |
| CLIENT | `email` | Identification unique par e-mail |
| ACCOMPAGNATEUR | `email` | Identification unique par e-mail |

### 3.3 Clés étrangères

| Entité | FK | Référence | ON DELETE |
|--------|-----|-----------|-----------|
| VILLE | `id_pays` | PAYS(id_pays) | RESTRICT |
| HOTEL | `id_ville` | VILLE(id_ville) | RESTRICT |
| ETAPE | `id_circuit` | CIRCUIT(id_circuit) | CASCADE |
| ETAPE | `id_ville` | VILLE(id_ville) | RESTRICT |
| ETAPE | `id_hotel` | HOTEL(id_hotel) | RESTRICT |
| VOYAGE | `id_circuit` | CIRCUIT(id_circuit) | RESTRICT |
| VOYAGE | `id_accompagnateur` | ACCOMPAGNATEUR(id_accompagnateur) | RESTRICT |
| VOYAGE | `id_ville_depart` | VILLE(id_ville) | RESTRICT |
| RESERVATION | `id_client` | CLIENT(id_client) | RESTRICT |
| RESERVATION | `id_voyage` | VOYAGE(id_voyage) | RESTRICT |

---

## 4. Traçabilité des modifications

| # | Modification | Motif | Impact |
|---|-------------|-------|--------|
| M01 | Création de l'entité PAYS | Éviter la répétition du nom du pays dans VILLE | Ajout d'une entité + FK dans VILLE |
| M02 | Suppression de `prix_total` dans RESERVATION | Attribut calculé, non stocké | Aucun impact structurel |
| M03 | Séparation `nom`/`prenom` du client | Atomicité des données (1NF) | Deux attributs distincts dans CLIENT |
| M04 | Création de ETAPE comme entité propre | Modélisation de la relation ternaire CIRCUIT-VILLE-HOTEL avec attribut | Entité associative avec `numero_nuit` |
| M05 | Renommage `NbJours` → `duree_nuits` | Sémantique plus précise (nuit = étape dans un hôtel) | Renommage d'attribut dans CIRCUIT |
| M06 | Contrainte UNIQUE sur `id_ville` dans HOTEL | Règle RG02 : une ville = un seul hôtel | Contrainte SQL `UNIQUE` |
| M07 | Contrainte UNIQUE composite dans VOYAGE | Règle RG10 | Contrainte SQL `UNIQUE(id_circuit, id_ville_depart, date_depart)` |
| M08 | Typage `statut` en ENUM dans RESERVATION et VOYAGE | Contrôle des valeurs autorisées | Contrainte de domaine |
| M09 | Ajout de `date_limite_solde` (D1) dans RESERVATION | Règle RG08 : annulation si solde impayé après D1 | Attribut DATE dans RESERVATION |
| M10 | Ajout de `date_limite_annulation` (D2) dans VOYAGE | Règle RG09 : annulation du circuit si réservations insuffisantes | Attribut DATE dans VOYAGE |
