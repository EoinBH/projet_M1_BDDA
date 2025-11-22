--Fonction qui insère un nouvel auteur dans la table auteur :
CREATE OR REPLACE FUNCTION ajouter_auteur(nom TEXT, pays TEXT) RETURNS VOID AS $$
	BEGIN
		IF nom IS NOT NULL THEN
			INSERT INTO auteur(nom, pays) VALUES (nom, pays);
		END IF;
	END
$$ LANGUAGE plpgsql;

--Tests :
SELECT ajouter_auteur('DUPONT', 'France');
SELECT ajouter_auteur(NULL, 'France');
SELECT * FROM auteur;