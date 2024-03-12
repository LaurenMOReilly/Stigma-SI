/*----------------------------------------------------
Project Title: Suicide Stigma and SI
Dataset: hom_1
Author: Lauren OReilly
Date: 1/10/2023
Revisions: 3/12/2024 Cleaned for Github
-----------------------------------------------------*/
/*Read in dataset*/
data hom_1;
set '\\Client\C$\Users\loreilly\OneDrive - Indiana University\My Passport Backup\Internship Resources\Stigma\hom_1';
run;


/*Set local macros*/
%MACRO proc_freq (data=, var=);
proc freq data = &data;
	table &var;
run;
%MEND;

%MACRO proc_uni (data=, var=);
proc univariate data = &data;
	var &var;
run;
%MEND;

%MACRO proc_corr (data=, var=);
proc corr data = &data;
	var &var;
run;
%MEND;

%MACRO sgplot (var=);
proc sgplot data = suistg;
	histogram &var;
run;
%MEND;

%MACRO proc_genmod (data=, vars=, outcome=, predictor=, dist=);
proc genmod data = &data;
	class &vars;
	model &outcome = &predictor &vars / dist=&dist;
	zeromodel &outcome / link=logit;
run;
%MEND;

%MACRO alpha (dataset=, var=);
	proc corr data = &dataset alpha;
		var &var;
	run;
%MEND;


/*CFA*/
	/*PS and Barriers to Care*/
proc calis data = hom_1 nobs = 237 modification;
factor 
	stigma ---> PS_1_1 PS_2_1 PS_3_1 PS_4_1 PS_5_1 PS_6_1,
	barriers ---> PS_7_1 PS_8_1 PS_9_1 PS_10_1 PS_11_1;
pvar 
	stigma barriers = 2 * 1.;
cov
	stigma barriers;
run;

proc calis data = hom_1 nobs = 211 modification;
factor 
	stigma ---> PS_1_2 PS_2_2 PS_3_2 PS_4_2 PS_5_2 PS_6_2,
	barriers ---> PS_7_2 PS_8_2 PS_9_2 PS_10_2 PS_11_2;
pvar 
	stigma barriers = 2 * 1.;
cov
	stigma barriers;
run;

proc calis data = hom_1 nobs = 150 modification;
factor 
	stigma ---> PS_1_3 PS_2_3 PS_3_3 PS_4_3 PS_5_3 PS_6_3,
	barriers ---> PS_7_3 PS_8_3 PS_9_3 PS_10_3 PS_11_3;
pvar 
	stigma barriers = 2 * 1.;
cov
	stigma barriers;
run;

		/*SOSS-SF - Suicide stigma*/
proc calis data = hom_1 nobs = 237 modification;
factor 
	stigma ---> SOSSSF_1_1 SOSSSF_2_1 SOSSSF_3_1 SOSSSF_4_1 SOSSSF_5_1 SOSSSF_6_1 SOSSSF_7_1 SOSSSF_8_1,
	depression ---> SOSSSF_9_1 SOSSSF_10_1 SOSSSF_11_1 SOSSSF_12_1,
	glorification ---> SOSSSF_13_1 SOSSSF_14_1 SOSSSF_15_1 SOSSSF_16_1;
pvar 
	stigma depression glorification = 3 * 1.;
cov
	stigma depression glorification;
run;

proc calis data = hom_1 nobs = 210 modification;
factor 
	stigma ---> SOSSSF_1_2 SOSSSF_2_2 SOSSSF_3_2 SOSSSF_4_2 SOSSSF_5_2 SOSSSF_6_2 SOSSSF_7_2 SOSSSF_8_2,
	depression ---> SOSSSF_9_2 SOSSSF_10_2 SOSSSF_11_2 SOSSSF_12_2,
	glorification ---> SOSSSF_13_2 SOSSSF_14_2 SOSSSF_15_2 SOSSSF_16_2;
pvar 
	stigma depression glorification = 3 * 1.;
cov
	stigma depression glorification;
run;

