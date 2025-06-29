

-- compter les mentions par genre
SELECT m.genre_pk, g.genre, COUNT(*) as number
FROM Mention m
JOIN Genre g ON m.genre_pk = g.genre_pk 
GROUP BY m.genre_pk, g.genre
ORDER BY g.genre ;

-- compter les personnes par genre
SELECT genre, COUNT(*) as number
FROM v_personne vp 
GROUP BY genre 
ORDER BY genre ;

SELECT *
FROM v_personne vp 
WHERE genre = 'femme';


-- date d'arrivée des personnes en relations avec le genre
SELECT SUBSTRING(min_date_permis,1,4)annee_arrivee, genre 
FROM v_personne vp ;

WITH tw1 AS (
SELECT SUBSTRING(min_date_permis,1,4) annee_arrivee, genre, famille
FROM v_personne_avec_proprietes_agg
)
SELECT annee_arrivee, genre, COUNT(*) AS number, GROUP_CONCAT(famille, ' // ')
FROM tw1
GROUP BY annee_arrivee, genre 
ORDER BY annee_arrivee, genre;

-- personne mentionnée comme conjointe
SELECT *
FROM Mention m 
WHERE m.Famille like '%Cassina%';

-- personne sans date arrivée
SELECT *
FROM v_personne vp
WHERE vp.min_date_permis is null;



WITH tw1 AS (
SELECT SUBSTRING(min_date_permis,1,4) annee_arrivee, genre, famille
FROM v_personne_avec_proprietes_agg
)
SELECT annee_arrivee, genre, COUNT(*) AS number, GROUP_CONCAT(famille, ' // ')
FROM tw1
GROUP BY annee_arrivee, genre 
ORDER BY annee_arrivee, genre;



WITH tw1 AS (
SELECT SUBSTRING(min_date_permis,1,4) annee_arrivee, genre
FROM v_personne_avec_proprietes_agg
)
SELECT annee_arrivee, genre, COUNT(*) AS number
FROM tw1
WHERE annee_arrivee NOTNULL 
GROUP BY annee_arrivee, genre 
ORDER BY annee_arrivee, genre;




SELECT SUBSTRING(min_date_permis,1,4) annee_arrivee, genre, count(*) as nombre	
FROM v_personne_avec_proprietes_agg
WHERE min_date_permis NOTNULL
GROUP BY SUBSTRING(min_date_permis,1,4), genre
ORDER BY annee_arrivee; 












