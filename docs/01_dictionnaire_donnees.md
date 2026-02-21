# 01 – Dictionnaire des données

## Présentation

Le dictionnaire des données recense l'ensemble des informations manipulées par le système d'information de l'agence de voyage. Il constitue le fondement de la modélisation MERISE et assure la cohérence entre les différents acteurs du projet.

---

## Entités identifiées

| # | Entité | Description |
|---|--------|-------------|
| 1 | CLIENT | Personne physique ayant ou souhaitant effectuer une réservation. |
| 2 | RESERVATION | Acte par lequel un client réserve une place pour un voyage. |
| 3 | VOYAGE | Instance d'un circuit à une date donnée, avec une ville de départ. |
| 4 | CIRCUIT | Itinéraire touristique défini, passant par plusieurs villes. |
| 5 | ETAPE | Nuit d'un circuit dans une ville et un hôtel précis. |
| 6 | VILLE | Localité géographique, identifiée par un nom unique. |
| 7 | HOTEL | Établissement d'hébergement, lié à une unique ville. |
| 8 | PAYS | Pays dans lequel se trouvent des villes du circuit. |
| 9 | ACCOMPAGNATEUR | Guide encadrant un voyage donné. |

---

## Détail des entités et attributs

### 1. CLIENT

| Attribut | Type | Longueur | Clé | Contrainte | Description |
|----------|------|----------|-----|------------|-------------|
| id_client | INT | — | PK | NOT NULL, AUTO_INCREMENT | Identifiant unique du client |
| nom | VARCHAR | 100 | — | NOT NULL | Nom de famille |
| prenom | VARCHAR | 100 | — | NOT NULL | Prénom |
| adresse | VARCHAR | 255 | — | — | Adresse postale complète |
| telephone | VARCHAR | 20 | — | — | Numéro de téléphone |
| email | VARCHAR | 150 | — | UNIQUE | Adresse e-mail de contact |

---

### 2. RESERVATION

| Attribut | Type | Longueur | Clé | Contrainte | Description |
|----------|------|----------|-----|------------|-------------|
| id_reservation | INT | — | PK | NOT NULL, AUTO_INCREMENT | Identifiant unique de la réservation |
| id_client | INT | — | FK → CLIENT | NOT NULL | Client concerné |
| id_voyage | INT | — | FK → VOYAGE | NOT NULL | Voyage réservé |
| date_reservation | DATE | — | — | NOT NULL | Date de création de la réservation |
| montant_acompte | DECIMAL | (10,2) | — | NOT NULL, ≥ 0 | Montant de l'acompte versé |
| date_limite_solde | DATE | — | — | NOT NULL | Date D1 : limite de paiement du solde |
| montant_solde | DECIMAL | (10,2) | — | ≥ 0, DEFAULT 0 | Montant du solde versé |
| statut | ENUM | — | — | NOT NULL | État : 'en_attente', 'confirmee', 'annulee' |

---

### 3. VOYAGE

| Attribut | Type | Longueur | Clé | Contrainte | Description |
|----------|------|----------|-----|------------|-------------|
| id_voyage | INT | — | PK | NOT NULL, AUTO_INCREMENT | Identifiant unique du voyage |
| id_circuit | INT | — | FK → CIRCUIT | NOT NULL | Circuit associé |
| id_accompagnateur | INT | — | FK → ACCOMPAGNATEUR | NOT NULL | Accompagnateur assigné |
| id_ville_depart | INT | — | FK → VILLE | NOT NULL | Ville de départ du voyage |
| date_depart | DATE | — | — | NOT NULL | Date de départ |
| date_limite_annulation | DATE | — | — | NOT NULL | Date D2 : annulation si réservations insuffisantes |
| nb_min_reservations | INT | — | — | NOT NULL, > 0 | Nombre minimum de réservations requis |
| statut | ENUM | — | — | NOT NULL | État : 'planifie', 'confirme', 'annule', 'termine' |

> **Contrainte RG10** : la combinaison `(id_circuit, id_ville_depart, date_depart)` est UNIQUE.

---

### 4. CIRCUIT

| Attribut | Type | Longueur | Clé | Contrainte | Description |
|----------|------|----------|-----|------------|-------------|
| id_circuit | INT | — | PK | NOT NULL, AUTO_INCREMENT | Identifiant unique du circuit |
| nom_circuit | VARCHAR | 200 | — | NOT NULL | Intitulé commercial du circuit |
| description | TEXT | — | — | — | Présentation détaillée du circuit |
| duree_nuits | INT | — | — | NOT NULL, ≥ 2 | Nombre de nuits (= nombre de villes minimum) |
| prix_base | DECIMAL | (10,2) | — | NOT NULL, > 0 | Tarif de base par personne |

