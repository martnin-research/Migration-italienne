

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



