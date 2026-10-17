-- ============================================================
-- Aussagekraeftige Testfaelle fuer die Buchtausch-App
-- Portfolio DLBDSPBDM01_D - Finalisierungsphase (Phase 3)
-- ============================================================
-- Aufbau: Die Tests weisen gezielt Integritaetsregeln (Negativtests)
-- und typische fachliche Anwendungsfaelle nach, statt nur Daten
-- auszugeben. Jeder Test nennt Ziel, erwartetes Ergebnis und die
-- fachliche Begruendung.
--
-- Negativtests sind in DO-Bloecke gekapselt: Sie provozieren absichtlich
-- einen Constraint-Fehler und geben eine lesbare Meldung aus, ob der
-- Schutz gegriffen hat. So bleibt das Skript als Ganzes lauffaehig.
-- ============================================================


-- ############################################################
-- TEIL A - INTEGRITAETSREGELN (NEGATIVTESTS)
-- Nachweis, dass die Constraints unzulaessige Daten abweisen.
-- ############################################################

-- ------------------------------------------------------------
-- T1  CHECK: unzulaessiger Buchzustand wird abgewiesen
--     Ziel      : condition darf nur definierte Werte annehmen.
--     Erwartet  : INSERT schlaegt fehl (CHECK-Verletzung).
--     Mehrwert  : Verhindert Tippfehler/uneinheitliche Zustaende,
--                 auf die sich Suche und Anzeige verlassen.
-- ------------------------------------------------------------
DO $$
BEGIN
    INSERT INTO book_copy (book_id, owner_id, condition)
    VALUES (1, 2, 'zerfleddert');   -- unzulaessiger Wert
    RAISE NOTICE 'T1 FEHLGESCHLAGEN: unzulaessiger Zustand wurde akzeptiert';
EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'T1 OK: unzulaessiger Zustand abgewiesen (CHECK greift)';
END $$;

-- ------------------------------------------------------------
-- T2  CHECK: Sternebewertung ausserhalb 1..5 wird abgewiesen
--     Ziel      : stars muss im gueltigen Bereich liegen.
--     Erwartet  : INSERT schlaegt fehl.
--     Mehrwert  : Sichert korrekte Durchschnittsbewertungen.
-- ------------------------------------------------------------
DO $$
BEGIN
    INSERT INTO review (loan_id, book_id, user_id, stars)
    VALUES (1, 1, 3, 7);            -- 7 Sterne sind unzulaessig
    RAISE NOTICE 'T2 FEHLGESCHLAGEN: 7 Sterne wurden akzeptiert';
EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'T2 OK: Sterne ausserhalb 1..5 abgewiesen';
END $$;

-- ------------------------------------------------------------
-- T3  UNIQUE: doppelte E-Mail wird abgewiesen
--     Ziel      : email muss eindeutig sein (Konto-Identitaet).
--     Erwartet  : zweiter INSERT schlaegt fehl.
--     Mehrwert  : Verhindert doppelte Benutzerkonten.
-- ------------------------------------------------------------
DO $$
BEGIN
    INSERT INTO app_user (first_name, last_name, email)
    VALUES ('Test','Doppel','lena.berger@example.com');  -- existiert bereits
    RAISE NOTICE 'T3 FEHLGESCHLAGEN: doppelte E-Mail wurde akzeptiert';
EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'T3 OK: doppelte E-Mail abgewiesen (UNIQUE greift)';
END $$;

-- ------------------------------------------------------------
-- T4  FOREIGN KEY: Exemplar ohne gueltiges Buch wird abgewiesen
--     Ziel      : book_copy.book_id muss auf ein echtes Buch zeigen.
--     Erwartet  : INSERT schlaegt fehl (FK-Verletzung).
--     Mehrwert  : Schuetzt vor "verwaisten" Exemplaren.
-- ------------------------------------------------------------
DO $$
BEGIN
    INSERT INTO book_copy (book_id, owner_id, condition)
    VALUES (9999, 2, 'good');       -- book_id existiert nicht
    RAISE NOTICE 'T4 FEHLGESCHLAGEN: Exemplar ohne gueltiges Buch akzeptiert';
EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'T4 OK: Exemplar ohne gueltiges Buch abgewiesen (FK greift)';
END $$;

-- ------------------------------------------------------------
-- T5  CHECK (mehrspaltig): Rueckgabe vor Ausleihe wird abgewiesen
--     Ziel      : returned_at >= borrowed_at.
--     Erwartet  : INSERT schlaegt fehl.
--     Mehrwert  : Verhindert logisch unmoegliche Ausleihdaten.
-- ------------------------------------------------------------
DO $$
BEGIN
    INSERT INTO loan (copy_id, borrower_id, slot_id, borrowed_at, due_at, returned_at, status)
    VALUES (1, 3, 1, '2024-09-10', '2024-10-10', '2024-09-01', 'returned');
    RAISE NOTICE 'T5 FEHLGESCHLAGEN: Rueckgabe vor Ausleihe akzeptiert';
EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'T5 OK: Rueckgabe vor Ausleihe abgewiesen';
END $$;

-- ------------------------------------------------------------
-- T6  CHECK: Nachricht an sich selbst wird abgewiesen
--     Ziel      : sender_id <> receiver_id.
--     Erwartet  : INSERT schlaegt fehl.
--     Mehrwert  : Sinnlose Selbst-Nachrichten werden verhindert.
-- ------------------------------------------------------------
DO $$
BEGIN
    INSERT INTO message (sender_id, receiver_id, body)
    VALUES (2, 2, 'Nachricht an mich selbst');
    RAISE NOTICE 'T6 FEHLGESCHLAGEN: Selbst-Nachricht akzeptiert';
EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'T6 OK: Selbst-Nachricht abgewiesen';
END $$;

-- ------------------------------------------------------------
-- T7  UNIQUE (Dreifachbeziehung): doppelte Reservierung
--     Ziel      : (user_id, copy_id, slot_id) darf nur einmal existieren.
--     Erwartet  : zweiter identischer INSERT schlaegt fehl.
--     Mehrwert  : Verhindert Doppelreservierung desselben Slots.
-- ------------------------------------------------------------
DO $$
BEGIN
    INSERT INTO reservation (user_id, copy_id, slot_id, expires_at, status)
    VALUES (3, 6, 7, '2024-10-20', 'pending');  -- Kombination existiert bereits
    RAISE NOTICE 'T7 FEHLGESCHLAGEN: doppelte Reservierung akzeptiert';
EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'T7 OK: doppelte Reservierung abgewiesen (UNIQUE greift)';
END $$;


-- ############################################################
-- TEIL B - FACHLICHE ANWENDUNGSFAELLE
-- Typische App-Szenarien, die die Modellierung nachweisen.
-- ############################################################

-- ------------------------------------------------------------
-- T8  Referenzielle Integritaet nachweisen: verwaiste FKs?
--     Ziel      : Kein Ausleihvorgang zeigt auf fehlende Stammdaten.
--     Erwartet  : 0 Zeilen (Beweis der Integritaet).
-- ------------------------------------------------------------
SELECT l.loan_id
FROM loan l
LEFT JOIN book_copy bc ON bc.copy_id = l.copy_id
LEFT JOIN app_user  u  ON u.user_id  = l.borrower_id
WHERE bc.copy_id IS NULL OR u.user_id IS NULL;
-- Erwartung: leere Ergebnismenge.

-- ------------------------------------------------------------
-- T9  Geschaeftsregel: Reviews nur zu abgeschlossenen Ausleihen?
--     Ziel      : Jede Bewertung gehoert zu einer 'returned'-Ausleihe.
--     Erwartet  : 0 Zeilen = Regel eingehalten.
--     Mehrwert  : Weist nach, dass Bewertungen fachlich valide sind.
-- ------------------------------------------------------------
SELECT rv.review_id, l.status
FROM review rv
JOIN loan l ON l.loan_id = rv.loan_id
WHERE l.status <> 'returned';
-- Erwartung: leere Ergebnismenge.

