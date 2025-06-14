
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
FROM v_personne vp; 

WITH tw1 AS (
SELECT m.pk_personne, m.Famille, m.fk_metier
FROM Mention m
ORDER BY m.date_permis_modifiee
)
SELECT vp.pk_personne, vp.person, vp.genre, vp.min_date_permis, vp.max_date_permis, vp.duree, vp.number,
group_concat(m.Famille, ' | ') famille,
group_concat(m2.metier, ' | ') metiers
FROM v_personne vp 
	JOIN tw1 m on m.pk_personne = vp.pk_personne
	LEFT JOIN metier m2 on m2.metier_pk = m.fk_metier
GROUP BY vp.pk_personne, vp.person, vp.genre, vp.min_date_permis, vp.max_date_permis, vp.duree, vp.number
ORDER BY vp.duree DESC





