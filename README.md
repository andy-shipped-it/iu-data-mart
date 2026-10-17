# Buchtausch-App – Datenbank (DLBDSPBDM01_D)

Relationale Datenbank als Backend einer **Buchtausch-App**, über die Nachbar:innen
private Bücher verleihen und ausleihen. Entwickelt im Rahmen des Portfolios
*„Data-Mart-Erstellung in SQL“* (DLBDSPBDM01_D).

**Autor:** Andreas Waida · **Matrikelnummer:** 32110605
**DBMS:** PostgreSQL 16

---

## Überblick

Die Datenbank bildet den gesamten fachlichen Lebenszyklus der App ab: das
Einstellen von Buchexemplaren mit Verleihkonditionen, die Suche inklusive
räumlicher Umkreissuche, die Abwicklung von Ausleih- und Reservierungsvorgängen
sowie Bewertungen, Nachrichten und Benachrichtigungen.

- **21 Tabellen** (15 inhaltliche Entitäten + 6 Verknüpfungs-/Historientabellen)
- Normalisiert bis zur **3. Normalform (3NF)**
- Zwei **Dreifachbeziehungen**: `pickup_offer` und `reservation`
- Datenintegrität über **PRIMARY KEY, FOREIGN KEY, UNIQUE** und **CHECK**-Constraints
- Mindestens **10 Datensätze je Tabelle** (232 Zeilen gesamt)

---

## Projektstruktur

| Datei            | Inhalt                                                             |
|------------------|--------------------------------------------------------------------|
| `schema.sql`     | Alle `CREATE TABLE`-Anweisungen mit Primär-/Fremdschlüsseln und Constraints |
| `data.sql`       | Dummy-Daten (mind. 10 Datensätze je Tabelle)                       |
| `queries.sql`    | Beispielabfragen zu den Kernfunktionen                             |
| `tests.sql`   | Aussagekräftige Testfälle: 7 Negativtests + 7 fachliche Anwendungsfälle |

---

## Installation und Einrichtung

### Voraussetzungen

- PostgreSQL 14 oder neuer
  - **macOS:** am einfachsten über [Postgres.app](https://postgresapp.com) –
    App herunterladen, in den Programme-Ordner ziehen, starten, *Initialize* klicken.
  - **Windows/Linux:** Installer von [postgresql.org](https://www.postgresql.org/download/).
- Optional ein grafisches Tool wie **DBeaver** oder **pgAdmin** zum Ausführen der SQL-Dateien.

### Schritt 1 – Datenbank anlegen

```bash
createdb buchtausch
```

Alternativ in einem SQL-Tool:

```sql
CREATE DATABASE buchtausch;
```

### Schritt 2 – Schema und Daten laden

**Reihenfolge beachten:** zuerst das Schema (legt die Tabellen an), dann die Daten.

Über die Kommandozeile (`psql`):

```bash
psql -d buchtausch -f schema.sql
psql -d buchtausch -f data.sql
```

In DBeaver/pgAdmin: Datei öffnen und das **gesamte Skript** ausführen
(DBeaver: `Alt + X` bzw. `⌥ + X`), erst `schema.sql`, dann `data.sql`.

### Schritt 3 – Installation prüfen

```sql
SELECT count(*) FROM pg_tables WHERE schemaname = 'public';   -- erwartet: 21
SELECT count(*) FROM book;                                    -- erwartet: 12
```

### Schritt 4 – Abfragen und Tests ausführen

```bash
psql -d buchtausch -f queries.sql
psql -d buchtausch -f tests.sql
```

Die Negativtests in `tests.sql` sind in `DO`-Blöcke gekapselt: Sie provozieren
absichtlich einen Constraint-Fehler und geben per `NOTICE` aus, ob der jeweilige
Schutz gegriffen hat (z. B. `T1 OK: unzulässiger Zustand abgewiesen`). Das Skript
bleibt dadurch als Ganzes lauffähig.

> **Hinweis:** Die Testfälle wurden gegen PostgreSQL 16 ausgeführt und liefern die
> dokumentierten Ergebnisse. `app_user` heißt bewusst nicht `user`, da `USER` in SQL
> ein reserviertes Schlüsselwort ist.

---

## Datenmodell (Kurzfassung)

**Stammdaten:** `address`, `app_user`, `publisher`, `language`, `genre`, `author`
**Buchbestand:** `book`, `book_copy`, `book_image`
**Übergabe:** `pickup_location`, `time_slot`
**Transaktionen:** `loan`, `loan_status_history`, `reservation`, `review`
**Kommunikation:** `message`, `notification`
**Verknüpfungstabellen:** `book_author`, `book_genre`, `wishlist`, `pickup_offer`

Die Trennung von `book` (Titel) und `book_copy` (physisches Exemplar) vermeidet
Redundanz; `loan_status_history` protokolliert jeden Statuswechsel einer Ausleihe
als Audit-Trail.
