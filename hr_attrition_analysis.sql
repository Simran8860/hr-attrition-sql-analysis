-- ================================================
-- HR Attrition Analysis
-- Author   : Simran Tyagi
-- Database : hr_attrition
-- Tool     : MySQL 8.0
-- Dataset  : IBM HR Analytics (1,470 employees)
-- ================================================
-- Project structure:
--   Section 1. Base View (reusable derived fields)
--   Section 2. Core Attrition Analysis
--   Section 3. Workforce Segmentation
--   Section 4. Attrition Driver Analysis
--   Section 5. At-Risk Employee Identification
-- ================================================

USE hr_attrition;


-- ================================================
-- SECTION 1. BASE VIEW
-- A single reusable view that adds derived columns
-- (bands, flags) so every query below stays clean
-- and business definitions are defined once.
-- ================================================

CREATE OR REPLACE VIEW v_employee AS
SELECT
    EmployeeNumber,
    Age,
    Gender,
    MaritalStatus,
    EducationField,
    Department,
    JobRole,
    JobLevel,
    MonthlyIncome,
    PercentSalaryHike,
    PerformanceRating,
    JobSatisfaction,
    EnvironmentSatisfaction,
    WorkLifeBalance,
    BusinessTravel,
    DistanceFromHome,
    OverTime,
    TotalWorkingYears,
    YearsAtCompany,
    YearsInCurrentRole,
    YearsSinceLastPromotion,
    YearsWithCurrManager,
    NumCompaniesWorked,
    TrainingTimesLastYear,
    Attrition,

    -- Binary flag makes aggregations simpler and readable
    CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END AS attrition_flag,

    -- Age grouping for demographic analysis
    CASE
        WHEN Age < 25              THEN 'Under 25'
        WHEN Age BETWEEN 25 AND 34 THEN '25-34'
        WHEN Age BETWEEN 35 AND 44 THEN '35-44'
        WHEN Age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END AS age_group,

    -- Tenure grouping to identify which career stage has highest attrition
    CASE
        WHEN YearsAtCompany <= 1  THEN '0-1 Years'
        WHEN YearsAtCompany <= 3  THEN '1-3 Years'
        WHEN YearsAtCompany <= 5  THEN '3-5 Years'
        WHEN YearsAtCompany <= 10 THEN '5-10 Years'
        ELSE '10+ Years'
    END AS tenure_group,

    -- Salary banding for compensation vs attrition analysis
    CASE
        WHEN MonthlyIncome < 3000  THEN 'Low (< 3K)'
        WHEN MonthlyIncome < 6000  THEN 'Mid (3-6K)'
        WHEN MonthlyIncome < 10000 THEN 'Upper-Mid (6-10K)'
        ELSE 'High (10K+)'
    END AS salary_band

FROM employee;


-- ================================================
-- SECTION 2. CORE ATTRITION ANALYSIS
-- ================================================

-- ── Q1. Overall attrition rate ───────────────────
-- The headline number — what percentage of the
-- workforce has left? Baseline for all comparisons.

SELECT
    COUNT(*)                                                        AS total_employees,
    SUM(attrition_flag)                                             AS employees_left,
    ROUND(SUM(attrition_flag) * 100.0 / COUNT(*), 2)               AS attrition_rate_pct,
    ROUND((1 - SUM(attrition_flag) / COUNT(*)) * 100.0, 2)         AS retention_rate_pct
FROM v_employee;


-- ── Q2. Attrition by department ──────────────────
-- Which departments are losing people at the highest
-- rate? RANK() adds a leaderboard view so HR can
-- immediately see which unit needs the most attention.

WITH dept_summary AS (
    SELECT
        Department,
        COUNT(*)            AS total_employees,
        SUM(attrition_flag) AS employees_left,
        ROUND(AVG(MonthlyIncome), 2) AS avg_monthly_income,
        ROUND(AVG(YearsAtCompany), 2) AS avg_tenure_years
    FROM v_employee
    GROUP BY Department
)
SELECT
    Department,
    total_employees,
    employees_left,
    ROUND(employees_left * 100.0 / total_employees, 2) AS attrition_rate_pct,
    avg_monthly_income,
    avg_tenure_years,
    RANK() OVER (ORDER BY employees_left * 100.0 / total_employees DESC) AS attrition_rank
