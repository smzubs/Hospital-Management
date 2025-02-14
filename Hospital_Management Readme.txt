# Hospital Management System

## Project Overview
This project is a Hospital Management System developed using Microsoft SQL Server. The system includes tables, stored procedures, and views to manage patients, doctors, appointments, billing, rooms, medical records, and prescriptions.

## Database Schema
The database schema consists of the following tables:
- Patients
- Doctors
- Departments
- Billing
- Appointments
- Rooms
- MedicalRecords
- Prescriptions

## Key Features

### Stored Procedures
- **ScheduleAppointment**: Schedules a new appointment for a patient with a doctor.
- **GetPatientHistory**: Retrieves the complete medical history of a patient.

### Views
- **DoctorAppointments**: Displays the total number of appointments each doctor has.
- **PatientsPerDepartment**: Calculates the total number of patients admitted per department.

## Setup Instructions
1. **Restore the Database Backup**:

Execute the SQL Scripts:

Run the provided SQL scripts to create tables, stored procedures, and views in SQL Server Management Studio (SSMS).

Using the Database
Scheduling an Appointment:
EXEC ScheduleAppointment @PatientID = 1, @DoctorID = 2, @AppointmentDate = '2025-02-20 14:00:00', @Status = 'Scheduled';

Retrieving Patient History:
EXEC GetPatientHistory @PatientID = 1;

Viewing Doctor Appointments:
SELECT * FROM DoctorAppointments;

Viewing Patients Per Department:
SELECT * FROM PatientsPerDepartment;


