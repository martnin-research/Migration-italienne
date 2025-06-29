

SELECT *
FROM v_personne_avec_proprietes_agg;

SELECT *
FROM v_personne_avec_proprietes_agg
WHERE pays_origine like '%Autriche%';

WITH tw1 AS (
SELECT SUBSTRING(min_date_permis,1,4) annee_arrivee, pays_origine_code
FROM v_personne_avec_proprietes_agg
)
SELECT annee_arrivee, pays_origine_code, COUNT(*) number
FROM tw1
GROUP BY annee_arrivee, pays_origine_code;


SELECT pays_origine_code, COUNT(*) number
FROM v_personne_avec_proprietes_agg
GROUP BY pays_origine_code
ORDER BY number DESC ;



SELECT pays_origine_code, genre, COUNT(*) number
FROM v_personne_avec_proprietes_agg
GROUP BY genre, pays_origine_code
ORDER BY pays_origine_code, genre;