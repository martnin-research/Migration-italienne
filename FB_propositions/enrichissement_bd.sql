--Convertir les dates
with tw1 AS (
SELECT pk_mention, 
SUBSTRING("Date du permis", 0, INSTR("Date du permis", '.')) as jour,
SUBSTRING("Date du permis", INSTR("Date du permis", '.')+1) as reste
FROM Mention m
), tw2 AS(
SELECT pk_mention, 
SUBSTRING(reste, 0, INSTR(reste, '.')) as mois,
SUBSTRING(reste, INSTR(reste, '.')+1) as annee
FROM tw1),
tw3 as (
SELECT tw1.pk_mention, tw2.annee || '-' ||
CASE 
	WHEN length(tw2.mois) = 1 
	THEN '0' || tw2.mois
	ELSE tw2.mois	
END ||  '-' ||
CASE 
	WHEN length(tw1.jour) = 1 
	THEN '0' || tw1.jour
	ELSE tw1.jour	
END AS date_iso
FROM tw1 
JOIN tw2 ON tw1.pk_mention = tw2.pk_mention
)
SELECT pk_mention, date_iso
FROM tw3
ORDER BY date_iso;

with tw1 AS (
SELECT pk_mention, 
SUBSTRING("Date du permis", 0, INSTR("Date du permis", '.')) as jour,
SUBSTRING("Date du permis", INSTR("Date du permis", '.')+1) as reste
FROM Mention m
), tw2 AS(
SELECT pk_mention, 
SUBSTRING(reste, 0, INSTR(reste, '.')) as mois,
SUBSTRING(reste, INSTR(reste, '.')+1) as annee
FROM tw1),
tw3 as (
SELECT tw1.pk_mention, tw2.annee || '-' ||
CASE 
	WHEN length(tw2.mois) = 1 
	THEN '0' || tw2.mois
	ELSE tw2.mois	
END ||  '-' ||
CASE 
	WHEN length(tw1.jour) = 1 
	THEN '0' || tw1.jour
	ELSE tw1.jour	
END AS date_iso
FROM tw1 
JOIN tw2 ON tw1.pk_mention = tw2.pk_mention
)
UPDATE Mention AS m SET date_permis_modifiee = tw3.date_iso
FROM tw3 WHERE tw3.pk_mention = m.pk_mention;



/*
 * VILLE D'ORIGINE
 */

SELECT m.ville_origine, vo.nom_ville, pk_ville_origine 
FROM Mention m 
   JOIN "Ville origine" vo ON vo.nom_ville = m.ville_origine; 

  
UPDATE Mention AS m SET fk_ville_origine = vo.pk_ville_origine
FROM  "Ville origine" vo
WHERE vo.nom_ville = m.ville_origine;



/*
 * METIER
 */


SELECT m.Metier, m2.metier, m2.metier_pk 
FROM Mention m 
   LEFT JOIN metier m2 ON TRIM(m2.metier) = TRIM(m.Metier); 

UPDATE Mention AS m SET fk_metier = m2.metier_pk
FROM  metier m2
WHERE TRIM(m2.metier) = TRIM(m.Metier);






