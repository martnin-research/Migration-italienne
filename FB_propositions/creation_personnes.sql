
-- données de base personne
DROP VIEW v_personne;

CREATE VIEW v_personne
AS
WITH tw1 AS (
SELECT p.pk_personne, nom_personne || ' ' || prenom_personne AS person , g.genre, 
m.date_permis_modifiee AS date_permis
FROM Personne p
	JOIN Mention m ON m.pk_personne = p.pk_personne 
	JOIN Genre g ON g.genre_pk = m.genre_pk
)
SELECT pk_personne, person, genre, 
		MIN(date_permis) AS min_date_permis, 
		CASE   
			WHEN MAX(date_permis) = MIN(date_permis)
			THEN ''
			ELSE MAX(date_permis)
		END max_date_permis,
		CASE   
			WHEN MAX(date_permis) = MIN(date_permis)
			THEN 0
			ELSE CAST((SUBSTRING(MAX(date_permis), 0, INSTR(MAX(date_permis), '-'))) AS INTEGER) - 
				CAST(SUBSTRING(MIN(date_permis), 0, INSTR(MIN(date_permis), '-')) AS INTEGER) + 1 
		END duree,		
		COUNT(*) as number
FROM tw1
GROUP BY pk_personne, person, genre
ORDER BY number DESC;

SELECT *
FROM Mention m 
WHERE m.pk_personne = 21;

SELECT *
FROM v_personne vp; 


DROP VIEW v_personne_avec_proprietes_agg ;
CREATE VIEW v_personne_avec_proprietes_agg
AS
WITH tw1 AS (
SELECT m.pk_personne, m.Famille Famille, m.fk_metier, 
	m."Pays origine" pays_origine, m.ville_origine, m.fk_ville_origine
FROM Mention m
ORDER BY m.date_permis_modifiee
)
SELECT vp.pk_personne, vp.person, vp.genre, vp.min_date_permis, vp.max_date_permis, vp.duree, vp.number,
group_concat(m.Famille, ' | ') famille,
group_concat(m2.metier, ' | ') metiers,
group_concat(m.pays_origine, ' | ') pays_origine,
CASE 
	WHEN 
		group_concat(m.pays_origine) like '%Sardeigne%'
	 	OR
	 	group_concat(m.pays_origine) like '%Piémont%'
	THEN 'Royaume de Sardeigne'
	WHEN 
		group_concat(m.pays_origine) like '%Lombard%'
	 	OR
	 	group_concat(m.pays_origine) like '%Autri%'
	THEN 'Lombardie'
	WHEN 
		group_concat(m.pays_origine) like '%Savoie%'
		OR
	 	group_concat(m.pays_origine) like '%Isèr%'
	THEN 'Savoie'
	ELSE TRIM(group_concat(DISTINCT m.pays_origine)) 
END pays_origine_code,
group_concat(DISTINCT m.ville_origine) villes_origine,
group_concat(DISTINCT vo."nom_ville" ) villes_origine_code
FROM v_personne vp 
	JOIN tw1 m on m.pk_personne = vp.pk_personne
	LEFT JOIN metier m2 on m2.metier_pk = m.fk_metier
	LEFT JOIN "Ville origine" vo on vo.pk_ville_origine = m.fk_ville_origine
GROUP BY vp.pk_personne, vp.person, vp.genre, vp.min_date_permis, vp.max_date_permis, vp.duree, vp.number
ORDER BY vp.duree DESC;


SELECT *
FROM v_personne_avec_proprietes_agg;


