-- ============================================
-- IT Service Desk Analytics
-- Tools: MySQL, Power BI
-- Dataset: ITSM Dataset (100,000 tickets)
-- ============================================

-- Query 1: Average Resolution Time by Priority
SELECT 
    Priority,
    ROUND(AVG(TIME_TO_SEC(TIMEDIFF(resolution_time, created_time))/3600), 2) AS avg_resolution_hours
FROM project.itsm_tickets
GROUP BY Priority
ORDER BY avg_resolution_hours DESC;

-- Query 2: Average Resolution Time by Agent Group
SELECT 
    agent_group,
    ROUND(AVG(TIME_TO_SEC(TIMEDIFF(resolution_time, created_time))/3600), 2) AS avg_resolution_hours
FROM project.itsm_tickets
GROUP BY agent_group
ORDER BY avg_resolution_hours DESC;

-- Query 3: Average Resolution Time by Source
SELECT 
    Source,
    ROUND(AVG(TIME_TO_SEC(TIMEDIFF(resolution_time, created_time))/3600), 2) AS avg_resolution_hours
FROM project.itsm_tickets
GROUP BY Source
ORDER BY avg_resolution_hours DESC;

-- Query 4: Monthly Ticket Volume Trend
SELECT 
    YEAR(created_time) AS year,
    MONTH(created_time) AS month,
    COUNT(ticket_ID) AS tickets_per_month
FROM project.itsm_tickets
GROUP BY year, month
ORDER BY year, month;

-- Query 5: Dissatisfaction Rate by Topic
SELECT 
    Topic,
    COUNT(*) AS total_tickets,
    SUM(CASE WHEN survey_results = 'Dissatisfied' THEN 1 ELSE 0 END) AS dissatisfied_count,
    ROUND(SUM(CASE WHEN survey_results = 'Dissatisfied' THEN 1 ELSE 0 END)*100/COUNT(*), 2) AS dissatisfaction_rate
FROM project.itsm_tickets
GROUP BY Topic
ORDER BY dissatisfaction_rate DESC;

-- Query 6: Ticket Distribution by Support Level
SELECT 
    support_level,
    COUNT(*) AS ticket_count
FROM project.itsm_tickets
GROUP BY support_level
ORDER BY ticket_count DESC;

-- Query 7: Agent Interactions vs Dissatisfaction Rate
SELECT 
    agent_name,
    COUNT(ticket_ID) AS ticket_count,
    ROUND(AVG(agent_interactions), 2) AS avg_interactions,
    SUM(CASE WHEN survey_results = 'Dissatisfied' THEN 1 ELSE 0 END) AS dissatisfied_count,
    ROUND(SUM(CASE WHEN survey_results = 'Dissatisfied' THEN 1 ELSE 0 END)*100/COUNT(*), 2) AS dissatisfaction_rate
FROM project.itsm_tickets
GROUP BY agent_name
ORDER BY dissatisfaction_rate DESC
LIMIT 10;

-- Query 8: Agent Interactions vs Satisfaction Rate
SELECT 
    agent_name,
    COUNT(ticket_ID) AS ticket_count,
    ROUND(AVG(agent_interactions), 2) AS avg_interactions,
    SUM(CASE WHEN survey_results = 'Satisfied' THEN 1 ELSE 0 END) AS satisfied_count,
    ROUND(SUM(CASE WHEN survey_results = 'Satisfied' THEN 1 ELSE 0 END)*100/COUNT(*), 2) AS satisfaction_rate
FROM project.itsm_tickets
GROUP BY agent_name
ORDER BY satisfaction_rate DESC
LIMIT 10;

-- Query 9: CTE - Resolution Time vs Satisfaction Rate by Agent Group
WITH resolution_cte AS (
    SELECT 
        agent_group,
        ROUND(AVG(TIME_TO_SEC(TIMEDIFF(resolution_time, created_time))/3600), 2) AS avg_resolution_hours
    FROM project.itsm_tickets
    GROUP BY agent_group
),
satisfaction_cte AS (
    SELECT 
        agent_group,
        ROUND(SUM(CASE WHEN survey_results = 'Satisfied' THEN 1 ELSE 0 END)*100/COUNT(*), 2) AS satisfaction_rate
    FROM project.itsm_tickets
    GROUP BY agent_group
)
SELECT 
    r.agent_group,
    r.avg_resolution_hours,
    s.satisfaction_rate
FROM resolution_cte r
JOIN satisfaction_cte s ON r.agent_group = s.agent_group
ORDER BY r.avg_resolution_hours DESC;