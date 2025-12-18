-- Partie Ouverte :

-- Fonction (statistique) qui affiche tous les livres (y compris tous les exemplaires et tous les livres qui sont empruntés) :
CREATE OR REPLACE FUNCTION afficher_livres_totals() RETURNS SETOF tDispo AS $$
DECLARE
	livres_dispo INT;
	livres_empruntes INT;
	resultat tDispo;
BEGIN
	SELECT SUM (nb_exemplaires) FROM livre INTO livres_dispo;
	SELECT COUNT (*) FROM emprunt INTO livres_empruntes;
	RAISE NOTICE 'Livres disponisbles : %, Livres empruntés : %', livres_dispo, livres_empruntes;
	resultat.dispo := livres_dispo;
    resultat.emprunte := livres_empruntes;
	RETURN NEXT resultat;
END
$$ LANGUAGE plpgsql;

DROP FUNCTION afficher_livres_totals;

--Création du type enregistrement tNuplet(dispo INT, emprunte INT) :
CREATE TYPE tDispo AS (
	dispo INT,
	emprunte INT
);

SELECT afficher_livres_totals();

SELECT * FROM livre;

SELECT * FROM emprunt;

-- Fonction pour afficher les livres les plus empruntés (par auteur / par livre) :

CREATE OR REPLACE FUNCTION livre_le_plus_emprunte() RETURNS SETOF tEmpruntes AS $$
DECLARE
	id_liv INT;
	nom_Livre TEXT;
	compte INT;
	resultat tEmpruntes;
BEGIN
	SELECT id_livre, COUNT (*) AS livres_comptes
	FROM emprunt
	GROUP BY id_livre
	ORDER BY livres_comptes DESC
	LIMIT 1
	INTO id_liv, compte;
	SELECT titre FROM livre WHERE id_livre = id_liv INTO nom_Livre;
	RAISE NOTICE 'Nom du livre le plus emprunté : %, Nombre de prêts : %', nom_Livre, compte;
	resultat.titre := nom_Livre;
    resultat.nombre_emprunte := compte;
	RETURN NEXT resultat;
END
$$ LANGUAGE plpgsql;

DROP FUNCTION livre_le_plus_emprunte;

--Création du type enregistrement tNuplet(titres TEXT, nombre_emprunte INT) :
CREATE TYPE tEmpruntes AS (
	titre TEXT,
	nombre_emprunte INT
);

SELECT livre_le_plus_emprunte();

---------------------------------
--Propositions d'Angela :
---------------------------------

--===============================================================================================================

-- Partie 2 : Fonctions et triggers ouverts

-- au moins 2 fonctions « classiques » (requêtes, insertions ou statistiques) ;

-- function total de livres dispo et pretes 
CREATE OR REPLACE FUNCTION total_livres() 
RETURNS TABLE(total_exemplaires INT, total_pretes INT, total_disponibles INT) AS $$
BEGIN
    SELECT SUM(nb_exemplaires) INTO total_exemplaires FROM livre;

    SELECT COUNT(*) INTO total_pretes FROM emprunt;
    total_disponibles := total_exemplaires - total_pretes;
  
    RETURN QUERY 
        SELECT total_exemplaires, total_pretes, total_disponibles;
END;
$$ LANGUAGE plpgsql;


