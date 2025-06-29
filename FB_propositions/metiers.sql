


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




