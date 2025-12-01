-- Partie 1: Fonctions de base 

--Fonction qui insère un nouvel auteur dans la table auteur :
CREATE OR REPLACE FUNCTION ajouter_auteur(p_nom TEXT, p_pays TEXT) 
RETURNS VOID AS $$
BEGIN
	INSERT INTO auteur(nom, pays) VALUES (p_nom, p_pays);
END;
$$ LANGUAGE plpgsql;

--Tests :
SELECT ajouter_auteur('HUGO', 'France');
SELECT ajouter_auteur(NULL, 'France');
SELECT ajouter_auteur('JOYCE', NULL);
SELECT ajouter_auteur('WERBER', 'France');

--Pour voir les données :
SELECT * FROM auteur;
--Supprimer les données si besoin :
DELETE FROM auteur;
ALTER SEQUENCE auteur_id_auteur_seq RESTART WITH 1;

--Fonction qui ajoute un livre et vérifie que le nombre d'exemplaires est positif :
CREATE OR REPLACE FUNCTION ajouter_livre(titre TEXT, id_auteur INT, id_categorie INT, annee INT, nb_exemplaires INT) 
RETURNS VOID AS $$
BEGIN
		IF nb_exemplaires > 0 THEN
			 INSERT INTO livre(titre, id_auteur, id_categorie, annee, nb_exemplaires) VALUES (titre, id_auteur, id_categorie, annee, nb_exemplaires);
		END IF;
END;
$$ LANGUAGE plpgsql;

SELECT ajouter_livre('Les Fourmis', 4, 2, 1991, 10); 
SELECT ajouter_livre('Le Dernier Jour d''un Condamnné', 7, 1, 1991, 10);
SELECT ajouter_livre('Exemple', 6, 2, 1991, 10);


--Proposition d'Eoin :
--Fonction qui ajoute un livre et vérifie que le nombre d'exemplaires est positif :
CREATE OR REPLACE FUNCTION ajouter_livre_texte(titre TEXT, nom_auteur TEXT, nom_categorie TEXT, annee INT, nb_exemplaires INT) RETURNS VOID AS $$
	DECLARE
		id_aut INT;
		id_cat INT;
	BEGIN
		SELECT id_auteur FROM auteur WHERE nom = nom_auteur INTO id_aut;
		SELECT id_categorie FROM categorie WHERE nom = nom_categorie INTO id_cat;
		INSERT INTO livre(titre, id_auteur, id_categorie, annee, nb_exemplaires) VALUES (titre, id_aut, id_cat, annee, nb_exemplaires);
	END
$$ LANGUAGE plpgsql;

--Pour voir les données :
SELECT * FROM  livre;
--Supprimer les données si besoin :
DELETE FROM livre;
ALTER SEQUENCE livre_id_livre_seq RESTART WITH 1;

--Fonction qui insère une nouvelle catégorie dans la table catégorie :
CREATE OR REPLACE FUNCTION ajouter_categorie(p_nom TEXT) RETURNS VOID AS $$
	BEGIN
		INSERT INTO categorie(nom) VALUES(p_nom);
	END
$$ LANGUAGE plpgsql;


--Test categorie:
SELECT ajouter_categorie('Biographie'); 
SELECT ajouter_categorie('Drame');
SELECT ajouter_categorie('Roman');
SELECT ajouter_categorie('Science');
SELECT ajouter_categorie('Essai');

--Pour voir les données :
SELECT * FROM categorie;

--Fonction qui retourne le nombre total de livres appartenant à une catégorie donnée.
CREATE OR REPLACE FUNCTION nb_livres_categorie(p_id_categorie INT) 
RETURNS INT AS $$
    DECLARE
		    nom_livres INT;
    BEGIN
		    SELECT COUNT (*) INTO nom_livres FROM livre WHERE id_categorie = p_id_categorie;
		RETURN nom_livres;
	END
$$ LANGUAGE plpgsql;

SELECT nb_livres_categorie(3);