FROM dept_summary
ORDER BY attrition_rate_pct DESC;


-- ── Q3. Attrition by job role ────────────────────
-- Role-level attrition to identify which positions
-- have the highest turnover. DENSE_RANK used so tied
-- roles share a rank without creating misleading gaps.

WITH role_summary AS (
    SELECT
        JobRole,
        Department,
        COUNT(*)            AS total_employees,
        SUM(attrition_flag) AS employees_left,
        ROUND(AVG(MonthlyIncome), 2)   AS avg_income,
        ROUND(AVG(JobSatisfaction), 2) AS avg_job_satisfaction
    FROM v_employee
    GROUP BY JobRole, Department
)
SELECT
    JobRole,
    Department,
    total_employees,
    employees_left,
    ROUND(employees_left * 100.0 / total_employees, 2) AS attrition_rate_pct,
    avg_income,
    avg_job_satisfaction,
    DENSE_RANK() OVER (ORDER BY employees_left * 100.0 / total_employees DESC) AS role_attrition_rank
FROM role_summary
ORDER BY attrition_rate_pct DESC;


-- ================================================
-- SECTION 3. WORKFORCE SEGMENTATION
-- ================================================

-- ── Q4. Attrition by age group ───────────────────
-- Are younger employees leaving at a higher rate?
-- Age group segmentation reveals early-career
-- attrition risk vs. mid/senior-career stability.

SELECT
    age_group,
    COUNT(*)                                                   AS total_employees,
    SUM(attrition_flag)                                        AS employees_left,
    ROUND(SUM(attrition_flag) * 100.0 / COUNT(*), 2)          AS attrition_rate_pct,
    ROUND(AVG(MonthlyIncome), 2)                               AS avg_income,
    RANK() OVER (ORDER BY SUM(attrition_flag) * 100.0 / COUNT(*) DESC) AS risk_rank
FROM v_employee
GROUP BY age_group
ORDER BY attrition_rate_pct DESC;


-- ── Q5. Attrition by tenure group ───────────────
-- At what stage of tenure do employees leave most?
-- This helps HR decide where to invest in retention
-- programmes — onboarding vs. mid-career support.
-- LAG() shows the change in attrition rate between
-- consecutive tenure stages.

WITH tenure_summary AS (
    SELECT
        tenure_group,
        MIN(YearsAtCompany)                                    AS sort_order,
        COUNT(*)                                               AS total_employees,
        SUM(attrition_flag)                                    AS employees_left,
        ROUND(AVG(MonthlyIncome), 2)                           AS avg_income,
        ROUND(AVG(JobSatisfaction), 2)                         AS avg_satisfaction
    FROM v_employee
    GROUP BY tenure_group
),
tenure_rates AS (
    SELECT
        *,
        ROUND(employees_left * 100.0 / total_employees, 2) AS attrition_rate_pct
    FROM tenure_summary
)
SELECT
    tenure_group,
    total_employees,
    employees_left,
    attrition_rate_pct,
    avg_income,
    avg_satisfaction,
    -- How much did attrition rate change from the previous tenure stage?
    LAG(attrition_rate_pct) OVER (ORDER BY sort_order)                     AS prev_stage_rate_pct,
    ROUND(
        attrition_rate_pct - LAG(attrition_rate_pct) OVER (ORDER BY sort_order),
        2
    )                                                                      AS rate_change_ppt
FROM tenure_rates
ORDER BY sort_order;


-- ── Q6. Attrition by salary band ────────────────
-- Are lower-paid employees leaving more?
-- Tests the compensation-attrition relationship.