proc calis data = hom_1 nobs = 149 modification;
factor 
	stigma ---> SOSSSF_1_3 SOSSSF_2_3 SOSSSF_3_3 SOSSSF_4_3 SOSSSF_5_3 SOSSSF_6_3 SOSSSF_7_3 SOSSSF_8_3,
	depression ---> SOSSSF_9_3 SOSSSF_10_3 SOSSSF_11_3 SOSSSF_12_3,
	glorification ---> SOSSSF_13_3 SOSSSF_14_3 SOSSSF_15_3 SOSSSF_16_3;
pvar 
	stigma depression glorification = 3 * 1.;
cov
	stigma depression glorification;
run;


/*Standardize variables*/
proc standard data=hom_1 mean=0 std=1 out=hom_2;
	var mean_ps_1 mean_bc_1 SOSSs_t1 SOSSi_t1 SOSSg_t1 SSOSH_t1
		mean_ps_2 mean_bc_2 SOSSs_t2 SOSSi_t2 SOSSg_t2 SSOSH_t2
		mean_ps_3 mean_bc_3 SOSSs_t3 SOSSi_t3 SOSSg_t3 SSOSH_t3
	;
run;

/*Only keep relevant variables*/
data hom_3; 
	set hom_2; 
		keep study_ID sex age race past_MHT 
		mean_ps_1 mean_bc_1 SOSSs_t1 SOSSi_t1 SOSSg_t1 SSOSH_t1
		mean_ps_2 mean_bc_2 SOSSs_t2 SOSSi_t2 SOSSg_t2 SSOSH_t2
		mean_ps_3 mean_bc_3 SOSSs_t3 SOSSi_t3 SOSSg_t3 SSOSH_t3
		DSISS_t1 DSISS_t2 DSISS_t3;
run;

/*MULTIPLE IMPUTATION*/
proc mi data = hom_3 seed=123 nimpute=1 out=hom_4mi;
	class ID sex age race past_MHT 
		mean_ps_1 mean_bc_1 SOSSs_t1 SOSSi_t1 SOSSg_t1 SSOSH_t1
		mean_ps_2 mean_bc_2 SOSSs_t2 SOSSi_t2 SOSSg_t2 SSOSH_t2
		mean_ps_3 mean_bc_3 SOSSs_t3 SOSSi_t3 SOSSg_t3 SSOSH_t3
		DSISS_t1 DSISS_t2 DSISS_t3;
	fcs nbiter=40 discrim (mean_ps_1 mean_bc_1 SOSSs_t1 SOSSi_t1 SOSSg_t1 SSOSH_t1
		mean_ps_2 mean_bc_2 SOSSs_t2 SOSSi_t2 SOSSg_t2 SSOSH_t2
		mean_ps_3 mean_bc_3 SOSSs_t3 SOSSi_t3 SOSSg_t3 SSOSH_t3
		DSISS_t1 DSISS_t2 DSISS_t3 / classeffects=include);
	var ID sex age race past_MHT 
		mean_ps_1 mean_bc_1 SOSSs_t1 SOSSi_t1 SOSSg_t1 SSOSH_t1
		mean_ps_2 mean_bc_2 SOSSs_t2 SOSSi_t2 SOSSg_t2 SSOSH_t2
		mean_ps_3 mean_bc_3 SOSSs_t3 SOSSi_t3 SOSSg_t3 SSOSH_t3
		DSISS_t1 DSISS_t2 DSISS_t3;
run;

data suistg.hom_4mi; 
	set hom_4mi; 
run;


/*Complete case*/
data hom_5;
	set hom_2;
		if mean_ps_1 = '.' then delete;
		if mean_bc_1 = '.' then delete;
		if SOSSs_t1 = '.' then delete;
		if SOSSi_t1 = '.' then delete;
		if SOSSg_t1 = '.' then delete;
		if SSOSH_t1 = '.' then delete;

		if mean_ps_2 = '.' then delete;
		if mean_bc_2 = '.' then delete;
		if SOSSs_t2 = '.' then delete;
		if SOSSi_t2 = '.' then delete;
		if SOSSg_t2 = '.' then delete;
		if SSOSH_t2 = '.' then delete;

		if mean_ps_3 = '.' then delete;
		if mean_bc_3 = '.' then delete;
		if SOSSs_t3 = '.' then delete;
		if SOSSi_t3 = '.' then delete;
		if SOSSg_t3 = '.' then delete;
		if SSOSH_t3 = '.' then delete;

		if DSISS_t1 = '.' then delete;
		if DSISS_t2 = '.' then delete;
		if DSISS_t3 = '.' then delete;
