# AI Candidate Evaluation Analysis

## Project Overview

This project investigates how AI-generated candidate evaluation scores compare with a simulated reference benchmark and human review scores. It also examines candidate job skills matching, score consistency across job roles, and the distribution of candidates across simulated recruitment stages.

The project demonstrates practical skills in Python, data analysis, statistical evaluation, data visualization, and communicating analytical findings.

## Business Questions

1. How closely do AI evaluation scores track the reference benchmark?
2. Which job role has the highest average skills match score?
3. How are candidates distributed across assigned recruitment stages?
4. Does the difference between AI and human scores vary across job roles?

## Tools and Technologies

- Python
- Pandas and NumPy
- Matplotlib and Seaborn
- SciPy and scikit-learn
- SQL

## Methodology

1. Generated a synthetic dataset of candidate profiles and evaluation scores.
2. Checked missing values, duplicate candidate IDs, and score ranges.
3. Calculated mean absolute error (MAE), correlations, and average score differences.
4. Compared skills match and technical scores across job roles.
5. Examined the distribution of assigned recruitment stages.
6. Visualized evaluation patterns and score differences.

## Key Findings

## Key Findings

### A. AI Evaluation Quality

The AI evaluation model achieved a Mean Absolute Error (MAE) of **6.20 points**, compared with **4.80 points** for the human evaluation scores, when both were compared against the simulated reference score. The AI scores had a correlation of **0.826** with the reference scores, indicating a strong positive linear relationship. The average AI-reference score difference was **-0.10 points**, suggesting that the AI scores were nearly unbiased on average relative to this simulated benchmark.

However, the AI scores had a higher MAE than the human scores, meaning they were less accurate against the reference benchmark in this experiment.

### B. Candidate-Job Matching

The Data Analyst role had the highest average skills-match score at **63.85**, closely followed by Junior Data Scientist at **63.84**. BI Analyst recorded the lowest average skills-match score at **62.67**.

Data Analyst candidates also had the highest average technical score at **67.17**, compared with 64.74 for Junior Data Scientist and 62.75 for BI Analyst. These results describe the simulated dataset and do not establish real-world candidate suitability.

### C. Recruitment Stage Distribution

Of the 500 simulated candidates, 195 (39.0%) were classified as Interview, 192 (38.4%) as Screening, 81 (16.2%) as Shortlisted, and 32 (6.4%) as Rejected.

Interview and Screening categories accounted for most candidates in the dataset. These categories were assigned using simulated reference-score thresholds; they do not represent actual recruitment-stage transitions or conversion rates.

### D. AI-Human Evaluation Consistency

The average AI-minus-human score difference was +0.34 points for BI Analyst, -0.69 points for Data Analyst, and +1.05 points for Junior Data Scientist.

BI Analyst had the largest mean absolute AI-human score difference at **8.72 points**, followed by Data Analyst at 7.24 and Junior Data Scientist at 6.99. This suggests that AI and human scores differed most, on average, for BI Analyst candidates in this simulation. Further investigation would be needed to understand the causes of these differences; the result alone does not establish bias or identify which evaluator was correct.

## Limitations

- The dataset contains 500 simulated candidates rather than real applicant records.
- The reference score was calculated using predefined weights for skills match, technical score, communication score, and experience.
- Recruitment stages were assigned from reference-score thresholds and do not represent a real recruitment funnel.
- The results do not establish that an AI evaluation system is fair, unbiased, or suitable for making hiring decisions.
- Real-world validation would require representative data, clearly defined evaluation criteria, human oversight, and appropriate fairness and privacy checks.

 ## What the results mean
Analysis	                Main conclusion
A — AI quality	          Human scores had lower error against the simulated reference benchmark.
B — Job matching	        Data Analyst ranked highest on average skills match and technical score.
C — Stage distribution	  Interview was the largest simulated category at 39%.
D — Consistency         	BI Analyst had the largest average absolute difference between AI and human scores.

## Conclusion

This project demonstrates a structured approach to evaluating scoring systems, checking data quality, comparing metrics, and communicating findings. Further work could include independent human ratings, validated outcomes, role specific evaluation rubrics, fairness testing, and controlled comparisons of AI evaluation methods.

## Repository Contents

- `ai_candidate_evaluation_analysis.ipynb` — analysis notebook
- `ai_candidate_evaluation_analysis.html` — browser-readable report
- `ai_candidate_evaluation_dashboard.png` — dashboard visualization
- `candidate_evaluation.csv` — synthetic dataset, if included
- `sql_analysis.sql` — SQL analysis queries, if included
