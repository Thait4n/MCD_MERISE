# 04 – Modèle Conceptuel de Données (MCD)

## Présentation

Le Modèle Conceptuel de Données (MCD) représente la structure statique du système d'information de l'agence de voyage. Il décrit les **entités**, leurs **attributs**, les **associations** entre entités et les **cardinalités** qui gouvernent ces associations.

---

## 1. Entités et attributs

### CLIENT
```
CLIENT
├── #id_client     INT
├── nom            VARCHAR(100)
├── prenom         VARCHAR(100)
├── adresse        VARCHAR(255)
├── telephone      VARCHAR(20)
└── email          VARCHAR(150) [UNIQUE]
```

### PAYS
```
PAYS
├── #id_pays       INT
├── nom_pays       VARCHAR(150) [UNIQUE]
└── code_iso       CHAR(2) [UNIQUE]
```

### VILLE
```
VILLE
├── #id_ville      INT
└── nom_ville      VARCHAR(150) [UNIQUE]
```

### HOTEL
```
HOTEL
├── #id_hotel      INT
├── nom_hotel      VARCHAR(200)
├── categorie      TINYINT
└── adresse        VARCHAR(255)
```

### CIRCUIT
```
CIRCUIT
├── #id_circuit    INT
├── nom_circuit    VARCHAR(200)
├── description    TEXT
├── duree_nuits    INT [≥ 2]
└── prix_base      DECIMAL(10,2) [> 0]
```

### ACCOMPAGNATEUR
```
ACCOMPAGNATEUR
├── #id_accompagnateur   INT
├── nom                  VARCHAR(100)
├── prenom               VARCHAR(100)
├── telephone            VARCHAR(20)
├── email                VARCHAR(150) [UNIQUE]
└── langues              VARCHAR(255)
```

### VOYAGE
```
VOYAGE
├── #id_voyage                INT
├── date_depart               DATE
├── date_limite_annulation    DATE
├── nb_min_reservations       INT [> 0]
└── statut                    ENUM
```

### RESERVATION
```
RESERVATION
├── #id_reservation      INT
├── date_reservation     DATE
├── montant_acompte      DECIMAL(10,2) [≥ 0]
├── date_limite_solde    DATE
├── montant_solde        DECIMAL(10,2) [≥ 0]
└── statut               ENUM
```

### ETAPE
```
ETAPE
├── #id_etape       INT
└── numero_nuit     INT [≥ 1]
```

---

## 2. Associations et cardinalités

### 2.1 APPARTIENT (VILLE – PAYS)

```
VILLE (1,1) ─────── APPARTIENT ─────── (1,N) PAYS
```

- Une ville appartient à **exactement un** pays.
- Un pays contient **au moins une** ville.

---

### 2.2 SITUE_DANS (HOTEL – VILLE)

```
HOTEL (1,1) ─────── SITUE_DANS ─────── (0,1) VILLE
```

- Un hôtel est situé dans **exactement une** ville.
- Une ville peut avoir **au plus un** hôtel (**RG02**).

