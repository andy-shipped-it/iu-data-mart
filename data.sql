-- ============================================================
-- Dummy-Daten fuer die Buchtausch-App
-- Mindestens 10 Eintraege je Tabelle
-- ============================================================

-- ADDRESS (12)
INSERT INTO address (street, house_no, zip_code, city, latitude, longitude) VALUES
('Hauptstrasse','12','10115','Berlin',52.531677,13.384610),
('Gartenweg','5','10247','Berlin',52.512500,13.454300),
('Lindenallee','88','20095','Hamburg',53.550341,9.992910),
('Schulstrasse','3','80331','Muenchen',48.137154,11.575490),
('Bahnhofplatz','1','50667','Koeln',50.943076,6.958600),
('Ringstrasse','44','60311','Frankfurt',50.110924,8.682127),
('Am Markt','7','01067','Dresden',51.050409,13.737262),
('Seestrasse','21','04109','Leipzig',51.339695,12.373075),
('Bergweg','9','70173','Stuttgart',48.775846,9.182932),
('Uferpromenade','15','40213','Duesseldorf',51.225402,6.776314),
('Kirchgasse','2','90402','Nuernberg',49.452103,11.076665),
('Waldstrasse','33','28195','Bremen',53.079296,8.801694);

-- APP_USER (12)
INSERT INTO app_user (role, is_active, first_name, last_name, email, phone, address_id, registered_at) VALUES
('admin',TRUE ,'Andreas','Waida','andreas.waida@example.com','+49 30 1111111',1,'2024-01-10'),
('user' ,TRUE ,'Lena'   ,'Berger','lena.berger@example.com','+49 40 2222222',2,'2024-02-15'),
('user' ,TRUE ,'Marco'  ,'Klein' ,'marco.klein@example.com','+49 89 3333333',3,'2024-03-01'),
('user' ,TRUE ,'Sofia'  ,'Neumann','sofia.neumann@example.com','+49 221 444444',4,'2024-03-20'),
('user' ,TRUE ,'Jonas'  ,'Weber' ,'jonas.weber@example.com','+49 69 5555555',5,'2024-04-05'),
('user' ,TRUE ,'Emily'  ,'Fischer','emily.fischer@example.com','+49 351 666666',6,'2024-04-18'),
('user' ,FALSE,'Tobias' ,'Schulz','tobias.schulz@example.com','+49 341 777777',7,'2024-05-02'),
('user' ,TRUE ,'Hanna'  ,'Wolf'  ,'hanna.wolf@example.com','+49 711 888888',8,'2024-05-22'),
('user' ,TRUE ,'David'  ,'Richter','david.richter@example.com','+49 211 999999',9,'2024-06-10'),
('user' ,TRUE ,'Clara'  ,'Hoffmann','clara.hoffmann@example.com','+49 911 101010',10,'2024-06-28'),
('user' ,TRUE ,'Felix'  ,'Braun' ,'felix.braun@example.com','+49 421 121212',11,'2024-07-14'),
('user' ,TRUE ,'Mia'    ,'Krueger','mia.krueger@example.com','+49 30 131313',12,'2024-08-01');

-- PUBLISHER (10)
INSERT INTO publisher (name, city) VALUES
('Heyne Verlag','Muenchen'),
('Suhrkamp','Berlin'),
('Rowohlt','Hamburg'),
('dtv','Muenchen'),
('S. Fischer','Frankfurt'),
('Penguin','Muenchen'),
('Klett-Cotta','Stuttgart'),
('Diogenes','Zuerich'),
('Piper','Muenchen'),
('Fischer Taschenbuch','Frankfurt');

-- LANGUAGE (10)
INSERT INTO language (name, iso_code) VALUES
('Deutsch','de'),('Englisch','en'),('Franzoesisch','fr'),('Spanisch','es'),
('Italienisch','it'),('Niederlaendisch','nl'),('Schwedisch','sv'),
('Polnisch','pl'),('Portugiesisch','pt'),('Russisch','ru');

-- GENRE (10)
INSERT INTO genre (name) VALUES
('Roman'),('Krimi'),('Science-Fiction'),('Fantasy'),('Sachbuch'),
('Biografie'),('Thriller'),('Kinderbuch'),('Lyrik'),('Historisch');

-- AUTHOR (12)
INSERT INTO author (first_name, last_name, birth_year) VALUES
('Ferdinand','von Schirach',1964),
('Juli','Zeh',1974),
('Sebastian','Fitzek',1971),
('Cornelia','Funke',1958),
('Daniel','Kehlmann',1975),
('Charlotte','Roche',1978),
('Frank','Schaetzing',1957),
('Nele','Neuhaus',1967),
('Bernhard','Schlink',1944),
('Terry','Pratchett',1948),
('Neil','Gaiman',1960),
('Agatha','Christie',1890);

