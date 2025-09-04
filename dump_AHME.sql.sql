DROP TABLE IF EXISTS adherent CASCADE;
DROP TABLE IF EXISTS tournoi CASCADE;
DROP TABLE IF EXISTS arme CASCADE;
DROP TABLE IF EXISTS style CASCADE;
DROP TABLE IF EXISTS club CASCADE;
DROP TABLE IF EXISTS discipline CASCADE;
DROP TABLE IF EXISTS maitre_arme CASCADE;
DROP TABLE IF EXISTS cree CASCADE;
DROP TABLE IF EXISTS licence_competition CASCADE;
DROP TABLE IF EXISTS licence CASCADE;
DROP TABLE IF EXISTS renouvellement CASCADE;
DROP TABLE IF EXISTS organise CASCADE;
DROP TABLE IF EXISTS participe CASCADE;
DROP TABLE IF EXISTS juge CASCADE;

CREATE TABLE adherent (
    n_adh serial primary key,
    nom varchar(25) NOT NULL,
    prenom varchar(25) NOT NULL,
    sexe char(1),
    date_de_naissance date,
	email VARCHAR(320) UNIQUE NOT NULL,
	hash_pw VARCHAR(255) NOT NULL
);

CREATE TABLE arme (
    typearme varchar(25) primary key
);

CREATE TABLE tournoi (
    n_tournoi serial primary key,
    nbmax int NOT NULL,
    type_arbitrage varchar(25),
    prix int,
    frais_inscription int, 
    niv_protection varchar(4),
    lieu varchar(20),
    date date NOT NULL,
	typearme varchar(25) references arme(typearme),
    validation_arbitre boolean,
    n_adh_arbitre int REFERENCES adherent(n_adh),
    CHECK (niv_protection IN ('350N', '800N'))
);


CREATE TABLE style (
    typestyle varchar(50) primary key
);

CREATE TABLE club (
    code serial primary key,
    nom varchar(25) UNIQUE,
    adresse varchar(100),
    descriptif text,
    logo character varying(25) DEFAULT 'default.jpg'
);

CREATE TABLE discipline (
    code int REFERENCES club(code),
    typearme varchar(25) references arme(typearme),
    typestyle varchar(50) REFERENCES style(typestyle),
    PRIMARY KEY(code, typearme, typestyle)
);

CREATE TABLE maitre_arme (
    idma serial primary key,
	code int,
    typearme varchar(25),
    typestyle varchar(50),
    n_adh int REFERENCES adherent(n_adh),
    FOREIGN KEY (code, typearme, typestyle) REFERENCES discipline(code, typearme, typestyle)
);

CREATE TABLE cree (
	idma int REFERENCES maitre_arme(idma),
	code int REFERENCES club(code),
	PRIMARY KEY (idma, code)
);

CREATE TABLE licence_competition (
    n_lic_compet serial primary key
);

CREATE TABLE licence (
    n_licence serial primary key,
    n_lic_compet int REFERENCES licence_competition(n_lic_compet),
    code int REFERENCES club(code)
);

CREATE TABLE renouvellement (
    annee int,
    validation_renouv boolean,
    n_licence int REFERENCES licence(n_licence),
    n_adh int REFERENCES adherent(n_adh),
    code int REFERENCES club(code),
    primary key (annee, n_licence, n_adh)
);

CREATE TABLE organise (
    idma int REFERENCES maitre_arme(idma),
    code int REFERENCES club(code),
    n_tournoi int REFERENCES tournoi(n_tournoi),
    primary key (idma, code, n_tournoi)
);

CREATE TABLE participe (
    n_lic_compet int REFERENCES licence_competition(n_lic_compet),
    n_tournoi int REFERENCES tournoi(n_tournoi),
    primary key (n_lic_compet, n_tournoi)
);

CREATE TABLE juge (
    n_adh int REFERENCES adherent(n_adh),
    n_tournoi int REFERENCES tournoi(n_tournoi),
    validation_juge boolean NOT NULL,
    primary key (n_adh, n_tournoi)
);


--- Filling table adherent : 

