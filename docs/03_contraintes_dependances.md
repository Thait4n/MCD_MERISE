# 03 – Contraintes d'intégrité et dépendances fonctionnelles

## 1. Contraintes d'intégrité

### 1.1 Contraintes d'entité (clés primaires)

Chaque entité possède une clé primaire technique garantissant l'unicité de chaque occurrence.

| Entité | Clé primaire | Type |
|--------|-------------|------|
| CLIENT | `id_client` | INT AUTO_INCREMENT |
| RESERVATION | `id_reservation` | INT AUTO_INCREMENT |
| VOYAGE | `id_voyage` | INT AUTO_INCREMENT |
| CIRCUIT | `id_circuit` | INT AUTO_INCREMENT |
| ETAPE | `id_etape` | INT AUTO_INCREMENT |
| VILLE | `id_ville` | INT AUTO_INCREMENT |
| HOTEL | `id_hotel` | INT AUTO_INCREMENT |
| PAYS | `id_pays` | INT AUTO_INCREMENT |
| ACCOMPAGNATEUR | `id_accompagnateur` | INT AUTO_INCREMENT |

### 1.2 Contraintes de référence (intégrité référentielle)

| Entité source | Attribut FK | Entité cible | Règle |
|---------------|-------------|--------------|-------|
| VILLE | `id_pays` | PAYS | Une ville appartient à un pays existant |
| HOTEL | `id_ville` | VILLE | Un hôtel est situé dans une ville existante |
| ETAPE | `id_circuit` | CIRCUIT | L'étape appartient à un circuit existant |
| ETAPE | `id_ville` | VILLE | La ville de l'étape doit exister |
| ETAPE | `id_hotel` | HOTEL | L'hôtel de l'étape doit exister |
| VOYAGE | `id_circuit` | CIRCUIT | Le voyage est basé sur un circuit existant |
| VOYAGE | `id_accompagnateur` | ACCOMPAGNATEUR | L'accompagnateur doit être référencé |
| VOYAGE | `id_ville_depart` | VILLE | La ville de départ doit exister |
| RESERVATION | `id_client` | CLIENT | Le client doit exister (RG01) |
| RESERVATION | `id_voyage` | VOYAGE | Le voyage doit exister |

### 1.3 Contraintes d'attribut (domaine et valeurs)

| Entité | Attribut | Contrainte | Justification |
|--------|----------|------------|---------------|
| CLIENT | `email` | UNIQUE | Un e-mail identifie un seul client |
| VILLE | `nom_ville` | NOT NULL, UNIQUE | RG03 : noms distincts |
| HOTEL | `id_ville` | UNIQUE | RG02 : une ville = un hôtel maximum |
| HOTEL | `categorie` | CHECK (1 ≤ categorie ≤ 5) | Étoiles de 1 à 5 |
| CIRCUIT | `duree_nuits` | CHECK (duree_nuits ≥ 2) | RG06 : au moins 2 nuits (2 villes) |
| CIRCUIT | `prix_base` | CHECK (prix_base > 0) | Un prix doit être positif |
| ETAPE | `numero_nuit` | CHECK (numero_nuit ≥ 1) | La numérotation commence à 1 |
| RESERVATION | `montant_acompte` | CHECK (montant_acompte ≥ 0) | Montant non négatif |
| RESERVATION | `montant_solde` | CHECK (montant_solde ≥ 0), DEFAULT 0 | Montant non négatif |
| RESERVATION | `statut` | ENUM('en_attente', 'confirmee', 'annulee') | Valeurs autorisées |
| VOYAGE | `nb_min_reservations` | CHECK (nb_min_reservations > 0) | Minimum 1 réservation requise |
| VOYAGE | `statut` | ENUM('planifie', 'confirme', 'annule', 'termine') | Valeurs autorisées |
| ACCOMPAGNATEUR | `email` | UNIQUE | Identification unique |

### 1.4 Contraintes de relation (unicité composite)

| Entité | Contrainte UNIQUE composite | Règle de gestion |
|--------|----------------------------|-----------------|
| VOYAGE | `(id_circuit, id_ville_depart, date_depart)` | RG10 : un circuit ne peut pas partir deux fois le même jour de la même ville |
| ETAPE | `(id_circuit, numero_nuit)` | Un numéro de nuit est unique dans un circuit donné |
| ETAPE | `(id_circuit, id_ville)` | Une ville n'apparaît qu'une fois dans un même circuit |

---

## 2. Dépendances fonctionnelles

Les dépendances fonctionnelles (DF) expriment les relations logiques entre attributs au sein du système. Notation : `A → B` signifie « A détermine fonctionnellement B ».

