SELECT * FROM ai_candidate_evaluation_analysis.my_data;

select count(*)
from my_data;

-- DATA QUALITY CHECK
-----------------------------------------------------------------------
-- [Q1] Row count and duplicate IDs
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT candidate_id) AS distinct_ids
FROM my_data;

 -- [Q2] Missing values and out-of-range scores
SELECT
    SUM(CASE WHEN job_role IS NULL OR stage IS NULL THEN 1 ELSE 0 END) AS missing_labels,
    SUM(CASE WHEN ai_score < 0 OR ai_score > 100 THEN 1 ELSE 0 END) AS ai_out_of_range,
    SUM(CASE WHEN human_score < 0 OR human_score > 100 THEN 1 ELSE 0 END) AS human_out_of_range,
    SUM(CASE WHEN experience_years < 0 THEN 1 ELSE 0 END) AS negative_experience
FROM my_data;


-- 2. BASICS: GROUP BY and aggregates
-- ---------------------------------------------------------------------
 
-- [Q3] Candidates per stage
SELECT stage, COUNT(*) AS candidates,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM my_data), 1) AS pct_of_total
FROM my_data
GROUP BY stage
ORDER BY candidates DESC;

-- [Q4] Candidates per job role and stage
SELECT job_role,
       SUM(CASE WHEN stage = 'Screening'   THEN 1 ELSE 0 END) AS screening,
       SUM(CASE WHEN stage = 'Interview'   THEN 1 ELSE 0 END) AS interview,
       SUM(CASE WHEN stage = 'Shortlisted' THEN 1 ELSE 0 END) AS shortlisted,
       SUM(CASE WHEN stage = 'Rejected'    THEN 1 ELSE 0 END) AS rejected,
       COUNT(*) AS total
FROM my_data
GROUP BY job_role
ORDER BY job_role;

-- [Q5] Average assessment scores per job role
SELECT job_role,
       ROUND(AVG(skills_match), 1)        AS avg_skills_match,
       ROUND(AVG(technical_score), 1)     AS avg_technical,
       ROUND(AVG(communication_score), 1) AS avg_communication,
       ROUND(AVG(reference_score), 1)     AS avg_reference,
       ROUND(AVG(experience_years), 1)    AS avg_experience_years
FROM my_data
GROUP BY job_role
ORDER BY job_role;

-- [Q6] What does each stage look like on average?
SELECT stage,
       COUNT(*) AS candidates,
       ROUND(AVG(skills_match), 1)        AS skills_match,
       ROUND(AVG(technical_score), 1)     AS technical,
       ROUND(AVG(communication_score), 1) AS communication,
       ROUND(AVG(reference_score), 1)     AS reference,
       ROUND(AVG(experience_years), 1)    AS experience_years,
       ROUND(AVG(ai_score), 1)            AS ai_score,
       ROUND(AVG(human_score), 1)         AS human_score
FROM my_data
GROUP BY stage
ORDER BY AVG(human_score) DESC;
 
 
 -- ---------------------------------------------------------------------
-- 3. INTERMEDIATE: CASE WHEN, subqueries, HAVING
-- ---------------------------------------------------------------------
 
-- [Q7] Shortlist rate by experience band
SELECT
    CASE WHEN experience_years <= 2 THEN '0-2 years'
         WHEN experience_years <= 4 THEN '3-4 years'
         ELSE '5-6 years' END AS experience_band,
    COUNT(*) AS candidates,
    SUM(CASE WHEN stage = 'Shortlisted' THEN 1 ELSE 0 END) AS shortlisted,
    ROUND(100.0 * SUM(CASE WHEN stage = 'Shortlisted' THEN 1 ELSE 0 END) / COUNT(*), 1) AS shortlist_rate_pct,
    ROUND(100.0 * SUM(CASE WHEN stage = 'Rejected' THEN 1 ELSE 0 END) / COUNT(*), 1) AS rejection_rate_pct
FROM my_data
GROUP BY experience_band
ORDER BY MIN(experience_years);

-- [Q8] AI score minus human score, per job role

SELECT job_role,
       COUNT(*) AS candidates,
       ROUND(AVG(ai_score), 1)    AS avg_ai_score,
       ROUND(AVG(human_score), 1) AS avg_human_score,
       ROUND(AVG(ai_score - human_score), 2) AS avg_gap,
       ROUND(AVG(ABS(ai_score - human_score)), 2) AS avg_abs_gap
FROM my_data
GROUP BY job_role
ORDER BY avg_abs_gap DESC;

