# What Drives a Fourth Down Decision? NFL 2025 Logistic Regression in SAS

On fourth down, an NFL team chooses between **going for it** (run or pass) and **kicking** (punt or field goal). This project uses 2025 NFL play-by-play data to find out which game situations drive that choice, and how well a logistic regression model can predict it.

**Tools:** SAS (PROC IMPORT, DATA step, PROC MEANS, PROC FREQ, PROC LOGISTIC, PROC SGPLOT)  
**Methods:** data cleaning, frequency tables, chi-square tests, odds ratios, logistic regression, stepwise selection, ROC/AUC, classification table

---

## Key findings

| Finding | Result |
|---|---|
| Share of fourth downs that ended in a kick | **76.6%** (598 of 2,555 plays were go-for-it attempts) |
| Strongest factor | Each extra yard to go lowers the odds of going for it by **about 30%** (odds ratio 0.698) |
| Score | Each extra point ahead lowers the odds by about 7% (odds ratio 0.928) |
| Timeouts | Teams with no timeouts left have **2.2 times** the odds of going for it compared with teams holding all three |
| Quarter | Teams went for it on 35.1% of 4th-quarter fourth downs, compared with 17.8% in the 1st |
| Model performance | **AUC 0.882**, 84.5% of decisions classified correctly |

![Fourth down decisions by quarter](images/quarter_chart.png)

---

## Data

- **Source:** [NFLverse play-by-play data, 2025 season](https://github.com/nflverse/nflverse-data/releases/tag/pbp)
- **Size:** 48,771 plays and 372 variables
- **Scope:** fourth down plays for 20 assigned teams (ARI, BUF, CHI, CIN, CLE, DAL, DEN, HOU, IND, JAX, KC, LA, NE, NO, NYJ, PHI, PIT, SF, TB, TEN)
- **Final dataset:** 2,555 clear fourth down decisions, after removing 182 plays with no clear decision (penalties, no-plays, aborted snaps, 2-point tries)
- **Missing values:** none in the predictors used

The raw CSV is not stored in this repository because of its size. Download `play_by_play_2025.csv` from the link above to run the code.

---

## Approach

1. **Import** the CSV with PROC IMPORT (`GUESSINGROWS=MAX` so SAS reads variable types correctly).
2. **Filter** to the 20 teams and to plays where `down = 4`.
3. **Create the response variable** `go_for_it`: 1 for run or pass, 0 for punt or field goal.
4. **Explore** the data with PROC MEANS and PROC FREQ, including chi-square tests and an odds ratio for late vs early quarters.
5. **Model** the decision with PROC LOGISTIC using yards to go, field position, score difference, time left, timeouts for both teams and quarter.
6. **Refine** the model with stepwise selection (entry and stay level 0.05).
7. **Evaluate** with the ROC curve, AUC, concordance and a classification table at a 0.5 cutoff.

---

## Model results

**Odds ratios (refined model, other factors held constant)**

| Factor | Odds ratio | Effect on odds of going for it |
|---|---|---|
| Each extra yard to go | 0.698 | Lower |
| Each extra point ahead | 0.928 | Lower |
| Each extra yard from the opponent's end zone | 0.977 | Lower |
| No timeouts left (vs three) | 2.215 | Higher |
| Quarter 2 (vs quarter 1) | 0.471 | Lower |
| Quarter 3 (vs quarter 1) | 0.358 | Lower |

**Full vs refined model**

| Measure | Full model | Refined model |
|---|---|---|
| AIC | 1,842.5 | 1,840.3 |
| AUC | 0.882 | 0.882 |
| Overall correct | 84.2% | 84.5% |
| Sensitivity (go-for-it plays caught) | 52.2% | 54.7% |
| Specificity (kicks caught) | 93.4% | 93.7% |

Stepwise selection removed the defense's timeouts, which were not significant. The refined model is simpler with no loss in accuracy.

![ROC curve, AUC 0.882](images/roc_curve.png)

---

## Limitations

- **Association, not cause.** The model shows which situations go with going for it, not whether those choices were right.
- **Part of the league, one season.** 20 of 32 teams in 2025 only.
- **Missing context.** Weather, injuries, personnel and coaching style are not in the data.
- **Better at predicting kicks than go-for-it plays**, because kicks make up 76.6% of the data.
- **Calibration.** The Hosmer-Lemeshow test was significant, though with 2,555 plays this test flags even small gaps.

## Next steps

- Extend to all 32 teams and several seasons
- Add weather and opponent data
- Compare actual choices with win-probability models

---

## Repository contents

| File | Description |
|---|---|
| `NFL_Fourth_Down_Analysis.sas` | SAS code for import, cleaning, analysis and modeling |
| `NFL_Fourth_Down_Report.docx` | Full written report with tables and interpretation |
| `NFL_Fourth_Down_Presentation.pdf` | 9-slide summary presentation |
| `images/` | Bar chart by quarter and ROC curve from SAS |

## How to run

1. Download `play_by_play_2025.csv` from NFLverse (link above).
2. Upload it to SAS OnDemand for Academics or your SAS environment.
3. In `NFL_Fourth_Down_Analysis.sas`, change the `DATAFILE=` path in Step 1 to where you saved the file.
4. Run the program from top to bottom.

---

**Author:** Sharon Rosina Wamalwa, MS Business Analytics, University of South Dakota  
[LinkedIn](https://www.linkedin.com/in/your-profile) · [Email](mailto:your-email)

*Completed as part of a SAS Programming course at the University of South Dakota.*
