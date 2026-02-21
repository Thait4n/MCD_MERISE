# MCD MERISE – Agence de Voyage

## Présentation du projet

Ce projet réalise la modélisation complète du système d'information d'une **agence de voyage** organisant des circuits touristiques dans plusieurs pays, en appliquant la méthode **MERISE** (Méthode d'Étude et de Réalisation Informatique pour les Systèmes d'Entreprise).

Il s'inscrit dans le cadre du cours **R3.10 – Management des Systèmes d'Information et des Projets** du BUT Informatique.

---

## Contexte métier

L'agence propose des **circuits touristiques** passant par plusieurs villes. Chaque nuit d'un circuit est associée à un hôtel dans une ville donnée. Les clients peuvent effectuer des réservations pour des voyages planifiés, avec un système d'acompte et de solde.

### Règles de gestion principales

| # | Règle |
|---|-------|
| RG01 | On conserve tous les clients, même sans réservation. |
| RG02 | Une ville possède un seul hôtel. |
| RG03 | Les villes ont des noms distincts. |
| RG04 | Un voyage est encadré par un seul accompagnateur. |
| RG05 | Chaque nuit d'un circuit se passe dans un hôtel. |
| RG06 | Un circuit contient au minimum 2 villes. |
| RG07 | Une réservation nécessite un acompte puis un solde. |
| RG08 | Après une date D1 : annulation de la réservation si le solde n'est pas payé. |
| RG09 | Après une date D2 : annulation du circuit si les réservations sont insuffisantes. |
| RG10 | À une même date, un circuit ne part pas deux fois de la même ville. |

---

## Méthode AGILE appliquée

Le projet est découpé en **sprints** selon une approche Agile itérative :

| Sprint | Livrable | Statut |
|--------|----------|--------|
| Sprint 1 | Dictionnaire des données | ✅ Terminé |
| Sprint 2 | Épuration et normalisation | ✅ Terminé |
| Sprint 3 | Contraintes et dépendances fonctionnelles | ✅ Terminé |
| Sprint 4 | Modèle Conceptuel de Données (MCD) | ✅ Terminé |
| Sprint 5 | Schéma SQL (MLD → MPD) | ✅ Terminé |

---

## Organisation des tâches

```
MCD_MERISE/
├── README.md                          # Présentation du projet
├── docs/
│   ├── 01_dictionnaire_donnees.md     # Dictionnaire des données
│   ├── 02_epuration.md                # Épuration et normalisation
│   ├── 03_contraintes_dependances.md  # Contraintes et dépendances fonctionnelles
│   └── 04_MCD.md                      # Modèle Conceptuel de Données
└── sql/
    └── schema.sql                     # Script SQL de création de la base
```

---

## Livrables

- [`docs/01_dictionnaire_donnees.md`](docs/01_dictionnaire_donnees.md) – Liste structurée de toutes les entités et leurs attributs
- [`docs/02_epuration.md`](docs/02_epuration.md) – Processus d'épuration et suppression des redondances
- [`docs/03_contraintes_dependances.md`](docs/03_contraintes_dependances.md) – Contraintes d'intégrité et dépendances fonctionnelles
- [`docs/04_MCD.md`](docs/04_MCD.md) – Modèle Conceptuel de Données complet
- [`sql/schema.sql`](sql/schema.sql) – Script SQL prêt à l'emploi (MySQL / PostgreSQL)

---

## Auteur

Projet réalisé dans le cadre du BUT Informatique – R3.10.
