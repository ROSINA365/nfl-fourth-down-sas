/*
NFL 4th Down Decision Modeling
A Logistic Regression Analysis of the 2025 NFL Season
*/


/* Step 1: Import the 2025 NFL Play-by-Play Data */
PROC IMPORT DATAFILE="/home/u64427539/play_by_play_2025.csv"
            OUT=work.pbp_2025
            DBMS=CSV REPLACE;
    GUESSINGROWS=MAX;
RUN;

/* Step 2: Filter to my assigned teams and 4th down plays */
DATA work.fourth_down_clean;
    SET work.pbp_2025;
    WHERE posteam IN ('ARI', 'BUF', 'CHI', 'CIN', 'CLE', 'DAL', 'DEN', 
                      'HOU', 'IND', 'JAX', 'KC', 'LA', 'NE', 'NO', 
                      'NYJ', 'PHI', 'PIT', 'SF', 'TB', 'TEN')
          AND down = 4;
RUN;

/* Step 3: Create binary response variable go_for_it */
DATA work.fourth_down_model;
    SET work.fourth_down_clean;
    IF play_type IN ('run', 'pass') THEN go_for_it = 1;
    ELSE IF play_type IN ('punt', 'field_goal') THEN go_for_it = 0;
    ELSE go_for_it = .;
RUN;

/* Step 4: Drop rows where go_for_it is missing */
DATA work.fourth_down_model;
    SET work.fourth_down_model;
    IF go_for_it = . THEN DELETE;
RUN;


/* Step 5: Check missing values for candidate predictors */
PROC MEANS DATA=work.fourth_down_model N NMISS;
    VAR ydstogo yardline_100 score_differential 
        game_seconds_remaining half_seconds_remaining
        wp posteam_timeouts_remaining defteam_timeouts_remaining qtr;
RUN;


/* Step 6: Frequency table for response variable */
PROC FREQ DATA=work.fourth_down_model;
    TABLES go_for_it;
RUN;


/* Step 7: Frequency tables for categorical predictors */
PROC FREQ DATA=work.fourth_down_model;
    TABLES qtr posteam_timeouts_remaining defteam_timeouts_remaining;
RUN;


/* Step 8: Summary statistics for continuous predictors */
PROC MEANS DATA=work.fourth_down_model 
           N MEAN STD MIN MAX MEDIAN;
    VAR ydstogo yardline_100 score_differential 
        game_seconds_remaining half_seconds_remaining;
RUN;


/* Step 9: Cross-tabulations with Chi-Square and Cramer's V */
PROC FREQ DATA=work.fourth_down_model;
    TABLES qtr*go_for_it / CHISQ;
    TABLES posteam_timeouts_remaining*go_for_it / CHISQ;
RUN;

/* Step 10: Odds Ratio - Early quarters (1-3) vs Late (4-5) */
DATA work.fourth_down_or;
    SET work.fourth_down_model;
    IF qtr IN (1,2,3) THEN qtr_group = 'Early (Q1-Q3)';
    ELSE IF qtr IN (4,5) THEN qtr_group = 'Late (Q4-Q5)';
RUN;

PROC FREQ DATA=work.fourth_down_or;
    TABLES qtr_group*go_for_it / CHISQ RELRISK;
RUN;


/* Step 11: Bar chart - Go-for-it rate by quarter */
PROC SGPLOT DATA=work.fourth_down_or;
    VBAR qtr_group / GROUP=go_for_it 
                     GROUPDISPLAY=CLUSTER
                     DATALABEL;
    XAXIS LABEL="Quarter Group";
    YAXIS LABEL="Frequency";
    KEYLEGEND / TITLE="Decision (0=Kick, 1=Go For It)";
    TITLE "Fourth Down Decision by Quarter Group";
RUN;

/* Step 12: Logistic Regression Model */
PROC LOGISTIC DATA=work.fourth_down_model DESCENDING PLOTS=ROC;
    CLASS qtr (PARAM=REF REF='1') 
          posteam_timeouts_remaining (PARAM=REF REF='3')
          defteam_timeouts_remaining (PARAM=REF REF='3');
    MODEL go_for_it = ydstogo yardline_100 score_differential
                      game_seconds_remaining 
                      posteam_timeouts_remaining 
                      defteam_timeouts_remaining
                      qtr / CTABLE LACKFIT;
    TITLE "Logistic Regression: Fourth Down Decision Model";
RUN;

/* Step 13: Model Refinement - Stepwise Selection */
PROC LOGISTIC DATA=work.fourth_down_model DESCENDING;
    CLASS qtr (PARAM=REF REF='1')
          posteam_timeouts_remaining (PARAM=REF REF='3')
          defteam_timeouts_remaining (PARAM=REF REF='3');
    MODEL go_for_it = ydstogo yardline_100 score_differential
                      game_seconds_remaining
                      posteam_timeouts_remaining
                      defteam_timeouts_remaining
                      qtr / SELECTION=STEPWISE
                            SLENTRY=0.05
                            SLSTAY=0.05
                            CTABLE;
    TITLE "Refined Model - Stepwise Selection";
RUN;