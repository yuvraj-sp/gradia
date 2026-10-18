-- ============================================================
-- Gradia: Student Management & Academic Analytics System
-- Schema Definition
-- ============================================================

DROP DATABASE IF EXISTS gradia;
CREATE DATABASE gradia;
USE gradia;

CREATE TABLE FACULTY (
    faculty_id      INT PRIMARY KEY AUTO_INCREMENT,
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL,
    department      VARCHAR(50) NOT NULL,
    email           VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE STUDENTS (
    student_id      INT PRIMARY KEY AUTO_INCREMENT,
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL,
    dob             DATE NOT NULL,
    email           VARCHAR(100) UNIQUE NOT NULL,
    enrollment_year INT NOT NULL,
    branch          VARCHAR(50) NOT NULL
);

CREATE TABLE COURSES (
    course_id       INT PRIMARY KEY AUTO_INCREMENT,
    course_name     VARCHAR(100) NOT NULL,
    credits         INT NOT NULL CHECK (credits BETWEEN 1 AND 6),
    semester        INT NOT NULL CHECK (semester BETWEEN 1 AND 8),
    faculty_id      INT,
    capacity        INT NOT NULL DEFAULT 60,
    branch          VARCHAR(50) NOT NULL,
    FOREIGN KEY (faculty_id) REFERENCES FACULTY(faculty_id) ON DELETE SET NULL
);


CREATE TABLE ENROLLMENTS (
    enrollment_id   INT PRIMARY KEY AUTO_INCREMENT,
    student_id      INT NOT NULL,
    course_id       INT NOT NULL,
    enrollment_date DATE NOT NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    FOREIGN KEY (student_id) REFERENCES STUDENTS(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id)  REFERENCES COURSES(course_id)  ON DELETE CASCADE,
    UNIQUE (student_id, course_id)
);

CREATE TABLE GRADES (
    grade_id        INT PRIMARY KEY AUTO_INCREMENT,
    enrollment_id   INT NOT NULL,
    exam_type       VARCHAR(20) NOT NULL,
    marks           DECIMAL(5,2) NOT NULL CHECK (marks BETWEEN 0 AND 100),
    grade_letter    CHAR(2),
    FOREIGN KEY (enrollment_id) REFERENCES ENROLLMENTS(enrollment_id) ON DELETE CASCADE
);

CREATE TABLE ATTENDANCE (
    attendance_id   INT PRIMARY KEY AUTO_INCREMENT,
    enrollment_id   INT NOT NULL,
    class_date      DATE NOT NULL,
    status          VARCHAR(10) NOT NULL CHECK (status IN ('Present','Absent')),
    FOREIGN KEY (enrollment_id) REFERENCES ENROLLMENTS(enrollment_id) ON DELETE CASCADE,
    UNIQUE (enrollment_id, class_date)
);

CREATE INDEX idx_enrollments_student ON ENROLLMENTS(student_id);
CREATE INDEX idx_enrollments_course  ON ENROLLMENTS(course_id);
CREATE INDEX idx_grades_enrollment   ON GRADES(enrollment_id);
CREATE INDEX idx_attendance_enrollment ON ATTENDANCE(enrollment_id);