### 2.1 Dépendances fonctionnelles élémentaires

#### Entité CLIENT
```
id_client → nom, prenom, adresse, telephone, email
email → id_client
```

#### Entité PAYS
```
id_pays → nom_pays, code_iso
nom_pays → id_pays
code_iso → id_pays
```

#### Entité VILLE
```
id_ville → nom_ville, id_pays
nom_ville → id_ville
```

#### Entité HOTEL
```
id_hotel → nom_hotel, categorie, adresse, id_ville
id_ville → id_hotel  (unicité : une ville = un hôtel)
```

#### Entité ACCOMPAGNATEUR
```
id_accompagnateur → nom, prenom, telephone, email, langues
email → id_accompagnateur
```

#### Entité CIRCUIT
```
id_circuit → nom_circuit, description, duree_nuits, prix_base
```

#### Entité ETAPE
```
id_etape → id_circuit, id_ville, id_hotel, numero_nuit
(id_circuit, numero_nuit) → id_ville, id_hotel
(id_circuit, id_ville) → numero_nuit, id_hotel
id_ville → id_hotel  (via RG02 : une ville = un hôtel)
```

> **Remarque** : la DF `id_ville → id_hotel` est une dépendance transitoire dans ETAPE. Elle passe par la contrainte métier RG02. Cela confirme que `id_hotel` dans ETAPE est redondant vis-à-vis de `id_ville`, mais conservé pour la lisibilité et la performance des requêtes.

#### Entité VOYAGE
```
id_voyage → id_circuit, id_accompagnateur, id_ville_depart, date_depart,
            date_limite_annulation, nb_min_reservations, statut
(id_circuit, id_ville_depart, date_depart) → id_voyage  (unicité RG10)
```

#### Entité RESERVATION
```
id_reservation → id_client, id_voyage, date_reservation,
                 montant_acompte, date_limite_solde, montant_solde, statut
```

---

### 2.2 Graphe des dépendances fonctionnelles (description textuelle)

Le graphe ci-dessous décrit les chaînes de dépendances entre les entités :

```
PAYS
  id_pays ──────────────────────────────► nom_pays
                                        ► code_iso

VILLE
  id_ville ─────────────────────────────► nom_ville
            └──► id_pays ───────────────► (PAYS)

HOTEL
  id_hotel ─────────────────────────────► nom_hotel, categorie, adresse
            └──► id_ville ──────────────► (VILLE)

CIRCUIT
  id_circuit ───────────────────────────► nom_circuit, description,
                                          duree_nuits, prix_base

ETAPE
  (id_circuit, numero_nuit) ────────────► id_ville, id_hotel
  id_ville ─────────────────────────────► id_hotel  [via RG02]

ACCOMPAGNATEUR
  id_accompagnateur ────────────────────► nom, prenom, telephone, email, langues

VOYAGE
  id_voyage ────────────────────────────► date_depart, statut,
                                          date_limite_annulation,
                                          nb_min_reservations
              └──► id_circuit ──────────► (CIRCUIT)
              └──► id_accompagnateur ───► (ACCOMPAGNATEUR)
              └──► id_ville_depart ─────► (VILLE)

CLIENT
  id_client ────────────────────────────► nom, prenom, adresse, telephone, email

RESERVATION
  id_reservation ──────────────────────► date_reservation, montant_acompte,
                                         date_limite_solde, montant_solde, statut
               └──► id_client ──────────► (CLIENT)
               └──► id_voyage ──────────► (VOYAGE)
```

---

### 2.3 Vérification de la 3NF (Troisième Forme Normale)

Le modèle respecte la **Troisième Forme Normale (3NF)** :

| Critère | Vérification |
|---------|-------------|
| **1NF** : Attributs atomiques | ✅ `nom`/`prenom` séparés, pas de listes dans les attributs |
| **2NF** : Pas de DF partielle sur la PK | ✅ Toutes les clés primaires sont simples (pas de PK composite dans les entités principales) |
| **3NF** : Pas de DF transitive | ⚠️ `id_ville → id_hotel` dans ETAPE est une dépendance transitive via RG02 ; conservée volontairement pour des raisons de performance et conformité métier |

> La dépendance transitive `id_ville → id_hotel` dans ETAPE est une **redondance contrôlée** : elle découle directement de la règle de gestion RG02 (une ville = un hôtel). Elle pourrait être supprimée (ETAPE ne contiendrait que `id_ville`, le reste dérivant de HOTEL), mais elle est maintenue pour des raisons de clarté et de conformité au domaine métier.
