

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




-- arrivée de la famille tout de suite ou après
SELECT
famille,
CASE 
	WHEN INSTR(famille, '|') = 2
		THEN 'dopo'
	ELSE 'subito'
END AS position, *
FROM v_personne_avec_proprietes_agg
WHERE length(ltrim(famille, '| ')) > 0;


- nombre de avec ou sans famille

WITH tw1 AS (
SELECT
CASE 
	WHEN INSTR(famille, '|') = 2
		THEN 'dopo'
	ELSE 'subito'
END AS position, *
FROM v_personne_avec_proprietes_agg vpapa 
WHERE length(ltrim(famille, '| ')) > 0
)
SELECT position, COUNT(*) as numero
FROM tw1
group by position;


-- metier 

SELECT vp.*, m.pk_mention, me.*, me.classement_3,  me.classement_4 
FROM v_personne vp 
	JOIN Mention m  ON m.pk_personne = vp.pk_personne 
	JOIN metier me ON me.metier_pk = m.fk_metier 
order by vp.person;


WITH tw1 AS (
SELECT vp.*, me.classement_2,  me.classement_3
FROM v_personne vp 
	JOIN Mention m  ON m.pk_personne = vp.pk_personne 
	JOIN metier me ON me.metier_pk = m.fk_metier 
)
select classement_2,  classement_3, count(*) AS number
from tw1
--WHERE SUBSTRING(min_date_permis,1,4) between '1848' AND '1854'
WHERE SUBSTRING(min_date_permis,1,4) between '1855' AND '1860'
--WHERE SUBSTRING(min_date_permis,1,4) between '1861' AND '1870'
group by classement_2,  classement_3
order by number DESC;





WITH tw1 AS (
SELECT vp.*, 
CASE 
	WHEN SUBSTRING(min_date_permis,1,4) between '1848' AND '1854'
	THEN '1848-1854'
	WHEN SUBSTRING(min_date_permis,1,4) between '1855' AND '1860'
	THEN '1855-1860'
	WHEN SUBSTRING(min_date_permis,1,4) between '1861' AND '1870'
	THEN '1861-1870'
END AS period,
me.classement_3
FROM v_personne vp 
	JOIN Mention m  ON m.pk_personne = vp.pk_personne 
	JOIN metier me ON me.metier_pk = m.fk_metier 
)
select classement_3, period, count(*) AS number
from tw1
group by classement_3, period
HAVING COUNT(*) > 5 
order by period, number DESC;


-- origine nationalité 

SELECT *
FROM v_personne_avec_proprietes_agg vpapa ;

SELECT *
FROM v_personne_avec_proprietes_agg
WHERE pays_origine like '%Autriche%';

WITH tw1 AS (
SELECT SUBSTRING(min_date_permis,1,4) annee_arrivee, pays_origine
FROM v_personne_avec_proprietes_agg
)
SELECT annee_arrivee, pays_origine, COUNT(*) number
FROM tw1
GROUP BY annee_arrivee, pays_origine;


SELECT pays_origine, COUNT(*) number
FROM v_personne_avec_proprietes_agg
GROUP BY pays_origine
ORDER BY number DESC;


SELECT pays_origine, genre, COUNT(*) number
FROM v_personne_avec_proprietes_agg
GROUP BY genre, pays_origine
ORDER BY pays_origine, genre;


