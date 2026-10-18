"""
Gradia - Sample Data Generator
Generates realistic CSV data for all tables, ready to load into MySQL.
Run: python generate_data.py
Outputs CSVs into ./data/
"""

import csv
import os
import random
from datetime import date, timedelta
from faker import Faker

fake = Faker("en_IN")
random.seed(42)
Faker.seed(42)

OUT_DIR = os.path.join(os.path.dirname(__file__), "data")
os.makedirs(OUT_DIR, exist_ok=True)

BRANCHES = ["Computer Engineering", "IT", "E&TC", "Mechanical", "Civil"]
DEPARTMENTS = ["Computer Engineering", "IT", "E&TC", "Mechanical", "Civil"]
EXAM_TYPES = ["Mid-term", "End-term", "Assignment"]

COURSE_CATALOG = {
    "Computer Engineering": [
        ("Data Structures", 4, 3),
        ("Database Management Systems", 4, 4),
        ("Operating Systems", 4, 5),
        ("Object Oriented Programming", 3, 2),
        ("Artificial Intelligence", 3, 6),
        ("Machine Learning", 4, 7),
        ("Compiler Design", 3, 6),
    ],
    "IT": [
        ("Web Technologies", 3, 4),
        ("Computer Networks", 3, 5),
        ("Software Engineering", 3, 5),
        ("Cloud Computing", 3, 7),
        ("Cyber Security Fundamentals", 3, 6),
        ("Database Management Systems", 4, 4),
        ("Theory of Computation", 3, 5),
    ],
    "E&TC": [
        ("Digital Electronics", 4, 3),
        ("Signals and Systems", 3, 4),
        ("Microprocessors", 4, 5),
        ("Communication Systems", 3, 5),
        ("VLSI Design", 3, 6),
        ("Embedded Systems", 3, 6),
        ("Control Systems", 3, 4),
    ],
    "Mechanical": [
        ("Thermodynamics", 4, 3),
        ("Fluid Mechanics", 4, 4),
        ("Machine Design", 3, 5),
        ("Manufacturing Processes", 3, 4),
        ("Heat Transfer", 3, 5),
        ("Automobile Engineering", 3, 6),
        ("CAD/CAM", 3, 6),
    ],
    "Civil": [
        ("Structural Analysis", 4, 3),
        ("Surveying", 3, 3),
        ("Geotechnical Engineering", 4, 4),
        ("Concrete Technology", 3, 5),
        ("Transportation Engineering", 3, 5),
        ("Environmental Engineering", 3, 6),
        ("Construction Management", 3, 6),
    ],
}

# ---------------------------------------------------------------
# 1. FACULTY
# ---------------------------------------------------------------
def generate_faculty(n=12):
    rows = []
    for i in range(1, n + 1):
        rows.append({
            "faculty_id": i,
            "first_name": fake.first_name(),
            "last_name": fake.last_name(),
            "department": random.choice(DEPARTMENTS),
            "email": f"faculty{i}@sinhgad.edu"
        })
    return rows

# ---------------------------------------------------------------
# 2. STUDENTS
# ---------------------------------------------------------------
def generate_students(n=60):
    rows = []
    for i in range(1, n + 1):
        dob = fake.date_of_birth(minimum_age=18, maximum_age=22)
        rows.append({
            "student_id": i,
            "first_name": fake.first_name(),
            "last_name": fake.last_name(),
            "dob": dob.isoformat(),
            "email": f"student{i}@sinhgad.edu",
            "enrollment_year": random.choice([2023, 2024, 2025]),
            "branch": random.choice(BRANCHES)
        })
    return rows

# ---------------------------------------------------------------
# 3. COURSES
# ---------------------------------------------------------------
def generate_courses(faculty_rows):
    """
    Builds the COURSES table. Each course is tagged with a `branch` so that
    generate_enrollments() can later restrict students to courses from their
    own branch. Faculty are assigned from the matching department where
    possible, falling back to a random faculty member otherwise.
    """
    rows = []
    course_id = 1
    for branch, courses in COURSE_CATALOG.items():
        branch_faculty = [f for f in faculty_rows if f["department"] == branch]
        for name, credits, semester in courses:
            chosen_faculty = random.choice(branch_faculty) if branch_faculty else random.choice(faculty_rows)
            rows.append({
                "course_id": course_id,
                "course_name": name,
                "credits": credits,
                "semester": semester,
                "faculty_id": chosen_faculty["faculty_id"],
                "capacity": random.choice([40, 50, 60]),
                "branch": branch,
            })
            course_id += 1
    return rows