-- BOOK (12)
INSERT INTO book (title, isbn, publication_year, publisher_id, language_id) VALUES
('Verbrechen','9783442471234',2009,1,1),
('Unterleuten','9783442471241',2016,2,1),
('Der Schwarm','9783442471258',2004,1,1),
('Tintenherz','9783442471265',2003,3,1),
('Die Vermessung der Welt','9783442471272',2005,4,1),
('Good Omens','9780060853969',1990,6,2),
('Mord im Orientexpress','9783442471289',1934,5,1),
('Der Vorleser','9783257471296',1995,8,1),
('Schnee','9783442471302',2018,9,1),
('Nachtschicht','9783442471319',2020,3,1),
('Sturmzeit','9783442471326',2012,7,1),
('Wassermusik','9783442471333',1999,10,1);

-- BOOK_COPY (14)
INSERT INTO book_copy (book_id, owner_id, condition, max_loan_days, shipping_possible, available) VALUES
(1,2,'good',30,TRUE ,TRUE),
(2,3,'very_good',21,FALSE,TRUE),
(3,4,'acceptable',30,TRUE ,TRUE),
(4,5,'new',14,FALSE,TRUE),
(5,6,'good',30,TRUE ,FALSE),
(6,8,'good',30,TRUE ,TRUE),
(7,9,'poor',30,FALSE,TRUE),
(1,10,'very_good',21,TRUE ,TRUE),
(8,11,'good',28,FALSE,TRUE),
(9,12,'new',14,TRUE ,TRUE),
(10,2,'good',30,TRUE ,TRUE),
(11,3,'acceptable',30,FALSE,FALSE),
(12,4,'very_good',21,TRUE ,TRUE),
(3,5,'good',30,TRUE ,TRUE);

-- BOOK_IMAGE (10)
INSERT INTO book_image (book_id, url, sort_order) VALUES
(1,'https://img.example.com/verbrechen.jpg',1),
(2,'https://img.example.com/unterleuten.jpg',1),
(3,'https://img.example.com/derschwarm.jpg',1),
(4,'https://img.example.com/tintenherz.jpg',1),
(5,'https://img.example.com/vermessung.jpg',1),
(6,'https://img.example.com/goodomens.jpg',1),
(7,'https://img.example.com/orientexpress.jpg',1),
(8,'https://img.example.com/dervorleser.jpg',1),
(9,'https://img.example.com/schnee.jpg',1),
(10,'https://img.example.com/nachtschicht.jpg',1);

-- PICKUP_LOCATION (10)
INSERT INTO pickup_location (label, address_id) VALUES
('Zuhause Lena',2),('Zuhause Marco',3),('Buero Sofia',4),('Cafe am Markt',7),
('Zuhause Jonas',5),('Bibliothek Dresden',6),('Zuhause Hanna',8),
('Zuhause David',9),('Zuhause Clara',10),('Zuhause Felix',11);

-- TIME_SLOT (10)
INSERT INTO time_slot (weekday, from_time, to_time) VALUES
(1,'09:00','12:00'),(1,'14:00','18:00'),(2,'10:00','13:00'),(3,'16:00','19:00'),
(4,'08:00','11:00'),(5,'15:00','18:00'),(6,'10:00','14:00'),(6,'15:00','17:00'),
(7,'11:00','13:00'),(2,'18:00','20:00');

-- LOAN (12)
INSERT INTO loan (copy_id, borrower_id, slot_id, borrowed_at, due_at, returned_at, status) VALUES
(1,3,1,'2024-09-01','2024-10-01','2024-09-20','returned'),
(2,4,3,'2024-09-05','2024-09-26',NULL,'borrowed'),
(3,5,4,'2024-09-10','2024-10-10','2024-10-02','returned'),
(4,6,5,'2024-09-15','2024-09-29',NULL,'borrowed'),
(5,8,6,'2024-09-20','2024-10-20',NULL,'confirmed'),
(6,9,7,'2024-10-01','2024-10-31','2024-10-25','returned'),
(7,10,8,'2024-10-05','2024-11-04',NULL,'requested'),
(8,11,9,'2024-10-10','2024-11-07','2024-11-01','returned'),
(9,12,1,'2024-10-12','2024-10-26',NULL,'borrowed'),
(10,2,2,'2024-10-15','2024-11-14',NULL,'cancelled'),
(11,3,3,'2024-10-18','2024-11-17','2024-11-10','returned'),
(13,4,4,'2024-10-20','2024-11-10',NULL,'borrowed');

-- LOAN_STATUS_HISTORY (12)
INSERT INTO loan_status_history (loan_id, old_status, new_status, changed_by) VALUES
(1,NULL,'requested',3),(1,'requested','confirmed',2),(1,'confirmed','borrowed',2),
(1,'borrowed','returned',2),(2,NULL,'requested',4),(2,'requested','confirmed',3),
(3,'confirmed','borrowed',4),(3,'borrowed','returned',4),(6,'borrowed','returned',9),
(10,'requested','cancelled',2),(5,NULL,'requested',8),(5,'requested','confirmed',6);

