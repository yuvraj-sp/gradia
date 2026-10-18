"""
Gradia - Database Loader
Connects to local MySQL and loads all CSV files from ./data/ into
their matching tables. Run this AFTER schema.sql has been applied.

Run: python db_setup.py
"""

import csv
import os
import mysql.connector

DATA_DIR = os.path.join(os.path.dirname(__file__), "data")

DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "",       # blank by default in XAMPP
    "database": "gradia",
}

# Order matters: parent tables before child tables (matches foreign key dependencies)
LOAD_ORDER = [
    ("faculty.csv", "FACULTY", ["faculty_id", "first_name", "last_name", "department", "email"]),
    ("students.csv", "STUDENTS", ["student_id", "first_name", "last_name", "dob", "email", "enrollment_year", "branch"]),
    ("courses.csv", "COURSES", ["course_id", "course_name", "credits", "semester", "faculty_id", "capacity", "branch"]),
    ("enrollments.csv", "ENROLLMENTS", ["enrollment_id", "student_id", "course_id", "enrollment_date", "status"]),
    ("grades.csv", "GRADES", ["grade_id", "enrollment_id", "exam_type", "marks", "grade_letter"]),
    ("attendance.csv", "ATTENDANCE", ["attendance_id", "enrollment_id", "class_date", "status"]),
]


def load_csv_to_table(cursor, filename, table_name, columns):
    path = os.path.join(DATA_DIR, filename)
    with open(path, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        rows = [tuple(row[col] for col in columns) for row in reader]

    placeholders = ", ".join(["%s"] * len(columns))
    col_list = ", ".join(columns)
    insert_sql = f"INSERT INTO {table_name} ({col_list}) VALUES ({placeholders})"

    cursor.executemany(insert_sql, rows)
    print(f"  loaded {len(rows):>6} rows -> {table_name}")


def main():
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()

    # temporarily disable FK checks so table order issues don't block us mid-load
    cursor.execute("SET FOREIGN_KEY_CHECKS = 0")

    print("Loading Gradia data into MySQL...")
    for filename, table_name, columns in LOAD_ORDER:
        load_csv_to_table(cursor, filename, table_name, columns)

    cursor.execute("SET FOREIGN_KEY_CHECKS = 1")
    conn.commit()

    cursor.close()
    conn.close()
    print("\nDone. All data loaded into the 'gradia' database.")


if __name__ == "__main__":
    main()