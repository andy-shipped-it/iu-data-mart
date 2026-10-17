-- ============================================================
-- Buchtausch-App – Datenbankschema (PostgreSQL)
-- Portfolio DLBDSPBDM01_D – Phase 2 (Erarbeitungsphase)
-- ============================================================
-- Konventionen:
--   * snake_case fuer Tabellen und Spalten
--   * SERIAL fuer kuenstliche Primaerschluessel
--   * Verknuepfungstabellen mit zusammengesetztem Primaerschluessel
--   * CHECK-Constraints mit explizit erlaubten Werten
-- ============================================================

-- ---------- Stammdaten / Basisentitaeten --------------------

CREATE TABLE address (
    address_id   SERIAL PRIMARY KEY,
    street       VARCHAR(100) NOT NULL,
    house_no     VARCHAR(10)  NOT NULL,
    zip_code     VARCHAR(10)  NOT NULL,
    city         VARCHAR(50)  NOT NULL,
    latitude     DECIMAL(9,6) NOT NULL,
    longitude    DECIMAL(9,6) NOT NULL
);

CREATE TABLE app_user (
    user_id       SERIAL PRIMARY KEY,
    role          VARCHAR(20)  NOT NULL DEFAULT 'user'
                  CHECK (role IN ('user', 'admin')),
    is_active     BOOLEAN      NOT NULL DEFAULT TRUE,
    first_name    VARCHAR(50)  NOT NULL,
    last_name     VARCHAR(50)  NOT NULL,
    email         VARCHAR(100) NOT NULL UNIQUE,
    phone         VARCHAR(20),
    address_id    INTEGER      REFERENCES address(address_id),
    registered_at DATE         NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE publisher (
    publisher_id SERIAL PRIMARY KEY,
    name         VARCHAR(100) NOT NULL,
    city         VARCHAR(50)
);

CREATE TABLE language (
    language_id SERIAL PRIMARY KEY,
    name        VARCHAR(30) NOT NULL,
    iso_code    CHAR(2)     NOT NULL UNIQUE
);

CREATE TABLE genre (
    genre_id SERIAL PRIMARY KEY,
    name     VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE author (
    author_id  SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(50) NOT NULL,
    birth_year SMALLINT
);

-- ---------- Buch und Exemplar -------------------------------

CREATE TABLE book (
    book_id          SERIAL PRIMARY KEY,
    title            VARCHAR(200) NOT NULL,
    isbn             VARCHAR(17)  UNIQUE,
    publication_year SMALLINT,
    publisher_id     INTEGER REFERENCES publisher(publisher_id),
    language_id      INTEGER REFERENCES language(language_id)
);

CREATE TABLE book_copy (
    copy_id           SERIAL PRIMARY KEY,
    book_id           INTEGER NOT NULL REFERENCES book(book_id),
    owner_id          INTEGER NOT NULL REFERENCES app_user(user_id),
    condition         VARCHAR(20) NOT NULL
                      CHECK (condition IN ('new','very_good','good','acceptable','poor')),
    max_loan_days     SMALLINT NOT NULL DEFAULT 30 CHECK (max_loan_days > 0),
    shipping_possible BOOLEAN  NOT NULL DEFAULT FALSE,
    available         BOOLEAN  NOT NULL DEFAULT TRUE
);

CREATE TABLE book_image (
    image_id   SERIAL PRIMARY KEY,
    book_id    INTEGER NOT NULL REFERENCES book(book_id),
    url        VARCHAR(255) NOT NULL,
    sort_order SMALLINT NOT NULL DEFAULT 1
);

-- ---------- Uebergabe: Orte und Zeitfenster -----------------

CREATE TABLE pickup_location (
    location_id SERIAL PRIMARY KEY,
    label       VARCHAR(100) NOT NULL,
    address_id  INTEGER NOT NULL REFERENCES address(address_id)
);

CREATE TABLE time_slot (
    slot_id   SERIAL PRIMARY KEY,
    weekday   SMALLINT NOT NULL CHECK (weekday BETWEEN 1 AND 7),
    from_time TIME NOT NULL,
    to_time   TIME NOT NULL,
    CHECK (from_time < to_time)
);

-- ---------- Transaktionen: Ausleihe, Reservierung -----------

CREATE TABLE loan (
    loan_id     SERIAL PRIMARY KEY,
    copy_id     INTEGER NOT NULL REFERENCES book_copy(copy_id),
    borrower_id INTEGER NOT NULL REFERENCES app_user(user_id),
    slot_id     INTEGER NOT NULL REFERENCES time_slot(slot_id),
    borrowed_at DATE NOT NULL DEFAULT CURRENT_DATE,
    due_at      DATE NOT NULL,
    returned_at DATE,
    status      VARCHAR(20) NOT NULL DEFAULT 'requested'
                CHECK (status IN ('requested','confirmed','borrowed','returned','cancelled')),
    CHECK (due_at >= borrowed_at),
    CHECK (returned_at IS NULL OR returned_at >= borrowed_at)
);

-- Protokolliert jeden Statuswechsel einer Ausleihe (Historie)
CREATE TABLE loan_status_history (
    history_id  SERIAL PRIMARY KEY,
    loan_id     INTEGER NOT NULL REFERENCES loan(loan_id),
    old_status  VARCHAR(20),
    new_status  VARCHAR(20) NOT NULL
                CHECK (new_status IN ('requested','confirmed','borrowed','returned','cancelled')),
    changed_by  INTEGER REFERENCES app_user(user_id),
    changed_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Dreifachbeziehung: app_user x book_copy x time_slot
CREATE TABLE reservation (
    reservation_id SERIAL PRIMARY KEY,
    user_id        INTEGER NOT NULL REFERENCES app_user(user_id),
    copy_id        INTEGER NOT NULL REFERENCES book_copy(copy_id),
    slot_id        INTEGER NOT NULL REFERENCES time_slot(slot_id),
    reserved_at    DATE NOT NULL DEFAULT CURRENT_DATE,
    expires_at     DATE NOT NULL,
    status         VARCHAR(20) NOT NULL DEFAULT 'pending'
                   CHECK (status IN ('pending','confirmed','cancelled','expired')),
    UNIQUE (user_id, copy_id, slot_id)
);

-- ---------- Bewertungen -------------------------------------

CREATE TABLE review (
    review_id  SERIAL PRIMARY KEY,
    loan_id    INTEGER NOT NULL REFERENCES loan(loan_id),
    book_id    INTEGER NOT NULL REFERENCES book(book_id),
    user_id    INTEGER NOT NULL REFERENCES app_user(user_id),
    stars      SMALLINT NOT NULL CHECK (stars BETWEEN 1 AND 5),
    comment    TEXT,
    created_at DATE NOT NULL DEFAULT CURRENT_DATE
);

-- ---------- Kommunikation & Benachrichtigung ----------------

CREATE TABLE message (
    message_id  SERIAL PRIMARY KEY,
    sender_id   INTEGER NOT NULL REFERENCES app_user(user_id),
    receiver_id INTEGER NOT NULL REFERENCES app_user(user_id),
    body        TEXT NOT NULL,
    sent_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_read     BOOLEAN NOT NULL DEFAULT FALSE,
    CHECK (sender_id <> receiver_id)
);

CREATE TABLE notification (
    notification_id SERIAL PRIMARY KEY,
    user_id         INTEGER NOT NULL REFERENCES app_user(user_id),
    loan_id         INTEGER REFERENCES loan(loan_id),
    reservation_id  INTEGER REFERENCES reservation(reservation_id),
    type            VARCHAR(30) NOT NULL
                    CHECK (type IN ('loan_requested','loan_confirmed','loan_returned',
                                    'reservation_expiring','message_received','system')),
    body            VARCHAR(255) NOT NULL,
    is_read         BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ---------- Verknuepfungstabellen (m:n) ---------------------

CREATE TABLE book_author (
    book_id   INTEGER NOT NULL REFERENCES book(book_id),
    author_id INTEGER NOT NULL REFERENCES author(author_id),
    PRIMARY KEY (book_id, author_id)
);

CREATE TABLE book_genre (
    book_id  INTEGER NOT NULL REFERENCES book(book_id),
    genre_id INTEGER NOT NULL REFERENCES genre(genre_id),
    PRIMARY KEY (book_id, genre_id)
);

-- Dreifachbeziehung: book_copy x pickup_location x time_slot
CREATE TABLE pickup_offer (
    copy_id     INTEGER NOT NULL REFERENCES book_copy(copy_id),
    location_id INTEGER NOT NULL REFERENCES pickup_location(location_id),
    slot_id     INTEGER NOT NULL REFERENCES time_slot(slot_id),
    PRIMARY KEY (copy_id, location_id, slot_id)
);

-- Merkliste: m:n zwischen app_user und book
CREATE TABLE wishlist (
    user_id  INTEGER NOT NULL REFERENCES app_user(user_id),
    book_id  INTEGER NOT NULL REFERENCES book(book_id),
    added_at DATE NOT NULL DEFAULT CURRENT_DATE,
    PRIMARY KEY (user_id, book_id)
);
