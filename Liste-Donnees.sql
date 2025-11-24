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

--Catégories :
--selon https://bookvillage.app/vendre-ses-livres/type-de-livre-quels-sont-les-principaux-genres-litteraires/
/*
1. Le genre narratif
– Nouvelle
– Conte
– Mythe
– Légende
– Biographie
– Autobiographie
– Chronique
– Apologue
– Journal
– Roman :
Les genres romanesques
– Roman sentimentaux
– Roman de mœurs
– Roman d’apprentissage
– Roman d’anticipation ou de science-fiction
– Roman d’aventures
– Roman philosophique
– Roman picaresque
– Roman policier
– Roman historique
– Roman d’horreur

2. Le genre poétique
- Chanson
– Ballade
– Calligramme
– Chant Royal
– Élégie
– Épigramme
– Épopée
– Fatrasie
– Ode

3. Le genre théâtral
– Tragédie
– Comédie
– Farce
– Moralité
– Drame
– Proverbe

4. Le genre épistolaire

5. Le genre argumentatif
- L’essai
– La fable
– Le fabliau
– Le pamphlet
– Le sermon
*/


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