-- [Q9] How often do AI and human disagree by more than 15 points?
SELECT
    COUNT(*) AS total_candidates,
    SUM(CASE WHEN ABS(ai_score - human_score) > 15 THEN 1 ELSE 0 END) AS big_disagreements,
    ROUND(100.0 * SUM(CASE WHEN ABS(ai_score - human_score) > 15 THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_big_disagreements,
    SUM(CASE WHEN ai_score - human_score > 15 THEN 1 ELSE 0 END)  AS ai_much_higher,
    SUM(CASE WHEN human_score - ai_score > 15 THEN 1 ELSE 0 END) AS human_much_higher
FROM my_data;
 
 -- [Q10] The biggest disagreements, with the final stage
SELECT candidate_id, job_role,
 experience_years,
ai_score, human_score,
       ROUND(ai_score - human_score, 1) AS gap,
       stage
FROM my_data
WHERE ABS(ai_score - human_score) > 15
ORDER BY ABS(ai_score - human_score) DESC
LIMIT 15;
 
 -- [Q11] Disagreements broken down by outcome
SELECT
    CASE WHEN ai_score - human_score > 15 THEN 'AI much higher'
         WHEN human_score - ai_score > 15 THEN 'Human much higher'
         ELSE 'Roughly agree' END AS disagreement_type,
    stage,
    COUNT(*) AS candidates
FROM my_data
GROUP BY disagreement_type, stage
ORDER BY disagreement_type, stage;
 
 -- [Q12] Does the AI score rise as experience rises, versus the human score?
SELECT experience_years,
       COUNT(*) AS candidates,
       ROUND(AVG(ai_score), 1)    AS avg_ai_score,
       ROUND(AVG(human_score), 1) AS avg_human_score,
       ROUND(AVG(ai_score - human_score), 2) AS avg_gap
FROM my_data
GROUP BY experience_years
HAVING COUNT(*) >= 10
ORDER BY experience_years;
 
 
 -- ---------------------------------------------------------------------
-- 4. ADVANCED: CTEs and window functions
-- ---------------------------------------------------------------------
 
-- [Q13] Rank candidates within each role by AI score and by human score
WITH ranked AS (
    SELECT candidate_id, job_role, stage, ai_score, human_score,
           RANK() OVER (PARTITION BY job_role ORDER BY ai_score DESC)    AS ai_rank,
           RANK() OVER (PARTITION BY job_role ORDER BY human_score DESC) AS human_rank
    FROM my_data
)
SELECT candidate_id, job_role, stage, ai_score, human_score,
       ai_rank, human_rank,
       ABS(CAST(ai_rank AS SIGNED) - CAST(human_rank AS SIGNED)) AS rank_difference
FROM ranked
ORDER BY rank_difference DESC
LIMIT 10;

-- [Q14] Do the AI and human top 10 per role agree?
WITH ranked AS (
    SELECT candidate_id, job_role,
           RANK() OVER (PARTITION BY job_role ORDER BY ai_score DESC)    AS ai_rank,
           RANK() OVER (PARTITION BY job_role ORDER BY human_score DESC) AS human_rank
    FROM my_data
)
SELECT job_role,
       SUM(CASE WHEN ai_rank <= 10 THEN 1 ELSE 0 END)                         AS in_ai_top10,
       SUM(CASE WHEN human_rank <= 10 THEN 1 ELSE 0 END)                      AS in_human_top10,
       SUM(CASE WHEN ai_rank <= 10 AND human_rank <= 10 THEN 1 ELSE 0 END)    AS in_both_top10
FROM ranked
GROUP BY job_role
ORDER BY job_role;
 
 -- [Q15] Shortlist rate by AI score quartile and by human score quartile
WITH quartiles AS (
    SELECT stage,
           NTILE(4) OVER (ORDER BY ai_score)    AS ai_quartile,
           NTILE(4) OVER (ORDER BY human_score) AS human_quartile
    FROM my_data
)
SELECT 'AI score' AS scorer, ai_quartile AS quartile,
       COUNT(*) AS candidates,
       SUM(CASE WHEN stage = 'Shortlisted' THEN 1 ELSE 0 END) AS shortlisted,
       ROUND(100.0 * SUM(CASE WHEN stage = 'Shortlisted' THEN 1 ELSE 0 END) / COUNT(*), 1) AS shortlist_rate_pct,
       ROUND(100.0 * SUM(CASE WHEN stage = 'Rejected' THEN 1 ELSE 0 END) / COUNT(*), 1) AS rejection_rate_pct
FROM quartiles
GROUP BY ai_quartile
UNION ALL
SELECT 'Human score', human_quartile,
       COUNT(*),
       SUM(CASE WHEN stage = 'Shortlisted' THEN 1 ELSE 0 END),
       ROUND(100.0 * SUM(CASE WHEN stage = 'Shortlisted' THEN 1 ELSE 0 END) / COUNT(*), 1),
       ROUND(100.0 * SUM(CASE WHEN stage = 'Rejected' THEN 1 ELSE 0 END) / COUNT(*), 1)
FROM quartiles
GROUP BY human_quartile
ORDER BY scorer, quartile;

-- [Q16] Which scorer separates Shortlisted from Rejected better?
-- A bigger gap between the two stage averages means better separation.
WITH stage_avgs AS (
    SELECT stage,
           AVG(ai_score)    AS avg_ai,
           AVG(human_score) AS avg_human
    FROM my_data
    WHERE stage IN ('Shortlisted', 'Rejected')
    GROUP BY stage
)
SELECT
    ROUND(MAX(CASE WHEN stage = 'Shortlisted' THEN avg_ai    END) -
          MAX(CASE WHEN stage = 'Rejected'    THEN avg_ai    END), 1) AS ai_separation,
    ROUND(MAX(CASE WHEN stage = 'Shortlisted' THEN avg_human END) -
          MAX(CASE WHEN stage = 'Rejected'    THEN avg_human END), 1) AS human_separation
FROM stage_avgs;
 
-- [Q17] Shortlisted candidates the AI scored below the overall average
WITH overall AS (
    SELECT AVG(ai_score) AS avg_ai FROM my_data
)
SELECT c.candidate_id, c.job_role, c.ai_score, c.human_score, c.stage
FROM my_data c, overall o
WHERE c.stage = 'Shortlisted' AND c.ai_score < o.avg_ai
ORDER BY c.ai_score ASC;

-- [Q18] Rejected candidates the human scored above the overall average
WITH overall AS (
    SELECT AVG(human_score) AS avg_human FROM my_data
)
SELECT c.candidate_id, c.job_role, c.ai_score, c.human_score, c.stage
FROM my_data c, overall o
WHERE c.stage = 'Rejected' AND c.human_score > o.avg_human
ORDER BY c.human_score DESC;

-- [Q19] Strongest candidates per role: top 3 by blended score
WITH blended AS (
    SELECT candidate_id, job_role, stage, ai_score, human_score,
           ROUND((ai_score + human_score) / 2, 1) AS blended_score,
           ROW_NUMBER() OVER (PARTITION BY job_role
                              ORDER BY (ai_score + human_score) / 2 DESC) AS rn
    FROM my_data
)
SELECT job_role, rn AS position, candidate_id, ai_score, human_score, blended_score, stage
FROM blended
WHERE rn <= 3
ORDER BY job_role, rn;
 
 
 -- [Q20] Which input scores track the AI and human scores most closely?
-- Average score of candidates in the top vs bottom third of each input.
WITH banded AS (
    SELECT ai_score, human_score,
           NTILE(3) OVER (ORDER BY skills_match)        AS skills_band,
           NTILE(3) OVER (ORDER BY technical_score)     AS technical_band,
           NTILE(3) OVER (ORDER BY communication_score) AS comm_band,
           NTILE(3) OVER (ORDER BY experience_years)    AS exp_band
    FROM my_data
)
SELECT 'skills_match' AS input,
       ROUND(AVG(CASE WHEN skills_band = 3 THEN ai_score END) - AVG(CASE WHEN skills_band = 1 THEN ai_score END), 1) AS ai_top_vs_bottom,
       ROUND(AVG(CASE WHEN skills_band = 3 THEN human_score END) - AVG(CASE WHEN skills_band = 1 THEN human_score END), 1) AS human_top_vs_bottom
FROM banded
UNION ALL
SELECT 'technical_score',
       ROUND(AVG(CASE WHEN technical_band = 3 THEN ai_score END) - AVG(CASE WHEN technical_band = 1 THEN ai_score END), 1),
       ROUND(AVG(CASE WHEN technical_band = 3 THEN human_score END) - AVG(CASE WHEN technical_band = 1 THEN human_score END), 1)
FROM banded
UNION ALL
SELECT 'communication_score',
       ROUND(AVG(CASE WHEN comm_band = 3 THEN ai_score END) - AVG(CASE WHEN comm_band = 1 THEN ai_score END), 1),
       ROUND(AVG(CASE WHEN comm_band = 3 THEN human_score END) - AVG(CASE WHEN comm_band = 1 THEN human_score END), 1)
FROM banded
UNION ALL
SELECT 'experience_years',
       ROUND(AVG(CASE WHEN exp_band = 3 THEN ai_score END) - AVG(CASE WHEN exp_band = 1 THEN ai_score END), 1),
       ROUND(AVG(CASE WHEN exp_band = 3 THEN human_score END) - AVG(CASE WHEN exp_band = 1 THEN human_score END), 1)
FROM banded;
 