INSERT INTO adherent (nom, prenom, sexe, date_de_naissance, email, hash_pw)
VALUES
('Ginola', 'David', 'H', '2005-08-12','david.ginola@gmail.com','$2b$12$ZkVMTQ0NNi/JFBYWpBOH9uxMfYtdc9dMcsldZgMpf56oOirO.qS3m'), 
('Marques', 'Cris', 'H', '2003-06-30','cris.marques@gmail.com','$2b$12$0Dt2b7YK1jfmk4D/BHrTtuDCyr27P3auA77e4iAsCpAaR.gFuowbu'),
('Messi', 'Lionel', 'H', '1986-07-26','lionel.messi@gmail.com','$2b$12$SOGO/ITmYfmJ/Wv24fKLKueAVi1iNCpNJjls5qGjx26sj1Xe85I42'),
('Yamal', 'Lamine', 'H', '2007-07-13','lamine.yamal@gmail.com','$2b$12$VfE7lGpOx3msMea8RU5kN.cTNYtXQx6.FgyQkgf8ryy8vGFA5b/zu'),
('Bakambu', 'Cedric', 'H', '2001-02-12','cedric.bakambu@gmail.com','$2b$12$EAGXk0cnbbyqwHpz1.4AUuxlHN7F2EVyvSrVoB.JmfPpuE4QeInjC'),
('Cherki', 'Rayan', 'H', '2003-09-12','rayan.cherki@gmail.com','$2b$12$nKLl5n.D7RDgCeekR8igLu9pHNUf0Gm4pQn7atBYvRw/yF21gNu6.'),
('Scofield', 'Mickeal', 'H', '1998-05-04','mickeal.scofield@gmail.com','$2b$12$8iFIhZTLa5Peksmig7GI2e51xnJRyolFU93.R8OxTDttHZjZ4O6XC'),
('Di Caprio', 'Leonardo', 'H', '1997-11-15','leonardo.dicaprio@gmail.com','$2b$12$J6W55Nc8.sSvJRSDh33X8u/schdkiyR.riC8oGyPyQrmQJbXGKhAq'),
('Maradona', 'Diego','H', '2002-01-23','diego.maradona@gmail.com','$2b$12$C490wdLhJVSL.QJZr9Ry.OAVvANgtu1/P9MkzfTpBaCZHL8dQgtAS'),
('Iniesta', 'Andres', 'H', '2001-03-18','andres.iniesta@gmail.com','$2b$12$CeQNdHBHtNziwDGc/5CZyO.U5XlK2L6KAcXDxk4YC7sulgVF9oN1a'),
('Saka', 'Bukayo', 'H', '2004-02-29','bukayo.saka@gmail.com', '$2b$12$mO9I/2is6HE.wpedQaSJCuiqeSdlGRg/b74LsEw6u0tHp/nNHyCNS'),
('Palmer', 'Cole', 'H', '2001-12-21','cole.palmer@gmail.com','$2b$12$sQR8YGYFdGs.A077R9BrreUYkfYnwdRh7Np9hb4bPscsHDcVbNODO'),
('Mahrez', 'Ryiad','H', '2000-06-15','ryiad.mahrez@gmail.com','$2b$12$Z2pM0MTVeFom37N/vug.2.muFGdIoc20mv9QH8Fo5wOWo3LWnnjqC'),
('Dubois', 'Emma', 'F', '2005-04-14','emma.dubois@gmail.com','$2b$12$Ib/DwLvxgiuOghZlEx3QMeadckY0.hKeRrFYqMY9W6EnKRiaxGMiq'),
('Garnier', 'Sophie', 'F', '2003-08-19','sophie.garnier@gmail.com','$2b$12$xuWwhXSeWKVgKr/TiWrKmegD1vfA0qZoS7lye2T1EAVEIGQl.fUIm'),
('Morel', 'Clara', 'F', '1999-01-22','clara.morel@gmail.com','$2b$12$iDCidviMe3ygHDGAUD9nnu0DpOPL8biOEA5ns/offYe8wejGeIRUS'),
('Bernard', 'Léa', 'F', '2007-06-30','lea.bernard@gmail.com','$2b$12$9DU3CO3bUrQtx6arl/WJBeCfMG2hfpJBAQlkmwwPo6EjiH.GrBJra'),
('Martin', 'Camille', 'F', '2004-09-05','camille.martin@gmail.com','$2b$12$zHbNNXjr/RjT0YoEgVlD3uHgQ7P7FimHDwEmNmBC33yAFIDB5GQDi'),
('Simon', 'Julie', 'F', '2001-12-12','julie.simon@gmail.com','$2b$12$5PR5iR063Y8W4VhMO/Vt..ecopaQ7BNgRUjtUDMqrIyTJZvKq7YXe'),
('Lefèvre', 'Chloé', 'F', '2002-03-17','chloe.lefevre@gmail.com','$2b$12$vxThhmo8ZojlzHiToXLgo.5I07/TtYLS0uCjywAtsqY7XOKQbDq5K'),
('Rousseau', 'Sarah', 'F', '1998-11-28','sarah.rousseau@gmail.com','$2b$12$PZNTtZF274YXZxb6KK/pJOuiO31egjj9BPVfsO0v8qkcswb.QS3yy'),
('Petit', 'Manon', 'F', '2000-07-08','manon.petit@gmail.com','$2b$12$RInM.zvFLem4WtsI9yVzHOegLBn2/jyCOtmj3oevWDud5Kb0D/lVq'),
('Leroy', 'Alice', 'F', '1997-02-03','alice.leroy@gmail.com','$2b$12$CC2nzw8eky1GBZ2dZ2gFMeMhvKcj/YVCBDJGdzQunP7vSoBcefV1G'),
('Robin', 'Anaïs', 'F', '2006-10-21','anais.robin@gmail.com','$2b$12$gx/DBz0qCuaSwPpwK3jXdulTXSVxi1E3ta8SHJjRh7Ci9g7/bMIO.'),
('Charline', 'Celine', 'F', '2008-05-16','celine.charline@gmail.com','$2b$12$ds.ch9OP5dfiMgt/AU7SouVcJzMroJ.sAHo/q5lZtqYRr.JRfqGzC');