-- RESERVATION (10)
INSERT INTO reservation (user_id, copy_id, slot_id, reserved_at, expires_at, status) VALUES
(3,6,7,'2024-10-01','2024-10-08','confirmed'),
(4,7,8,'2024-10-02','2024-10-09','pending'),
(5,8,9,'2024-10-03','2024-10-10','cancelled'),
(6,9,1,'2024-10-04','2024-10-11','pending'),
(8,10,2,'2024-10-05','2024-10-12','confirmed'),
(9,11,3,'2024-10-06','2024-10-13','expired'),
(10,13,4,'2024-10-07','2024-10-14','pending'),
(11,14,5,'2024-10-08','2024-10-15','confirmed'),
(12,1,6,'2024-10-09','2024-10-16','pending'),
(2,3,7,'2024-10-10','2024-10-17','confirmed');

-- REVIEW (10)
INSERT INTO review (loan_id, book_id, user_id, stars, comment, created_at) VALUES
(1,1,3,5,'Spannend und klug erzaehlt.','2024-09-21'),
(3,3,5,4,'Toller Wissenschaftsthriller.','2024-10-03'),
(6,6,9,5,'Sehr witzig!','2024-10-26'),
(8,8,11,4,'Bewegende Geschichte.',' 2024-11-02'),
(11,11,3,3,'Solide, aber etwas lang.','2024-11-11'),
(1,1,3,4,'Zweite Lektuere, immer noch gut.','2024-11-15'),
(3,3,5,5,'Beim zweiten Mal noch besser.','2024-11-16'),
(6,6,9,4,'Klassiker.','2024-11-17'),
(8,8,11,5,'Absolute Empfehlung.','2024-11-18'),
(11,11,3,4,'Gute Charaktere.','2024-11-19');

-- MESSAGE (10)
INSERT INTO message (sender_id, receiver_id, body, is_read) VALUES
(3,2,'Hallo, ist das Buch noch verfuegbar?',TRUE),
(2,3,'Ja, gerne! Wann passt die Abholung?',TRUE),
(4,3,'Koennte ich Unterleuten leihen?',FALSE),
(6,8,'Danke fuer das Buch!',TRUE),
(9,8,'Wann kann ich vorbeikommen?',FALSE),
(10,11,'Ist Versand moeglich?',TRUE),
(12,2,'Reserviere ich das richtig?',FALSE),
(5,6,'Bis morgen dann.',TRUE),
(8,9,'Kein Problem, bis Samstag.',FALSE),
(11,10,'Alles klar, danke!',TRUE);

-- NOTIFICATION (10)
INSERT INTO notification (user_id, loan_id, reservation_id, type, body, is_read) VALUES
(2,1,NULL,'loan_requested','Neue Ausleihanfrage fuer dein Exemplar.',TRUE),
(3,1,NULL,'loan_confirmed','Deine Ausleihe wurde bestaetigt.',TRUE),
(2,1,NULL,'loan_returned','Ein Buch wurde zurueckgegeben.',FALSE),
(4,2,NULL,'loan_confirmed','Deine Ausleihe wurde bestaetigt.',FALSE),
(6,NULL,4,'reservation_expiring','Deine Reservierung laeuft bald ab.',FALSE),
(8,5,NULL,'loan_confirmed','Deine Ausleihe wurde bestaetigt.',TRUE),
(3,NULL,1,'reservation_expiring','Deine Reservierung laeuft bald ab.',FALSE),
(9,6,NULL,'loan_returned','Danke fuer die Rueckgabe.',TRUE),
(11,NULL,NULL,'message_received','Du hast eine neue Nachricht.',FALSE),
(2,NULL,NULL,'system','Willkommen bei der Buchtausch-App!',TRUE);

-- BOOK_AUTHOR (12)  (inkl. Good Omens mit zwei Autoren)
INSERT INTO book_author (book_id, author_id) VALUES
(1,1),(2,2),(3,7),(4,4),(5,5),(6,10),(6,11),(7,12),(8,9),(9,8),(10,3),(11,8);

-- BOOK_GENRE (12)
INSERT INTO book_genre (book_id, genre_id) VALUES
(1,2),(1,1),(2,1),(3,3),(3,7),(4,4),(5,1),(6,4),(7,2),(8,1),(9,2),(10,7);

-- PICKUP_OFFER (12)
INSERT INTO pickup_offer (copy_id, location_id, slot_id) VALUES
(1,1,1),(1,1,2),(2,2,3),(3,3,4),(4,5,5),(6,7,6),
(7,8,7),(8,9,8),(9,10,9),(10,1,10),(11,2,1),(13,4,3);

-- WISHLIST (10)
INSERT INTO wishlist (user_id, book_id) VALUES
(3,3),(3,6),(4,1),(5,8),(6,2),(8,9),(9,4),(10,5),(11,7),(12,10);
