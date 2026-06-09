# MediCore-Hospital-Management-System-DATABASE-PROJECT-
🏥 MediCore — Hospital Management System
A relational database project built with MySQL, modeling the core operations of a hospital including patient management, doctor appointments, medical records, billing, and admissions.

📋 Project Overview
MediCore is a fully implemented Hospital Management System database developed as part of the Introduction to Database Systems course at the University of Central Punjab (UCP), Faculty of Information Technology and Computer Science.
The project demonstrates real-world database design principles including normalized schema design, referential integrity, cascading constraints, and complex query writing.

🗂️ Database Schema
The database consists of 10 tables:
TableDescriptionDepartmentHospital departments (Cardiology, Neurology, etc.)DoctorDoctor profiles linked to departmentsPatientPatient registration and personal detailsRoomHospital rooms with availability statusAppointmentPatient-doctor appointment schedulingMedicalRecordDiagnoses and treatment plansPrescriptionMedicines linked to medical recordsAdmissionPatient room admissions and discharge infoBillingBills generated per appointmentPaymentPayment records linked to bills

🔗 Entity Relationships
Department ──< Doctor ──< Appointment >── Patient
                               │
                          MedicalRecord ──< Prescription
                          
Patient ──< Admission >── Room
Patient ──< Billing   >── Appointment ──< Payment
All foreign keys are defined with ON DELETE CASCADE ON UPDATE CASCADE to ensure referential integrity.

📁 What's Inside the Script
The SQL script is divided into 9 parts:

DDL — Create Tables — Full schema with constraints and foreign keys
DDL — ALTER TABLE — Add/modify/drop columns, rename tables, add constraints
DML — Insert Data — 10 rows per table with realistic Pakistani context
DML — Update & Delete — Practical update and delete demonstrations
Queries — Joins — INNER, LEFT, RIGHT, FULL OUTER, NATURAL, SELF, and complex multi-table joins
Queries — Subqueries — IN, ANY, ALL, NOT IN, EXISTS, NOT EXISTS
Queries — Aggregates & Set Operations — COUNT, SUM, AVG, MIN, MAX, GROUP BY, HAVING, UNION, INTERSECT, EXCEPT
Views — PatientAppointmentView, DoctorDepartmentView, BillingPaymentView
Cascade Demonstrations — ON DELETE CASCADE and ON DELETE SET NULL with isolated test data


▶️ How to Run

Open MySQL Workbench (or any MySQL client)
Open the file medicore.sql
Run the entire script — it will:

Create the MediCore database
Create all tables
Insert sample data
Execute all queries and create views




Note: The script uses SET SQL_SAFE_UPDATES = 0 at the start to allow updates/deletes by condition. It is reset to 1 at the end.


🛠️ Technologies Used

MySQL — Database engine
MySQL Workbench — Query execution and schema visualization


👩‍💻 Author
Surrayah Ismil
BS Software Engineering — University of Central Punjab (UCP)
Introduction to Database Systems