# ---------------------------------------------------------------
# 4. ENROLLMENTS  (each student enrolls in 4-6 courses, own branch only)
# ---------------------------------------------------------------
def generate_enrollments(student_rows, course_rows):
    rows = []
    enrollment_id = 1
    for student in student_rows:
        eligible_courses = [c for c in course_rows if c["branch"] == student["branch"]]
        num_courses = min(random.randint(4, 6), len(eligible_courses))
        chosen_courses = random.sample(eligible_courses, num_courses)
        for course in chosen_courses:
            enroll_date = date(student["enrollment_year"], random.choice([7, 8]), random.randint(1, 28))
            rows.append({
                "enrollment_id": enrollment_id,
                "student_id": student["student_id"],
                "course_id": course["course_id"],
                "enrollment_date": enroll_date.isoformat(),
                "status": "ACTIVE"
            })
            enrollment_id += 1
    return rows

# ---------------------------------------------------------------
# 5. GRADES  (each enrollment gets 3 grade entries: Mid/End/Assignment)
# ---------------------------------------------------------------
def marks_to_letter(marks):
    if marks >= 90: return "O"
    if marks >= 80: return "A"
    if marks >= 70: return "B"
    if marks >= 60: return "C"
    if marks >= 50: return "D"
    if marks >= 40: return "E"
    return "F"

def generate_grades(enrollment_rows):
    rows = []
    grade_id = 1
    for enr in enrollment_rows:
        base = random.gauss(68, 15)
        for exam_type in EXAM_TYPES:
            marks = max(0, min(100, round(base + random.gauss(0, 8), 2)))
            rows.append({
                "grade_id": grade_id,
                "enrollment_id": enr["enrollment_id"],
                "exam_type": exam_type,
                "marks": marks,
                "grade_letter": marks_to_letter(marks)
            })
            grade_id += 1
    return rows

# ---------------------------------------------------------------
# 6. ATTENDANCE  (simulate ~30 class sessions per enrollment)
# ---------------------------------------------------------------
def generate_attendance(enrollment_rows, sessions_per_course=30):
    rows = []
    attendance_id = 1
    for enr in enrollment_rows:
        attendance_rate = random.uniform(0.55, 0.98)
        start = date.fromisoformat(enr["enrollment_date"])
        for s in range(sessions_per_course):
            class_date = start + timedelta(days=7 * s)
            status = "Present" if random.random() < attendance_rate else "Absent"
            rows.append({
                "attendance_id": attendance_id,
                "enrollment_id": enr["enrollment_id"],
                "class_date": class_date.isoformat(),
                "status": status
            })
            attendance_id += 1
    return rows

# ---------------------------------------------------------------
# CSV WRITER HELPER
# ---------------------------------------------------------------
def write_csv(filename, rows):
    if not rows:
        return
    path = os.path.join(OUT_DIR, filename)
    with open(path, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=rows[0].keys())
        writer.writeheader()
        writer.writerows(rows)
    print(f"  wrote {len(rows):>6} rows -> {filename}")

# ---------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------
if __name__ == "__main__":
    print("Generating Gradia sample data...")

    faculty_rows = generate_faculty(n=12)
    student_rows = generate_students(n=60)
    course_rows = generate_courses(faculty_rows)
    enrollment_rows = generate_enrollments(student_rows, course_rows)
    grade_rows = generate_grades(enrollment_rows)
    attendance_rows = generate_attendance(enrollment_rows)

    write_csv("faculty.csv", faculty_rows)
    write_csv("students.csv", student_rows)
    write_csv("courses.csv", course_rows)
    write_csv("enrollments.csv", enrollment_rows)
    write_csv("grades.csv", grade_rows)
    write_csv("attendance.csv", attendance_rows)

    print("\nDone. CSV files are in ./data/")