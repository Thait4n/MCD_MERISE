-- =============================================================================
-- Agence de Voyage – Schéma SQL (MPD)
-- Basé sur le MCD MERISE – R3.10 Management des SI et des Projets
-- Compatible MySQL 8+ / PostgreSQL 13+
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Table : PAYS
-- Un pays dans lequel se trouvent des villes du circuit.
-- -----------------------------------------------------------------------------
CREATE TABLE pays (
    id_pays   INT          NOT NULL AUTO_INCREMENT,
    nom_pays  VARCHAR(150) NOT NULL,
    code_iso  CHAR(2)      NOT NULL,
    CONSTRAINT pk_pays       PRIMARY KEY (id_pays),
    CONSTRAINT uq_pays_nom   UNIQUE (nom_pays),
    CONSTRAINT uq_pays_iso   UNIQUE (code_iso)
);

-- -----------------------------------------------------------------------------
-- Table : VILLE
-- Localité géographique identifiée par un nom unique (RG03).
-- -----------------------------------------------------------------------------
CREATE TABLE ville (
    id_ville  INT          NOT NULL AUTO_INCREMENT,
    nom_ville VARCHAR(150) NOT NULL,
    id_pays   INT          NOT NULL,
    CONSTRAINT pk_ville       PRIMARY KEY (id_ville),
    CONSTRAINT uq_ville_nom   UNIQUE (nom_ville),
    CONSTRAINT fk_ville_pays  FOREIGN KEY (id_pays)
        REFERENCES pays (id_pays)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- -----------------------------------------------------------------------------
-- Table : HOTEL
-- Établissement d'hébergement. Une ville possède au plus un hôtel (RG02).
-- -----------------------------------------------------------------------------
CREATE TABLE hotel (
    id_hotel  INT          NOT NULL AUTO_INCREMENT,
    nom_hotel VARCHAR(200) NOT NULL,
    categorie TINYINT,
    adresse   VARCHAR(255),
    id_ville  INT          NOT NULL,
    CONSTRAINT pk_hotel          PRIMARY KEY (id_hotel),
    CONSTRAINT uq_hotel_ville    UNIQUE (id_ville),
    CONSTRAINT fk_hotel_ville    FOREIGN KEY (id_ville)
        REFERENCES ville (id_ville)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT ck_hotel_categorie CHECK (categorie BETWEEN 1 AND 5)
);

-- -----------------------------------------------------------------------------
-- Table : ACCOMPAGNATEUR
-- Guide encadrant un voyage.
-- -----------------------------------------------------------------------------
CREATE TABLE accompagnateur (
    id_accompagnateur INT          NOT NULL AUTO_INCREMENT,
    nom               VARCHAR(100) NOT NULL,
    prenom            VARCHAR(100) NOT NULL,
    telephone         VARCHAR(20),
    email             VARCHAR(150),
    langues           VARCHAR(255),
    CONSTRAINT pk_accompagnateur     PRIMARY KEY (id_accompagnateur),
    CONSTRAINT uq_accompagnateur_email UNIQUE (email)
);

-- -----------------------------------------------------------------------------
-- Table : CIRCUIT
-- Itinéraire touristique passant par au moins 2 villes (RG06).
-- -----------------------------------------------------------------------------
CREATE TABLE circuit (
    id_circuit  INT           NOT NULL AUTO_INCREMENT,
    nom_circuit VARCHAR(200)  NOT NULL,
    description TEXT,
    duree_nuits INT           NOT NULL,
    prix_base   DECIMAL(10,2) NOT NULL,
    CONSTRAINT pk_circuit         PRIMARY KEY (id_circuit),
    CONSTRAINT ck_circuit_duree   CHECK (duree_nuits >= 2),
    CONSTRAINT ck_circuit_prix    CHECK (prix_base > 0)
);

-- -----------------------------------------------------------------------------
-- Table : ETAPE
-- Nuit d'un circuit dans une ville et un hôtel précis (RG05).
-- Une ville n'apparaît qu'une fois dans un même circuit.
-- -----------------------------------------------------------------------------
CREATE TABLE etape (
    id_etape    INT NOT NULL AUTO_INCREMENT,
    numero_nuit INT NOT NULL,
    id_circuit  INT NOT NULL,
    id_ville    INT NOT NULL,
    id_hotel    INT NOT NULL,
    CONSTRAINT pk_etape               PRIMARY KEY (id_etape),
    CONSTRAINT uq_etape_nuit          UNIQUE (id_circuit, numero_nuit),
    CONSTRAINT uq_etape_ville_circuit UNIQUE (id_circuit, id_ville),
    CONSTRAINT ck_etape_nuit          CHECK (numero_nuit >= 1),
    CONSTRAINT fk_etape_circuit       FOREIGN KEY (id_circuit)
        REFERENCES circuit (id_circuit)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_etape_ville         FOREIGN KEY (id_ville)
        REFERENCES ville (id_ville)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_etape_hotel         FOREIGN KEY (id_hotel)
        REFERENCES hotel (id_hotel)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- -----------------------------------------------------------------------------
-- Table : VOYAGE
-- Instance d'un circuit à une date donnée, avec une ville de départ.
-- Un circuit ne part pas deux fois le même jour de la même ville (RG10).
-- -----------------------------------------------------------------------------
CREATE TABLE voyage (
    id_voyage              INT     NOT NULL AUTO_INCREMENT,
    date_depart            DATE    NOT NULL,
    date_limite_annulation DATE    NOT NULL,
    nb_min_reservations    INT     NOT NULL,
    statut                 ENUM('planifie', 'confirme', 'annule', 'termine') NOT NULL DEFAULT 'planifie',
    id_circuit             INT     NOT NULL,
    id_accompagnateur      INT     NOT NULL,
    id_ville_depart        INT     NOT NULL,
    CONSTRAINT pk_voyage              PRIMARY KEY (id_voyage),
    CONSTRAINT uq_voyage_depart       UNIQUE (id_circuit, id_ville_depart, date_depart),
    CONSTRAINT ck_voyage_nb_min       CHECK (nb_min_reservations > 0),
    CONSTRAINT fk_voyage_circuit      FOREIGN KEY (id_circuit)
        REFERENCES circuit (id_circuit)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_voyage_accompagnateur FOREIGN KEY (id_accompagnateur)
        REFERENCES accompagnateur (id_accompagnateur)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_voyage_ville_depart FOREIGN KEY (id_ville_depart)
        REFERENCES ville (id_ville)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- -----------------------------------------------------------------------------
-- Table : CLIENT
-- Personne physique cliente de l'agence (conservée même sans réservation, RG01).
-- -----------------------------------------------------------------------------
CREATE TABLE client (
    id_client INT          NOT NULL AUTO_INCREMENT,
    nom       VARCHAR(100) NOT NULL,
    prenom    VARCHAR(100) NOT NULL,
    adresse   VARCHAR(255),
    telephone VARCHAR(20),
    email     VARCHAR(150),
    CONSTRAINT pk_client       PRIMARY KEY (id_client),
    CONSTRAINT uq_client_email UNIQUE (email)
);

-- -----------------------------------------------------------------------------
-- Table : RESERVATION
-- Acte de réservation d'un client pour un voyage, avec acompte et solde (RG07).
-- L'annulation intervient après D1 si le solde n'est pas versé (RG08).
-- -----------------------------------------------------------------------------
CREATE TABLE reservation (
    id_reservation     INT           NOT NULL AUTO_INCREMENT,
    date_reservation   DATE          NOT NULL,
    montant_acompte    DECIMAL(10,2) NOT NULL DEFAULT 0,
    date_limite_solde  DATE          NOT NULL,
    montant_solde      DECIMAL(10,2) NOT NULL DEFAULT 0,
    statut             ENUM('en_attente', 'confirmee', 'annulee') NOT NULL DEFAULT 'en_attente',
    id_client          INT           NOT NULL,
    id_voyage          INT           NOT NULL,
    CONSTRAINT pk_reservation         PRIMARY KEY (id_reservation),
    CONSTRAINT ck_reservation_acompte CHECK (montant_acompte >= 0),
    CONSTRAINT ck_reservation_solde   CHECK (montant_solde >= 0),
    CONSTRAINT fk_reservation_client  FOREIGN KEY (id_client)
        REFERENCES client (id_client)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_reservation_voyage  FOREIGN KEY (id_voyage)
        REFERENCES voyage (id_voyage)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);