> La cardinalité `(0,1)` côté VILLE traduit qu'une ville peut ne pas avoir d'hôtel dans la base (si elle n'est pas encore utilisée comme étape), mais qu'elle ne peut en avoir **qu'un seul**.

---

### 2.3 COMPREND / ETAPE (CIRCUIT – VILLE – HOTEL)

```
CIRCUIT (1,N) ─── ETAPE ─── (1,N) VILLE
                     │
                  numero_nuit
                     │
                  (1,1) HOTEL
```

ETAPE est une **entité associative ternaire** entre CIRCUIT, VILLE et HOTEL :

- Un circuit est composé de **1 à N étapes**.
- Une ville peut figurer dans **0 à N circuits** (mais une seule fois par circuit).
- Un hôtel accueille **0 à N étapes**.
- Une étape correspond à **exactement un** hôtel (**RG05**).

Cardinalités détaillées :

| Côté | Cardinalité | Lecture |
|------|-------------|---------|
| CIRCUIT → ETAPE | (1,N) | Un circuit a au moins 2 étapes (**RG06**) |
| ETAPE → CIRCUIT | (1,1) | Une étape appartient à un seul circuit |
| VILLE → ETAPE | (0,N) | Une ville peut ne pas figurer dans un circuit |
| ETAPE → VILLE | (1,1) | Une étape se passe dans une seule ville |
| HOTEL → ETAPE | (0,N) | Un hôtel peut ne pas être utilisé |
| ETAPE → HOTEL | (1,1) | Une étape utilise exactement un hôtel (**RG05**) |

---

### 2.4 BASE_SUR (VOYAGE – CIRCUIT)

```
VOYAGE (1,N) ─────── BASE_SUR ─────── (1,1) CIRCUIT
```

- Un voyage est basé sur **exactement un** circuit.
- Un circuit peut donner lieu à **1 ou plusieurs** voyages.

---

### 2.5 ENCADRE (VOYAGE – ACCOMPAGNATEUR)

```
VOYAGE (0,N) ─────── ENCADRE ─────── (1,1) ACCOMPAGNATEUR
```

- Un voyage est encadré par **exactement un** accompagnateur (**RG04**).
- Un accompagnateur peut encadrer **0 à N** voyages.

---

### 2.6 PART_DE (VOYAGE – VILLE)

```
VOYAGE (0,N) ─────── PART_DE ─────── (1,1) VILLE
```

- Un voyage part d'**exactement une** ville de départ.
- Une ville peut être le point de départ de **0 à N** voyages.

> **Contrainte RG10** : la combinaison (CIRCUIT, VILLE de départ, DATE) est unique : un circuit ne peut pas partir deux fois le même jour de la même ville.

---

### 2.7 RESERVE (CLIENT – VOYAGE via RESERVATION)

```
CLIENT (0,N) ─── RESERVE ─── (1,N) VOYAGE
                     │
               (attributs de RESERVATION)
               date_reservation
               montant_acompte
               date_limite_solde (D1)
               montant_solde
               statut
```

RESERVATION est une **entité associative** entre CLIENT et VOYAGE :

| Côté | Cardinalité | Lecture |
|------|-------------|---------|
| CLIENT → RESERVATION | (0,N) | Un client peut avoir **0 à N** réservations (**RG01** : conservé sans réservation) |
| RESERVATION → CLIENT | (1,1) | Une réservation concerne **exactement un** client |
| VOYAGE → RESERVATION | (0,N) | Un voyage peut recevoir **0 à N** réservations |
| RESERVATION → VOYAGE | (1,1) | Une réservation porte sur **exactement un** voyage |

---

## 3. Récapitulatif des associations

| Association | Entités liées | Type | Attributs portés |
|-------------|---------------|------|-----------------|
| APPARTIENT | VILLE – PAYS | Binaire | — |
| SITUE_DANS | HOTEL – VILLE | Binaire | — |
| ETAPE | CIRCUIT – VILLE – HOTEL | Ternaire (entité assoc.) | `numero_nuit` |
| BASE_SUR | VOYAGE – CIRCUIT | Binaire | — |
| ENCADRE | VOYAGE – ACCOMPAGNATEUR | Binaire | — |
| PART_DE | VOYAGE – VILLE | Binaire | — |
| RESERVE | CLIENT – VOYAGE | Binaire (entité assoc.) | `date_reservation`, `montant_acompte`, `date_limite_solde`, `montant_solde`, `statut` |

---

## 4. Contraintes métier rappelées dans le MCD

| Code | Contrainte | Portée dans le MCD |
|------|------------|-------------------|
| RG01 | Clients conservés sans réservation | Cardinalité `(0,N)` côté CLIENT dans RESERVE |
| RG02 | Une ville = un seul hôtel | Cardinalité `(0,1)` côté VILLE dans SITUE_DANS |
| RG03 | Noms de villes distincts | Contrainte `UNIQUE` sur `nom_ville` |
| RG04 | Un accompagnateur par voyage | Cardinalité `(1,1)` côté ACCOMPAGNATEUR dans ENCADRE |
| RG05 | Chaque nuit = un hôtel | Cardinalité `(1,1)` côté HOTEL dans ETAPE |
| RG06 | Circuit ≥ 2 villes | Contrainte `CHECK (duree_nuits ≥ 2)` + cardinalité (1,N) |
| RG07 | Acompte + solde pour réservation | Attributs `montant_acompte` et `montant_solde` dans RESERVATION |
| RG08 | Annulation si solde non payé après D1 | Attribut `date_limite_solde` + `statut` dans RESERVATION |
| RG09 | Annulation circuit si réservations insuffisantes après D2 | Attributs `date_limite_annulation` + `nb_min_reservations` + `statut` dans VOYAGE |
| RG10 | Pas deux départs identiques le même jour | Contrainte `UNIQUE(id_circuit, id_ville_depart, date_depart)` dans VOYAGE |

---

## 5. Modèle Logique Relationnel (MLD) dérivé

Le MLD est la traduction directe du MCD en tables relationnelles :

```
PAYS (id_pays, nom_pays, code_iso)

VILLE (id_ville, nom_ville, #id_pays)

HOTEL (id_hotel, nom_hotel, categorie, adresse, #id_ville)
  UNIQUE (id_ville)

ACCOMPAGNATEUR (id_accompagnateur, nom, prenom, telephone, email, langues)

CIRCUIT (id_circuit, nom_circuit, description, duree_nuits, prix_base)

ETAPE (id_etape, numero_nuit, #id_circuit, #id_ville, #id_hotel)
  UNIQUE (id_circuit, numero_nuit)
  UNIQUE (id_circuit, id_ville)

VOYAGE (id_voyage, date_depart, date_limite_annulation, nb_min_reservations,
        statut, #id_circuit, #id_accompagnateur, #id_ville_depart)
  UNIQUE (id_circuit, id_ville_depart, date_depart)

CLIENT (id_client, nom, prenom, adresse, telephone, email)

RESERVATION (id_reservation, date_reservation, montant_acompte,
             date_limite_solde, montant_solde, statut,
             #id_client, #id_voyage)
```
