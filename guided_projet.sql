--------------------------------
-- Partie 1: Fonctions de base
--------------------------------

--Fonction qui insère un nouvel auteur dans la table auteur :
CREATE OR REPLACE FUNCTION ajouter_auteur(p_nom TEXT, p_pays TEXT) 
RETURNS VOID AS $$
BEGIN
	INSERT INTO auteur(nom, pays) VALUES (p_nom, p_pays);
END;
$$ LANGUAGE plpgsql;

--Tests ajouter_auteur :
SELECT ajouter_auteur('HUGO', 'France');
SELECT ajouter_auteur(NULL, 'France');
SELECT ajouter_auteur('JOYCE', NULL);
SELECT ajouter_auteur('WERBER', 'France');

--Pour voir les données :
SELECT * FROM auteur;
--Supprimer les données si besoin :
DELETE FROM auteur;
--Remettre à zéro le prochain identifiant affecté :
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

--Tests ajouter_livre :
SELECT ajouter_livre('Les Fourmis', 4, 2, 1991, 10); 
SELECT ajouter_livre('Le Dernier Jour d''un Condamnné', 7, 1, 1991, 10);
SELECT ajouter_livre('Exemple', 6, 2, 1991, 10);

--Fonction supplémentaire qui ajoute un livre et vérifie que le nombre d'exemplaires est positif :
--Les paramètres sont de type TEXT !
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
--Remettre à zéro le prochain identifiant affecté :
ALTER SEQUENCE livre_id_livre_seq RESTART WITH 1;

--Fonction supplémentaire qui insère une nouvelle catégorie dans la table catégorie :
CREATE OR REPLACE FUNCTION ajouter_categorie(p_nom TEXT) RETURNS VOID AS $$
	BEGIN
		INSERT INTO categorie(nom) VALUES(p_nom);
	END
$$ LANGUAGE plpgsql;

--Tests ajouter_categorie:
SELECT ajouter_categorie('Biographie'); 
SELECT ajouter_categorie('Drame');
SELECT ajouter_categorie('Roman');
SELECT ajouter_categorie('Science');
SELECT ajouter_categorie('Essai');

--Pour voir les données :
SELECT * FROM categorie;

--Fonction qui retourne le nombre total de livres appartenant à une catégorie donnée :
CREATE OR REPLACE FUNCTION nb_livres_categorie(p_id_categorie INT) 
RETURNS INT AS $$
    DECLARE
		    nom_livres INT;
    BEGIN
		    SELECT COUNT (*) INTO nom_livres FROM livre WHERE id_categorie = p_id_categorie;
		RETURN nom_livres;
	END
$$ LANGUAGE plpgsql;

--Tests nb_livres_categorie :
SELECT nb_livres_categorie(3);

--Fonction supplémentaire qui permet d'insérer un emprunteur dans la table emprunteur :
CREATE OR REPLACE FUNCTION ajouter_emprunteur(p_nom TEXT) RETURNS VOID AS $$
BEGIN
	INSERT INTO emprunteur(nom) VALUES (p_nom);
END;
$$ LANGUAGE plpgsql;

--Fonction supplémentaire qui permet d'insérer un emprunt dans la table emprunt :
--Cette fonction prend un entier 'duree' qui indique le nombre de jours du prêt
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

-----------------------------------
-- Partie 2: Fonction avec boucle
-----------------------------------

--Fonction qui affiche tous les livres publiés avant l'année 2000 :
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

--Tests maj_annee_livres :
SELECT maj_annee_livres();

-----------------------------------
-- Partie 3: Fonction avec curseur
-----------------------------------

--Fonction qui retourne tous les livres écrits par un auteur donnée :
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

--Création du type enregistrement tLivre(id_aut INT, titre TEXT) :
CREATE TYPE tLivre AS (
	id_aut INT,
	titre TEXT
);

--Tests liste_livres_auteur :
SELECT liste_livres_auteur('HUGO');
SELECT liste_livres_auteur('KING');
SELECT liste_livres_auteur('JOYCE');

-------------------------------------------
-- Partie 4: Fonctions avec SQL dynamique
-------------------------------------------

--Fonction qui compte le nombre d'enregistrements présents dans une table donnée :
CREATE OR REPLACE FUNCTION compter_elements(table_name TEXT) RETURNS INT AS $$
DECLARE
    nombreEnreg INT;
BEGIN
    EXECUTE 'SELECT COUNT (*) FROM ' || table_name INTO nombreEnreg;
    RETURN nombreEnreg;
END
$$ LANGUAGE plpgsql;

--Tests compter_elements :
SELECT compter_elements('auteur');
SELECT compter_elements('categorie');

----------------------------
-- Partie 5: Trigger guidé
----------------------------

--Création d'un trigger qui empêche l'insertion d'un emprunt si le livre n'a plus d'exemplaires :
CREATE TRIGGER verif_disponibilite
BEFORE INSERT ON emprunt
FOR EACH ROW
EXECUTE PROCEDURE verif_dispo();

--Supprimer le trigger si besoin :
DROP TRIGGER verif_disponibilite ON emprunt;

--Fonction associée au trigger verif_disponibilite :
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

--------------------------------------------------
-- Alimentation et tests de la base de données :
--------------------------------------------------

--Auteurs :
--Bernard WERBER, France
SELECT ajouter_auteur('WERBER', 'France');
--James JOYCE, Irlande
SELECT ajouter_auteur('JOYCE', 'Irlande');
--F. Scott Fitzgerald, États-Unis
SELECT ajouter_auteur('FITZGERALD', 'États-Unis');
--Charles DICKENS, Angleterre
SELECT ajouter_auteur('DICKENS', 'Angleterre');
--William SHAKESPEARE, Angleterre
SELECT ajouter_auteur('SHAKESPEARE', 'Angleterre');
--George ORWELL, Angleterre
SELECT ajouter_auteur('ORWELL', 'Angleterre');
--Victor HUGO, France
SELECT ajouter_auteur('HUGO', 'France');
--Stephen KING, États-Unis
SELECT ajouter_auteur('KING', 'États-Unis')
--R.F. KUANG, États-Unis
SELECT ajouter_auteur('KUANG', 'États-Unis')

