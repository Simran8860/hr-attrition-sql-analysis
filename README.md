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
├── sql/
└── docs/
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

*Built with MySQL 8.0 | Dataset: IBM HR Analytics (Kaggle) | Author: Simran Tyagi*
