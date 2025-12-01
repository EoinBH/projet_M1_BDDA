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

SELECT ajouter_emprunt('The War of the Worlds', 'DUPONT', 30);
SELECT ajouter_emprunt('The War of the Worlds', 'CONSTANT', 30);
SELECT ajouter_emprunt('The War of the Worlds', 'MARTIN', 30);

SELECT * FROM emprunt;
SELECT * FROM livre;

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