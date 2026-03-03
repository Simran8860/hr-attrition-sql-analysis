-- =============================================
-- HR Attrition Analysis Project
-- Author: Simran Tyagi
-- Database: hr_attrition
-- =============================================

USE hr_attrition;

-- 1. Overall Attrition Rate
SELECT 
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
    ROUND(
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS attrition_rate_percent
FROM employee;


-- 2. Attrition by Department
SELECT 
    Department,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
    ROUND(
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS attrition_rate_percent
FROM employee
GROUP BY Department
ORDER BY attrition_rate_percent DESC;


-- 3. Age Group Segmentation
SELECT 
    CASE 
        WHEN Age < 30 THEN 'Under 30'
        WHEN Age BETWEEN 30 AND 40 THEN '30-40'
        WHEN Age BETWEEN 41 AND 50 THEN '41-50'
        ELSE '50+'
    END AS age_group,
    
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
    
    ROUND(
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS attrition_rate

FROM employee
GROUP BY age_group
ORDER BY attrition_rate DESC;


-- 4. Income Band Analysis
SELECT 
    CASE 
        WHEN MonthlyIncome < 3000 THEN 'Low Income'
        WHEN MonthlyIncome BETWEEN 3000 AND 7000 THEN 'Mid Income'
        ELSE 'High Income'
    END AS income_band,
    
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
    
    ROUND(
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS attrition_rate

FROM employee
GROUP BY income_band
ORDER BY attrition_rate DESC;


-- 5. Rank Job Roles by Attrition
SELECT 
    JobRole,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
    
    ROUND(
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS attrition_rate,
    
    RANK() OVER (
        ORDER BY 
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) DESC
    ) AS attrition_rank

FROM employee
GROUP BY JobRole;