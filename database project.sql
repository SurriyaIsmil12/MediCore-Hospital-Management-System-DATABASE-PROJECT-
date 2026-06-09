/*
   MEDICORE DATABASE - COMPLETE SCRIPT (FINAL VERSION)
   All foreign keys include ON DELETE CASCADE ON UPDATE CASCADE
   so that deletes/updates on parent rows propagate cleanly
   and never throw Error 1451.
    */

CREATE DATABASE IF NOT EXISTS MediCore;
USE MediCore;
SET SQL_SAFE_UPDATES = 0;

/*
   PART 1 — DDL: CREATE TABLES
    */

-- Department (no FK, root table)
CREATE TABLE Department (
    DepartmentID      INT          PRIMARY KEY,
    DepartmentName    VARCHAR(100) NOT NULL UNIQUE,
    FloorNumber       INT          CHECK (FloorNumber > 0),
    ContactExtension  VARCHAR(20)  DEFAULT 'N/A'
);

-- Doctor → Department
CREATE TABLE Doctor (
    DoctorID       INT          PRIMARY KEY,
    FirstName      VARCHAR(50),
    LastName       VARCHAR(50),
    Specialization VARCHAR(100),
    PhoneNumber    VARCHAR(15),
    Email          VARCHAR(100),
    Qualification  VARCHAR(100),
    DepartmentID   INT,

    CONSTRAINT fk_doctor_department
        FOREIGN KEY (DepartmentID)
        REFERENCES Department(DepartmentID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Patient (no FK, root table)
CREATE TABLE Patient (
    PatientID        INT          PRIMARY KEY,
    FirstName        VARCHAR(50),
    LastName         VARCHAR(50),
    Gender           VARCHAR(10),
    DateOfBirth      DATE,
    PhoneNumber      VARCHAR(20),
    Email            VARCHAR(100),
    Address          VARCHAR(255),
    BloodGroup       VARCHAR(5),
    RegistrationDate DATE,
    EmergencyContact VARCHAR(15)
);

-- Room (no FK, root table)
CREATE TABLE Room (
    RoomID             INT         PRIMARY KEY,
    RoomNumber         VARCHAR(20),
    RoomType           VARCHAR(50),
    FloorNumber        INT,
    AvailabilityStatus VARCHAR(20)
);

-- Appointment → Patient, Doctor
CREATE TABLE Appointment (
    AppointmentID   INT          PRIMARY KEY,
    PatientID       INT,
    DoctorID        INT,
    AppointmentDate DATE,
    AppointmentTime TIME,
    Status          VARCHAR(20),
    VisitReason     VARCHAR(255),

    CONSTRAINT fk_appointment_patient
        FOREIGN KEY (PatientID)
        REFERENCES Patient(PatientID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_appointment_doctor
        FOREIGN KEY (DoctorID)
        REFERENCES Doctor(DoctorID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


-- MedicalRecord → Patient, Doctor
CREATE TABLE MedicalRecord (
    RecordID      INT          PRIMARY KEY,
    PatientID     INT,
    DoctorID      INT,
    Diagnosis     VARCHAR(255),
    TreatmentPlan TEXT,
    RecordDate    DATE,

    CONSTRAINT fk_record_patient
        FOREIGN KEY (PatientID)
        REFERENCES Patient(PatientID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_record_doctor
        FOREIGN KEY (DoctorID)
        REFERENCES Doctor(DoctorID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Prescription → MedicalRecord
CREATE TABLE Prescription (
    PrescriptionID INT          PRIMARY KEY,
    RecordID       INT,
    MedicineName   VARCHAR(100),
    Dosage         VARCHAR(50),
    Duration       VARCHAR(50),
    Instructions   TEXT,

    CONSTRAINT fk_prescription_record
        FOREIGN KEY (RecordID)
        REFERENCES MedicalRecord(RecordID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Admission → Patient, Room
CREATE TABLE Admission (
    AdmissionID     INT         PRIMARY KEY,
    PatientID       INT,
    RoomID          INT,
    AdmissionDate   DATE,
    DischargeDate   DATE,
    AdmissionStatus VARCHAR(20),

    CONSTRAINT fk_admission_patient
        FOREIGN KEY (PatientID)
        REFERENCES Patient(PatientID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_admission_room
        FOREIGN KEY (RoomID)
        REFERENCES Room(RoomID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Billing → Patient, Appointment
CREATE TABLE Billing (
    BillID        INT             PRIMARY KEY,
    PatientID     INT,
    AppointmentID INT,
    TotalAmount   DECIMAL(10,2),
    BillDate      DATE,
    PaymentStatus VARCHAR(20)     DEFAULT 'Pending',

    CONSTRAINT fk_billing_patient
        FOREIGN KEY (PatientID)
        REFERENCES Patient(PatientID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_billing_appointment
        FOREIGN KEY (AppointmentID)
        REFERENCES Appointment(AppointmentID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Payment → Billing
CREATE TABLE Payment (
    PaymentID     INT             PRIMARY KEY,
    BillID        INT,
    PaymentMethod VARCHAR(50),
    PaymentDate   DATE,
    AmountPaid    DECIMAL(10,2),

    CONSTRAINT fk_payment_bill
        FOREIGN KEY (BillID)
        REFERENCES Billing(BillID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


/* 
   PART 2 — DDL: ALTER TABLE DEMONSTRATIONS
    */

-- Add / Modify / Drop a demo column
ALTER TABLE Patient ADD COLUMN Notes TEXT;
ALTER TABLE Patient MODIFY COLUMN Notes VARCHAR(500);
ALTER TABLE Patient DROP COLUMN Notes;

-- Rename table and rename back (demonstration only)
RENAME TABLE Billing TO PatientBilling;
RENAME TABLE PatientBilling TO Billing;

-- Add UNIQUE constraint on Doctor email
ALTER TABLE Doctor
ADD CONSTRAINT uq_doctor_email UNIQUE (Email);

-- Add CHECK constraint on Patient gender
ALTER TABLE Patient
ADD CONSTRAINT chk_patient_gender
CHECK (Gender IN ('Male', 'Female'));

-- Change DEFAULT for PaymentStatus
ALTER TABLE Billing
MODIFY PaymentStatus VARCHAR(20) DEFAULT 'Unpaid';

-- To DROP these constraints later (run separately, not in same script):
-- ALTER TABLE Doctor DROP INDEX uq_doctor_email;
-- ALTER TABLE Patient DROP CHECK chk_patient_gender;


/* 
   PART 3 — DML: INSERT DATA
    */

-- Department
INSERT INTO Department VALUES
(1,  'Cardiology',       3, '301'),
(2,  'Neurology',        4, '401'),
(3,  'Orthopedics',      2, '201'),
(4,  'Pediatrics',       1, '101'),
(5,  'Oncology',         5, '501'),
(6,  'Dermatology',      2, '202'),
(7,  'Radiology',        1, '102'),
(8,  'General Medicine', 1, '103'),
(9,  'Emergency',        1, '104'),
(10, 'Gynecology',       3, '302');

-- Doctor
INSERT INTO Doctor VALUES
(1,  'Ali',    'Hassan',   'Cardiologist',        '03001234567', 'ali.hassan@medicore.pk',   'MBBS FCPS', 1),
(2,  'Sara',   'Khan',     'Neurologist',          '03011234567', 'sara.khan@medicore.pk',    'MBBS MRCP', 2),
(3,  'Usman',  'Raza',     'Orthopedic Surgeon',   '03021234567', 'usman.raza@medicore.pk',   'MBBS MS',   3),
(4,  'Hira',   'Malik',    'Pediatrician',         '03031234567', 'hira.malik@medicore.pk',   'MBBS DCH',  4),
(5,  'Bilal',  'Ahmed',    'Oncologist',           '03041234567', 'bilal.ahmed@medicore.pk',  'MBBS FCPS', 5),
(6,  'Nadia',  'Siddiqui', 'Dermatologist',        '03051234567', 'nadia.sid@medicore.pk',    'MBBS DDV',  6),
(7,  'Kamran', 'Javed',    'Radiologist',          '03061234567', 'kamran.javed@medicore.pk', 'MBBS DMRD', 7),
(8,  'Rabia',  'Tariq',    'General Physician',    '03071234567', 'rabia.tariq@medicore.pk',  'MBBS',      8),
(9,  'Faisal', 'Qureshi',  'Emergency Specialist', '03081234567', 'faisal.q@medicore.pk',     'MBBS',      9),
(10, 'Zara',   'Hussain',  'Gynecologist',         '03091234567', 'zara.hussain@medicore.pk', 'MBBS FCPS', 10);

-- Patient
INSERT INTO Patient
    (PatientID, FirstName, LastName, Gender, DateOfBirth,
     PhoneNumber, Email, Address, BloodGroup, RegistrationDate, EmergencyContact)
VALUES
(1,  'Ahmed',   'Nawaz',    'Male',   '1990-05-12', '03211001001', 'ahmed@gmail.com',   'Lahore',     'O+',  '2025-01-10', '03000000001'),
(2,  'Fatima',  'Iqbal',    'Female', '1985-08-23', '03211001002', 'fatima@gmail.com',  'Karachi',    'A+',  '2025-01-12', '03000000002'),
(3,  'Hamza',   'Sheikh',   'Male',   '2000-03-07', '03211001003', 'hamza@gmail.com',   'Islamabad',  'B+',  '2025-01-15', '03000000003'),
(4,  'Aisha',   'Butt',     'Female', '1995-11-30', '03211001004', 'aisha@gmail.com',   'Faisalabad', 'AB+', '2025-01-18', '03000000004'),
(5,  'Zaid',    'Chaudhry', 'Male',   '1978-06-14', '03211001005', 'zaid@gmail.com',    'Multan',     'O-',  '2025-01-20', '03000000005'),
(6,  'Sana',    'Mirza',    'Female', '1992-09-01', '03211001006', 'sana@gmail.com',    'Rawalpindi', 'B-',  '2025-02-01', '03000000006'),
(7,  'Omar',    'Farooq',   'Male',   '1988-12-19', '03211001007', 'omar@gmail.com',    'Lahore',     'A-',  '2025-02-04', '03000000007'),
(8,  'Maryam',  'Alam',     'Female', '2005-04-25', '03211001008', 'maryam@gmail.com',  'Quetta',     'AB-', '2025-02-06', '03000000008'),
(9,  'Talha',   'Rehan',    'Male',   '1975-01-03', '03211001009', 'talha@gmail.com',   'Sialkot',    'O+',  '2025-02-10', '03000000009'),
(10, 'Nimra',   'Waheed',   'Female', '1999-07-16', '03211001010', 'nimra@gmail.com',   'Gujranwala', 'A+',  '2025-02-12', '03000000010');

-- Room
INSERT INTO Room VALUES
(1,  'R101', 'General',   1, 'Available'),
(2,  'R102', 'Private',   1, 'Occupied'),
(3,  'R201', 'General',   2, 'Available'),
(4,  'R202', 'ICU',       2, 'Occupied'),
(5,  'R301', 'Private',   3, 'Available'),
(6,  'R302', 'General',   3, 'Available'),
(7,  'R401', 'ICU',       4, 'Occupied'),
(8,  'R402', 'Private',   4, 'Available'),
(9,  'R501', 'Emergency', 5, 'Available'),
(10, 'R502', 'General',   5, 'Available');

-- Appointment
INSERT INTO Appointment VALUES
(1,  1,  1,  '2025-03-01', '09:00:00', 'Completed', 'Chest pain'),
(2,  2,  2,  '2025-03-02', '10:00:00', 'Completed', 'Headache'),
(3,  3,  3,  '2025-03-03', '11:00:00', 'Scheduled', 'Knee pain'),
(4,  4,  4,  '2025-03-04', '09:30:00', 'Completed', 'Child fever'),
(5,  5,  5,  '2025-03-05', '14:00:00', 'Completed', 'Lump checkup'),
(6,  6,  6,  '2025-03-06', '12:00:00', 'Cancelled', 'Skin rash'),
(7,  7,  7,  '2025-03-07', '15:00:00', 'Completed', 'X-ray followup'),
(8,  8,  8,  '2025-03-08', '10:30:00', 'Scheduled', 'General checkup'),
(9,  9,  9,  '2025-03-09', '08:00:00', 'Completed', 'Accident injuries'),
(10, 10, 10, '2025-03-10', '11:30:00', 'Completed', 'Prenatal checkup');

-- MedicalRecord
INSERT INTO MedicalRecord VALUES
(1,  1,  1,  'Hypertension',       'Blood pressure medication prescribed', '2025-03-01'),
(2,  2,  2,  'Migraine',           'Pain relief and rest advised',          '2025-03-02'),
(3,  3,  3,  'Knee Ligament Tear', 'Physiotherapy recommended',             '2025-03-03'),
(4,  4,  4,  'Viral Fever',        'Paracetamol and fluids advised',        '2025-03-04'),
(5,  5,  5,  'Breast Lump',        'Biopsy ordered',                        '2025-03-05'),
(6,  6,  6,  'Eczema',             'Steroid cream prescribed',              '2025-03-06'),
(7,  7,  7,  'Fractured Rib',      'X-ray done rest advised',               '2025-03-07'),
(8,  8,  8,  'Common Cold',        'Antihistamines prescribed',             '2025-03-08'),
(9,  9,  9,  'Head Injury',        'CT scan ordered',                       '2025-03-09'),
(10, 10, 10, 'Pregnancy 20 weeks', 'Vitamins and checkup schedule given',   '2025-03-10');

-- Prescription
INSERT INTO Prescription VALUES
(1,  1,  'Amlodipine',          '5mg',              '30 days', 'Take once daily after breakfast'),
(2,  2,  'Ibuprofen',           '400mg',             '7 days',  'Take after meals'),
(3,  3,  'Diclofenac Gel',      'Apply thin layer',  '14 days', 'Apply on knee twice daily'),
(4,  4,  'Paracetamol',         '500mg',             '5 days',  'Take every 6 hours'),
(5,  5,  'Vitamin D',           '1000IU',            '60 days', 'Take once daily'),
(6,  6,  'Betamethasone Cream', 'Apply small amount','10 days', 'Apply affected area'),
(7,  7,  'Tramadol',            '50mg',              '7 days',  'Take as needed'),
(8,  8,  'Cetirizine',          '10mg',              '5 days',  'Take at night'),
(9,  9,  'Mannitol',            '20%',               '3 days',  'IV use only'),
(10, 10, 'Folic Acid',          '5mg',               '90 days', 'Take daily morning');

-- Admission
INSERT INTO Admission VALUES
(1,  1,  4, '2025-03-01', '2025-03-05', 'Discharged'),
(2,  2,  2, '2025-03-02', NULL,         'Active'),
(3,  3,  1, '2025-03-03', '2025-03-07', 'Discharged'),
(4,  4,  3, '2025-03-04', '2025-03-06', 'Discharged'),
(5,  5,  5, '2025-03-05', NULL,         'Active'),
(6,  6,  6, '2025-03-06', '2025-03-08', 'Discharged'),
(7,  7,  7, '2025-03-07', NULL,         'Active'),
(8,  8,  8, '2025-03-08', '2025-03-09', 'Discharged'),
(9,  9,  4, '2025-03-09', NULL,         'Active'),
(10, 10, 5, '2025-03-10', '2025-03-15', 'Discharged');

-- Billing
INSERT INTO Billing VALUES
(1,  1,  1,  5000.00,  '2025-03-01', 'Paid'),
(2,  2,  2,  3000.00,  '2025-03-02', 'Pending'),
(3,  3,  3,  8000.00,  '2025-03-03', 'Paid'),
(4,  4,  4,  2000.00,  '2025-03-04', 'Paid'),
(5,  5,  5,  15000.00, '2025-03-05', 'Pending'),
(6,  6,  6,  1500.00,  '2025-03-06', 'Paid'),
(7,  7,  7,  6000.00,  '2025-03-07', 'Pending'),
(8,  8,  8,  1000.00,  '2025-03-08', 'Paid'),
(9,  9,  9,  12000.00, '2025-03-09', 'Pending'),
(10, 10, 10, 4000.00,  '2025-03-10', 'Paid');

-- Payment
INSERT INTO Payment VALUES
(1,  1,  'Cash',      '2025-03-01', 5000.00),
(2,  3,  'Card',      '2025-03-03', 8000.00),
(3,  4,  'Cash',      '2025-03-04', 2000.00),
(4,  6,  'Online',    '2025-03-06', 1500.00),
(5,  8,  'Cash',      '2025-03-08', 1000.00),
(6,  10, 'Card',      '2025-03-10', 4000.00),
(7,  2,  'Online',    '2025-03-11', 1500.00),
(8,  5,  'Insurance', '2025-03-12', 7000.00),
(9,  7,  'Cash',      '2025-03-13', 3000.00),
(10, 9,  'Card',      '2025-03-14', 6000.00);


/* 
   PART 4 — DML: UPDATE & DELETE
    */

-- UPDATE: mark appointment 3 as Completed
UPDATE Appointment
SET Status = 'Completed'
WHERE AppointmentID = 3;

-- UPDATE: fix patient address
UPDATE Patient
SET Address = 'Lahore, Punjab, Pakistan'
WHERE PatientID = 1;

-- UPDATE: mark room 3 as occupied
UPDATE Room
SET AvailabilityStatus = 'Occupied'
WHERE RoomID = 3;

-- DELETE: remove the cancelled appointment (AppointmentID = 6)
-- Because Billing → Appointment and Payment → Billing all have
-- ON DELETE CASCADE, deleting the Appointment automatically
-- removes its Billing row and that Billing's Payment row.
DELETE FROM Appointment
WHERE AppointmentID = 6 AND Status = 'Cancelled';

SET SQL_SAFE_UPDATES = 1;


/* 
   PART 5 — QUERIES: JOINS
    */

-- 1. INNER JOIN: patients with appointments
SELECT P.FirstName, P.LastName, A.AppointmentDate, A.Status
FROM Patient P
INNER JOIN Appointment A ON P.PatientID = A.PatientID;

-- 2. LEFT JOIN: all patients (even without appointments)
SELECT P.FirstName, P.LastName, A.AppointmentDate, A.Status
FROM Patient P
LEFT JOIN Appointment A ON P.PatientID = A.PatientID;

-- 3. RIGHT JOIN: all appointments (even if patient missing)
SELECT P.FirstName, P.LastName, A.AppointmentDate, A.VisitReason
FROM Patient P
RIGHT JOIN Appointment A ON P.PatientID = A.PatientID;

-- 4. FULL OUTER JOIN (MySQL workaround)
SELECT P.FirstName, P.LastName, A.AppointmentDate, A.Status
FROM Patient P LEFT JOIN Appointment A ON P.PatientID = A.PatientID
UNION
SELECT P.FirstName, P.LastName, A.AppointmentDate, A.Status
FROM Patient P RIGHT JOIN Appointment A ON P.PatientID = A.PatientID;

-- 5. NATURAL JOIN
SELECT FirstName, LastName, AppointmentDate, Status
FROM Patient
NATURAL JOIN Appointment;

-- 6. SELF JOIN: doctors in same department
SELECT D1.FirstName AS Doctor1, D2.FirstName AS Doctor2, D1.DepartmentID
FROM Doctor D1
INNER JOIN Doctor D2
    ON D1.DepartmentID = D2.DepartmentID
    AND D1.DoctorID < D2.DoctorID;

-- 7. COMPLEX JOIN: patient + doctor + appointment
SELECT
    P.FirstName  AS PatientName,
    D.FirstName  AS DoctorName,
    D.Specialization,
    A.AppointmentDate,
    A.VisitReason,
    A.Status
FROM Appointment A
INNER JOIN Patient P ON A.PatientID = P.PatientID
INNER JOIN Doctor  D ON A.DoctorID  = D.DoctorID;


/* 
   PART 6 — QUERIES: SUBQUERIES
    */

-- IN
SELECT FirstName, LastName FROM Patient
WHERE PatientID IN (SELECT PatientID FROM Billing);

-- ANY
SELECT BillID, TotalAmount FROM Billing
WHERE TotalAmount > ANY (
    SELECT TotalAmount FROM Billing WHERE PaymentStatus = 'Paid'
);

-- ALL
SELECT BillID, TotalAmount FROM Billing
WHERE TotalAmount > ALL (
    SELECT TotalAmount FROM Billing WHERE PaymentStatus = 'Paid'
);

-- NOT IN
SELECT FirstName, LastName FROM Patient
WHERE PatientID NOT IN (SELECT PatientID FROM Admission);

-- NOT ANY (bills <= minimum pending bill)
SELECT BillID, TotalAmount FROM Billing
WHERE TotalAmount <= ALL (
    SELECT TotalAmount FROM Billing WHERE PaymentStatus = 'Pending'
);

-- NOT ALL (bills not greater than ALL pending bills)
SELECT BillID, TotalAmount FROM Billing B
WHERE NOT (
    B.TotalAmount > ALL (
        SELECT TotalAmount FROM Billing WHERE PaymentStatus = 'Pending'
    )
);

-- EXISTS
SELECT P.FirstName, P.LastName FROM Patient P
WHERE EXISTS (
    SELECT 1 FROM Appointment A WHERE A.PatientID = P.PatientID
);

-- NOT EXISTS
SELECT D.FirstName, D.LastName FROM Doctor D
WHERE NOT EXISTS (
    SELECT 1 FROM Appointment A WHERE A.DoctorID = D.DoctorID
);


/* 
   PART 7 — QUERIES: AGGREGATES & SET OPERATIONS
    */

SELECT COUNT(*)         AS TotalPatients FROM Patient;
SELECT SUM(TotalAmount) AS TotalRevenue  FROM Billing;
SELECT AVG(TotalAmount) AS AverageBill   FROM Billing;
SELECT MIN(TotalAmount) AS LowestBill    FROM Billing;
SELECT MAX(TotalAmount) AS HighestBill   FROM Billing;

SELECT DepartmentID, COUNT(*) AS TotalDoctors
FROM Doctor GROUP BY DepartmentID;

SELECT DepartmentID, COUNT(*) AS TotalDoctors
FROM Doctor GROUP BY DepartmentID HAVING COUNT(*) > 1;

-- UNION
SELECT PatientID AS ID FROM Patient
UNION
SELECT DoctorID  AS ID FROM Doctor;

-- UNION ALL
SELECT PatientID AS ID FROM Patient
UNION ALL
SELECT DoctorID  AS ID FROM Doctor;

-- INTERSECT workaround
SELECT DISTINCT P.PatientID
FROM Patient P INNER JOIN Doctor D ON P.PatientID = D.DoctorID;

-- EXCEPT workaround
SELECT PatientID FROM Patient
WHERE PatientID NOT IN (SELECT PatientID FROM Admission);


/* 
   PART 8 — VIEWS
    */

CREATE OR REPLACE VIEW PatientAppointmentView AS
SELECT P.PatientID, P.FirstName, P.LastName,
       A.AppointmentDate, A.Status, A.VisitReason
FROM Patient P
INNER JOIN Appointment A ON P.PatientID = A.PatientID;

SELECT * FROM PatientAppointmentView;

CREATE OR REPLACE VIEW DoctorDepartmentView AS
SELECT D.DoctorID, D.FirstName, D.LastName, D.Specialization,
       DP.DepartmentName
FROM Doctor D
INNER JOIN Department DP ON D.DepartmentID = DP.DepartmentID;

SELECT * FROM DoctorDepartmentView;

CREATE OR REPLACE VIEW BillingPaymentView AS
SELECT B.BillID, B.TotalAmount, B.PaymentStatus,
       P.PaymentMethod, P.AmountPaid
FROM Billing B
LEFT JOIN Payment P ON B.BillID = P.BillID;

SELECT * FROM BillingPaymentView;


/* 
   PART 9 — CASCADE DEMONSTRATIONS
   Uses isolated test patients (IDs 91, 92) — main data safe.
  */

INSERT INTO Patient
    (PatientID, FirstName, LastName, Gender, DateOfBirth,
     PhoneNumber, Email, Address, BloodGroup, RegistrationDate, EmergencyContact)
VALUES
(91, 'Test', 'CascadeUser', 'Male',   '1990-01-01', '03000000091', 'test91@demo.com', 'TestCity', 'O+', '2025-01-01', '03000000000'),
(92, 'Test', 'SetNullUser', 'Female', '1990-01-01', '03000000092', 'test92@demo.com', 'TestCity', 'A+', '2025-01-01', '03000000000');

-- ---- ON DELETE CASCADE demo ----
DROP TABLE IF EXISTS Appointment_Cascade;

CREATE TABLE Appointment_Cascade (
    AppointmentID   INT  PRIMARY KEY,
    PatientID       INT,
    AppointmentDate DATE,

    CONSTRAINT fk_cascade_patient
        FOREIGN KEY (PatientID)
        REFERENCES Patient(PatientID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

INSERT INTO Appointment_Cascade VALUES
(101, 91, '2025-04-01'),
(102, 91, '2025-04-02');

SELECT * FROM Appointment_Cascade WHERE PatientID = 91;  -- 2 rows
DELETE FROM Patient WHERE PatientID = 91;
SELECT * FROM Appointment_Cascade WHERE PatientID = 91;  -- 0 rows (cascaded)

-- ---- ON DELETE SET NULL demo ----
DROP TABLE IF EXISTS Billing_SetNull;

CREATE TABLE Billing_SetNull (
    BillID      INT            PRIMARY KEY,
    PatientID   INT            NULL,
    TotalAmount DECIMAL(10,2),

    CONSTRAINT fk_setnull_patient
        FOREIGN KEY (PatientID)
        REFERENCES Patient(PatientID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

INSERT INTO Billing_SetNull VALUES (201, 92, 3000.00);

SELECT * FROM Billing_SetNull;              -- PatientID = 92
DELETE FROM Patient WHERE PatientID = 92;
SELECT * FROM Billing_SetNull;              -- PatientID = NULL

SET SQL_SAFE_UPDATES = 1;