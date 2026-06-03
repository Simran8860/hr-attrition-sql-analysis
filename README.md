# Workforce Analytics & Retention Intelligence System
### Enterprise SQL Analytics Portfolio | People Analytics | HR Strategy

> *"Transforming raw HR data into actionable workforce intelligence — identifying attrition drivers, quantifying retention risk, and enabling evidence-based talent strategy."*

---

## Table of Contents
1. [Executive Summary](#executive-summary)
2. [Business Problem](#business-problem)
3. [Dataset Overview](#dataset-overview)
4. [SQL Architecture](#sql-architecture)
5. [Advanced SQL Concepts Used](#advanced-sql-concepts-used)
6. [KPI Framework](#kpi-framework)
7. [Key Business Insights](#key-business-insights)
8. [Workforce Recommendations](#workforce-recommendations)
9. [Project Structure](#project-structure)
10. [Interview Preparation](#interview-preparation)
11. [Future Improvements](#future-improvements)

---

## Executive Summary

This project delivers a **multi-layer SQL analytics framework** for workforce attrition modelling, retention intelligence, and HR KPI tracking — built on the IBM HR Analytics dataset (1,470 employees, 35 dimensions).

The solution moves beyond descriptive statistics into **predictive segmentation and executive-grade reporting**, structured across four SQL layers: Staging → Core KPIs → Advanced Analytics → Executive Insights. Each query solves a defined business problem, uses industry-standard analytical SQL patterns, and produces output directly consumable by BI tools (Tableau, Power BI, Looker).

**Key outputs include:**
- A composite **Flight Risk Score** identifying intervention candidates before they resign
- A **Workforce Health Index** benchmarking departments on retention, engagement, and workload
- Financial impact modelling estimating the **replacement cost of attrition by department**
- Cohort and tenure-based analysis identifying the **critical windows** when employees are most likely to leave

---

## Business Problem

### Why Attrition Matters

Employee attrition is not an HR metric — it is a **financial and operational risk**. The Society for Human Resource Management (SHRM) estimates that replacing a single employee costs **50–200% of their annual salary**, factoring in:

| Cost Category | Typical Range |
|---|---|
| Recruiting and sourcing | $3,000 – $15,000+ |
| Onboarding and training | 3–6 months of productivity loss |
| Lost institutional knowledge | Difficult to quantify; high impact |
| Team disruption and morale | Cascading attrition risk |
| Manager time cost | 20–40 hours per departure |

For an organisation of 1,470 employees with a **16.1% attrition rate** (237 departures), estimated annual replacement cost ranges from **$10M to $42M** depending on role level — making this a CFO-level concern, not just an HR operational problem.

### Business Objectives

| # | Objective | Business Owner |
|---|---|---|
| 1 | Quantify attrition rates by department, role, and demographic segment | CHRO |
| 2 | Identify the primary drivers of voluntary turnover | People Analytics Team |
| 3 | Segment current employees by flight risk for proactive intervention | HR Business Partners |
| 4 | Model the financial cost of attrition by department | CFO / Finance |
| 5 | Build a reusable KPI layer for monthly executive reporting | VP HR |
| 6 | Provide department-level workforce health benchmarking | Department Heads |

---

## Dataset Overview

**Source:** IBM HR Analytics Employee Attrition & Performance (Kaggle)  
**Rows:** 1,470 employees | **Columns:** 35 dimensions  
**Attrition Rate:** ~16.1% (237 of 1,470 employees)

| Dimension Category | Fields |
|---|---|
| Demographics | Age, Gender, MaritalStatus, EducationField |
| Employment | Department, JobRole, JobLevel, YearsAtCompany |
| Compensation | MonthlyIncome, DailyRate, HourlyRate, PercentSalaryHike |
| Engagement | JobSatisfaction, WorkLifeBalance, EnvironmentSatisfaction |
| Career | YearsSinceLastPromotion, TotalWorkingYears, NumCompaniesWorked |
| Workload | OverTime, BusinessTravel, TrainingTimesLastYear |

---

## SQL Architecture

The project is structured as a **4-layer modular SQL framework**, mirroring the analytical engineering patterns used in enterprise data warehouses (Medallion Architecture).

```
┌─────────────────────────────────────────────────────────┐
│  RAW LAYER — employee table (source data, untouched)    │
└────────────────────────┬────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────┐
│  STAGING LAYER — stg_employee view                      │
│  • Derived fields: attrition_flag, tenure_band,         │
│    age_band, salary_band, is_stagnant, flight_risk_score │
│  • All downstream views reference this, never raw data  │
└────────────────────────┬────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────┐
│  CORE KPI LAYER — vw_department_kpis, vw_jobrole_*      │
│  • Aggregated metrics with ranking functions            │
│  • Business-unit level scorecards                       │
└────────────────────────┬────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────┐
│  ADVANCED ANALYTICS LAYER                               │
│  • Salary band attrition, overtime impact,              │
│    tenure cohorts, promotion stagnation,                │
│    rolling trends, demographic breakdowns               │
└────────────────────────┬────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────┐
│  EXECUTIVE INSIGHT LAYER                                │
│  • High-risk employee watchlist                         │
│  • Financial cost of attrition model                   │
│  • Retention KPI summary (BI-tool ready)                │
└─────────────────────────────────────────────────────────┘
```

### Project Folder Structure

```
workforce-analytics-sql/
│
├── README.md
├── data/
│   └── Employee.csv
│
├── sql/
│   ├── 00_staging/
│   │   └── stg_employee.sql          ← Single source of truth view
│   │
│   ├── 01_core_kpis/
│   │   ├── vw_department_kpis.sql
│   │   └── vw_jobrole_attrition.sql
│   │
│   ├── 02_advanced_analytics/
│   │   ├── vw_salary_attrition.sql
│   │   ├── vw_overtime_impact.sql
│   │   ├── vw_tenure_attrition.sql
│   │   ├── vw_high_risk_employees.sql
│   │   ├── vw_cohort_analysis.sql
│   │   ├── vw_demographic_attrition.sql
│   │   └── vw_promotion_stagnation.sql
│   │
│   ├── 03_workforce_health/
│   │   ├── vw_dept_performance_index.sql
│   │   ├── vw_rolling_attrition_trend.sql
│   │   └── vw_workforce_stability.sql
│   │
│   └── 04_executive_insights/
│       ├── vw_retention_kpis.sql
│       ├── exec_financial_cost_model.sql
│       ├── exec_high_risk_watchlist.sql
│       └── exec_overtime_satisfaction.sql
│
└── docs/
    ├── business_recommendations.md
    └── kpi_dictionary.md
```

---

## Advanced SQL Concepts Used

Every technique below solves a specific business problem — nothing is added for cosmetic complexity.

| SQL Concept | Where Used | Business Purpose |
|---|---|---|
| **Staging View** | `stg_employee` | Single source of truth; derived fields computed once, reused everywhere |
| **CTEs (WITH clause)** | All analytical views | Modular, readable query structure; separates computation from presentation |
| **Nested CTEs** | `vw_salary_attrition`, `vw_cohort_analysis` | Multi-step transformations without subquery nesting hell |
| **CASE WHEN** | Staging layer, all views | Business-defined segments (salary bands, risk tiers, tenure bands) |
| **Window Functions** | 8+ views | Ranking, running totals, period comparisons without self-joins |
| **RANK() / DENSE_RANK()** | `vw_jobrole_attrition`, `vw_dept_kpis` | Leaderboard-style role and department rankings |
| **ROW_NUMBER()** | `vw_high_risk_employees` | Department-scoped employee risk watchlist |
| **NTILE()** | `vw_jobrole_attrition`, `vw_dept_performance_index` | Quartile/tier bucketing for dashboard colour coding |
| **PERCENT_RANK()** | `vw_dept_performance_index` | Relative standing for executive benchmarking |
| **LAG()** | `vw_tenure_attrition`, `vw_cohort_analysis` | Period-over-period attrition rate change |
| **FIRST_VALUE()** | `vw_overtime_impact` | Overtime attrition premium vs. baseline |
| **PARTITION BY** | Multiple views | Department-scoped rankings without losing other rows |
| **Running Totals** | `vw_salary_attrition`, `vw_rolling_attrition_trend` | Cumulative attrition across salary/tenure spectrum |
| **Rolling Averages** | `vw_rolling_attrition_trend` | 3-band smoothed attrition trend |
| **NULLIF()** | `vw_promotion_stagnation` | Safe division — prevents divide-by-zero on small segments |
| **HAVING** | `vw_demographic_attrition` | Suppresses statistically unreliable micro-segments |
| **UNION ALL** | `vw_retention_kpis` | Metric-value-context format for direct BI tool consumption |
| **Composite Scoring** | Staging `flight_risk_score`, `workforce_health_index` | Multi-factor risk and health indices |

---

## KPI Framework

### Tier 1 — Executive Dashboard KPIs

| KPI | Definition | Target |
|---|---|---|
| Overall Attrition Rate | Attrited ÷ Total Headcount | < 12% |
| Retention Rate | Active ÷ Total Headcount | > 88% |
| Estimated Replacement Cost | Attrited × 0.75 × Annual Salary | Minimise |
| % Workforce at High Flight Risk | Risk Score ≥ 3 ÷ Active HC | < 15% |

### Tier 2 — Department Operations KPIs

| KPI | Definition |
|---|---|
| Department Attrition Rate | Dept Attrited ÷ Dept Headcount |
| Overtime Rate | OT Workers ÷ Dept Headcount |
| Avg Job Satisfaction | Mean(JobSatisfaction) per dept |
| Workforce Health Index | Weighted composite score |

### Tier 3 — People Analytics Deep-Dive Metrics

| KPI | Definition |
|---|---|
| Cohort Attrition Delta | Attrition rate change between tenure bands |
| Stagnation Rate | Employees >3yr without promotion ÷ Total |
| Overtime Attrition Premium | OT attrition rate − non-OT attrition rate |
| Salary Band Attrition Gap | Attrition rate difference: lowest vs. highest band |

---

## Key Business Insights

> *Derived from the IBM HR Analytics dataset; findings directionally consistent with industry research.*

### 1. Attrition is Concentrated in Low-Tenure, Low-Income Segments
Employees in the **0–1 year** tenure band show the highest attrition rate, suggesting onboarding and early engagement are the highest-ROI retention levers. Employees in the lowest salary band (< $2,500/month) attrite at nearly **3× the rate** of employees in the top band.

### 2. Overtime is the Strongest Controllable Driver
Employees working overtime show an attrition rate approximately **2× higher** than non-overtime peers within the same department. This is the single highest-impact operational variable HR managers can influence directly.

### 3. Sales Department Carries Disproportionate Risk
The Sales department shows both the highest attrition rate among departments and the highest proportion of overtime workers — a compounding risk. Sales Representatives rank #1 in role-level attrition.

### 4. Career Stagnation Amplifies Attrition Risk
Employees who have not been promoted in 3+ years show measurably higher attrition than actively promoted peers — even when compensation is equal. This indicates that career growth visibility matters as much as pay.

### 5. Engagement Scores Are Leading Indicators
Employees with JobSatisfaction ≤ 2 or WorkLifeBalance ≤ 2 attrite at significantly higher rates. Since engagement surveys are collected before departure, these scores function as **early warning signals** that can trigger manager intervention.

---

## Workforce Recommendations

### Priority 1 — Immediate Interventions (0–90 Days)

| Action | Target Segment | Expected Impact |
|---|---|---|
| Manager 1:1 review for CRITICAL risk employees | Flight risk score ≥ 4, currently active | Reduce near-term voluntary attrition |
| Overtime audit and scheduling relief | OT workers with satisfaction ≤ 2 | Address top controllable attrition driver |
| 30/60/90-day check-in programme | 0–1 year tenure employees | Reduce early-career attrition |

### Priority 2 — Medium-Term Structural Actions (90 Days – 6 Months)

| Action | Target | Owner |
|---|---|---|
| Salary band review for Band 1 & Band 2 employees | Compensation team | CHRO + CFO |
| Promotion pipeline audit (3yr+ stagnant employees) | Talent Management | Department Heads |
| Sales department workload restructure | Sales VP | COO |
| Engagement pulse survey in R&D | HR Business Partner | VP HR |

### Priority 3 — Long-Term Retention Architecture (6–12 Months)

- Formalise an **internal mobility programme** to reduce stagnation
- Implement a **predictive flight risk model** (monthly scoring of all active employees)
- Create a **retention investment framework** that ties retention spend to estimated replacement cost
- Build a **manager effectiveness index** combining team attrition, satisfaction, and promotion rates

### Risk-to-Action Mapping

```
Flight Risk Score 5  → CHRO escalation + immediate retention offer
Flight Risk Score 4  → HR Business Partner intervention within 2 weeks
Flight Risk Score 3  → Manager conversation + development plan review
Flight Risk Score 2  → Include in next engagement cycle monitoring
Flight Risk Score 0-1 → Standard monitoring
```

---

## Interview Preparation

### SQL Technical Questions

**Q: Why did you build a staging view instead of querying the raw table directly?**

> The staging view (`stg_employee`) is the most important architectural decision in the project. It does three things: (1) it centralises all derived field logic — salary bands, flight risk score, tenure bands — so if a business rule changes, I update it in one place, not across 12 queries; (2) it enforces a clean separation between raw data and analytical logic; (3) it mirrors how a real dbt/Medallion architecture would work in production, where a staging layer normalises source data before it reaches analytical consumers. Any recruiter who has worked in an actual analytics team will recognise this pattern immediately.

**Q: Explain your flight_risk_score calculation. Why those specific factors?**

> The score sums five binary indicators: overtime, low job satisfaction (≤2), poor work-life balance (≤2), career stagnation (>3 years without promotion), and low environment satisfaction (≤2). Each factor has empirical backing in HR research as a predictor of voluntary attrition. The composite score gives a 0–5 range, which I then bucket into CRITICAL/HIGH/MEDIUM/LOW risk tiers. A key design decision was keeping it interpretable — five factors a manager can actually act on — rather than a black-box score. In a production environment, I'd calibrate the weights using logistic regression on historical attrition data.

**Q: When would you use RANK() vs DENSE_RANK() vs ROW_NUMBER()?**

> `ROW_NUMBER()` assigns a unique sequential integer regardless of ties — I use it in `vw_high_risk_employees` where I need exactly one watchlist position per employee. `RANK()` skips numbers after ties (1,1,3) — I use it for department-level rankings where tied departments should see the same rank and the skip communicates "these are equivalent." `DENSE_RANK()` doesn't skip (1,1,2) — I use it in `vw_jobrole_attrition` where I don't want gaps to mislead a reader into thinking there are missing roles.

**Q: How does your rolling average work, and why a 3-band window?**

> The rolling average uses `AVG() OVER (ORDER BY sort_order ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)`. This creates a 3-period moving average that smooths out single-band noise — a common technique in time-series analysis. In this dataset, tenure bands replace time periods, so the "rolling" dimension is tenure progression rather than calendar time. Three periods is the standard for small datasets; with monthly calendar data I would extend to 6 or 12 months.

**Q: Why use NULLIF() in the promotion stagnation query?**

> `NULLIF(stagnant_count, 0)` prevents a divide-by-zero error when computing the stagnant attrition rate for segments where no one is stagnant. Without it, MySQL would throw an error or return NULL unexpectedly. It's a defensive coding practice that makes queries production-safe — critical if this view is embedded in a dashboard that auto-refreshes.

---

### Business Analytics Questions

**Q: How would you present this analysis to a non-technical CHRO?**

> I'd lead with the financial number — "We're likely spending $10–20M annually replacing employees who leave." Then I'd show three visuals: (1) the department risk leaderboard, (2) the overtime-attrition connection as a simple bar chart, and (3) the high-risk watchlist as a prioritised action list. I wouldn't show a single SQL query. The analytical depth shows in the accuracy and specificity of the insights, not in the code. The ask at the end would be specific: "Approve a 90-day intervention programme for the 47 CRITICAL-risk employees."

**Q: What's the difference between correlation and causation in this analysis?**

> This is observational data, so all findings are correlational. I cannot claim that overtime *causes* attrition — it's possible that already-disengaged employees are assigned more overtime, creating reverse causality. To establish causation I'd need an experimental design (e.g., a controlled overtime reduction pilot in one department) or natural experiment data. In the recommendations I am careful to say "overtime correlates with attrition at 2x the rate" rather than "overtime causes attrition."

---

### Stakeholder Questions

**Q: A VP of Sales pushes back: "Our attrition is high because we hire young people who leave after 2 years — it's industry standard." How do you respond?**

> I'd validate the hypothesis with data first. I'd segment Sales attrition by age and tenure to test whether the pattern holds only in early-career employees or extends to mid-career staff. If Sales attrition in the 3–7 year tenure band is also elevated, that's evidence beyond industry baseline behaviour. I'd also ask the VP to share external benchmarks — if the industry average Sales attrition is 25% and we're at 22%, the conversation changes. The goal isn't to win the argument; it's to reach the right diagnostic conclusion together.

---

## Future Improvements

| Improvement | Type | Estimated Impact |
|---|---|---|
| Integrate time-series data (monthly snapshots) to replace tenure-as-proxy | Data | High — enables true trend analysis |
| Logistic regression model for attrition probability (Python + SQL) | Modelling | High — upgrades from descriptive to predictive |
| dbt model conversion (staging → marts) | Architecture | Medium — production-grade data pipeline |
| Power BI / Tableau dashboard connected to views | Visualisation | High — makes project end-to-end demonstrable |
| Cost model calibration with actual industry salary data | Business | Medium — improves financial estimate accuracy |
| Manager effectiveness index (team attrition + satisfaction combined) | Analytics | Medium — adds people manager dimension |
| Survival analysis: time-to-attrition modelling | Advanced Analytics | High — identifies exact intervention timing |

---

## Key Design Decisions

**1. Staging view as single source of truth**  
All business logic (bands, scores, flags) lives in `stg_employee`. No downstream view contains derived field definitions. This means a business rule change requires editing exactly one view.

**2. Views over stored procedures**  
Views are readable, debuggable, and chainable. For a portfolio project demonstrating SQL logic, views show the analytical thinking more clearly than procedural code.

**3. Flight risk score kept interpretable**  
A 0–5 additive score with named factors is immediately actionable by a non-technical HR manager. A black-box ML score would be more accurate but less adoptable in a real HR context.

**4. NULLIF() for division safety**  
Every division operation involving a potentially-zero denominator uses `NULLIF()` rather than a `WHERE` filter that would silently drop rows.

**5. HAVING to suppress micro-segments**  
Segments with fewer than 5 employees produce statistically unreliable attrition rates (e.g., a team of 2 where 1 person left = 50% "attrition"). The `HAVING COUNT(*) >= 5` filter prevents misleading executive reporting.

---

*Built with MySQL 8.0 | Dataset: IBM HR Analytics (Kaggle) | Author: Simran Tyagi*
