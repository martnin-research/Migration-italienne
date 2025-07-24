
-- explorer les adresses
WITH tw1 AS (
SELECT nom_rue || ' ' || numero as adresse, pkuid, proprietai, geometry 
FROM adresses_qgis
)
SELECT adresse, pkuid, proprietai, geometry, '%' || adresse || '%' as adresse_like
FROM tw1;

SELECT *
FROM v_mention_lieu_domicile_periode ;


/*
 * Evolution des adresses pour une personne
 */

-- agréger afin d'inspecter l'évolution des adresses
SELECT pk_personne, personne, 
GROUP_CONCAT(date_permis_modifiee, ' | ') dates, GROUP_CONCAT(domicile, ' | ') domiciles
FROM v_mention_lieu_domicile_periode
GROUP BY pk_personne, personne;


CREATE VIEW v_evolution_adresse_personne AS
SELECT pk_personne, personne, 
GROUP_CONCAT(date_permis_modifiee, ' | ') dates, GROUP_CONCAT(domicile, ' | ') domiciles
FROM v_mention_lieu_domicile_periode
GROUP BY pk_personne, personne;


SELECT *
FROM v_evolution_adresse_personne;



/*
 * domicile -> métier !

 */

-- Filtre: domicile  like '%Promenade%'
-- Observer les propriétaires et Rue Robert !!!

WITH tw1 AS (
SELECT nom_rue || ' ' || numero as adresse, pkuid, proprietai, geometry 
FROM adresses_qgis
)
SELECT vml.*, tw1.*
FROM v_mention_lieu_domicile_periode vml 
	--LEFT 
		JOIN tw1 
		ON adresse LIKE '%' || vml.partie_b || '%'
WHERE LENGTH(partie_b) > 0
-- adresses sans numéro !
	AND partie_b != 'Robert'
	AND partie_b != 'Puits'
	AND partie_b != 'Grand Rue'
	AND partie_b != 'Ronde'
	AND partie_b != 'Hotel'
	AND partie_b != 'Dufour'
	AND partie_b != 'Droz'
	AND partie_b != 'Balance';



SELECT nom_rue, group_concat(numero) as numéros, 'LINESTRING (' || group_concat(distinct (REPLACE((REPLACE(geometry, 'POINT (', '')), ')', ''))) || ')' geometry
FROM adresses_qgis
GROUP BY trim(nom_rue) ;










-- éliminer les doublons de propriétaire,
-- seulement l'adresse compte
SELECT nom_rue || ' ' || numero as adresse, MAX(pkuid)
FROM adresses_qgis
GROUP BY nom_rue || ' ' || numero;




-- Problème Rue Robert, Rue Léopold Robert
SELECT vml.pk_personne, vml.personne, vml.date_permis_modifiee , 
CASE 
	WHEN vml.partie_b = 'Robert 5'
	THEN 'Rue Robert 5'
	ELSE vml.partie_b
END as partie_b
FROM v_mention_lieu_domicile_periode vml 
ORDER BY partie_b;










/*
 * On ne représente que les personnes résidant à des adresses correctement identifiées
 * On utilise ici des POINTS sur la carte
 */

SELECT *
FROM v_mention_domicile_metier_periode;

-- inspection
WITH tw1 AS (
SELECT nom_rue || ' ' || numero as adresse, pkuid, geometry 
FROM adresses_qgis
WHERE pkuid in (SELECT MAX(pkuid)
FROM adresses_qgis
GROUP BY nom_rue || ' ' || numero)
), tw2 AS (
SELECT vml.pk_personne, vml.person, vml.genre, vml.classement_calcule, 
CASE 
	WHEN vml.partie_b = 'Robert 5'
	THEN 'Rue Robert 5'
	ELSE vml.partie_b
END as partie_b,
periode,
vml.date_permis_modifiee 
FROM v_mention_domicile_metier_periode vml )
SELECT tw2.*, tw1.*
FROM tw2 
	--LEFT 
		JOIN tw1 
		ON adresse LIKE '%' || tw2.partie_b || '%'
WHERE LENGTH(partie_b) > 0
	AND partie_b != 'Robert'
	AND partie_b != 'Puits'
	AND partie_b != 'Ronde'
	AND partie_b != 'Parc'
	AND partie_b != 'Collège'
	AND partie_b != 'Grand Rue'
	AND partie_b != 'Grognerie'
	AND partie_b != 'Hotel'
	AND partie_b != 'Dufour'
	AND partie_b != 'Droz'
	AND partie_b != 'Balance'
ORDER BY partie_b	
;