-- Test (la function s'appelle de maniere differente)
SELECT * FROM total_livres()


-- plus demande 

CREATE OR REPLACE FUNCTION plus_demande() 
RETURNS VOID AS $$
DECLARE
    rec RECORD;    
BEGIN
    FOR rec IN 
        SELECT l.titre, COUNT(*) AS nb_emprunts FROM emprunt e
        JOIN livre l ON e.id_livre = l.id_livre
        GROUP BY l.titre
        ORDER BY nb_emprunts DESC
    LOOP

        RAISE NOTICE 'Nombre livre: %, Cantites Livres: %', rec.titre, rec.nb_emprunts;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT plus_demande();

-- 1 fonction utilisant un curseur implicite 

--Réservation d'un livre s'il n'est pas déjà emprunté :
CREATE OR REPLACE FUNCTION ajouter_reservation(p_livre TEXT, p_emprunteur TEXT) RETURNS TEXT AS $$
DECLARE 
    v_disponible INT;
    v_emprunts INT;
	v_id_livre INT;
	v_id_emprunteur INT;
BEGIN
	--Récupération des identifiants à partir du texte fourni en paramètres :
	SELECT id_livre FROM livre WHERE titre = p_livre INTO v_id_livre;
	SELECT id_emprunteur FROM emprunteur WHERE nom = p_emprunteur INTO v_id_emprunteur;

    SELECT nb_exemplaires INTO v_disponible FROM livre WHERE id_livre = v_id_livre;
    IF v_disponible IS NULL THEN 
        RAISE EXCEPTION 'Livre inexistant (%).', v_id_livre;
    END IF; 
    
    SELECT COUNT (*) INTO v_emprunts FROM emprunt WHERE id_livre = v_id_livre;
    IF v_emprunts >= v_disponible THEN 
        INSERT INTO reservation(id_livre, id_emprunteur)
        VALUES (v_id_livre, v_id_emprunteur);
        
        RETURN 'Reservation créée';
    ELSE 
        RAISE EXCEPTION 'Il reste des exemplaires : pas besoin de réserver.';
    END IF;
END;
$$ LANGUAGE plpgsql;
    
SELECT ajouter_reservation('It', 'MARTIN');
SELECT ajouter_reservation('It', 'CONSTANT');
SELECT ajouter_reservation('It', 'DUPONT');


-- 1 fonction utilisant un curseur explicite 

--function qui verifie les reservation et ajoute le nom du livre et le nom de qui a fait la reservation
CREATE OR REPLACE FUNCTION liste_reservation_detail()
RETURNS TABLE (id_reservation INT, titre TEXT, nom_emprunteur TEXT, date_reservation DATE, statut TEXT) AS $$
DECLARE
    rec RECORD;
    cur_reservation CURSOR FOR SELECT r.id_reservation, l.titre, e.nom, r.date_reservation, r.statut  FROM reservation r
        JOIN livre l ON r.id_livre = l.id_livre
        JOIN emprunteur e ON r.id_emprunteur = e.id_emprunteur;

BEGIN 
    OPEN cur_reservation;
    LOOP
        FETCH cur_reservation INTO rec;
        EXIT WHEN NOT FOUND;
        id_reservation := rec.id_reservation;
        titre := rec.titre;
        nom_emprunteur := rec.nom;
        date_reservation := rec.date_reservation;
        statut := rec.statut;
        RETURN NEXT;
    END LOOP; 
    CLOSE cur_reservation;  
END;
$$ LANGUAGE plpgsql;

SELECT * FROM liste_reservation_detail();


-- 1 fonction utilisant du SQL paramétré 
-- Donner le nombre total de livres d’une catégorie (parametre = nom catégorie)

CREATE OR REPLACE FUNCTION nb_livres_par_categorie(p_categorie TEXT)
RETURNS INT AS $$
DECLARE
    total INT;
BEGIN 
    SELECT SUM(nb_exemplaires) INTO total FROM livre l
    JOIN categorie c ON l.id_categorie = c.id_categorie
    WHERE c.nom = p_categorie;
    RETURN total;
END;
$$ LANGUAGE plpgsql;

SELECT nb_livres_par_categorie('Horreur')
SELECT nb_livres_par_categorie('Science-fiction')


-- 1 fonction utilisant du SQL dynamique justifié. Il est très important de penser à une requête
--qui ne pourra fonctionner correctement qu’à l’aide d’un SQL dynamique 
CREATE OR REPLACE FUNCTION total_exemplaires_filtre(p_type_filtre TEXT, p_valeur TEXT)
RETURNS INT AS $$
DECLARE
    total INT;
    sql_query TEXT;
BEGIN
    IF p_type_filtre = 'titre' THEN
        sql_query := 'SELECT SUM(nb_exemplaires) ' || 'FROM livre l '||
        'WHERE titre = ''' || p_valeur || '''';
    ELSIF p_type_filtre = 'auteur' THEN
        sql_query := 'SELECT SUM(nb_exemplaires) ' || 'FROM livre l '||
        'JOIN auteur a ON l.id_auteur = a.id_auteur '||
        'WHERE a.nom = ''' || p_valeur || '''';
    ELSIF p_type_filtre = 'categorie' THEN
        sql_query := 'SELECT SUM(nb_exemplaires) ' || 'FROM livre l '||
        'JOIN categorie c ON l.id_categorie = c.id_categorie '||
        'WHERE c.nom = ''' || p_valeur || '''';
    ELSE
        RAISE EXCEPTION
            'Type de filtre invalide: %, attendu ''titre'', ''auteur'' ou ''categorie''',
            p_type_filtre;
    END IF;
    EXECUTE sql_query INTO total;

    IF total IS NULL THEN
        total := 0;
    END IF;

    RETURN total;
END;
$$ LANGUAGE plpgsql;

SELECT total_exemplaires_filtre('titre','Les Fourmis');
SELECT total_exemplaires_filtre('auteur', 'WERBER');
SELECT total_exemplaires_filtre('categorie','Horreur');

-- au moins un trigger cohérent. Ce trigger doit être cohérent et pertinent par rapport à cette base
--de données. Justifiez et expliquez son objectif ainsi que son fonctionnement dans le rapport.

--Validation de statut reservation de en attente a validee si l'emprunteur il y a pas ce livre prete  
CREATE OR REPLACE FUNCTION verif_reservation_validee()
RETURNS TRIGGER AS $$
DECLARE
    v_nb_emprunts INT;
BEGIN
    IF OLD.statut = 'en attente' AND NEW.statut = 'validee' THEN
        SELECT COUNT(*) INTO v_nb_emprunts FROM emprunt
        WHERE id_livre = NEW.id_livre AND id_emprunteur = NEW.id_emprunteur;
        IF v_nb_emprunts >= 1 THEN
            RAISE EXCEPTION
                'Réservation refusée: l''emprunteur % a déjà ce livre emprunté %.',
                NEW.id_emprunteur, v_nb_emprunts;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_verif_reservation_validee
BEFORE UPDATE OF statut ON reservation
FOR EACH ROW
EXECUTE FUNCTION verif_reservation_validee();

UPDATE reservation
SET statut = 'validee'
WHERE id_reservation = 2;

SELECT * FROM reservation;
SELECT * FROM emprunt;

DROP TRIGGER trig_verif_reservation_validee ON reservation;