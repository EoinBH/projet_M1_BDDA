-- =====================================================
-- Script de création de la base "Bibliothèque+"
-- =====================================================

-- Table des auteurs
CREATE TABLE auteur (
    id_auteur SERIAL PRIMARY KEY,
    nom TEXT NOT NULL,
    pays TEXT
);

-- Table des catégories de livres
CREATE TABLE categorie (
    id_categorie SERIAL PRIMARY KEY,
    nom TEXT NOT NULL
);

-- Table des livres
CREATE TABLE livre (
    id_livre SERIAL PRIMARY KEY,
    titre TEXT NOT NULL,
    id_auteur INT REFERENCES auteur(id_auteur),
    id_categorie INT REFERENCES categorie(id_categorie),
    annee INT,
    nb_exemplaires INT CHECK (nb_exemplaires >= 0)
);

-- Table des emprunteurs
CREATE TABLE emprunteur (
    id_emprunteur SERIAL PRIMARY KEY,
    nom TEXT NOT NULL,
    date_inscription DATE DEFAULT CURRENT_DATE
);

-- Table des emprunts
CREATE TABLE emprunt (
    id_emprunt SERIAL PRIMARY KEY,
    id_livre INT REFERENCES livre(id_livre),
    id_emprunteur INT REFERENCES emprunteur(id_emprunteur),
    date_emprunt DATE DEFAULT CURRENT_DATE,
    date_retour DATE
);

-- Table des réservations
CREATE TABLE reservation (
    id_reservation SERIAL PRIMARY KEY,
    id_livre INT REFERENCES livre(id_livre),
    id_emprunteur INT REFERENCES emprunteur(id_emprunteur),
    date_reservation DATE DEFAULT CURRENT_DATE,
    statut TEXT DEFAULT 'en attente' 
        CHECK (statut IN ('en attente', 'validee', 'annulee'))
);

-- Quelques index utiles
CREATE INDEX idx_livre_auteur ON livre(id_auteur);
CREATE INDEX idx_livre_categorie ON livre(id_categorie);
CREATE INDEX idx_emprunt_livre ON emprunt(id_livre);
CREATE INDEX idx_reservation_statut ON reservation(statut);