--- Filling table arme :

INSERT INTO arme (typearme)
VALUES
('Epée longue'),
('Dague'),
('Epée et dague'),
('Epée bocle'); 

--- Filling table tournoi :

INSERT INTO tournoi (nbmax, type_arbitrage, prix, frais_inscription, niv_protection, lieu, date, typearme, validation_arbitre, n_adh_arbitre)
VALUES
(4,'avantage à l’attaquant', 200, 5, '800N', 'Paris', '2024-11-20', 'Epée longue', TRUE, 2),
(6,'nul', 500, 10, '350N', 'Londres', '2024-12-10', 'Dague', TRUE, 4),
(4,'double point', 300, 7, '350N', 'Cancùn', '2025-01-09', 'Epée et dague', TRUE, 2),
(6,'double point', 200, 10, '350N', 'Tokyo', '2024-12-30', 'Epée longue', TRUE, 8),
(4,'avantage à l’attaquant', 100, 5, '800N', 'Washington', '2018-01-15', 'Epée bocle', TRUE, 20), 
(6,'avantage à l’attaquant', 250, 8, '350N', 'Madrid', '2022-02-05', 'Dague', TRUE, 4), 
(4,'nul', 180, 6, '350N', 'Rome', '2025-03-12', 'Epée et dague', TRUE, 7),
(4,'avantage à l’attaquant', 300, 9, '800N', 'Dubaï', '2023-04-20', 'Dague', TRUE, 14);

--- Filling table style :

INSERT INTO style (typestyle)
VALUES 
('Johannes Lichtenauer'),
('Fiore del Liberi'),
('Joachim Meyer'),
('Albrecht Dürer');

--- Filling table club : 

INSERT INTO club (nom, adresse, descriptif, logo)
VALUES
('Paris Club', '12 rue de Paris', 'Viens découvrir la pratique de l''épée longue façon Johannes Lichtenauer dans le Paris Club !!', 'Paris Club.jpg'),
('London Club', '22 London Street', 'Envie d''apprendre à manier la dague ? Rejoins nous dans le London Club pour l''apprendre à la façon Fiore del Liberi !', 'London Club.jpg'),
('Tokyo Club', '34 Tokyo Avenue', 'Au Tokyo Club, on exerce l''épée et dague façon Albrecht Dürer, alors si tu es en quête de nouvelles choses à apprendre, bienvenue !', 'Tokyo Club.jpg'),
('Berlin Club', '50 Munich Street', 'Bienvenue au Berlin Club où on vous enseigne l''épée bocle façon Johannes Lichtenauer !','Berlin Club.jpg'),
('Rome Club', '18 Via Roma', 'Envie d''apprendre à manier l''épée longue ? Rejoins nous dans le Rome Club pour l''apprendre à la façon Fiore del Liberi !','Rome Club.jpg'),
('Sydney Club', '10 Surf Street', 'Viens découvrir la pratique de l''épée longue façon Joachim Meyer dans le Sydney Club !!','Sydney Club.jpg');

--- Filling table discipline : 

