
/*
 * Pour la syntaxe SQLite, cf. https://www.sqlitetutorial.net/
 */


/* Personnes: on observe qu'il y a une septeantaine de personnes 
 * mentionnées plusieurs fois. Peut-être plus avec des 
 * variantes ortographiques ?
 */

-- regrouper et compter les différents métiers
WITH tw1 AS ( 
SELECT Nom || ' ' || Prenom AS person, "Ville origine" origine
FROM Mention m)
SELECT person, count(*) as number, GROUP_CONCAT(origine, ',') AS lieu
FROM tw1
GROUP BY person
ORDER BY number DESC;



/* Métiers : il y a du nettoyage à faire, on le fera dans la table des métiers 
 * mais en partie directement ?
 * On le voit dans les accents, genres, etc.
 * 
 * Noter qu'il faut distinguer le métier (maçon) et le statut (apprenti, maître):
 * ce sont deux concepts et classes donc différentes
 */

-- regrouper et compter les métiers
SELECT TRIM(Metier), COUNT(*) AS number 
FROM Mention m 
GROUP BY TRIM(Metier)
ORDER BY number DESC;


/* Origine: pays
 * noter qu'il y a des espaces de trop dans les données
 * qui disparaissent avec TRIM
 */

-- regrouper et compter les pays
SELECT TRIM("Pays origine") origine_pays, COUNT(*) AS number 
FROM Mention m 
GROUP BY TRIM("Pays origine" )
ORDER BY number DESC;


/* Origine: ville
 * noter qu'il y a des espaces de trop dans les données
 * qui disparaissent avec TRIM
 * Il a aussi des questions d'accents  et orthographe à corriger
 */

-- regrouper et compter les villes
SELECT TRIM("Ville origine") origine_ville, COUNT(*) AS number 
FROM Mention m 
GROUP BY TRIM("Ville origine" )
ORDER BY number DESC;


/* Domicile: 
 * 
 * Il a aussi des questions d'accents  et orthographe à corriger
 */

-- regrouper et compter les villes
SELECT TRIM(Domicile) domicile, COUNT(*) AS number 
FROM Mention m 
GROUP BY TRIM(Domicile )
ORDER BY number DESC;

SELECT 
	CASE 
		WHEN INSTR(Domicile, '/') > 0 THEN TRIM(SUBSTR(Domicile, 1, INSTR(Domicile, '/')-1)) 
		ELSE ''	
	END partie_a,
	CASE 
		WHEN INSTR(Domicile, '/') > 0 THEN TRIM(SUBSTR(Domicile, INSTR(Domicile, '/')+1)) 
		ELSE TRIM(Domicile)	
	END partie_b,
INSTR(Domicile, '/') val, TRIM(Domicile) domicile
FROM Mention m 
ORDER BY val DESC ;

/*
 * On voit qu'il y a des données à corriger
 * Pour extraire le tout il me faudra passer par du Python,
 * ce sera vite fait mais avant le nettoyage est indispensable
 * où possible
 */

WITH tw1 AS (
	SELECT 
		CASE 
			WHEN INSTR(Domicile, '/') > 0 THEN TRIM(SUBSTR(Domicile, 1, INSTR(Domicile, '/')-1)) 
			ELSE ''	
		END partie_a,
		CASE 
			WHEN INSTR(Domicile, '/') > 0 THEN TRIM(SUBSTR(Domicile, INSTR(Domicile, '/')+1)) 
			ELSE TRIM(Domicile)	
		END partie_b,
	INSTR(Domicile, '/') val, TRIM(Domicile) domicile
	FROM Mention m 
)
SELECT partie_a, partie_b, count(*) as nombre, MIN(domicile) AS original
FROM tw1
GROUP BY partie_b, partie_a
ORDER BY nombre DESC;