SELECT
    salary_band,
    COUNT(*)                                                   AS total_employees,
    SUM(attrition_flag)                                        AS employees_left,
    ROUND(SUM(attrition_flag) * 100.0 / COUNT(*), 2)          AS attrition_rate_pct,
    ROUND(AVG(MonthlyIncome), 2)                               AS avg_income,
    RANK() OVER (ORDER BY SUM(attrition_flag) * 100.0 / COUNT(*) DESC) AS risk_rank
FROM v_employee
GROUP BY salary_band
ORDER BY avg_income;


-- ── Q7. Attrition by gender and marital status ──
-- Demographic breakdown to understand if attrition
-- affects any specific group disproportionately.

SELECT
    Gender,
    MaritalStatus,
    COUNT(*)                                                   AS total_employees,
    SUM(attrition_flag)                                        AS employees_left,
    ROUND(SUM(attrition_flag) * 100.0 / COUNT(*), 2)          AS attrition_rate_pct,
    ROUND(AVG(MonthlyIncome), 2)                               AS avg_income
FROM v_employee
GROUP BY Gender, MaritalStatus
ORDER BY attrition_rate_pct DESC;


-- ================================================
-- SECTION 4. ATTRITION DRIVER ANALYSIS
-- ================================================

-- ── Q8. Impact of overtime on attrition ─────────
-- Overtime is one of the most cited drivers of
-- burnout and voluntary departure. This query
-- shows the attrition rate split for OT vs non-OT
-- employees within each department.

SELECT
    Department,
    OverTime,
    COUNT(*)                                                   AS total_employees,
    SUM(attrition_flag)                                        AS employees_left,
    ROUND(SUM(attrition_flag) * 100.0 / COUNT(*), 2)          AS attrition_rate_pct,
    ROUND(AVG(WorkLifeBalance), 2)                             AS avg_work_life_balance,
    ROUND(AVG(JobSatisfaction), 2)                             AS avg_job_satisfaction
FROM v_employee
GROUP BY Department, OverTime
ORDER BY Department, OverTime;


-- ── Q9. Job satisfaction vs. attrition ──────────
-- Do employees with low satisfaction scores leave
-- more? This tests if engagement data can serve
-- as an early warning signal.

SELECT
    JobSatisfaction,
    CASE
        WHEN JobSatisfaction = 1 THEN 'Low'
        WHEN JobSatisfaction = 2 THEN 'Below Average'
        WHEN JobSatisfaction = 3 THEN 'Above Average'
        ELSE 'High'
    END AS satisfaction_label,
    COUNT(*)                                                   AS total_employees,
    SUM(attrition_flag)                                        AS employees_left,
    ROUND(SUM(attrition_flag) * 100.0 / COUNT(*), 2)          AS attrition_rate_pct
FROM v_employee
GROUP BY JobSatisfaction, satisfaction_label
ORDER BY JobSatisfaction;


-- ── Q10. Promotion stagnation vs. attrition ─────
-- Employees who haven't been promoted in a while
-- may feel stuck and look elsewhere. This query
-- groups employees by years since last promotion
-- and checks if stagnation correlates with attrition.

SELECT
    CASE
        WHEN YearsSinceLastPromotion = 0 THEN 'Just Promoted'
        WHEN YearsSinceLastPromotion <= 2 THEN '1-2 Years Ago'
        WHEN YearsSinceLastPromotion <= 4 THEN '3-4 Years Ago'
        ELSE '5+ Years Ago'
    END AS promotion_recency,
    COUNT(*)                                                   AS total_employees,
    SUM(attrition_flag)                                        AS employees_left,
    ROUND(SUM(attrition_flag) * 100.0 / COUNT(*), 2)          AS attrition_rate_pct,
    ROUND(AVG(MonthlyIncome), 2)                               AS avg_income,
    ROUND(AVG(JobSatisfaction), 2)                             AS avg_satisfaction
FROM v_employee
GROUP BY promotion_recency
ORDER BY attrition_rate_pct DESC;


-- ── Q11. Work-life balance vs. attrition ────────