--Livres :
--"Les Fourmis", Bernard WERBER, Science-fiction, année 1991, 10 exemplaires
SELECT ajouter_livre_texte('Les Fourmis', 'WERBER', 'Science-fiction', 1991, 10);
--"Ulysses", James JOYCE, Autobiographie, année 1920, 10 exemplaires
SELECT ajouter_livre_texte('Ulysses', 'JOYCE', 'Autobiographie', 1920, 10);
--"Le Dernier Jour d'un Condamnné", Victor HUGO, Journal, année 1829, 10 exemplaires
SELECT ajouter_livre_texte('Le Dernier Jour d''un Condamnné', 'HUGO', 'Journal', 1829, 10);
--"Les Misérables", Victor HUGO, Drame, année 1862, 10 exemplaires
SELECT ajouter_livre_texte('Les Misérables', 'HUGO', 'Drame', 1862, 10);
--"The Shining", Stephen KING, Horreur, année 1977, 10 exemplaires
SELECT ajouter_livre_texte('The Shining', 'KING', 'Horreur', 1977, 10);
--"It", Stephen KING, Horreur, année 1986, 10 exemplaires
SELECT ajouter_livre_texte('It', 'KING', 'Horreur', 1986, 10);
--"The Tragedy of Macbeth", William SHAKESPEARE, Tragédie, année 1623, 10 exemplaires
SELECT ajouter_livre_texte('The Tragedy of Macbeth', 'SHAKESPEARE', 'Tragédie', 1623, 10);
--"Babel", R.F. KUANG, 'Historique', année 2022, 10 exemplaires
SELECT ajouter_livre_texte('Babel', 'KUANG', 'Historique', 2022, 10);
--"The War of the Worlds", George ORWELL, Science-fiction, année 1898, 2 exemplaires
SELECT ajouter_livre_texte('The War of the Worlds', 'ORWELL', 'Science-fiction', 1898, 2);

SELECT * FROM livre;

--Catégories :
SELECT ajouter_categorie('Nouvelle');
SELECT ajouter_categorie('Conte');
SELECT ajouter_categorie('Mythe');
SELECT ajouter_categorie('Légende');
SELECT ajouter_categorie('Biographie');
SELECT ajouter_categorie('Autobiographie');
SELECT ajouter_categorie('Chronique');
SELECT ajouter_categorie('Apologue');
SELECT ajouter_categorie('Journal');
SELECT ajouter_categorie('Roman');

SELECT ajouter_categorie('Sentimental');
SELECT ajouter_categorie('Apprentissage');
SELECT ajouter_categorie('Anticipation');
SELECT ajouter_categorie('Science-fiction');
SELECT ajouter_categorie('Aventure');
SELECT ajouter_categorie('Philosophique');
SELECT ajouter_categorie('Picaresque');
SELECT ajouter_categorie('Policier');
SELECT ajouter_categorie('Historique');
SELECT ajouter_categorie('Horreur');

SELECT ajouter_categorie('Chanson');
SELECT ajouter_categorie('Ballade');
SELECT ajouter_categorie('Calligramme');
SELECT ajouter_categorie('Chant Royal');
SELECT ajouter_categorie('Élégie');
SELECT ajouter_categorie('Épigramme');
SELECT ajouter_categorie('Épopée');
SELECT ajouter_categorie('Fatrasie');
SELECT ajouter_categorie('Ode');

SELECT ajouter_categorie('Tragédie');
SELECT ajouter_categorie('Comédie');
SELECT ajouter_categorie('Farce');
SELECT ajouter_categorie('Moralité');
SELECT ajouter_categorie('Drame');
SELECT ajouter_categorie('Proverbe');

SELECT ajouter_categorie('Essai');
SELECT ajouter_categorie('Fable');
SELECT ajouter_categorie('Fabliau');
SELECT ajouter_categorie('Pamphlet');
SELECT ajouter_categorie('Sermon');

--Pour voir les données :
SELECT * FROM  categorie;
--Supprimer les données si besoin :
DELETE FROM categorie;
ALTER SEQUENCE categorie_id_categorie_seq RESTART WITH 1;

SELECT ajouter_emprunteur('DUPONT');
SELECT ajouter_emprunteur('CONSTANT');
SELECT ajouter_emprunteur('MARTIN');
SELECT ajouter_emprunteur('BERNARD');
SELECT ajouter_emprunteur('DURAND');
SELECT ajouter_emprunteur('ROBERT');
SELECT ajouter_emprunteur('DUBOIS');
SELECT ajouter_emprunteur('LEBLANC');
SELECT ajouter_emprunteur('ROUSSEAU');

SELECT * FROM emprunteur;
DELETE FROM emprunteur;
ALTER SEQUENCE emprunteur_id_emprunteur_seq RESTART WITH 1;

SELECT ajouter_emprunt('It', 'DUPONT', 30);
SELECT ajouter_emprunt('It', 'CONSTANT', 30);
SELECT ajouter_emprunt('It', 'MARTIN', 30);
SELECT ajouter_emprunt('The Shining', 'BERNARD', 30);
SELECT ajouter_emprunt('The Shining', 'DURAND', 30);
SELECT ajouter_emprunt('Babel', 'ROBERT', 30);

SELECT * FROM emprunt;
DELETE FROM emprunt;
SELECT * FROM livre;