-- ------------------------------------------------------------
-- T10 Anwendungsfall: Ueberfaellige Ausleihen ermitteln
--     Ziel      : Noch nicht zurueckgegebene Ausleihen nach Frist.
--     Erwartet  : Liste mit Titel, Ausleiher:in, Faelligkeit, Status.
--     Mehrwert  : Basis fuer Mahnungen/Benachrichtigungen.
-- ------------------------------------------------------------
SELECT b.title,
       u.first_name || ' ' || u.last_name AS borrower,
       l.due_at, l.status
FROM loan l
JOIN book_copy bc ON bc.copy_id = l.copy_id
JOIN book b       ON b.book_id  = bc.book_id
JOIN app_user u   ON u.user_id  = l.borrower_id
WHERE l.returned_at IS NULL
  AND l.status IN ('confirmed','borrowed')
ORDER BY l.due_at;

-- ------------------------------------------------------------
-- T11 Anwendungsfall: Umkreissuche (raeumliche Funktion)
--     Ziel      : Verfuegbare Exemplare < 50 km um Berlin-Mitte.
--     Erwartet  : Treffer mit aufsteigender Distanz.
--     Mehrwert  : Kernfunktion "Buecher in meiner Naehe".
-- ------------------------------------------------------------
SELECT DISTINCT b.title, a.city,
       ROUND((6371 * acos(
           cos(radians(52.52)) * cos(radians(a.latitude)) *
           cos(radians(a.longitude) - radians(13.405)) +
           sin(radians(52.52)) * sin(radians(a.latitude))
       ))::numeric, 1) AS distance_km
FROM pickup_offer po
JOIN book_copy bc       ON bc.copy_id   = po.copy_id
JOIN book b             ON b.book_id    = bc.book_id
JOIN pickup_location pl ON pl.location_id = po.location_id
JOIN address a          ON a.address_id = pl.address_id
WHERE bc.available = TRUE
  AND 6371 * acos(
        cos(radians(52.52)) * cos(radians(a.latitude)) *
        cos(radians(a.longitude) - radians(13.405)) +
        sin(radians(52.52)) * sin(radians(a.latitude))
      ) < 50
ORDER BY distance_km;

-- ------------------------------------------------------------
-- T12 Anwendungsfall: Historie weist lueckenlosen Status-Verlauf nach
--     Ziel      : Statuskette einer Ausleihe nachvollziehbar.
--     Erwartet  : geordnete Folge requested->confirmed->borrowed->returned.
--     Mehrwert  : Fachlicher Nutzen der Historientabelle (Audit-Trail).
-- ------------------------------------------------------------
SELECT lsh.changed_at, lsh.old_status, lsh.new_status,
       u.first_name AS changed_by
FROM loan_status_history lsh
LEFT JOIN app_user u ON u.user_id = lsh.changed_by
WHERE lsh.loan_id = 1
ORDER BY lsh.changed_at, lsh.history_id;

-- ------------------------------------------------------------
-- T13 Anwendungsfall: Merklisten-Treffer (Wunschbuch verfuegbar)
--     Ziel      : Welche Wunschbuecher sind aktuell ausleihbar?
--     Erwartet  : Nutzer:in + Titel, sofern verfuegbares Exemplar existiert.
--     Mehrwert  : Grundlage fuer "Dein Wunschbuch ist verfuegbar"-Hinweis.
-- ------------------------------------------------------------
SELECT u.first_name, b.title
FROM wishlist w
JOIN app_user u ON u.user_id = w.user_id
JOIN book b     ON b.book_id = w.book_id
WHERE EXISTS (
    SELECT 1 FROM book_copy bc
    WHERE bc.book_id = b.book_id AND bc.available = TRUE
)
ORDER BY u.first_name;

-- ------------------------------------------------------------
-- T14 Aggregat: Durchschnittsbewertung je Buch
--     Ziel      : Bewertungen verdichten statt roh ausgeben.
--     Erwartet  : Titel mit Durchschnitt und Anzahl, absteigend.
--     Mehrwert  : Vermeidet redundante Speicherung (3NF-konform).
-- ------------------------------------------------------------
SELECT b.title,
       ROUND(AVG(rv.stars)::numeric, 2) AS avg_stars,
       COUNT(*) AS num_reviews
FROM review rv
JOIN book b ON b.book_id = rv.book_id
GROUP BY b.title
ORDER BY avg_stars DESC, num_reviews DESC;
