-- 1. Student GPA (credit-weighted average)
--------------------------------------------------------------------------------------------
sql
SELECT 
    S.student_id,
    S.first_name,
    S.last_name,
    ROUND(SUM(course_avg.avg_marks * C.credits) / SUM(C.credits), 2) AS GPA
FROM STUDENTS S
JOIN ENROLLMENTS E ON S.student_id = E.student_id
JOIN COURSES C ON E.course_id = C.course_id
JOIN (
    SELECT enrollment_id, AVG(marks) AS avg_marks
    FROM GRADES
    GROUP BY enrollment_id
) course_avg ON E.enrollment_id = course_avg.enrollment_id
GROUP BY S.student_id, S.first_name, S.last_name
ORDER BY GPA DESC
LIMIT 10;


-- 2. Attendance Percentage per Student per Course
--------------------------------------------------------------------------------------------------

sql
SELECT 
    S.first_name,
    S.last_name,
    C.course_name,
    COUNT(*) AS total_classes,
    SUM(CASE WHEN A.status = 'Present' THEN 1 ELSE 0 END) AS classes_attended,
    ROUND(SUM(CASE WHEN A.status = 'Present' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attendance_pct
FROM STUDENTS S
JOIN ENROLLMENTS E ON S.student_id = E.student_id
JOIN COURSES C ON E.course_id = C.course_id
JOIN ATTENDANCE A ON E.enrollment_id = A.enrollment_id
GROUP BY S.student_id, S.first_name, S.last_name, C.course_id, C.course_name
ORDER BY attendance_pct ASC
LIMIT 15;


-- 3. At-Risk Students (attendance + grades combined)
-------------------------------------------------------------------------------------------------

sql
SELECT 
    S.first_name,
    S.last_name,
    C.course_name,
    ROUND(attendance_summary.attendance_pct, 2) AS attendance_pct,
    ROUND(grade_summary.avg_marks, 2) AS avg_marks,
    CASE 
        WHEN attendance_summary.attendance_pct < 60 AND grade_summary.avg_marks < 40 THEN 'HIGH RISK'
        WHEN attendance_summary.attendance_pct < 60 OR grade_summary.avg_marks < 40 THEN 'AT RISK'
        ELSE 'OK'
    END AS risk_status,
    CASE 
        WHEN attendance_summary.attendance_pct < 60 AND grade_summary.avg_marks < 40 THEN 1
        ELSE 2
    END AS risk_priority
FROM ENROLLMENTS E
JOIN STUDENTS S ON E.student_id = S.student_id
JOIN COURSES C ON E.course_id = C.course_id
JOIN (
    SELECT enrollment_id, 
           SUM(CASE WHEN status = 'Present' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS attendance_pct
    FROM ATTENDANCE
    GROUP BY enrollment_id
) attendance_summary ON E.enrollment_id = attendance_summary.enrollment_id
JOIN (
    SELECT enrollment_id, AVG(marks) AS avg_marks
    FROM GRADES
    GROUP BY enrollment_id
) grade_summary ON E.enrollment_id = grade_summary.enrollment_id
WHERE attendance_summary.attendance_pct < 60 OR grade_summary.avg_marks < 40
ORDER BY risk_priority ASC, attendance_pct ASC;


-- 4. Top 3 Students Per Branch (window function)
------------------------------------------------------------------------------------------------------

sql
WITH student_gpa AS (
    SELECT 
        S.student_id,
        S.first_name,
        S.last_name,
        S.branch,
        ROUND(SUM(course_avg.avg_marks * C.credits) / SUM(C.credits), 2) AS GPA
    FROM STUDENTS S
    JOIN ENROLLMENTS E ON S.student_id = E.student_id
    JOIN COURSES C ON E.course_id = C.course_id
    JOIN (
        SELECT enrollment_id, AVG(marks) AS avg_marks
        FROM GRADES
        GROUP BY enrollment_id
    ) course_avg ON E.enrollment_id = course_avg.enrollment_id
    GROUP BY S.student_id, S.first_name, S.last_name, S.branch
),
ranked AS (
    SELECT 
        branch,
        first_name,
        last_name,
        GPA,
        RANK() OVER (PARTITION BY branch ORDER BY GPA DESC) AS branch_rank
    FROM student_gpa
)
SELECT * FROM ranked WHERE branch_rank <= 3
ORDER BY branch, branch_rank;


-- 5. Faculty Teaching Load
-------------------------------------------------------------------------------------------------

sql
SELECT 
    F.first_name,
    F.last_name,
    F.department,
    COUNT(DISTINCT C.course_id) AS courses_taught,
    COUNT(E.enrollment_id) AS total_students_taught
FROM FACULTY F
LEFT JOIN COURSES C ON F.faculty_id = C.faculty_id
LEFT JOIN ENROLLMENTS E ON C.course_id = E.course_id
GROUP BY F.faculty_id, F.first_name, F.last_name, F.department
ORDER BY total_students_taught DESC;


-- 6. Branch-wise Performance Comparison
---------------------------------------------------------------------------------------------------

sql
WITH student_gpa AS (
    SELECT 
        S.student_id,
        S.branch,
        ROUND(SUM(course_avg.avg_marks * C.credits) / SUM(C.credits), 2) AS GPA
    FROM STUDENTS S
    JOIN ENROLLMENTS E ON S.student_id = E.student_id
    JOIN COURSES C ON E.course_id = C.course_id
    JOIN (
        SELECT enrollment_id, AVG(marks) AS avg_marks
        FROM GRADES
        GROUP BY enrollment_id
    ) course_avg ON E.enrollment_id = course_avg.enrollment_id
    GROUP BY S.student_id, S.branch
),
student_attendance AS (
    SELECT 
        S.student_id,
        S.branch,
        SUM(CASE WHEN A.status = 'Present' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS attendance_pct
    FROM STUDENTS S
    JOIN ENROLLMENTS E ON S.student_id = E.student_id
    JOIN ATTENDANCE A ON E.enrollment_id = A.enrollment_id
    GROUP BY S.student_id, S.branch
)
SELECT 
    g.branch,
    COUNT(DISTINCT g.student_id) AS num_students,
    ROUND(AVG(g.GPA), 2) AS avg_gpa,
    ROUND(AVG(a.attendance_pct), 2) AS avg_attendance_pct
FROM student_gpa g
JOIN student_attendance a ON g.student_id = a.student_id
GROUP BY g.branch
ORDER BY avg_gpa DESC;


-- 7. Views (just introduced)
--------------------------------------------------------------------------------------------------

sql
CREATE VIEW student_gpa_view AS
SELECT 
    S.student_id,
    S.first_name,
    S.last_name,
    S.branch,
    ROUND(SUM(course_avg.avg_marks * C.credits) / SUM(C.credits), 2) AS GPA
FROM STUDENTS S
JOIN ENROLLMENTS E ON S.student_id = E.student_id
JOIN COURSES C ON E.course_id = C.course_id
JOIN (
    SELECT enrollment_id, AVG(marks) AS avg_marks
    FROM GRADES
    GROUP BY enrollment_id
) course_avg ON E.enrollment_id = course_avg.enrollment_id
GROUP BY S.student_id, S.first_name, S.last_name, S.branch;


CREATE VIEW student_attendance_view AS
SELECT 
    S.student_id,
    S.first_name,
    S.last_name,
    C.course_name,
    SUM(CASE WHEN A.status = 'Present' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS attendance_pct
FROM STUDENTS S
JOIN ENROLLMENTS E ON S.student_id = E.student_id
JOIN COURSES C ON E.course_id = C.course_id
JOIN ATTENDANCE A ON E.enrollment_id = A.enrollment_id
GROUP BY S.student_id, S.first_name, S.last_name, C.course_id, C.course_name;