-- ============================================================
-- Testabfragen fuer die Buchtausch-App
-- Jede Abfrage demonstriert eine Kernfunktion aus Abschnitt 2.4
-- ============================================================

-- Q1: Verfuegbare Exemplare mit Titel, Zustand und Besitzer:in
--     (Join ueber book_copy, book, app_user)
SELECT bc.copy_id, b.title, bc.condition,
       u.first_name || ' ' || u.last_name AS owner
FROM book_copy bc
JOIN book b     ON b.book_id = bc.book_id
JOIN app_user u ON u.user_id = bc.owner_id
WHERE bc.available = TRUE
ORDER BY b.title;

-- Q2: Umkreissuche - Exemplare im Umkreis von ~50 km um Berlin-Mitte
--     (Geokoordinaten via pickup_offer -> pickup_location -> address)
--     Distanz per Haversine-Naeherung
SELECT DISTINCT b.title, pl.label, a.city,
       ROUND(
         6371 * acos(
           cos(radians(52.52)) * cos(radians(a.latitude)) *
           cos(radians(a.longitude) - radians(13.405)) +
           sin(radians(52.52)) * sin(radians(a.latitude))
         )::numeric, 1) AS distance_km
FROM pickup_offer po
JOIN book_copy bc       ON bc.copy_id = po.copy_id
JOIN book b             ON b.book_id = bc.book_id
JOIN pickup_location pl ON pl.location_id = po.location_id
JOIN address a          ON a.address_id = pl.address_id
WHERE 6371 * acos(
        cos(radians(52.52)) * cos(radians(a.latitude)) *
        cos(radians(a.longitude) - radians(13.405)) +
        sin(radians(52.52)) * sin(radians(a.latitude))
      ) < 50
ORDER BY distance_km;

-- Q3: Ternaere Beziehung PICKUP_OFFER ausgelesen
--     (welches Exemplar an welchem Ort zu welchem Zeitfenster)
SELECT b.title, pl.label,
       ts.weekday, ts.from_time, ts.to_time
FROM pickup_offer po
JOIN book_copy bc       ON bc.copy_id = po.copy_id
JOIN book b             ON b.book_id = bc.book_id
JOIN pickup_location pl ON pl.location_id = po.location_id
JOIN time_slot ts       ON ts.slot_id = po.slot_id
ORDER BY b.title, ts.weekday;

-- Q4: Ternaere Beziehung RESERVATION
--     (wer reserviert welches Exemplar zu welchem Zeitfenster)
SELECT u.first_name || ' ' || u.last_name AS reserver,
       b.title, ts.weekday, ts.from_time, r.status
FROM reservation r
JOIN app_user u   ON u.user_id = r.user_id
JOIN book_copy bc ON bc.copy_id = r.copy_id
JOIN book b       ON b.book_id = bc.book_id
JOIN time_slot ts ON ts.slot_id = r.slot_id
ORDER BY r.reserved_at;

-- Q5: Durchschnittsbewertung je Buch (Aggregat, kein redundantes Feld)
SELECT b.title,
       ROUND(AVG(rv.stars)::numeric, 2) AS avg_stars,
       COUNT(*) AS num_reviews
FROM review rv
JOIN book b ON b.book_id = rv.book_id
GROUP BY b.title
ORDER BY avg_stars DESC;

-- Q6: Buecher mit mehreren Autor:innen (m:n via book_author)
SELECT b.title,
       STRING_AGG(au.first_name || ' ' || au.last_name, ', ') AS authors
FROM book b
JOIN book_author ba ON ba.book_id = b.book_id
JOIN author au      ON au.author_id = ba.author_id
GROUP BY b.title
HAVING COUNT(*) > 1;

-- Q7: Ausleihhistorie einer bestimmten Ausleihe (Statuswechsel)
SELECT lsh.changed_at, lsh.old_status, lsh.new_status,
       u.first_name AS changed_by
FROM loan_status_history lsh
LEFT JOIN app_user u ON u.user_id = lsh.changed_by
WHERE lsh.loan_id = 1
ORDER BY lsh.changed_at;

-- Q8: Offene (nicht zurueckgegebene) Ausleihen mit Faelligkeit
SELECT l.loan_id, b.title,
       u.first_name || ' ' || u.last_name AS borrower,
       l.due_at, l.status
FROM loan l
JOIN book_copy bc ON bc.copy_id = l.copy_id
JOIN book b       ON b.book_id = bc.book_id
JOIN app_user u   ON u.user_id = l.borrower_id
WHERE l.returned_at IS NULL
  AND l.status IN ('confirmed','borrowed')
ORDER BY l.due_at;

-- Q9: Merklisten-Treffer - gewuenschte Buecher, die aktuell verfuegbar sind
SELECT u.first_name, b.title
FROM wishlist w
JOIN app_user u ON u.user_id = w.user_id
JOIN book b     ON b.book_id = w.book_id
WHERE EXISTS (
    SELECT 1 FROM book_copy bc
    WHERE bc.book_id = b.book_id AND bc.available = TRUE
);

-- Q10: Aktivste Verleiher:innen (Anzahl eigener Exemplare, die verliehen wurden)
SELECT u.first_name || ' ' || u.last_name AS owner,
       COUNT(DISTINCT l.loan_id) AS loans_given
FROM app_user u
JOIN book_copy bc ON bc.owner_id = u.user_id
JOIN loan l       ON l.copy_id = bc.copy_id
GROUP BY owner
ORDER BY loans_given DESC;