run;


/*Univariate statistics*/
%proc_freq (data=hom_1, var=dataset);
%proc_freq (data=hom_1, var=race age sex_orient past_MHT marital military);
%proc_freq (data=hom_1, var=sex educ employ_1 employ_2);
%proc_freq (data=hom_1, var=black hispanic asian other age19 age20 age21older sex_minority past_MHT);
%proc_freq (data=hom_1, var=PS_1_1 PS_2_1 PS_3_1 PS_4_1 PS_5_1 PS_6_1 PS_7_1 PS_8_1 PS_9_1 PS_10_1 PS_11_1);
%proc_freq (data=hom_1, var=PS_1_2 PS_2_2 PS_3_2 PS_4_2 PS_5_2 PS_6_2 PS_7_2 PS_8_2 PS_9_2 PS_10_2 PS_11_2);
%proc_freq (data=hom_1, var=PS_1_3 PS_2_3 PS_3_3 PS_4_3 PS_5_3 PS_6_3 PS_7_3 PS_8_3 PS_9_3 PS_10_3 PS_11_3);
%proc_freq (data=hom_1, var=DSISS_t1d DSISS_t2d DSISS_t3d);


proc freq data = hom_1;
	table sex race sex_orient age past_MHT marital military educ employ_1 employ_2;
	where t2 = 1;
run;
proc freq data = hom_1;
	table sex race sex_orient age past_MHT marital military educ employ_1 employ_2;
	where t3 = 1;
run;

%proc_freq (data=hom_1, var=SSOSH_1_1 SSOSH_2_1 SSOSH_3_1 SSOSH_4_1 SSOSH_5_1 SSOSH_6_1 SSOSH_7_1 SSOSH_8_1 SSOSH_9_1 SSOSH_10_1);
%proc_freq (data=hom_1, var=SSOSH_1_2 SSOSH_2_2 SSOSH_3_2 SSOSH_4_2 SSOSH_5_2 SSOSH_6_2 SSOSH_7_2 SSOSH_8_2 SSOSH_9_2 SOSSH_10_2);
%proc_freq (data=hom_1, var=SOSSH_1_3 SOSSH_2_3 SOSSH_3_3 SOSSH_4_3 SOSSH_5_3 SOSSH_6_3 SOSSH_7_3 SOSSH_8_3 SOSSH_9_3 SOSSH_10_3);

%proc_freq (data=hom_1, var=SOSSSF_1_1 SOSSSF_2_1 SOSSSF_3_1 SOSSSF_4_1 SOSSSF_5_1 SOSSSF_6_1 SOSSSF_7_1 SOSSSF_8_1 SOSSSF_9_1 
	SOSSSF_10_1 SOSSSF_11_1 SOSSSF_12_1 SOSSSF_13_1 SOSSSF_14_1 SOSSSF_15_1 SOSSSF_16_1);
%proc_freq (data=hom_1, var=SOSSSF_1_2 SOSSSF_2_2 SOSSSF_3_2 SOSSSF_4_2 SOSSSF_5_2 SOSSSF_6_2 SOSSSF_7_2 SOSSSF_8_2 SOSSSF_9_2 
	SOSSSF_10_2 SOSSSF_11_2 SOSSSF_12_2 SOSSSF_13_2 SOSSSF_14_2 SOSSSF_15_2 SOSSSF_16_2);
%proc_freq (data=hom_1, var=SOSSSF_1_3 SOSSSF_2_3 SOSSSF_3_3 SOSSSF_4_3 SOSSSF_5_3 SOSSSF_6_3 SOSSSF_7_3 SOSSSF_8_3 SOSSSF_9_3 
	SOSSSF_10_3 SOSSSF_11_3 SOSSSF_12_3 SOSSSF_13_3 SOSSSF_14_3 SOSSSF_15_3 SOSSSF_16_3);

%proc_uni (data=hom_1, var=mean_ps_1 mean_bc_1 SOSSs_t1 SOSSi_t1 SOSSg_t1 SSOSH_t1 DSISS_t1);
%proc_uni (data=hom_1, var=mean_ps_2 mean_bc_2 SOSSs_t2 SOSSi_t2 SOSSg_t2 SSOSH_t2 DSISS_t2);
%proc_uni (data=hom_1, var=mean_ps_3 mean_bc_3 SOSSs_t3 SOSSi_t3 SOSSg_t3 SSOSH_t3 DSISS_t3);