DROP VIEW v_points_classes_metiers_periodes_effectif;
CREATE VIEW v_points_classes_metiers_periodes_effectif AS
WITH tw1 AS (
SELECT nom_rue || ' ' || numero as adresse, pkuid, geometry 
FROM adresses_qgis
WHERE pkuid in (SELECT MAX(pkuid)
FROM adresses_qgis
GROUP BY nom_rue || ' ' || numero)
), tw2 AS (
SELECT vml.pk_personne, vml.person, vml.genre, vml.classement_calcule, 
CASE 
	WHEN vml.partie_b = 'Robert 5'
	THEN 'Rue Robert 5'
	ELSE vml.partie_b
END as partie_b,
periode,
vml.date_permis_modifiee 
FROM v_mention_domicile_metier_periode vml ),
tw3 AS (
SELECT tw2.*, tw1.*
FROM tw2 
	--LEFT 
		JOIN tw1 
		ON adresse LIKE '%' || tw2.partie_b || '%'
WHERE LENGTH(partie_b) > 0
	AND partie_b != 'Robert'
	AND partie_b != 'Puits'
	AND partie_b != 'Ronde'
	AND partie_b != 'Parc'
	AND partie_b != 'Collège'
	AND partie_b != 'Grand Rue'
	AND partie_b != 'Grognerie'
	AND partie_b != 'Hotel'
	AND partie_b != 'Dufour'
	AND partie_b != 'Droz'
	AND partie_b != 'Balance')
SELECT classement_calcule, periode, adresse, pkuid, geometry, COUNT(*) effectif
FROM tw3
GROUP BY classement_calcule, periode, adresse, pkuid, geometry
ORDER BY effectif DESC;
	


SELECT *
FROM v_points_classes_metiers_periodes_effectif
ORDER BY periode, classement_calcule ;


-- regrouper et compter par classement métier et période
SELECT classement_calcule, periode, SUM(effectif) AS effectif
FROM v_points_classes_metiers_periodes_effectif
GROUP BY classement_calcule, periode
ORDER BY periode, effectif DESC;


/*
 * Question: faut-il représenter sur la carte seulement les professions qui 
 * comptent plus de 10 personnes ?
 */

-- regrouper et compter par classement métier
SELECT classement_calcule, SUM(effectif) AS effectif
FROM v_points_classes_metiers_periodes_effectif
GROUP BY classement_calcule
--HAVING SUM(effectif) < 10
HAVING SUM(effectif) > 10
ORDER BY classement_calcule DESC;








/*
 * Créer les rues
 * 
 * Tentative de créer des rues à partir des points
 * 
 * L'affichage n'est pas joli, même si on a une logique de simplification dans QGis
 * 
 */

with tw1 AS (
SELECT REPLACE(REPLACE(geometry, 'POINT (', ''), ')', '') geom
from adresses_qgis)
select geom, 
	(SUBSTR(geom, 1, INSTR(geom, ' ') - 1) + 0.001) || ' ' || (SUBSTR(geom, INSTR(geom, ' ') + 1) + 0.001) AS new_geom
from tw1;


DROP VIEW v_rues;
CREATE VIEW v_rues AS
WITH TW1 AS (
SELECT nom_rue_corr, numero,geometry
FROM adresses_qgis
ORDER BY geometry
), tw2 AS (
SELECT nom_rue_corr, COUNT(*) AS points,  group_concat(numero) as numeros, group_concat(distinct (REPLACE((REPLACE(geometry, 'POINT (', '')), ')', ''))) geometry
FROM tw1
GROUP BY nom_rue_corr
)
SELECT nom_rue_corr,
'LINESTRING (' || CASE 
		WHEN points = 1 
		THEN geometry || ',' || (SUBSTR(geometry, 1, INSTR(geometry, ' ') - 1) + 0.0002) || ' ' || (SUBSTR(geometry, INSTR(geometry, ' ') + 1) + 0.0002)
		ELSE geometry
END || ')' AS geometry, numeros, points
FROM tw2;

SELECT *
FROM v_rues;


/*
 * Résidence dans les rues
 */

SELECT *
FROM v_mention_domicile_metier_periode;

SELECT *
FROM v_rues;


-- inspection
SELECT vml.pk_personne, vml.person, vml.genre, vml.classement_calcule, 
CASE 
	WHEN vml.partie_b LIKE 'Robert%'
	THEN 'Rue Robert'
	ELSE vml.partie_b
END as partie_b_corr,
vr.nom_rue_corr,
periode,
vml.date_permis_modifiee,
vr.geometry
FROM v_mention_domicile_metier_periode vml 
	--LEFT 
	JOIN v_rues vr ON vr.nom_rue_corr LIKE '%' || 
	TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(partie_b_corr, '0', ''),
		'1', ''),
		'2', ''),
		'3', ''),
		'4', ''),
		'5', ''),
		'6', ''),
		'7', ''),
		'8', ''),
		'9', ''))
	|| '%'
	WHERE length(partie_b_corr) > 0;



-- requête pour préparer le fichier à exporter vers QGis
SELECT vml.genre, 
vml.classement_calcule, 
vr.nom_rue_corr,
periode,
vr.geometry,
COUNT(*) as effectif
FROM v_mention_domicile_metier_periode vml 
	--LEFT 
	JOIN v_rues vr ON vr.nom_rue_corr LIKE '%' || 
	TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
		CASE 
			WHEN vml.partie_b LIKE 'Robert%'
			THEN 'Rue Robert'
			ELSE vml.partie_b
		END , '0', ''),
		'1', ''),
		'2', ''),
		'3', ''),
		'4', ''),
		'5', ''),
		'6', ''),
		'7', ''),
		'8', ''),
		'9', ''))
	|| '%'
	WHERE length(vr.nom_rue_corr) > 0
	Group BY vml.genre, 
	vml.classement_calcule, 
	vr.nom_rue_corr,
	periode,
	vr.geometry;