-- Partie 2: Fonctions avec boucle
CREATE OR REPLACE FUNCTION maj_annee_livres() RETURNS VOID AS $$
	DECLARE
		liv RECORD;
	BEGIN
		FOR liv IN SELECT * FROM livre WHERE annee < 2000
		LOOP
			RAISE NOTICE 'Livre : %, Année : %', liv.titre, liv.annee;
		END LOOP;
	END;
$$ LANGUAGE plpgsql;

SELECT maj_annee_livres();

-- Partie 3: Fonctions avec curseur

CREATE OR REPLACE FUNCTION liste_livres_auteur(nom_auteur TEXT) RETURNS SETOF tLivre AS $$
DECLARE
	id_aut INT;
    cursLivres CURSOR FOR SELECT id_auteur, titre FROM livre;
	tNuplet tLivre;
BEGIN
    SELECT id_auteur FROM auteur WHERE nom = nom_auteur INTO id_aut;
	OPEN cursLivres;
	FETCH cursLivres INTO tNuplet;
	WHILE FOUND LOOP
		IF tNuplet.id_aut = id_aut THEN
			RETURN NEXT tNuplet;
		END IF;
		FETCH cursLivres INTO tNuplet;
	END LOOP;
	CLOSE cursLivres;
    RETURN;
END
$$ LANGUAGE plpgsql;

--Création du type enregistrement tNuplet(nom TEXT, titre TEXT) :
CREATE TYPE tLivre AS (
	id_aut INT,
	titre TEXT
);

SELECT liste_livres_auteur('HUGO');
SELECT liste_livres_auteur('KING');
SELECT liste_livres_auteur('JOYCE');


-- Partie 4: Fonctions avec SQL dynamique

CREATE OR REPLACE FUNCTION compter_elements(table_name TEXT) RETURNS INT AS $$
DECLARE
    nombreEnreg INT;
BEGIN
    EXECUTE 'SELECT COUNT (*) FROM ' || table_name INTO nombreEnreg;
    -- EXECUTE format('SELECT COUNT (*) FROM %I' || table_name INTO nombreEnreg;)
    RETURN nombreEnreg;
END
$$ LANGUAGE plpgsql;

SELECT compter_elements('auteur');
SELECT compter_elements('categorie');

-- Partie 5: Trigger guidé

CREATE TRIGGER verif_disponibilite
BEFORE INSERT ON emprunt
FOR EACH ROW
EXECUTE PROCEDURE verif_dispo();

DROP TRIGGER verif_disponibilite ON emprunt;

CREATE OR REPLACE FUNCTION verif_dispo() RETURNS TRIGGER AS $$
DECLARE
	nombreExem INT;
BEGIN
	SELECT nb_exemplaires FROM livre WHERE id_livre = NEW.id_livre INTO nombreExem;
	IF nombreExem <= 0 THEN
        RAISE EXCEPTION 'Il n''y a plus d''exemplaires !';
    END IF;
	--Diminuer le nombre d'exemplaires :
	UPDATE livre SET nb_exemplaires = nb_exemplaires - 1 WHERE id_livre = NEW.id_livre;
	RETURN NEW;
END
$$ LANGUAGE plpgsql;

-- Plus de fonctions de base qui seront nécessaires :

CREATE OR REPLACE FUNCTION ajouter_emprunteur(p_nom TEXT) RETURNS VOID AS $$
BEGIN
	INSERT INTO emprunteur(nom) VALUES (p_nom);
END;
$$ LANGUAGE plpgsql;

-- Cette fonction prend un entier 'duree' qui indique le nombre de jours du prêt
CREATE OR REPLACE FUNCTION ajouter_emprunt(p_titre_livre TEXT, p_nom_emprunteur TEXT, duree INT) RETURNS VOID AS $$
DECLARE
	id_liv INT;
	id_emp INT;
	date_fin DATE = CURRENT_DATE + duree;
BEGIN
	SELECT id_livre FROM livre WHERE titre = p_titre_livre INTO id_liv;
	SELECT id_emprunteur FROM emprunteur WHERE nom = p_nom_emprunteur INTO id_emp;
	INSERT INTO emprunt(id_livre, id_emprunteur, date_retour) VALUES (id_liv, id_emp, date_fin);
END
$$ LANGUAGE plpgsql;

DROP FUNCTION ajouter_emprunt;