/*Chi-square */
proc freq data = hom_1;
	tables (t3) * (sex race sex_orient age past_MHT marital military educ employ_1 employ_2) / chisq
		plots=(freqplot(twoway=groupvertical scale=percent));
run;

proc freq data = hom_1;
	tables (t3) * (sex_minority) / chisq
		plots=(freqplot(twoway=groupvertical scale=percent));
run;

data hom_1chi;
	set hom_1;

	if age > 21 then age = 21;

	if educ > 4 then educ = 4;
run;

proc freq data = hom_1chi;
	tables (t3) * (age educ) / chisq
		plots=(freqplot(twoway=groupvertical scale=percent));
run;


/*Chronbach's alpha*/
%MACRO alpha (dataset=, var=);
	proc corr data = &dataset alpha;
		var &var;
	run;
%MEND;

%alpha (dataset=hom_1, var=PS_1_1 PS_2_1 PS_3_1 PS_4_1 PS_5_1 PS_6_1);
%alpha (dataset=hom_1, var=PS_1_2 PS_2_2 PS_3_2 PS_4_2 PS_5_2 PS_6_2);
%alpha (dataset=hom_1, var=PS_1_3 PS_2_3 PS_3_3 PS_4_3 PS_5_3 PS_6_3);

%alpha (dataset=hom_1, var=PS_7_1 PS_8_1 PS_9_1 PS_10_1 PS_11_1);
%alpha (dataset=hom_1, var=PS_7_2 PS_8_2 PS_9_2 PS_10_2 PS_11_2);
%alpha (dataset=hom_1, var=PS_7_3 PS_8_3 PS_9_3 PS_10_3 PS_11_3);

%alpha (dataset=hom_1, var=SOSSSF_1_1 SOSSSF_2_1 SOSSSF_3_1 SOSSSF_4_1 SOSSSF_5_1 SOSSSF_6_1 SOSSSF_7_1 SOSSSF_8_1);
%alpha (dataset=hom_1, var=SOSSSF_1_2 SOSSSF_2_2 SOSSSF_3_2 SOSSSF_4_2 SOSSSF_5_2 SOSSSF_6_2 SOSSSF_7_2 SOSSSF_8_2);
%alpha (dataset=hom_1, var=SOSSSF_1_3 SOSSSF_2_3 SOSSSF_3_3 SOSSSF_4_3 SOSSSF_5_3 SOSSSF_6_3 SOSSSF_7_3 SOSSSF_8_3);

%alpha (dataset=hom_1, var=SOSSSF_9_1 SOSSSF_10_1 SOSSSF_11_1 SOSSSF_12_1);
%alpha (dataset=hom_1, var=SOSSSF_9_2 SOSSSF_10_2 SOSSSF_11_2 SOSSSF_12_2);
%alpha (dataset=hom_1, var=SOSSSF_9_3 SOSSSF_10_3 SOSSSF_11_3 SOSSSF_12_3);

%alpha (dataset=hom_1, var=SOSSSF_13_1 SOSSSF_14_1 SOSSSF_15_1 SOSSSF_16_1);
%alpha (dataset=hom_1, var=SOSSSF_13_2 SOSSSF_14_2 SOSSSF_15_2 SOSSSF_16_2);
%alpha (dataset=hom_1, var=SOSSSF_13_3 SOSSSF_14_3 SOSSSF_15_3 SOSSSF_16_3);

%alpha (dataset=hom_1, var=SSOSH_1_1 SSOSH_2_1_rev SSOSH_3_1 SSOSH_4_1_rev SSOSH_5_1_rev SSOSH_6_1 SSOSH_7_1_rev SSOSH_8_1 SSOSH_9_1_rev SSOSH_10_1);
%alpha (dataset=hom_1, var=SSOSH_1_2 SSOSH_2_2_rev SSOSH_3_2 SSOSH_4_2_rev SSOSH_5_2_rev SSOSH_6_2 SSOSH_7_2_rev SSOSH_8_2 SSOSH_9_2_rev SOSSH_10_2);
%alpha (dataset=hom_1, var=SOSSH_1_3 SSOSH_2_3_rev SOSSH_3_3 SSOSH_4_3_rev SSOSH_5_3_rev SOSSH_6_3 SSOSH_7_3_rev SOSSH_8_3 SSOSH_9_3_rev SOSSH_10_3);

