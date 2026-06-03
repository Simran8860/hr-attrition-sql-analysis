# HR Attrition Analysis
### SQL Analytics Project | MySQL | People Analytics

---

## Overview

This project analyses employee attrition patterns using SQL on the IBM HR Analytics dataset (1,470 employees, 35 attributes). The goal is to understand *why* employees leave, identify which segments are most at risk, and surface insights that HR teams can act on.

The analysis is structured in five logical sections — from a headline attrition rate all the way to a prioritised list of current employees showing multiple risk factors.

**Tools:** MySQL 8.0 | MySQL Workbench  
**Dataset:** IBM HR Analytics Employee Attrition & Performance (Kaggle)

---

## Business Problem

Employee attrition is expensive. Replacing a single employee typically costs 50–150% of their annual salary when you factor in recruiting, onboarding time, and lost productivity. For a company of 1,470 employees with a 16.1% attrition rate, that adds up quickly.

The core questions this analysis answers:

1. Which departments and roles have the highest attrition rates?
2. Who is most likely to leave — and why?
3. What are the key drivers: compensation, overtime, satisfaction, career growth?
4. Which current employees show the most warning signs?

---

## Dataset Overview

| Category | Columns |
|---|---|
| Demographics | Age, Gender, MaritalStatus, EducationField |
| Employment | Department, JobRole, JobLevel, YearsAtCompany |
| Compensation | MonthlyIncome, PercentSalaryHike |
| Engagement | JobSatisfaction, WorkLifeBalance, EnvironmentSatisfaction |
| Career | YearsSinceLastPromotion, TotalWorkingYears, NumCompaniesWorked |
| Workload | OverTime, BusinessTravel |

---

## Project Structure

```
hr-attrition-analysis/
├── README.md
├── Employee.csv
└── hr_attrition_analysis.sql
```

The SQL file is organised into five clearly commented sections:

| Section | What it covers |
|---|---|
| 1. Base View | Reusable view with derived fields (age groups, tenure bands, salary bands) |
| 2. Core Attrition Analysis | Overall rate, by department, by job role |
| 3. Workforce Segmentation | Age, tenure, salary band, demographic breakdowns |
| 4. Attrition Driver Analysis | Overtime, job satisfaction, promotions, work-life balance, travel |
| 5. At-Risk Employee Identification | Multi-factor risk profiling of current employees |

---

## SQL Concepts Used

| Concept | Where and Why |
|---|---|
| **Base View** (`CREATE VIEW`) | Derived fields (bands, flags) defined once and reused across all queries |
| **CTEs** (`WITH`) | Break multi-step queries into readable, logical steps |
| **CASE WHEN** | Create meaningful business segments from raw numeric fields |
| **Aggregations** (`COUNT`, `SUM`, `AVG`, `ROUND`) | Core metrics for every analysis |
| **RANK()** | Department and role leaderboards by attrition rate |
| **DENSE_RANK()** | Role ranking without gaps when two roles tie |
| **ROW_NUMBER() with PARTITION BY** | Per-department priority ranking of at-risk employees |
| **LAG()** | Period-over-period attrition rate change across tenure stages |
| **HAVING** | Filter out segments too small to draw reliable conclusions from |

---

## Key Findings

**1. Overall attrition rate is 16.1%** — above the general industry benchmark of 10–12%, suggesting a meaningful retention problem.

**2. Sales has the highest department attrition** — compounded by the highest overtime rate. Sales Representatives are the single highest-attriting job role.

**3. Early-career employees (0–1 year tenure) leave at the highest rate** — pointing to onboarding and early engagement as high-ROI areas for intervention.

**4. Overtime workers leave at roughly twice the rate of non-overtime peers** — the most actionable finding in the dataset, since workload is something managers can directly control.

**5. Low salary + low satisfaction is the riskiest combination** — employees in the lowest salary band who also report low job satisfaction have the highest attrition rate by a wide margin.

**6. Promotion stagnation matters** — employees who haven't been promoted in 5+ years attrite at a noticeably higher rate, even after controlling for salary level.

---

## Recommendations

| Finding | Recommended Action |
|---|---|
| High overtime in Sales | Audit workload distribution; review if headcount matches targets |
| Early-career attrition (0–1 yr) | Structured 30/60/90-day check-ins for new joiners |
| Low satisfaction scores | Use satisfaction data as an early warning — flag scores ≤ 2 for manager follow-up |
| Promotion stagnation | Conduct a promotion pipeline review for employees 4+ years without movement |
| Low salary band attrition | Prioritise compensation review for employees in the lowest band with key skills |

---

## Future Improvements

- Add a **Tableau or Power BI dashboard** connecting directly to the SQL views for visual reporting
- Incorporate **time-series data** (monthly snapshots) to track attrition trends over time rather than using tenure as a proxy
- Build a **Python analysis layer** with logistic regression to predict attrition probability per employee

---

*Author: Simran Tyagi | MySQL 8.0 | IBM HR Analytics Dataset (Kaggle)*
