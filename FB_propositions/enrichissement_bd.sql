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