INSERT INTO discipline (code, typearme, typestyle)
VALUES
(1, 'Epée longue', 'Johannes Lichtenauer'), 
(2, 'Dague', 'Fiore del Liberi'),
(3, 'Epée et dague', 'Albrecht Dürer'),
(4, 'Epée bocle', 'Johannes Lichtenauer'),
(5, 'Dague', 'Joachim Meyer'),
(6, 'Epée longue','Joachim Meyer');

--- Filling table maitre_arme :

INSERT INTO maitre_arme (code, typearme, typestyle, n_adh)
VALUES
(4, 'Epée bocle', 'Johannes Lichtenauer', 1),
(4, 'Epée bocle','Johannes Lichtenauer', 7),
(3, 'Epée et dague', 'Albrecht Dürer', 10),
(3, 'Epée et dague', 'Albrecht Dürer', 12),
(3, 'Epée et dague', 'Albrecht Dürer', 19), 
(2, 'Dague', 'Fiore del Liberi', 11),
(2, 'Dague', 'Fiore del Liberi', 2),
(5, 'Dague', 'Joachim Meyer', 5), 
(5, 'Dague', 'Joachim Meyer', 13),
(1, 'Epée longue', 'Johannes Lichtenauer', 1),
(1, 'Epée longue', 'Johannes Lichtenauer', 3),
(6, 'Epée longue', 'Joachim Meyer', 6),
(6, 'Epée longue', 'Joachim Meyer', 14);

--- Filling table cree :
INSERT INTO cree (idma, code) VALUES
(1,1),
(7,2),
(5,3),
(2,4),
(9,5),
(12,6);

--- Filling table licence_competition : 

INSERT INTO licence_competition (n_lic_compet) VALUES
(1),
(2),
(3),
(4),
(5),
(6),
(7),
(8),
(9),
(10),
(11),
(12),
(13),
(14),
(15),
(16),
(17),
(18),
(19),
(20),
(21),
(22),
(23),
(24),
(25),
(26);

--- Filling table licence :

INSERT INTO licence (n_lic_compet, code)
VALUES
(NULL, 1),
(1, 2),
(2, 1),
(3, 3),
(NULL, 5),
(4, 6),
(5, 4),
(6, 3),
(7, 5),
(8, 3),
(9, 2),
(10, 3),
(11, 5),
(NULL, 6),
(12, 1),
(13, 4),
(26, 5),
(14, 2),
(NULL, 3),
(15, 2),
(16, 6),
(NULL, 4),
(17, 6),
(18, 4),
(19, 1),
(20, 6),
(21, 4),
(22, 4),
(23, 4),
(24, 3),
(25, 3);

--- Filling table renouvellement : 

INSERT INTO renouvellement (annee, validation_renouv, n_licence, n_adh, code)
VALUES
(2022, TRUE, 1, 1, 1),
(2024, TRUE, 1, 1, 1),
(2024, TRUE, 2, 2, 2),
(2024, TRUE, 3, 3, 1),
(2024, TRUE, 4, 4, 3),
(2024, TRUE, 5, 5, 5),
(2023, TRUE, 6, 6, 6),
(2024, TRUE, 6, 6, 6),
(2024, TRUE, 7, 7, 4),
(2024, TRUE, 8, 8, 3),
(2022, TRUE, 9, 9, 5),
(2023, TRUE, 9, 9, 5),
(2024, TRUE, 9, 9, 5),
(2024, TRUE, 10, 10, 3),
(2024, TRUE, 11, 11, 2),
(2024, TRUE, 12, 12, 3),
(2024, TRUE, 13, 13, 5),
(2024, TRUE, 14, 14, 6),
(2024, TRUE, 15, 15, 1),
(2022, TRUE, 15, 15, 1),
(2016, TRUE, 16, 16, 4),
(2024, TRUE, 16, 16, 4),
(2024, TRUE, 17, 17, 5),
(2023, TRUE, 18, 18, 2),
(2024, TRUE, 18, 18, 2),
(2024, TRUE, 19, 19, 3),
(2024, TRUE, 20, 20, 2),
(2023, TRUE, 21, 21, 6),
(2024, TRUE, 21, 21, 6),
(2024, TRUE, 22, 22, 4),
(2024, TRUE, 23, 23, 6),
(2023, TRUE, 24, 24, 4),
(2024, TRUE, 24, 24, 4),
(2023, TRUE, 25, 25, 1),
(2024, TRUE, 25, 25, 1),
(2024, TRUE, 26, 1, 6),
(2024, TRUE, 27, 3, 4),
(2024, TRUE, 28, 10, 4),
(2024, TRUE, 29, 21, 4),
(2024, TRUE, 30, 9, 3),
(2024, TRUE, 31, 23, 3);

