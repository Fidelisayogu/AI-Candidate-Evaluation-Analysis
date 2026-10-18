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

- **AI evaluation quality:** [Insert verified MAE, correlation, and average score difference.]
- **Candidate-job matching:** [Insert the role with the highest average skills-match score and its value.]
- **Recruitment stages:** [Summarize the stage distribution and explain that these are simulated categories, not actual transitions.]
- **Evaluation consistency:** [Describe the differences between AI and human scores across roles.]

## Limitations

The dataset is synthetic and does not contain real candidate outcomes or validated hiring decisions. The reference score is generated using predefined weights, so agreement with it does not establish real-world predictive accuracy. The simulated recruitment stages do not measure actual hiring funnel conversion. Score differences alone cannot establish bias or fairness.

## Conclusion

This project demonstrates a structured approach to evaluating scoring systems, checking data quality, comparing metrics, and communicating findings. Further work could include independent human ratings, validated outcomes, role-specific evaluation rubrics, fairness testing, and controlled comparisons of AI evaluation methods.

## Repository Contents

- `ai_candidate_evaluation_analysis.ipynb` — analysis notebook
- `ai_candidate_evaluation_analysis.html` — browser-readable report
- `ai_candidate_evaluation_dashboard.png` — dashboard visualization
- `candidate_evaluation.csv` — synthetic dataset, if included
- `sql_analysis.sql` — SQL analysis queries, if included
