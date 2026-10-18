# 🎓 Gradia — Student Management & Academic Analytics System

![MySQL](https://img.shields.io/badge/MySQL-005C84?style=for-the-badge&logo=mysql&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Status](https://img.shields.io/badge/Status-Complete-success?style=for-the-badge)

A full-stack database project built with **MySQL** and **Python**, designed to manage student records and generate meaningful academic analytics — GPA tracking, attendance analysis, at-risk student detection, and branch-wise performance comparison.

---

## 📌 Features

- ✅ Normalized 6-table relational schema (FACULTY, STUDENTS, COURSES, ENROLLMENTS, GRADES, ATTENDANCE)
- ✅ Synthetic but realistic data generation using Faker (en_IN locale) across 5 engineering branches
- ✅ Six analytical SQL queries covering GPA calculation, attendance tracking, risk detection, and performance ranking
- ✅ Advanced SQL concepts: window functions (`RANK()`), CTEs, and views

---

## 🛠️ Tech Stack

| Category | Technology |
|----------|-----------|
| Database | MySQL |
| Language | Python |
| Libraries | `mysql-connector-python`, `Faker` |

---

## 📂 Project Structure

```gradia/
├── schema.sql # Database schema definition
├── generate_data.py # Generates realistic synthetic data
├── db_setup.py # Loads CSV data into MySQL
├── Queries.sql # Analytical queries + views
└── data/ # Generated CSV data files
```

---

## 📊 Analytical Queries

| # | Query | Concept Used |
|---|-------|-------------|
| 1 | Student GPA (credit-weighted) | Aggregation, JOIN |
| 2 | Attendance Percentage per Course | CASE, Aggregation |
| 3 | At-Risk Student Detection | Multi-condition CASE |
| 4 | Top 3 Students Per Branch | `RANK()`, CTEs |
| 5 | Faculty Teaching Load | LEFT JOIN, COUNT |
| 6 | Branch-wise Performance Comparison | CTEs, Multi-table JOIN |

---

## 🚀 How to Run

**1. Set up MySQL locally** (e.g., via XAMPP)

**2. Run the schema:**
```bash
mysql -u root -p < schema.sql
```

**3. Generate sample data:**
```bash
python generate_data.py
```

**4. Load data into MySQL:**
```bash
python db_setup.py
```

**5. Run analytical queries** from `Queries.sql` directly in MySQL

---

## 👤 Author

**Yuvraj Sharadchandra Patil**  
Computer Engineering Student | Sinhgad College of Engineering

[GitHub](https://github.com/yuvraj-sp) • [LinkedIn](https://linkedin.com/in/yuvraj-s-patil)