--- Filling table organise : 

INSERT INTO organise (idma, code, n_tournoi)
VALUES
(1, 1, 1),
(11, 1, 2), 
(5, 3, 3),
(7, 2, 4), 
(2, 4, 5),
(3, 3, 6),
(8, 5, 7),
(13, 6, 8);

--- Filling table participe :

INSERT INTO participe (n_lic_compet, n_tournoi)
VALUES 
(20,1),
(4, 1),
(12, 1),
(16, 1),
(1, 2),
(7, 2),
(11, 2),
(14, 2),
(15, 2),
(26, 2),
(3, 3),
(6, 3),
(24, 3),
(25, 3),
(20, 4),
(2, 4),
(16, 4),
(17, 4),
(19, 4),
(4, 4),
(18, 5),
(5, 5),
(22, 5), 
(13, 5),
(1, 6),
(7, 6),
(9, 6),
(26, 6),
(14, 6),
(15, 6),
(3, 7),
(6, 7),
(10, 7),
(25, 7),
(1, 8),
(7, 8),
(14, 8);

--- Filling table juge :

INSERT INTO juge (n_adh, n_tournoi, validation_juge)
VALUES
(3, 1, TRUE),
(5, 1, FALSE),
(6, 1, TRUE),
(7, 1, TRUE),
(9, 1, TRUE),
(11, 2, TRUE),
(7, 2, TRUE),
(13, 2, TRUE),
(15, 2, TRUE),
(3, 3, TRUE),
(13, 3, FALSE),
(5, 3, TRUE),
(11, 3, TRUE),
(17, 3, TRUE),
(7, 4, TRUE),
(9, 4, TRUE),
(15, 4, TRUE),
(16, 4, TRUE),
(3, 5, TRUE),
(9, 5, TRUE),
(15, 5, FALSE),
(5, 5, FALSE),
(21, 5, TRUE),
(1, 5, TRUE),
(19, 6, TRUE),
(13, 6, TRUE),
(7, 6, TRUE),
(3, 6, TRUE),
(11, 7, TRUE),
(15, 7, TRUE),
(9, 7, TRUE),
(19, 7, FALSE),
(2, 7, TRUE),
(5, 8, TRUE),
(17, 8, TRUE),
(13, 8, TRUE),
(11,8,TRUE);


/*CREATE VIEW style_populaire AS 
(
    SELECT typestyle, typearme, count(*) AS nb_enseignement
    FROM discipline AS d1
    GROUP BY d1.typestyle, d1.typearme
    HAVING count(*) = 
    (
        SELECT max(count(*))
        FROM discipline AS d2
        WHERE d1.typearme = d2.typearme
        GROUP BY d2.typestyle
    )
); 

CREATE VIEW proportion_juge_arbitre AS
( 
    SELECT tournoi.n_tournoi, 
    count(DISTINCT j.n_adh) AS nb_juges_valides, 
    count(DISTINCT t.n_adh) AS nb_arbitres_valides, 
    count(DISTINCT j.n_adh) AS total_juges,
    count(DISTINCT t.n_adh) AS total_arbitres
    FROM tournoi AS t
    LEFT JOIN juge AS j ON j.n_tournoi = t.n_tournoi
    LEFT JOIN adherent AS a ON a.n_adh = j.n_adh
    LEFT JOIN club AS c ON c.code = a.code
    LEFT JOIN discipline AS d ON d.iddiscipline = c.code
    LEFT JOIN arme AS a2 ON a2.typearme = d.typearme
    WHERE j.validation_juge = TRUE AND t.validation_arbitre = TRUE
    GROUP BY t.n_tournoi
);

CREATE VIEW taux_de_participation AS
(
    SELECT (count(DISTINCT p.n_adh) * 1.0 / (SELECT count(DISTINCT n_adh) FROM adherent)) * 100 AS taux_participation
    FROM 
    (
        SELECT n_adh FROM juge
        UNION
        SELECT n_adh FROM participe
        UNION
        SELECT idma FROM organise
        UNION
        SELECT n_adh FROM tournoi WHERE validation_arbitre = TRUE
    ) AS p
);*/