---

### 5. ETAPE

| Attribut | Type | Longueur | Clé | Contrainte | Description |
|----------|------|----------|-----|------------|-------------|
| id_etape | INT | — | PK | NOT NULL, AUTO_INCREMENT | Identifiant unique de l'étape |
| id_circuit | INT | — | FK → CIRCUIT | NOT NULL | Circuit auquel appartient l'étape |
| id_ville | INT | — | FK → VILLE | NOT NULL | Ville de l'étape |
| id_hotel | INT | — | FK → HOTEL | NOT NULL | Hôtel où se passe la nuit |
| numero_nuit | INT | — | — | NOT NULL, ≥ 1 | Numéro d'ordre de la nuit dans le circuit |

> **Contrainte RG05** : chaque nuit d'un circuit correspond exactement à une étape avec un hôtel.  
> **Contrainte RG06** : un circuit doit comporter au minimum 2 étapes (villes distinctes).

---

### 6. VILLE

| Attribut | Type | Longueur | Clé | Contrainte | Description |
|----------|------|----------|-----|------------|-------------|
| id_ville | INT | — | PK | NOT NULL, AUTO_INCREMENT | Identifiant unique de la ville |
| nom_ville | VARCHAR | 150 | — | NOT NULL, UNIQUE | Nom de la ville (unique, RG03) |
| id_pays | INT | — | FK → PAYS | NOT NULL | Pays auquel appartient la ville |

---

### 7. HOTEL

| Attribut | Type | Longueur | Clé | Contrainte | Description |
|----------|------|----------|-----|------------|-------------|
| id_hotel | INT | — | PK | NOT NULL, AUTO_INCREMENT | Identifiant unique de l'hôtel |
| nom_hotel | VARCHAR | 200 | — | NOT NULL | Nom de l'établissement |
| categorie | TINYINT | — | — | CHECK (1–5) | Nombre d'étoiles |
| adresse | VARCHAR | 255 | — | — | Adresse de l'hôtel |
| id_ville | INT | — | FK → VILLE | NOT NULL, UNIQUE | Ville de l'hôtel (RG02 : un hôtel par ville) |

> **Contrainte RG02** : `id_ville` est UNIQUE, garantissant qu'une ville n'a qu'un seul hôtel.

---

### 8. PAYS

| Attribut | Type | Longueur | Clé | Contrainte | Description |
|----------|------|----------|-----|------------|-------------|
| id_pays | INT | — | PK | NOT NULL, AUTO_INCREMENT | Identifiant unique du pays |
| nom_pays | VARCHAR | 150 | — | NOT NULL, UNIQUE | Nom du pays |
| code_iso | CHAR | 2 | — | UNIQUE | Code ISO 3166-1 alpha-2 |

---

### 9. ACCOMPAGNATEUR

| Attribut | Type | Longueur | Clé | Contrainte | Description |
|----------|------|----------|-----|------------|-------------|
| id_accompagnateur | INT | — | PK | NOT NULL, AUTO_INCREMENT | Identifiant unique de l'accompagnateur |
| nom | VARCHAR | 100 | — | NOT NULL | Nom de famille |
| prenom | VARCHAR | 100 | — | NOT NULL | Prénom |
| telephone | VARCHAR | 20 | — | — | Numéro de téléphone |
| email | VARCHAR | 150 | — | UNIQUE | Adresse e-mail professionnelle |
| langues | VARCHAR | 255 | — | — | Langues maîtrisées (ex. : FR, EN, ES) |

---

## Récapitulatif des types utilisés

| Type SQL | Usage |
|----------|-------|
| `INT` | Identifiants, compteurs entiers |
| `VARCHAR(n)` | Chaînes de caractères de longueur variable |
| `CHAR(n)` | Codes fixes (code ISO pays) |
| `TEXT` | Textes longs sans longueur maximale |
| `DECIMAL(10,2)` | Montants financiers (précision 2 décimales) |
| `DATE` | Dates (sans heure) |
| `ENUM` | Valeurs d'état prédéfinies |
| `TINYINT` | Petits entiers (catégorie hôtel 1–5) |