%alpha (dataset=hom_1, var=DSI_SS_A_1 DSI_SS_B_1 DSI_SS_C_1 DSI_SS_D_1);
%alpha (dataset=hom_1, var=DSI_SS_A_2 DSI_SS_B_2 DSI_SS_C_2 DSI_SS_D_2);
%alpha (dataset=hom_1, var=DSI_SS_A_3 DSI_SS_B_3 DSI_SS_C_3 DSI_SS_D_3);


/*--------------------------*/
/*MAIN ANALYSES*/
/*MACRO for Poisson regression*/
%MACRO proc_genmod (data=, classvars=, outcome=, predictor=, allvars=, dist=);
proc genmod data = &data;
	class &classvars / desc;
	model &outcome = &predictor &allvars / dist=&dist;
	zeromodel &outcome / link=logit;
	estimate '&predictor' &predictor 1 / exp;
run;
%MEND;


/*-------------------*/
/*Time 1 with Time 1*/
	/*Main - Poisson*/
%proc_genmod (data=hom_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=mean_ps_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=hom_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=mean_bc_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=hom_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=SOSSs_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=hom_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=SOSSi_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=hom_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=SOSSg_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=hom_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=SSOSH_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
	
	/*Complete case*/
%proc_genmod (data=hom_5, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=mean_ps_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=hom_5, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=mean_bc_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=hom_5, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=SOSSs_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=hom_5, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=SOSSi_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=hom_5, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=SOSSg_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=hom_5, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=SSOSH_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);

	/*No covariates*/
%proc_genmod (data=hom_2, outcome=DSISS_t1, predictor=mean_ps_1, dist=poisson);
%proc_genmod (data=hom_2, outcome=DSISS_t1, predictor=mean_bc_1, dist=poisson);
%proc_genmod (data=hom_2, outcome=DSISS_t1, predictor=SOSSs_t1, dist=poisson);
%proc_genmod (data=hom_2, outcome=DSISS_t1, predictor=SOSSi_t1, dist=poisson);
%proc_genmod (data=hom_2, outcome=DSISS_t1, predictor=SOSSg_t1, dist=poisson);
%proc_genmod (data=hom_2, outcome=DSISS_t1, predictor=SSOSH_t1, dist=poisson);


/*-------------------*/
/*Time 1 with Time 2*/
	/*Main - Poisson*/
%proc_genmod (data=hom_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=mean_ps_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=mean_bc_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSs_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSi_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSg_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SSOSH_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);

	/*Complete case*/
%proc_genmod (data=hom_5, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=mean_ps_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_5, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=mean_bc_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_5, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSs_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_5, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSi_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_5, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSg_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_5, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SSOSH_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);

	/*No covariates*/
%proc_genmod (data=hom_2, outcome=DSISS_t2, predictor=mean_ps_1, dist=poisson);
%proc_genmod (data=hom_2, outcome=DSISS_t2, predictor=mean_bc_1, dist=poisson);
%proc_genmod (data=hom_2, outcome=DSISS_t2, predictor=SOSSs_t1, dist=poisson);
%proc_genmod (data=hom_2, outcome=DSISS_t2, predictor=SOSSi_t1, dist=poisson);
%proc_genmod (data=hom_2, outcome=DSISS_t2, predictor=SOSSg_t1, dist=poisson);
%proc_genmod (data=hom_2, outcome=DSISS_t2, predictor=SSOSH_t1, dist=poisson);


/*-------------------*/
/*Time 1 with Time 3*/
	/*Main - Poisson*/
%proc_genmod (data=hom_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_ps_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_bc_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSs_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSi_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSg_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SSOSH_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);

	/*Complete case*/
%proc_genmod (data=hom_5, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_ps_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_5, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_bc_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_5, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSs_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_5, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSi_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_5, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSg_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_5, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SSOSH_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);

	/*No covariates*/
%proc_genmod (data=hom_2, outcome=DSISS_t3, predictor=mean_ps_1, dist=poisson);
%proc_genmod (data=hom_2, outcome=DSISS_t3, predictor=mean_bc_1, dist=poisson);
%proc_genmod (data=hom_2, outcome=DSISS_t3, predictor=SOSSs_t1, dist=poisson);
%proc_genmod (data=hom_2, outcome=DSISS_t3, predictor=SOSSi_t1, dist=poisson);
%proc_genmod (data=hom_2, outcome=DSISS_t3, predictor=SOSSg_t1, dist=poisson);
%proc_genmod (data=hom_2, outcome=DSISS_t3, predictor=SSOSH_t1, dist=poisson);


/*------------------*/
/*Time 2 with Time 2*/
	/*Main - Poisson*/
%proc_genmod (data=hom_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=mean_ps_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=mean_bc_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSs_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSi_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSg_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SSOSH_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);

	/*Complete case*/
%proc_genmod (data=hom_5, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=mean_ps_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_5, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=mean_bc_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_5, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSs_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_5, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSi_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_5, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSg_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_5, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SSOSH_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);

	/*No covariates*/
%proc_genmod (data=hom_2, outcome=DSISS_t2, predictor=mean_ps_2, dist=poisson);
%proc_genmod (data=hom_2, outcome=DSISS_t2, predictor=mean_bc_2, dist=poisson);
%proc_genmod (data=hom_2, outcome=DSISS_t2, predictor=SOSSs_t2, dist=poisson);
%proc_genmod (data=hom_2, outcome=DSISS_t2, predictor=SOSSi_t2, dist=poisson);
%proc_genmod (data=hom_2, outcome=DSISS_t2, predictor=SOSSg_t2, dist=poisson);
%proc_genmod (data=hom_2, outcome=DSISS_t2, predictor=SSOSH_t2, dist=poisson);


/*------------------*/
/*Time 2 with Time 3*/
	/*Main - Poisson*/
%proc_genmod (data=hom_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_ps_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_bc_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSs_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSi_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSg_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SSOSH_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);

	/*Complete case*/
%proc_genmod (data=hom_5, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_ps_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_5, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_bc_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_5, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSs_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_5, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSi_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_5, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSg_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_5, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SSOSH_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);

	/*No covariates*/
%proc_genmod (data=hom_2, outcome=DSISS_t3, predictor=mean_ps_2, dist=poisson);
%proc_genmod (data=hom_2, outcome=DSISS_t3, predictor=mean_bc_2, dist=poisson);
%proc_genmod (data=hom_2, outcome=DSISS_t3, predictor=SOSSs_t2, dist=poisson);
%proc_genmod (data=hom_2, outcome=DSISS_t3, predictor=SOSSi_t2, dist=poisson);
%proc_genmod (data=hom_2, outcome=DSISS_t3, predictor=SOSSg_t2, dist=poisson);
%proc_genmod (data=hom_2, outcome=DSISS_t3, predictor=SSOSH_t2, dist=poisson);


/*------------------*/
/*Time 3 with Time 3*/
	/*Main - Poisson*/
%proc_genmod (data=hom_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_ps_3, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_bc_3, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSs_t3, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSi_t3, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSg_t3, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SSOSH_t3, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);

	/*Complete case*/
%proc_genmod (data=hom_5, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_ps_3, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_5, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_bc_3, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_5, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSs_t3, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_5, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSi_t3, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_5, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSg_t3, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);
%proc_genmod (data=hom_5, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SSOSH_t3, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=poisson);

	/*No covariates*/
%proc_genmod (data=hom_2, outcome=DSISS_t3, predictor=mean_ps_3, dist=poisson);
%proc_genmod (data=hom_2, outcome=DSISS_t3, predictor=mean_bc_3, dist=poisson);
%proc_genmod (data=hom_2, outcome=DSISS_t3, predictor=SOSSs_t3, dist=poisson);
%proc_genmod (data=hom_2, outcome=DSISS_t3, predictor=SOSSi_t3, dist=poisson);
%proc_genmod (data=hom_2, outcome=DSISS_t3, predictor=SOSSg_t3, dist=poisson);
%proc_genmod (data=hom_2, outcome=DSISS_t3, predictor=SSOSH_t3, dist=poisson);

/*End*/