SELECT
    WorkLifeBalance,
    CASE
        WHEN WorkLifeBalance = 1 THEN 'Poor'
        WHEN WorkLifeBalance = 2 THEN 'Fair'
        WHEN WorkLifeBalance = 3 THEN 'Good'
        ELSE 'Excellent'
    END AS wlb_label,
    COUNT(*)                                                   AS total_employees,
    SUM(attrition_flag)                                        AS employees_left,
    ROUND(SUM(attrition_flag) * 100.0 / COUNT(*), 2)          AS attrition_rate_pct
FROM v_employee
GROUP BY WorkLifeBalance, wlb_label
ORDER BY WorkLifeBalance;


-- ── Q12. Business travel vs. attrition ──────────

SELECT
    BusinessTravel,
    COUNT(*)                                                   AS total_employees,
    SUM(attrition_flag)                                        AS employees_left,
    ROUND(SUM(attrition_flag) * 100.0 / COUNT(*), 2)          AS attrition_rate_pct,
    ROUND(AVG(MonthlyIncome), 2)                               AS avg_income
FROM v_employee
GROUP BY BusinessTravel
ORDER BY attrition_rate_pct DESC;


-- ================================================
-- SECTION 5. AT-RISK EMPLOYEE IDENTIFICATION
-- ================================================

-- ── Q13. High-risk employee segments ────────────
-- Identifies current employees who show multiple
-- warning signs at once — overtime + low satisfaction
-- + no recent promotion. These are the people most
-- likely to leave next and worth HR's attention.
-- ROW_NUMBER() ranks them within each department
-- so managers get a prioritised list for their team.

WITH risk_profile AS (
    SELECT
        EmployeeNumber,
        Department,
        JobRole,
        Age,
        MonthlyIncome,
        YearsAtCompany,
        YearsSinceLastPromotion,
        OverTime,
        JobSatisfaction,
        WorkLifeBalance,
        -- Count how many risk factors each employee has (max 3)
        (
            CASE WHEN OverTime = 'Yes'           THEN 1 ELSE 0 END +
            CASE WHEN JobSatisfaction <= 2        THEN 1 ELSE 0 END +
            CASE WHEN YearsSinceLastPromotion > 3 THEN 1 ELSE 0 END
        ) AS risk_factor_count
    FROM v_employee
    WHERE Attrition = 'No'   -- current employees only
)
SELECT
    EmployeeNumber,
    Department,
    JobRole,
    Age,
    MonthlyIncome,
    YearsAtCompany,
    YearsSinceLastPromotion,
    OverTime,
    JobSatisfaction,
    WorkLifeBalance,
    risk_factor_count,
    CASE
        WHEN risk_factor_count = 3 THEN 'High Risk'
        WHEN risk_factor_count = 2 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_level,
    -- Rank within department so managers see their own team's priority list
    ROW_NUMBER() OVER (
        PARTITION BY Department
        ORDER BY risk_factor_count DESC, YearsSinceLastPromotion DESC
    ) AS dept_priority_rank
FROM risk_profile
WHERE risk_factor_count >= 2
ORDER BY risk_factor_count DESC, Department;


-- ── Q14. Department attrition + workforce summary
-- A combined summary view useful for a dashboard
-- or final reporting slide — attrition rate, avg
-- satisfaction, overtime %, and compensation by dept.

SELECT
    Department,
    COUNT(*)                                                        AS total_employees,
    SUM(attrition_flag)                                             AS employees_left,
    ROUND(SUM(attrition_flag) * 100.0 / COUNT(*), 2)               AS attrition_rate_pct,
    ROUND(AVG(MonthlyIncome), 2)                                    AS avg_monthly_income,
    ROUND(AVG(JobSatisfaction), 2)                                  AS avg_job_satisfaction,
    ROUND(AVG(WorkLifeBalance), 2)                                  AS avg_work_life_balance,
    ROUND(SUM(CASE WHEN OverTime = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
                                                                    AS overtime_rate_pct,
    RANK() OVER (ORDER BY SUM(attrition_flag) * 100.0 / COUNT(*) DESC) AS attrition_rank
FROM v_employee
GROUP BY Department
ORDER BY attrition_rate_pct DESC;


-- ================================================
-- END OF SCRIPT
-- ================================================
