create database project_hosp;
use project_hosp;

-- TABLE CRERATION:

create table patient(Id varchar(50) PRIMARY KEY,BIRTHDATE varchar(20),FIRST varchar(30),LAST varchar(30),GENDER varchar(30),CITY varchar(30),
STATE varchar(30),ZIP varchar(30));
select * from patient limit 10;

UPDATE patient SET BIRTHDATE = str_to_date(BIRTHDATE,'%m/%d/%Y');
ALTER TABLE patient MODIFY BIRTHDATE DATE;

-- TABLE CRERATION:

create table organizations(Id varchar(50) PRIMARY KEY,NAME varchar(100),ADDRESS varchar(100),CITY varchar(50),STATE varchar(30),ZIP varchar(30));
select * from organizations;

-- TABLE CRERATION:

create table payers(Id varchar(50) PRIMARY KEY,NAME varchar(100),CITY varchar(50),STATE_HEADQUARTERED varchar(30),PHONE varchar(20));
select * from payers;

-- TABLE CRERATION:

Create Table encounters (
    Id VARCHAR(50) PRIMARY KEY,
    START VARCHAR(30),
    STOP VARCHAR(30),
    PATIENT VARCHAR(50),
    ORGANIZATION VARCHAR(50),
    PAYER VARCHAR(50),
    ENCOUNTERCLASS VARCHAR(30),
    DESCRIPTION VARCHAR(200),
    BASE_ENCOUNTER_COST DECIMAL(10,2),
    TOTAL_CLAIM_COST DECIMAL(10,2),
    PAYER_COVERAGE DECIMAL(10,2),
    REASONDESCRIPTION VARCHAR(200)
);
select * from encounters limit 10;

-- TABLE CRERATION:

create  table procedures (
    START VARCHAR(30),
    STOP VARCHAR(30),
    PATIENT VARCHAR(50),
    ENCOUNTER VARCHAR(50),
    DESCRIPTION VARCHAR(200),
    BASE_COST DECIMAL(10,2),
    REASONDESCRIPTION VARCHAR(200)
);
select * from procedures limit 10 ;

use project_hosp;
SELECT 'patient' AS table_name, COUNT(*) AS total_rows FROM patient
UNION ALL
SELECT 'organizations', COUNT(*) FROM organizations
UNION ALL
SELECT 'payers', COUNT(*) FROM payers
UNION ALL
SELECT 'encounters', COUNT(*) FROM encounters
UNION ALL
SELECT 'procedures', COUNT(*) FROM procedures;

SELECT GENDER, COUNT(*) AS total FROM patient GROUP BY GENDER;
SELECT CITY, COUNT(*) AS total FROM patient GROUP BY CITY ORDER BY total DESC LIMIT 10;
SELECT ENCOUNTERCLASS, COUNT(*) AS total FROM encounters GROUP BY ENCOUNTERCLASS ORDER BY total DESC;
SELECT ENCOUNTERCLASS,
    ROUND(AVG(TOTAL_CLAIM_COST), 2) AS avg_cost,
    ROUND(SUM(TOTAL_CLAIM_COST), 2) AS total_cost FROM encounters GROUP BY ENCOUNTERCLASS;
    
SELECT 
    p.NAME AS insurance_name,
    COUNT(e.Id) AS total_encounters,
    ROUND(SUM(e.PAYER_COVERAGE), 2) AS total_coverage,
    ROUND(AVG(e.TOTAL_CLAIM_COST), 2) AS avg_claim_cost
FROM encounters e
JOIN payers p ON e.PAYER = p.Id
GROUP BY p.NAME
ORDER BY total_coverage DESC;

SELECT DESCRIPTION, COUNT(*) AS total,
ROUND(AVG(BASE_COST), 2) AS avg_cost
FROM procedures
GROUP BY DESCRIPTION
ORDER BY total DESC
LIMIT 10;

SELECT p.FIRST, p.LAST, e.ENCOUNTERCLASS FROM patient p JOIN encounters e ON p.Id = e.PATIENT;

-- Patients table null check
SELECT 
    SUM(CASE WHEN Id IS NULL THEN 1 ELSE 0 END) AS null_id,
    SUM(CASE WHEN BIRTHDATE IS NULL THEN 1 ELSE 0 END) AS null_birthdate,
    SUM(CASE WHEN FIRST IS NULL THEN 1 ELSE 0 END) AS null_first,
    SUM(CASE WHEN LAST IS NULL THEN 1 ELSE 0 END) AS null_last,
    SUM(CASE WHEN GENDER IS NULL THEN 1 ELSE 0 END) AS null_gender,
    SUM(CASE WHEN CITY IS NULL THEN 1 ELSE 0 END) AS null_city
FROM patient;


SELECT
    SUM(CASE WHEN TOTAL_CLAIM_COST IS NULL THEN 1 ELSE 0 END) AS null_cost,
    SUM(CASE WHEN PAYER IS NULL THEN 1 ELSE 0 END) AS null_payer,
    SUM(CASE WHEN PATIENT IS NULL THEN 1 ELSE 0 END) AS null_patient
FROM encounters;

-- Procedures null check
SELECT
    SUM(CASE WHEN DESCRIPTION IS NULL THEN 1 ELSE 0 END) AS null_desc,
    SUM(CASE WHEN BASE_COST IS NULL THEN 1 ELSE 0 END) AS null_cost,
    SUM(CASE WHEN PATIENT IS NULL THEN 1 ELSE 0 END) AS null_patient
FROM procedures;

-- Duplicate check
SELECT Id, COUNT(*) AS count
FROM patient
GROUP BY Id
HAVING COUNT(*) > 1;

SELECT COUNT(*) AS invalid_dates
FROM encounters
WHERE START > NOW();

-- Cost negative values check
SELECT COUNT(*) AS negative_costs
FROM encounters
WHERE TOTAL_CLAIM_COST < 0 OR BASE_ENCOUNTER_COST < 0;
