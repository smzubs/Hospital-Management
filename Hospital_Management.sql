CREATE TABLE Patients (
    PatientID INT PRIMARY KEY IDENTITY(1,1),
    FullName NVARCHAR(100),
    DOB DATE,
    Gender NVARCHAR(10),
    Contact NVARCHAR(50),
    Address NVARCHAR(200)
);


CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY IDENTITY(1,1),
    DepartmentName NVARCHAR(100)
);

CREATE TABLE Doctors (
    DoctorID INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100),
    Specialty NVARCHAR(50),
    Contact NVARCHAR(50),
    DepartmentID INT NOT NULL,
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);

CREATE TABLE Billing (
    BillID INT PRIMARY KEY IDENTITY(1,1),
    PatientID INT,
    Amount DECIMAL(10, 2),
    PaymentStatus NVARCHAR(20),
    Date DATE,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    CHECK (PaymentStatus IN ('Paid', 'Unpaid', 'Pending'))
);

CREATE TABLE Appointments (
    AppointmentID INT PRIMARY KEY IDENTITY(1,1),
    PatientID INT,
    DoctorID INT,
    AppointmentDate DATETIME,
    Status NVARCHAR(20),
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID),
    CHECK (Status IN ('Scheduled', 'Completed', 'Cancelled'))
);

CREATE TABLE Rooms (
    RoomID INT PRIMARY KEY IDENTITY(1,1),
    RoomType NVARCHAR(50),
    Status NVARCHAR(20),
    CHECK (Status IN ('Available', 'Occupied', 'Under Maintenance'))
);

CREATE TABLE MedicalRecords (
    RecordID INT PRIMARY KEY IDENTITY(1,1),
    PatientID INT,
    Diagnosis NVARCHAR(200),
    Treatment NVARCHAR(200),
    AdmissionDate DATE,
    DischargeDate DATE,
    RoomID INT,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (RoomID) REFERENCES Rooms(RoomID)
);

CREATE TABLE Prescriptions (
    PrescriptionID INT PRIMARY KEY IDENTITY(1,1),
    AppointmentID INT,
    Medicine NVARCHAR(100),
    Dosage NVARCHAR(50),
    Instructions NVARCHAR(200),
    FOREIGN KEY (AppointmentID) REFERENCES Appointments(AppointmentID)
);

----SCHEDULE APPOINTMENT STORED PROCEDURE
CREATE PROCEDURE ScheduleAppointment
    @PatientID INT,
    @DoctorID INT,
    @AppointmentDate DATETIME,
    @Status NVARCHAR(20)
AS
BEGIN
    INSERT INTO Appointments (PatientID, DoctorID, AppointmentDate, Status)
    VALUES (@PatientID, @DoctorID, @AppointmentDate, @Status);
    
    PRINT 'Appointment Scheduled Successfully';
END;


---Get PAtient History Stored Procedure
CREATE PROCEDURE GetPatientHistory
    @PatientID INT
AS
BEGIN
    SELECT 
        p.FullName,
        a.AppointmentDate,
        d.Name AS DoctorName,
        m.Diagnosis,
        m.Treatment
    FROM 
        Patients p
        JOIN Appointments a ON p.PatientID = a.PatientID
        JOIN Doctors d ON a.DoctorID = d.DoctorID
        LEFT JOIN MedicalRecords m ON p.PatientID = m.PatientID
    WHERE 
        p.PatientID = @PatientID
    ORDER BY 
        a.AppointmentDate DESC;
END;


--Create View
CREATE VIEW DoctorAppointments AS
SELECT 
    d.Name AS DoctorName,
    d.Specialty,
    COUNT(a.AppointmentID) AS TotalAppointments
FROM 
    Doctors d
    LEFT JOIN Appointments a ON d.DoctorID = a.DoctorID
GROUP BY 
    d.Name, d.Specialty;


---Patients Per Department
CREATE VIEW PatientsPerDepartment AS
SELECT 
    dep.DepartmentName,
    COUNT(DISTINCT m.PatientID) AS TotalPatients
FROM 
    Departments dep
    JOIN Doctors doc ON dep.DepartmentID = doc.DepartmentID
    JOIN Appointments app ON doc.DoctorID = app.DoctorID
    JOIN MedicalRecords m ON app.PatientID = m.PatientID
GROUP BY 
    dep.DepartmentName;


-- Insert sample data into Departments
INSERT INTO Departments (DepartmentName) VALUES ('Cardiology'), ('Neurology'), ('Orthopedics');

-- Insert sample data into Patients
INSERT INTO Patients (FullName, DOB, Gender, Contact, Address) VALUES 
('John Doe', '1985-06-15', 'Male', '555-1234', '123 Maple St'),
('Jane Smith', '1990-07-20', 'Female', '555-5678', '456 Oak St');

-- Insert sample data into Doctors
INSERT INTO Doctors (Name, Specialty, Contact, DepartmentID) VALUES 
('Dr. Alice', 'Cardiologist', '555-9999', 1),
('Dr. Bob', 'Neurologist', '555-8888', 2);

-- Insert sample data into Rooms
INSERT INTO Rooms (RoomType, Status) VALUES 
('Single', 'Available'),
('Double', 'Occupied');

-- Insert sample data into Billing
INSERT INTO Billing (PatientID, Amount, PaymentStatus, Date) VALUES 
(1, 200.00, 'Paid', '2025-02-01'),
(2, 150.00, 'Unpaid', '2025-02-05');

-- Insert sample data into Appointments
INSERT INTO Appointments (PatientID, DoctorID, AppointmentDate, Status) VALUES 
(1, 1, '2025-02-10 10:00:00', 'Scheduled'),
(2, 2, '2025-02-11 11:00:00', 'Completed');

-- Insert sample data into MedicalRecords
INSERT INTO MedicalRecords (PatientID, Diagnosis, Treatment, AdmissionDate, DischargeDate, RoomID) VALUES 
(1, 'Hypertension', 'Medication', '2025-02-01', '2025-02-05', 1);

-- Insert sample data into Prescriptions
INSERT INTO Prescriptions (AppointmentID, Medicine, Dosage, Instructions) VALUES 
(1, 'Aspirin', '100mg', 'Take twice daily');

--Test Stored Procedure

EXEC ScheduleAppointment @PatientID = 1, @DoctorID = 2, @AppointmentDate = '2025-02-20 14:00:00', @Status = 'Scheduled';


--Check if the appointment has been added:
SELECT * FROM Appointments WHERE PatientID = 1 AND DoctorID = 2;

--GetPatientHistory Procedure
EXEC GetPatientHistory @PatientID = 1;

--Test VIEW,  DoctorAppointments View

SELECT * FROM DoctorAppointments;


--PatientsPerDepartment View
SELECT * FROM PatientsPerDepartment;


-- Test PaymentStatus constraint in Billing table
INSERT INTO Billing (PatientID, Amount, PaymentStatus, Date) VALUES (1, 300.00, 'InvalidStatus', '2025-02-10');

-- Test Status constraint in Rooms table
INSERT INTO Rooms (RoomType, Status) VALUES ('Suite', 'InvalidStatus');




