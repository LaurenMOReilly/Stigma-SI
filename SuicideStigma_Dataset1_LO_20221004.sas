/*----------------------------------------------------
Project Title: Suicide Stigma and SI: IPT
Dataset: Melanie Hom's Sleep and Mental Health Study
Author: Lauren OReilly
Date: 10/04/2022
Revisions: 
-----------------------------------------------------*/
/*Required: SAS datafile has permanent formats but don't have format library
  Allows to process SAS files despite not having format library
  Not able to see formatted values for variables*/
OPTIONS nofmterr;

/*Assign library*/
/*IU Citrix Receiver Destination*/
libname suistg '\\Client\D$\Internship Resources\Stigma';

data suistg_;
set '\\Client\C$\Users\loreilly\OneDrive - Indiana University\My Passport Backup\Internship Resources\Stigma\suistg_';
run;

data suistg_1;
set '\\Client\C$\Users\loreilly\OneDrive - Indiana University\My Passport Backup\Internship Resources\Stigma\suistg_1';
run;

/*Import data file - original data file*/
/*
proc import out=work.suistg
	datafile='D:\Data\1707701 Yu-MH Stigma-Suicidal\Data\Sleep & Mental Health Study_Transposed.sav'
	DBMS=SAV replace;
run;
*/

/*Set local macros*/
%let Vars = SOSSs_t1 SOSSi_t1 SOSSg_t1 SOSSs_t2 SOSSi_t2 SOSSg_t2 INQPB_t1 INQPB_t2 INQTB_t1 INQTB_t2 BSS_t1 BSS_t2 BSS_t3;
%let VarsDSS = SOSSs_t1 SOSSi_t1 SOSSg_t1 SOSSs_t2 SOSSi_t2 SOSSg_t2 INQPB_t1 INQPB_t2 INQTB_t1 INQTB_t2 DSISS_t1 DSISS_t2 DSISS_t3;
%let SOSS = SOSS_SF_1_1 SOSS_SF_2_1 SOSS_SF_3_1 SOSS_SF_4_1 SOSS_SF_5_1 SOSS_SF_6_1 
	SOSS_SF_7_1 SOSS_SF_8_1 SOSS_SF_9_1 SOSS_SF_10_1 SOSS_SF_11_1 SOSS_SF_12_1 SOSS_SF_13_1
	SOSS_SF_14_1 SOSS_SF_15_1 SOSS_SF_16_1;

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

/*Simple statistics*/
%proc_uni (data=suistg, var=&Vars);

%sgplot (var=SOSSs_t1);
%sgplot (var=SOSSi_t1);
%sgplot (var=SOSSg_t1);
%sgplot (var=SOSSs_t2);
%sgplot (var=SOSSi_t2);
%sgplot (var=SOSSg_t2);
%sgplot (var=INQPB_t1);
%sgplot (var=INQPB_t2);
%sgplot (var=INQTB_t1);
%sgplot (var=INQTB_t2);
%sgplot (var=BSS_t1);
%sgplot (var=BSS_t2);
%sgplot (var=BSS_t3);

/*Missingness*/
proc mi data = suistg nimpute=0 displaypattern=nomeans;
	var &Vars;
run;

/*Examine dispersion*/
proc means data = suistg mean var n nway;
	var SOSSs_t1 SOSSi_t1 SOSSg_t1 SOSSs_t2 SOSSi_t2 SOSSg_t2 INQPB_t1 INQPB_t2 INQTB_t1 INQTB_t2 BSS_t3; 
run;

proc means data = suistg_ mean var n nway;
	var mean_ps_1 mean_ps_2 mean_ps_3 mean_bc_1 mean_bc_2 mean_bc_3 BSS_t1 BSS_t2 BSS_t3 BSS_t1 BSS_t2 BSS_t3; 
run;

proc means data = suistg mean var n nway;
	var DSISS_t1 DSISS_t2 DSISS_t3; 
run;

proc means data = suistg mean var n nway;
	var PS_1_1 PS_2_1 PS_3_1 PS_4_1 PS_5_1 PS_6_1 PS_7_1 PS_8_1 PS_9_1 PS_10_1 PS_11_1
	PS_1_2 PS_2_2 PS_3_2 PS_4_2 PS_5_2 PS_6_2 PS_7_2 PS_8_2 PS_9_2 PS_10_2 PS_11_2
	PS_1_3 PS_2_3 PS_3_3 PS_4_3 PS_5_3 PS_6_3 PS_7_3 PS_8_3 PS_9_3 PS_10_3 PS_11_3; 
run;

/*Create missingness indicator for stigma variables to predict SI*/
data suistg_;
	set suistg;

	/*Add dataset indicator*/
	dataset = 0;
	
	/*No missing at Time 1*/
	/*
	SOSSs_t1_miss = 0;
	SOSSi_t1_miss = 0;
	SOSSg_t1_miss = 0;
	INQPB_t1_miss = 0;
	INQTB_t1_miss = 0;
	*/

	SOSSs_t2_miss = 0;
	SOSSi_t2_miss = 0;
	SOSSg_t2_miss = 0;
	INQPB_t2_miss = 0;
	INQTB_t2_miss = 0;

	BSS_t1_miss = 0;
	BSS_t2_miss = 0;
	BSS_t3_miss = 0;

	/*
	if SOSSs_t1 = '.' then SOSSs_t1_miss = 1;
	if SOSSi_t1 = '.' then SOSSi_t1_miss = 1;
	if SOSSg_t1 = '.' then SOSSg_t1_miss = 1;
	if INQPB_t1 = '.' then INQPB_t1_miss = 1;
	if INQTB_t1 = '.' then INQTB_t1_miss = 1;
	*/

	if SOSSs_t2 = '.' then SOSSs_t2_miss = 1;
	if SOSSi_t2 = '.' then SOSSi_t2_miss = 1;
	if SOSSg_t2 = '.' then SOSSg_t2_miss = 1;
	if INQPB_t2 = '.' then INQPB_t2_miss = 1;
	if INQTB_t2 = '.' then INQTB_t2_miss = 1;

	if BSS_t1 = '.' then BSS_t1_miss = 1;
	if BSS_t2 = '.' then BSS_t2_miss = 1;
	if BSS_t3 = '.' then BSS_t3_miss = 1;

	/*Dichotomize BSS variabls*/
	if BSS_t1 > 0 then BSS_t1d = 1;
		else if BSS_t1 = 0 then BSS_t1d = 0;

	if BSS_t2 > 0 then BSS_t2d = 1;
		else if BSS_t2 = 0 then BSS_t2d = 0;

	if BSS_t3 > 0 then BSS_t3d = 1;
		else if BSS_t3 = 0 then BSS_t3d = 0;

	/*Create mean variable for perceived stigma and barriers to care variables by wave*/
	mean_ps_1 = mean (PS_1_1, PS_2_1, PS_3_1, PS_4_1, PS_5_1, PS_6_1);
	mean_ps_2 = mean (PS_1_2, PS_2_2, PS_3_2, PS_4_2, PS_5_2, PS_6_2);
	mean_ps_3 = mean (PS_1_3, PS_2_3, PS_3_3, PS_4_3, PS_5_3, PS_6_3);

	mean_bc_1 = mean (PS_7_1, PS_8_1, PS_9_1, PS_10_1, PS_11_1);
	mean_bc_2 = mean (PS_7_2, PS_8_2, PS_9_2, PS_10_2, PS_11_2);
	mean_bc_3 = mean (PS_7_3, PS_8_3, PS_9_3, PS_10_3, PS_11_3);

	/*Recode range of SSOSH variables*/
	SSOSH_t1_ = SSOSH_t1 - 10;
	SSOSH_t2_ = SSOSH_t2 - 10;
	SSOSH_t3_ = SSOSH_t3 - 10;

	/*Dummy code covariates*/
	if sex = 2 then 
		do;
			sex = 0;
		end;
	else if sex = 1 then 
		do;
			sex = 1;
		end;

	if race = 1 then
		do;
			black = 0;
			hispanic = 0;
			asian = 0;
			other = 0;
		end;
	else if race = 2 then
		do;
			black = 1;
			hispanic = 0;
			asian = 0;
			other = 0;
		end;
	else if race = 3 then
		do;
			black = 0;
			hispanic = 1;
			asian = 0;
			other = 0;
		end;
	else if race = 4 then
		do;
			black = 0;
			hispanic = 0;
			asian = 1;
			other = 0;
		end;
	else if race >4 then
		do;
			black = 0;
			hispanic = 0;
			asian = 0;
			other = 1;
		end;

	if sex_orient = 1 then
		do;
			sex_minority = 0;
		end;
	else if sex_orient = 2 then
		do;
			sex_minority = 1;
		end;
	else if sex_orient = 3 then
		do;
			sex_minority = 1;
		end;
	else if sex_orient = 4 then
		do;
			sex_minority = 1;
		end;

	if age = 18 then 
		do;
			age19 = 0;
			age20 = 0;
			age20older = 0;
			age21older = 0;
		end;
	else if age = 19 then 
		do;
			age19 = 1;
			age20 = 0;
			age20older = 0;
			age21older = 0;
		end;
	else if age = 20 then 
		do;
			age19 = 0;
			age20 = 1;
			age20older = 1;
			age21older = 0;
		end;
	else if age = 21 then 
		do;
			age19 = 0;
			age20 = 0;
			age20older = 1;
			age21older = 1;
		end;
	else if age = 22 then 
		do;
			age19 = 0;
			age20 = 0;
			age20older = 1;
			age21older = 1;
		end;
	else if age >=23 then 
		do;
			age19 = 0;
			age20 = 0;
			age20older = 1;
			age21older = 1;
		end;

	if MHS_ther_gen_lt ^= '.' or MHS_psych_gen_lt ^= '.' or MHS_other_gen_lt ^= '.' or MHS_clergy_gen_lt ^= '.' then
		 do;
			past_MHT = 1;
		end;
	else past_MHT = 0;

	if MHS_ther_gen_pm ^= '.' or MHS_psych_gen_pm ^= '.' or MHS_other_gen_pm ^= '.' or MHS_clergy_gen_pm ^= '.' then
		 do;
			pastmo_MHT = 1;
		end;
	else pastmo_MHT = 0;

	/*Code missing to 0 for employment variables*/
	if employ_ft_work = '.' then employ_ft_work = 0;
	if employ_pt_work = '.' then employ_pt_work = 0;

	/*Code DSI-SS*/
	DSISS_t1 = sum (of DSISS_A_1 DSISS_B_1 DSISS_C_1 DSISS_D_1);
	DSISS_t2 = sum (of DSISS_A_2 DSISS_B_2 DSISS_C_2 DSISS_D_2);
	DSISS_t3 = sum (of DSISS_A_3 DSISS_B_3 DSISS_C_3 DSISS_D_3);

	/*Dichotomize DSI-SS*/
	if DSISS_t1 > 0 then DSISS_t1d = 1; 
		else if DSISS_t1 = 0 then DSISS_t1d = 0;
	if DSISS_t2 > 0 then DSISS_t2d = 1; 
		else if DSISS_t2 = 0 then DSISS_t2d = 0;
	if DSISS_t3 > 0 then DSISS_t3d = 1; 
		else if DSISS_t3 = 0 then DSISS_t3d = 0;

	/*Create indicators for completing data collection by wave*/
	t1 = 1;

	if DSISS_t2 ^= '.' then t2 = 1;
		else if DSISS_t2 = '.' then t2 = 0;

	if DSISS_t3 ^= '.' then t3 = 1;
		else if DSISS_t3 = '.' then t3 = 0;

run;

/*
proc sql;
create table check_ as
select MHS_ther_gen_lt, MHS_psych_gen_lt, MHS_other_gen_lt, MHS_clergy_gen_lt, past_MHT,
	   MHS_ther_gen_pm, MHS_psych_gen_pm, MHS_other_gen_pm, MHS_clergy_gen_pm, pastmo_MHT
from suistg_;
quit;
*/

/*Standardize variables*/
proc standard data=suistg_ mean=0 std=1 out=suistg_1;
	var mean_ps_1 mean_bc_1 SOSSs_t1 SOSSi_t1 SOSSg_t1 SSOSH_t1_
	mean_ps_2 mean_bc_2 SOSSs_t2 SOSSi_t2 SOSSg_t2 SSOSH_t2_
	mean_ps_3 mean_bc_3 SOSSs_t3 SOSSi_t3 SOSSg_t3 SSOSH_t3_
	;
run;

proc standard data=suistg.suistg_ mean=0 std=1 out=suistg_1;
	var mean_ps_1 mean_bc_1 SOSSs_t1 SOSSi_t1 SOSSg_t1 SSOSH_t1_
	mean_ps_2 mean_bc_2 SOSSs_t2 SOSSi_t2 SOSSg_t2 SSOSH_t2_
	mean_ps_3 mean_bc_3 SOSSs_t3 SOSSi_t3 SOSSg_t3 SSOSH_t3_
	;
run;

/*NOTE: issue here in code - assigned nonstandardized dataset to suistg_1 - variables */
data suistg.suistg_1; 
	set suistg_; 
		keep ID sex age race past_MHT 
		mean_ps_1 mean_bc_1 SOSSs_t1 SOSSi_t1 SOSSg_t1 SSOSH_t1_
		mean_ps_2 mean_bc_2 SOSSs_t2 SOSSi_t2 SOSSg_t2 SSOSH_t2_
		mean_ps_3 mean_bc_3 SOSSs_t3 SOSSi_t3 SOSSg_t3 SSOSH_t3_
		DSISS_t1 DSISS_t2 DSISS_t3;
run;

proc mi data = suistg.suistg_1 seed=123 nimpute=1 out=suistg_1mi;
	class ID sex age race past_MHT 
		mean_ps_1 mean_bc_1 SOSSs_t1 SOSSi_t1 SOSSg_t1 SSOSH_t1_
		mean_ps_2 mean_bc_2 SOSSs_t2 SOSSi_t2 SOSSg_t2 SSOSH_t2_
		mean_ps_3 mean_bc_3 SOSSs_t3 SOSSi_t3 SOSSg_t3 SSOSH_t3_
		DSISS_t1 DSISS_t2 DSISS_t3;
	fcs nbiter=40 discrim (mean_ps_1 mean_bc_1 SOSSs_t1 SOSSi_t1 SOSSg_t1 SSOSH_t1_
		mean_ps_2 mean_bc_2 SOSSs_t2 SOSSi_t2 SOSSg_t2 SSOSH_t2_
		mean_ps_3 mean_bc_3 SOSSs_t3 SOSSi_t3 SOSSg_t3 SSOSH_t3_
		DSISS_t1 DSISS_t2 DSISS_t3 / classeffects=include)
				  ;
	var ID sex age race past_MHT 
		mean_ps_1 mean_bc_1 SOSSs_t1 SOSSi_t1 SOSSg_t1 SSOSH_t1_
		mean_ps_2 mean_bc_2 SOSSs_t2 SOSSi_t2 SOSSg_t2 SSOSH_t2_
		mean_ps_3 mean_bc_3 SOSSs_t3 SOSSi_t3 SOSSg_t3 SSOSH_t3_
		DSISS_t1 DSISS_t2 DSISS_t3;
run;




/*Univariate stats of measures*/
%proc_freq (data=suistg_, var=SOSSs_t2_miss SOSSi_t2_miss SOSSg_t2_miss INQPB_t2_miss INQTB_t2_miss 
     	  BSS_t1_miss BSS_t2_miss BSS_t3_miss BSS_t1d BSS_t2d BSS_t3d);
%proc_freq (data=suistg_, var=MHS_ther_gen_lt MHS_ther_si_lt MHS_ther_no_lt MHS_psych_gen_lt MHS_psych_no_lt 
MHS_other_gen_lt MHS_clergy_gen_lt supp_hotline_gen_lt MHS_hosp_yn_lt);
%proc_freq (data=suistg_, var=MHS_hosp_yn_lt);
%proc_freq (data=suistg_, var=mean_ps_1 mean_bc_1 SOSSs_t1 SOSSi_t1 SOSSg_t1 SSOSH_t1_
		mean_ps_2 mean_bc_2 SOSSs_t2 SOSSi_t2 SOSSg_t2 SSOSH_t2_
		mean_ps_3 mean_bc_3 SOSSs_t3 SOSSi_t3 SOSSg_t3 SSOSH_t3_);
%proc_freq (data=suistg_1mi, var=mean_ps_1 mean_bc_1 SOSSs_t1 SOSSi_t1 SOSSg_t1 SSOSH_t1_
		mean_ps_2 mean_bc_2 SOSSs_t2 SOSSi_t2 SOSSg_t2 SSOSH_t2_
		mean_ps_3 mean_bc_3 SOSSs_t3 SOSSi_t3 SOSSg_t3 SSOSH_t3_);

%proc_freq (data=suistg_, var=dataset);
%proc_freq (data=suistg_, var=t1 t2 t3);
%proc_freq (data=suistg_, var=past_MHT);
%proc_freq (data=suistg_, var=sex);
%proc_freq (data=suistg_, var=sex race sex_orient age);
%proc_freq (data=suistg_, var=sex black hispanic asian other sex_minority age19 age20 age20older age21older);
%proc_freq (data=suistg_, var=marital military education employ_ft_work employ_pt_work);
proc freq data = suistg_;
	table sex race sex_orient age past_MHT marital military education employ_ft_work employ_pt_work;
	where t2 = 1;
run;
proc freq data = suistg_;
	table sex race sex_orient age past_MHT marital military education employ_ft_work employ_pt_work;
	where t3 = 1;
run;
%proc_freq (data=suistg_, var=PS_1_1 PS_2_1 PS_3_1 PS_4_1 PS_5_1 PS_6_1 PS_7_1 PS_8_1 PS_9_1 PS_10_1 PS_11_1);
%proc_freq (data=suistg_, var=PS_1_2 PS_2_2 PS_3_2 PS_4_2 PS_5_2 PS_6_2 PS_7_2 PS_8_2 PS_9_2 PS_10_2 PS_11_2);
%proc_freq (data=suistg_, var=PS_1_3 PS_2_3 PS_3_3 PS_4_3 PS_5_3 PS_6_3 PS_7_3 PS_8_3 PS_9_3 PS_10_3 PS_11_3);

%proc_freq (data=suistg_, var=SSOSH_1_1 SSOSH_2_1 SSOSH_3_1 SSOSH_4_1 SSOSH_5_1 SSOSH_6_1 SSOSH_7_1 SSOSH_8_1 SSOSH_9_1 SSOSH_10_1);
%proc_freq (data=suistg_, var=SSOSH_2_rev_1 SSOSH_4_rev_1 SSOSH_5_rev_1 SSOSH_7_rev_1 SSOSH_9_rev_1);
%proc_freq (data=suistg_, var=SSOSH_2_rev_2 SSOSH_4_rev_2 SSOSH_5_rev_2 SSOSH_7_rev_2 SSOSH_9_rev_2);
%proc_freq (data=suistg_, var=SSOSH_1_2 SSOSH_2_2 SSOSH_3_2 SSOSH_4_2 SSOSH_5_2 SSOSH_6_2 SSOSH_7_2 SSOSH_8_2 SSOSH_9_2 SSOSH_10_2);
%proc_freq (data=suistg_, var=SSOSH_1_3 SSOSH_2_3 SSOSH_3_3 SSOSH_4_3 SSOSH_5_3 SSOSH_6_3 SSOSH_7_3 SSOSH_8_3 SSOSH_9_3 SSOSH_10_3);

%proc_freq (data=suistg_, var=SOSSs_t1 SOSSi_t1 SOSSg_t1);

%proc_uni (data=suistg_, var=DSISS_t1 DSISS_t2 DSISS_t3);
%proc_freq (data=suistg_, var=DSISS_t1 DSISS_t2 DSISS_t3);
%proc_freq (data=suistg_, var=DSISS_t1d DSISS_t2d DSISS_t3d);

%proc_uni (data=suistg_, var=mean_ps_3 mean_bc_3 SOSSs_t3 SOSSi_t3 SOSSg_t3 SSOSH_t3_ BSS_t3 DSISS_t3);

%proc_uni (data = suistg_, var=mean_ps_1 mean_ps_2 mean_ps_3 mean_bc_1 mean_bc_2 mean_bc_3);
%proc_uni (data = suistg_, var=SOSSs_t1 SOSSi_t1 SOSSg_t1 SOSSs_t2 SOSSi_t2 SOSSg_t2 SOSSs_t3 SOSSi_t3 SOSSg_t3);
%proc_uni (data = suistg_, var=SSOSH_t1_ SSOSH_t2_ SSOSH_t3_);

%proc_corr (data = suistg_, var=SOSSs_t2_miss SOSSi_t2_miss SOSSg_t2_miss INQPB_t2_miss INQTB_t2_miss BSS_t3_miss BSS_t3);
%proc_corr (data = suistg_, var=mean_ps_1 mean_ps_2 mean_ps_3 BSS_t1 BSS_t2 BSS_t3);

/*Chi-square*/
data suistg_chi;
	set suistg_;

	if age > 21 then age = 21;

	if education > 4 then education = 4;

	if race = 1 then nonwhite = 0;
	if race > 1 then nonwhite = 1;
run;

proc freq data = suistg_;
	tables (t3) * (sex race sex_orient age past_MHT marital military education employ_ft_work employ_pt_work) / chisq
		plots=(freqplot(twoway=groupvertical scale=percent));
run;

proc freq data = suistg_chi;
	tables (t3) * (sex_minority nonwhite age education) / chisq
		plots=(freqplot(twoway=groupvertical scale=percent));
run;


/*Complete case*/
data suistg_2;
	set suistg_1;
		if mean_ps_1 = '.' then delete;
		if mean_bc_1 = '.' then delete;
		if SOSSs_t1 = '.' then delete;
		if SOSSi_t1 = '.' then delete;
		if SOSSg_t1 = '.' then delete;
		if SSOSH_t1_ = '.' then delete;
		/*if BSS_t1 = '.' then delete;*/

		if mean_ps_2 = '.' then delete;
		if mean_bc_2 = '.' then delete;
		if SOSSs_t2 = '.' then delete;
		if SOSSi_t2 = '.' then delete;
		if SOSSg_t2 = '.' then delete;
		if SSOSH_t2_ = '.' then delete;
		/*if BSS_t2 = '.' then delete;*/

		if mean_ps_3 = '.' then delete;
		if mean_bc_3 = '.' then delete;
		if SOSSs_t3 = '.' then delete;
		if SOSSi_t3 = '.' then delete;
		if SOSSg_t3 = '.' then delete;
		if SSOSH_t3_ = '.' then delete;
		/*if BSS_t3 = '.' then delete;*/

		if DSISS_t1 = '.' then delete;
		if DSISS_t2 = '.' then delete;
		if DSISS_t3 = '.' then delete;
run;

data suistg.suistg_2;
	set suistg_2;
run;

/*Associations with covariates*/
/*
proc genmod data = suistg_1;
	class sex;
	model BSS_t1 = sex / dist=poisson;
run;

proc genmod data = suistg_1;
	model BSS_t1 = CESDR_t1 / dist=poisson;
run;


proc reg data = suistg_1;
	model SOSSs_t1 = age;
run;

proc reg data = suistg_1;
	model SOSSs_t1 = sex;
run;

proc reg data = suistg_1;
	model SOSSi_t1 = CESDR_t1;
run;
*/

/*MACRO for Poisson regression*/
%MACRO proc_genmod (data=, classvars=, outcome=, predictor=, allvars=, dist=);
proc genmod data = &data;
	class &classvars / desc;
	model &outcome = &predictor &allvars / dist=&dist;
	zeromodel &outcome / link=logit;
	estimate '&predictor' &predictor 1 / exp;
run;
%MEND;


/*Check covariates*/
%proc_genmod (data=suistg_1, classvars=sex, outcome=BSS_t1, predictor=sex, dist=poisson);
%proc_genmod (data=suistg_1, outcome=BSS_t1, classvars=age, predictor=SOSSs_t1, allvars=age, dist=zip);
%proc_genmod (data=suistg_1, outcome=BSS_t1, predictor=SOSSi_t1, dist=zip);
%proc_genmod (data=suistg_1, outcome=BSS_t1, predictor=mean_ps_1, dist=poisson);

/*--------------------------*/
/*Time 1 with Time 1*/
		/*BSS*/
			/*Poisson*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t1, predictor=mean_ps_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t1, predictor=mean_bc_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t1, predictor=SOSSs_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t1, predictor=SOSSi_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t1, predictor=SOSSg_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t1, predictor=SSOSH_t1_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);

			/*Neg binomial*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t1, predictor=mean_ps_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t1, predictor=mean_bc_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t1, predictor=SOSSs_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t1, predictor=SOSSi_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t1, predictor=SOSSg_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t1, predictor=SSOSH_t1_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
	
		/*DSISS*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=mean_ps_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=mean_bc_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=SOSSs_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=SOSSi_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=SOSSg_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=SSOSH_t1_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);

			/*Neg Bin*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=mean_ps_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=mean_bc_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=SOSSs_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=SOSSi_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=SOSSg_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=SSOSH_t1_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);

	/*No covariates*/
		/*BSS*/
%proc_genmod (data=suistg_1, outcome=BSS_t1, predictor=mean_ps_1, dist=poisson);
%proc_genmod (data=suistg_1, outcome=BSS_t1, predictor=mean_bc_1, dist=poisson);
%proc_genmod (data=suistg_1, outcome=BSS_t1, predictor=SOSSs_t1, dist=poisson);
%proc_genmod (data=suistg_1, outcome=BSS_t1, predictor=SOSSi_t1, dist=poisson);
%proc_genmod (data=suistg_1, outcome=BSS_t1, predictor=SOSSg_t1, dist=poisson);
%proc_genmod (data=suistg_1, outcome=BSS_t1, predictor=SSOSH_t1_, dist=poisson);

		/*DSISS*/
			/*Poisson*/
%proc_genmod (data=suistg_1, outcome=DSISS_t1, predictor=mean_ps_1, dist=poisson);
%proc_genmod (data=suistg_1, outcome=DSISS_t1, predictor=mean_bc_1, dist=poisson);
%proc_genmod (data=suistg_1, outcome=DSISS_t1, predictor=SOSSs_t1, dist=poisson);
%proc_genmod (data=suistg_1, outcome=DSISS_t1, predictor=SOSSi_t1, dist=poisson);
%proc_genmod (data=suistg_1, outcome=DSISS_t1, predictor=SOSSg_t1, dist=poisson);
%proc_genmod (data=suistg_1, outcome=DSISS_t1, predictor=SSOSH_t1_, dist=poisson);

			/*Neg binomial*/
%proc_genmod (data=suistg_1, outcome=DSISS_t1, predictor=mean_ps_1, dist=negbin);
%proc_genmod (data=suistg_1, outcome=DSISS_t1, predictor=mean_bc_1, dist=negbin);
%proc_genmod (data=suistg_1, outcome=DSISS_t1, predictor=SOSSs_t1, dist=negbin);
%proc_genmod (data=suistg_1, outcome=DSISS_t1, predictor=SOSSi_t1, dist=negbin);
%proc_genmod (data=suistg_1, outcome=DSISS_t1, predictor=SOSSg_t1, dist=negbin);
%proc_genmod (data=suistg_1, outcome=DSISS_t1, predictor=SSOSH_t1_, dist=negbin);

	/*Complete case*/
		/*BSS*/
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t1, predictor=mean_ps_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t1, predictor=mean_bc_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t1, predictor=SOSSs_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t1, predictor=SOSSi_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t1, predictor=SOSSg_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t1, predictor=SSOSH_t1_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);

		/*DSISS*/
			/*Poisson*/
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian sex_minority age19 age20older past_MHT, outcome=DSISS_t1, predictor=mean_ps_1, allvars=sex black hispanic asian sex_minority age19 age20older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian sex_minority age19 age20older past_MHT, outcome=DSISS_t1, predictor=mean_bc_1, allvars=sex black hispanic asian sex_minority age19 age20older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian sex_minority age19 age20older past_MHT, outcome=DSISS_t1, predictor=SOSSs_t1, allvars=sex black hispanic asian sex_minority age19 age20older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian sex_minority age19 age20older past_MHT, outcome=DSISS_t1, predictor=SOSSi_t1, allvars=sex black hispanic asian sex_minority age19 age20older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian sex_minority age19 age20older past_MHT, outcome=DSISS_t1, predictor=SOSSg_t1, allvars=sex black hispanic asian sex_minority age19 age20older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian sex_minority age19 age20older past_MHT, outcome=DSISS_t1, predictor=SSOSH_t1_, allvars=sex black hispanic asian sex_minority age19 age20older past_MHT, dist=poisson);

			/*Neg binomial*/
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=mean_ps_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=mean_bc_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=SOSSs_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=SOSSi_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=SOSSg_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=SSOSH_t1_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);

	/*Zero inflated poisson*/
		/*BSS*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t1, predictor=mean_ps_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t1, predictor=mean_bc_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t1, predictor=SOSSs_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t1, predictor=SOSSi_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t1, predictor=SOSSg_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t1, predictor=SSOSH_t1_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);

		/*DSISS*/
			/*Poisson*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=mean_ps_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=mean_bc_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=SOSSs_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=SOSSi_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=SOSSg_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=SSOSH_t1_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);

			/*Neg binomial*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=mean_ps_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zinb);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=mean_bc_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zinb);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=SOSSs_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zinb);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=SOSSi_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zinb);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=SOSSg_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zinb);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t1, predictor=SSOSH_t1_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zinb);


/*--------------------------*/
/*Time 1 with Time 2*/
		/*BSS*/
			/*Poisson*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=mean_ps_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=mean_bc_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=SOSSs_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=SOSSi_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=SOSSg_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=SSOSH_t1_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);

			/*Neg binomial*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=mean_ps_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=mean_bc_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=SOSSs_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=SOSSi_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=SOSSg_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=SSOSH_t1_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);

		/*DSISS*/
			/*Poisson*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=mean_ps_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=mean_bc_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSs_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSi_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSg_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SSOSH_t1_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);

			/*Neg binomial*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=mean_ps_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=mean_bc_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSs_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSi_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSg_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SSOSH_t1_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);

				/*With DSISS covariate*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=mean_ps_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=mean_bc_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSs_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSi_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSg_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SSOSH_t1_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);

	/*No covariates*/
		/*BSS*/
%proc_genmod (data=suistg_1, outcome=BSS_t2, predictor=mean_ps_1, dist=poisson);
%proc_genmod (data=suistg_1, outcome=BSS_t2, predictor=mean_bc_1, dist=poisson);
%proc_genmod (data=suistg_1, outcome=BSS_t2, predictor=SOSSs_t1, dist=poisson);
%proc_genmod (data=suistg_1, outcome=BSS_t2, predictor=SOSSi_t1, dist=poisson);
%proc_genmod (data=suistg_1, outcome=BSS_t2, predictor=SOSSg_t1, dist=poisson);
%proc_genmod (data=suistg_1, outcome=BSS_t2, predictor=SSOSH_t1_, dist=poisson);

		/*DSISS*/
			/*Poisson*/
%proc_genmod (data=suistg_1, outcome=DSISS_t2, predictor=mean_ps_1, dist=poisson);
%proc_genmod (data=suistg_1, outcome=DSISS_t2, predictor=mean_bc_1, dist=poisson);
%proc_genmod (data=suistg_1, outcome=DSISS_t2, predictor=SOSSs_t1, dist=poisson);
%proc_genmod (data=suistg_1, outcome=DSISS_t2, predictor=SOSSi_t1, dist=poisson);
%proc_genmod (data=suistg_1, outcome=DSISS_t2, predictor=SOSSg_t1, dist=poisson);
%proc_genmod (data=suistg_1, outcome=DSISS_t2, predictor=SSOSH_t1_, dist=poisson);

			/*Neg binomial*/
%proc_genmod (data=suistg_1, outcome=DSISS_t2, predictor=mean_ps_1, dist=negbin);
%proc_genmod (data=suistg_1, outcome=DSISS_t2, predictor=mean_bc_1, dist=negbin);
%proc_genmod (data=suistg_1, outcome=DSISS_t2, predictor=SOSSs_t1, dist=negbin);
%proc_genmod (data=suistg_1, outcome=DSISS_t2, predictor=SOSSi_t1, dist=negbin);
%proc_genmod (data=suistg_1, outcome=DSISS_t2, predictor=SOSSg_t1, dist=negbin);
%proc_genmod (data=suistg_1, outcome=DSISS_t2, predictor=SSOSH_t1_, dist=negbin);

	/*Complete case*/
		/*BSS*/
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=mean_ps_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=mean_bc_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=SOSSs_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=SOSSi_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=SOSSg_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=SSOSH_t1_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);

	 /*DSISS*/
		/*Poisson*/
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=mean_ps_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=mean_bc_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSs_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSi_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSg_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SSOSH_t1_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);

		/*Neg binomial w/ DSISS covariates*/
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=mean_ps_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=mean_bc_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSs_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSi_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSg_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SSOSH_t1_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);

	/*Zero inflated poisson*/
		/*BSS*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=mean_ps_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=mean_bc_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=SOSSs_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=SOSSi_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=SOSSg_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=SSOSH_t1_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);

		/*DSISS*/
			/*Poisson*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=mean_ps_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=mean_bc_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSs_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSi_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSg_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SSOSH_t1_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);

			/*Poisson*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=mean_ps_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zinb);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=mean_bc_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zinb);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSs_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zinb);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSi_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zinb);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSg_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zinb);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SSOSH_t1_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zinb);


/*--------------------------*/
/*Time 1 with Time 3*/
		/*BSS*/
			/*Poisson*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=mean_ps_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=mean_bc_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=SOSSs_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=SOSSi_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=SOSSg_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=SSOSH_t1_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);

			/*Neg binomial*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=mean_ps_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=mean_bc_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=SOSSs_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=SOSSi_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=SOSSg_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=SSOSH_t1_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);

		/*DSISS*/
			/*Poisson*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic other sex_minority age19 age20older past_MHT, outcome=DSISS_t3, predictor=mean_ps_1, allvars=sex black hispanic asian other sex_minority age19 age20older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic other sex_minority age19 age20older past_MHT, outcome=DSISS_t3, predictor=mean_bc_1, allvars=sex black hispanic asian other sex_minority age19 age20older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic other sex_minority age19 age20older past_MHT, outcome=DSISS_t3, predictor=SOSSs_t1, allvars=sex black hispanic asian other sex_minority age19 age20older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic other sex_minority age19 age20older past_MHT, outcome=DSISS_t3, predictor=SOSSi_t1, allvars=sex black hispanic asian other sex_minority age19 age20older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic other sex_minority age19 age20older past_MHT, outcome=DSISS_t3, predictor=SOSSg_t1, allvars=sex black hispanic asian other sex_minority age19 age20older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic other sex_minority age19 age20older past_MHT, outcome=DSISS_t3, predictor=SSOSH_t1_, allvars=sex black hispanic asian other sex_minority age19 age20older past_MHT, dist=poisson);

			/*Neg binomial*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_ps_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_bc_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSs_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSi_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSg_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SSOSH_t1_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);

				/*With DSISS covariate*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_ps_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_bc_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSs_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSi_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSg_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SSOSH_t1_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);

	/*No covariates*/
		/*BSS*/
%proc_genmod (data=suistg_1, outcome=BSS_t3, predictor=mean_ps_1, dist=poisson);
%proc_genmod (data=suistg_1, outcome=BSS_t3, predictor=mean_bc_1, dist=poisson);
%proc_genmod (data=suistg_1, outcome=BSS_t3, predictor=SOSSs_t1, dist=poisson);
%proc_genmod (data=suistg_1, outcome=BSS_t3, predictor=SOSSi_t1, dist=poisson);
%proc_genmod (data=suistg_1, outcome=BSS_t3, predictor=SOSSg_t1, dist=poisson);
%proc_genmod (data=suistg_1, outcome=BSS_t3, predictor=SSOSH_t1_, dist=poisson);

		/*DSISS*/
			/*Poisson*/
%proc_genmod (data=suistg_1, outcome=DSISS_t3, predictor=mean_ps_1, dist=poisson);
%proc_genmod (data=suistg_1, outcome=DSISS_t3, predictor=mean_bc_1, dist=poisson);
%proc_genmod (data=suistg_1, outcome=DSISS_t3, predictor=SOSSs_t1, dist=poisson);
%proc_genmod (data=suistg_1, outcome=DSISS_t3, predictor=SOSSi_t1, dist=poisson);
%proc_genmod (data=suistg_1, outcome=DSISS_t3, predictor=SOSSg_t1, dist=poisson);
%proc_genmod (data=suistg_1, outcome=DSISS_t3, predictor=SSOSH_t1_, dist=poisson);

			/*Neg binomial*/
%proc_genmod (data=suistg_1, outcome=DSISS_t3, predictor=mean_ps_1, dist=negbin);
%proc_genmod (data=suistg_1, outcome=DSISS_t3, predictor=mean_bc_1, dist=negbin);
%proc_genmod (data=suistg_1, outcome=DSISS_t3, predictor=SOSSs_t1, dist=negbin);
%proc_genmod (data=suistg_1, outcome=DSISS_t3, predictor=SOSSi_t1, dist=negbin);
%proc_genmod (data=suistg_1, outcome=DSISS_t3, predictor=SOSSg_t1, dist=negbin);
%proc_genmod (data=suistg_1, outcome=DSISS_t3, predictor=SSOSH_t1_, dist=negbin);

	/*Complete case*/
		/*BSS*/
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=mean_ps_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=mean_bc_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=SOSSs_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=SOSSi_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=SOSSg_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=SSOSH_t1_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);

		/*DSISS*/
			/*Poisson*/
%proc_genmod (data=suistg_2, classvars=sex black hispanic other sex_minority age19 age20older past_MHT, outcome=DSISS_t3, predictor=mean_ps_1, allvars=sex black hispanic other sex_minority age19 age20older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic other sex_minority age19 age20older past_MHT, outcome=DSISS_t3, predictor=mean_bc_1, allvars=sex black hispanic other sex_minority age19 age20older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic other sex_minority age19 age20older past_MHT, outcome=DSISS_t3, predictor=SOSSs_t1, allvars=sex black hispanic other sex_minority age19 age20older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic other sex_minority age19 age20older past_MHT, outcome=DSISS_t3, predictor=SOSSi_t1, allvars=sex black hispanic other sex_minority age19 age20older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic other sex_minority age19 age20older past_MHT, outcome=DSISS_t3, predictor=SOSSg_t1, allvars=sex black hispanic other sex_minority age19 age20older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic other sex_minority age19 age20older past_MHT, outcome=DSISS_t3, predictor=SSOSH_t1_, allvars=sex black hispanic other sex_minority age19 age20older past_MHT, dist=poisson);

			/*Neg binomial with DSISS covariate*/
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_ps_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_bc_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSs_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSi_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSg_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SSOSH_t1_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);

	/*Zero inflated poisson*/
		/*BSS*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=mean_ps_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=mean_bc_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=SOSSs_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=SOSSi_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=SOSSg_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=SSOSH_t1_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);

		/*DSISS*/
			/*Poisson*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_ps_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_bc_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSs_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSi_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSg_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SSOSH_t1_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);

			/*Neg binomial*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_ps_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zinb);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_bc_1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zinb);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSs_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zinb);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSi_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zinb);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSg_t1, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zinb);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SSOSH_t1_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zinb);


/*--------------------------*/
/*Time 2 with Time 2*/
		/*BSS*/
			/*Poisson*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=mean_ps_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=mean_bc_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=SOSSs_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=SOSSi_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=SOSSg_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=SSOSH_t2_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);

			/*Neg binomial*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=mean_ps_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=mean_bc_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=SOSSs_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=SOSSi_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=SOSSg_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=SSOSH_t2_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);

		/*DSI-SS*/
			/*Poisson*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=mean_ps_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=mean_bc_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSs_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSi_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSg_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SSOSH_t2_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);

			/*Neg bin*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=mean_ps_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=mean_bc_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSs_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSi_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSg_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SSOSH_t2_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);

				/*With DSISS covariate*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=mean_ps_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=mean_bc_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSs_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSi_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSg_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SSOSH_t2_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);


	/*No covariates*/
		/*BSS*/
%proc_genmod (data=suistg_1, outcome=BSS_t2, predictor=mean_ps_2, dist=poisson);
%proc_genmod (data=suistg_1, outcome=BSS_t2, predictor=mean_bc_2, dist=poisson);
%proc_genmod (data=suistg_1, outcome=BSS_t2, predictor=SOSSs_t2, dist=poisson);
%proc_genmod (data=suistg_1, outcome=BSS_t2, predictor=SOSSi_t2, dist=poisson);
%proc_genmod (data=suistg_1, outcome=BSS_t2, predictor=SOSSg_t2, dist=poisson);
%proc_genmod (data=suistg_1, outcome=BSS_t2, predictor=SSOSH_t2_, dist=poisson);

		/*DSISS*/
			/*Poisson*/
%proc_genmod (data=suistg_1, outcome=DSISS_t2, predictor=mean_ps_2, dist=poisson);
%proc_genmod (data=suistg_1, outcome=DSISS_t2, predictor=mean_bc_2, dist=poisson);
%proc_genmod (data=suistg_1, outcome=DSISS_t2, predictor=SOSSs_t2, dist=poisson);
%proc_genmod (data=suistg_1, outcome=DSISS_t2, predictor=SOSSi_t2, dist=poisson);
%proc_genmod (data=suistg_1, outcome=DSISS_t2, predictor=SOSSg_t2, dist=poisson);
%proc_genmod (data=suistg_1, outcome=DSISS_t2, predictor=SSOSH_t2_, dist=poisson);

			/*Neg binomial*/
%proc_genmod (data=suistg_1, outcome=DSISS_t2, predictor=mean_ps_2, dist=negbin);
%proc_genmod (data=suistg_1, outcome=DSISS_t2, predictor=mean_bc_2, dist=negbin);
%proc_genmod (data=suistg_1, outcome=DSISS_t2, predictor=SOSSs_t2, dist=negbin);
%proc_genmod (data=suistg_1, outcome=DSISS_t2, predictor=SOSSi_t2, dist=negbin);
%proc_genmod (data=suistg_1, outcome=DSISS_t2, predictor=SOSSg_t2, dist=negbin);
%proc_genmod (data=suistg_1, outcome=DSISS_t2, predictor=SSOSH_t2_, dist=negbin);

	/*Complete case*/
		/*BSS*/
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=mean_ps_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=mean_bc_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=SOSSs_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=SOSSi_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=SOSSg_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=SSOSH_t2_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);

		/*DSISS*/
			/*Poisson*/
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=mean_ps_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=mean_bc_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSs_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSi_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSg_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SSOSH_t2_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);

			/*Neg binomial with DSISS covariate*/
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=mean_ps_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=mean_bc_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSs_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSi_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSg_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SSOSH_t2_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);

	/*Zero inflated poisson*/
		/*BSS*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=mean_ps_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=mean_bc_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=SOSSs_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=SOSSi_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=SOSSg_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t2, predictor=SSOSH_t2_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);

		/*DSISS*/
			/*Poisson*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=mean_ps_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=mean_bc_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSs_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSi_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSg_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SSOSH_t2_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);

			/*Poisson*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=mean_ps_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zinb);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=mean_bc_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zinb);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSs_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zinb);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSi_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zinb);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SOSSg_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zinb);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t2, predictor=SSOSH_t2_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zinb);


/*--------------------------*/
/*Time 2 with Time 3*/
		/*BSS*/
			/*Poisson*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=mean_ps_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=mean_bc_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=SOSSs_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=SOSSi_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=SOSSg_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=SSOSH_t2_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);

			/*Neg binomial*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=mean_ps_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=mean_bc_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=SOSSs_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=SOSSi_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=SOSSg_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=SSOSH_t2_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);

		/*DSI-SS*/
			/*Poisson*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic other sex_minority age19 age20older past_MHT, outcome=DSISS_t3, predictor=mean_ps_2, allvars=sex black hispanic other sex_minority age19 age20older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic other sex_minority age19 age20older past_MHT, outcome=DSISS_t3, predictor=mean_bc_2, allvars=sex black hispanic other sex_minority age19 age20older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic other sex_minority age19 age20older past_MHT, outcome=DSISS_t3, predictor=SOSSs_t2, allvars=sex black hispanic other sex_minority age19 age20older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic other sex_minority age19 age20older past_MHT, outcome=DSISS_t3, predictor=SOSSi_t2, allvars=sex black hispanic other sex_minority age19 age20older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic other sex_minority age19 age20older past_MHT, outcome=DSISS_t3, predictor=SOSSg_t2, allvars=sex black hispanic other sex_minority age19 age20older past_MHT, dist=poisson);
%proc_genmod (data=suistg_1, classvars=sex black hispanic other sex_minority age19 age20older past_MHT, outcome=DSISS_t3, predictor=SSOSH_t2_, allvars=sex black hispanic other sex_minority age19 age20older past_MHT, dist=poisson);

			/*Neg binomial*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_ps_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_bc_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSs_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSi_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSg_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SSOSH_t2_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
	
				/*with DSISS covariate*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_ps_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_bc_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSs_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSi_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSg_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SSOSH_t2_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);

	/*No covariates*/
		/*BSS*/
%proc_genmod (data=suistg_1, outcome=BSS_t3, predictor=mean_ps_2, dist=poisson);
%proc_genmod (data=suistg_1, outcome=BSS_t3, predictor=mean_bc_2, dist=poisson);
%proc_genmod (data=suistg_1, outcome=BSS_t3, predictor=SOSSs_t2, dist=poisson);
%proc_genmod (data=suistg_1, outcome=BSS_t3, predictor=SOSSi_t2, dist=poisson);
%proc_genmod (data=suistg_1, outcome=BSS_t3, predictor=SOSSg_t2, dist=poisson);
%proc_genmod (data=suistg_1, outcome=BSS_t3, predictor=SSOSH_t2_, dist=poisson);

		/*DSISS*/
			/*Poisson*/
%proc_genmod (data=suistg_1, outcome=DSISS_t3, predictor=mean_ps_2, dist=poisson);
%proc_genmod (data=suistg_1, outcome=DSISS_t3, predictor=mean_bc_2, dist=poisson);
%proc_genmod (data=suistg_1, outcome=DSISS_t3, predictor=SOSSs_t2, dist=poisson);
%proc_genmod (data=suistg_1, outcome=DSISS_t3, predictor=SOSSi_t2, dist=poisson);
%proc_genmod (data=suistg_1, outcome=DSISS_t3, predictor=SOSSg_t2, dist=poisson);
%proc_genmod (data=suistg_1, outcome=DSISS_t3, predictor=SSOSH_t2_, dist=poisson);

			/*Neg binomial*/
%proc_genmod (data=suistg_1, outcome=DSISS_t3, predictor=mean_ps_2, dist=negbin);
%proc_genmod (data=suistg_1, outcome=DSISS_t3, predictor=mean_bc_2, dist=negbin);
%proc_genmod (data=suistg_1, outcome=DSISS_t3, predictor=SOSSs_t2, dist=negbin);
%proc_genmod (data=suistg_1, outcome=DSISS_t3, predictor=SOSSi_t2, dist=negbin);
%proc_genmod (data=suistg_1, outcome=DSISS_t3, predictor=SOSSg_t2, dist=negbin);
%proc_genmod (data=suistg_1, outcome=DSISS_t3, predictor=SSOSH_t2_, dist=negbin);

	/*Complete case*/
		/*BSS*/
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=mean_ps_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=mean_bc_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=SOSSs_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=SOSSi_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=SOSSg_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=SSOSH_t2_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=poisson);

		/*DSISS*/
			/*Poisson*/
%proc_genmod (data=suistg_2, classvars=sex black hispanic other sex_minority age19 age20older past_MHT, outcome=DSISS_t3, predictor=mean_ps_2, allvars=sex black hispanic other sex_minority age19 age20older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic other sex_minority age19 age20older past_MHT, outcome=DSISS_t3, predictor=mean_bc_2, allvars=sex black hispanic other sex_minority age19 age20older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic other sex_minority age19 age20older past_MHT, outcome=DSISS_t3, predictor=SOSSs_t2, allvars=sex black hispanic other sex_minority age19 age20older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic other sex_minority age19 age20older past_MHT, outcome=DSISS_t3, predictor=SOSSi_t2, allvars=sex black hispanic other sex_minority age19 age20older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic other sex_minority age19 age20older past_MHT, outcome=DSISS_t3, predictor=SOSSg_t2, allvars=sex black hispanic other sex_minority age19 age20older past_MHT, dist=poisson);
%proc_genmod (data=suistg_2, classvars=sex black hispanic other sex_minority age19 age20older past_MHT, outcome=DSISS_t3, predictor=SSOSH_t2_, allvars=sex black hispanic other sex_minority age19 age20older past_MHT, dist=poisson);

			/*Neg binomial with DSISS covariate*/
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_ps_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_bc_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSs_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSi_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSg_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SSOSH_t2_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);

	/*Zero inflated poisson*/
		/*BSS*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=mean_ps_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=mean_bc_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=SOSSs_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=SOSSi_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=SOSSg_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=SSOSH_t2_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);

		/*DSISS*/
			/*Poisson*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_ps_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_bc_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSs_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSi_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSg_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SSOSH_t2_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zip);

			/*Neg binomial*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_ps_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zinb);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_bc_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zinb);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSs_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zinb);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSi_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zinb);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSg_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zinb);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SSOSH_t2_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zinb);


/*--------------------------*/
/*Time 3 with Time 3*/
		/*BSS*/
			/*Neg binomial*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=mean_ps_3, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=mean_bc_3, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=SOSSs_t3, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=SOSSi_t3, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=SOSSg_t3, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=BSS_t3, predictor=SSOSH_t3_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);

		/*DSI-SS*/
			/*Neg binomial*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_ps_3, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_bc_3, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSs_t3, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSi_t3, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSg_t3, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SSOSH_t3_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=negbin);
	
				/*with DSISS covariate*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_ps_3, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_bc_3, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSs_t3, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSi_t3, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSg_t3, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SSOSH_t3_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);

		/*Complete case*/
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_ps_3, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_bc_3, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSs_t3, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSi_t3, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSg_t3, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);
%proc_genmod (data=suistg_2, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SSOSH_t3_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT DSISS_t1d, dist=negbin);

		/*No coviariates*/
%proc_genmod (data=suistg_1, outcome=DSISS_t3, predictor=mean_ps_3, dist=negbin);
%proc_genmod (data=suistg_1, outcome=DSISS_t3, predictor=mean_bc_3, dist=negbin);
%proc_genmod (data=suistg_1, outcome=DSISS_t3, predictor=SOSSs_t3, dist=negbin);
%proc_genmod (data=suistg_1, outcome=DSISS_t3, predictor=SOSSi_t3, dist=negbin);
%proc_genmod (data=suistg_1, outcome=DSISS_t3, predictor=SOSSg_t3, dist=negbin);
%proc_genmod (data=suistg_1, outcome=DSISS_t3, predictor=SSOSH_t3_, dist=negbin);

			/*Neg binomial*/
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_ps_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zinb);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=mean_bc_2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zinb);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSs_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zinb);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSi_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zinb);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SOSSg_t2, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zinb);
%proc_genmod (data=suistg_1, classvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, outcome=DSISS_t3, predictor=SSOSH_t2_, allvars=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT, dist=zinb);



/*MACRO for logistic regression*/
%MACRO proc_log (data=, outcome=, predictor=, covs=);
	proc logistic data = &data desc;
		model &outcome = &predictor &covs;
	run;
%MEND;

/*Time 1 with Time 1*/
	/*BSS*/
%proc_log (data=suistg_1, outcome=BSS_t1d, predictor=mean_ps_1, covs=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=BSS_t1d, predictor=mean_bc_1, covs=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=BSS_t1d, predictor=SOSSs_t1, covs=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=BSS_t1d, predictor=SOSSi_t1, covs=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=BSS_t1d, predictor=SOSSg_t1, covs=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=BSS_t1d, predictor=SSOSH_t1_, covs=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT);

	/*DSI-SS*/
%proc_log (data=suistg_1, outcome=DSISS_t1d, predictor=mean_ps_1, covs=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=DSISS_t1d, predictor=mean_bc_1, covs=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=DSISS_t1d, predictor=SOSSs_t1, covs=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=DSISS_t1d, predictor=SOSSi_t1, covs=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=DSISS_t1d, predictor=SOSSg_t1, covs=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=DSISS_t1d, predictor=SSOSH_t1_, covs=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT);

/*Time 1 with Time 2*/
	/*BSS*/
%proc_log (data=suistg_1, outcome=BSS_t2d, predictor=mean_ps_1, covs=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=BSS_t2d, predictor=mean_bc_1, covs=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=BSS_t2d, predictor=SOSSs_t1, covs=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=BSS_t2d, predictor=SOSSi_t1, covs=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=BSS_t2d, predictor=SOSSg_t1, covs=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=BSS_t2d, predictor=SSOSH_t1_, covs=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT);

	/*DSI-SS*/
%proc_log (data=suistg_1, outcome=DSISS_t2d, predictor=mean_ps_1, covs=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=DSISS_t2d, predictor=mean_bc_1, covs=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=DSISS_t2d, predictor=SOSSs_t1, covs=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=DSISS_t2d, predictor=SOSSi_t1, covs=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=DSISS_t2d, predictor=SOSSg_t1, covs=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=DSISS_t2d, predictor=SSOSH_t1_, covs=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT);

/*Time 1 with Time 3*/
	/*BSS*/
%proc_log (data=suistg_1, outcome=BSS_t3d, predictor=mean_ps_1, covs=sex black hispanic other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=BSS_t3d, predictor=mean_bc_1, covs=sex black hispanic other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=BSS_t3d, predictor=SOSSs_t1, covs=sex black hispanic other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=BSS_t3d, predictor=SOSSi_t1, covs=sex black hispanic other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=BSS_t3d, predictor=SOSSg_t1, covs=sex black hispanic other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=BSS_t3d, predictor=SSOSH_t1_, covs=sex black hispanic other sex_minority age19 age20 age21older past_MHT);

	/*DSI-SS*/
%proc_log (data=suistg_1, outcome=DSISS_t3d, predictor=mean_ps_1, covs=sex hispanic other sex_minority age19 age20older past_MHT);
%proc_log (data=suistg_1, outcome=DSISS_t3d, predictor=mean_bc_1, covs=sex hispanic other sex_minority age19 age20older past_MHT);
%proc_log (data=suistg_1, outcome=DSISS_t3d, predictor=SOSSs_t1, covs=sex hispanic other sex_minority age19 age20older past_MHT);
%proc_log (data=suistg_1, outcome=DSISS_t3d, predictor=SOSSi_t1, covs=sex hispanic other sex_minority age19 age20older past_MHT);
%proc_log (data=suistg_1, outcome=DSISS_t3d, predictor=SOSSg_t1, covs=sex hispanic other sex_minority age19 age20older past_MHT);
%proc_log (data=suistg_1, outcome=DSISS_t3d, predictor=SSOSH_t1_, covs=sex hispanic other sex_minority age19 age20older past_MHT);

/*Time 2 with Time 2*/
	/*BSS*/
%proc_log (data=suistg_1, outcome=BSS_t2d, predictor=mean_ps_2, covs=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=BSS_t2d, predictor=mean_bc_2, covs=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=BSS_t2d, predictor=SOSSs_t2, covs=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=BSS_t2d, predictor=SOSSi_t2, covs=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=BSS_t2d, predictor=SOSSg_t2, covs=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=BSS_t2d, predictor=SSOSH_t2_, covs=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT);

	/*DSI-SS*/
%proc_log (data=suistg_1, outcome=DSISS_t2d, predictor=mean_ps_2, covs=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=DSISS_t2d, predictor=mean_bc_2, covs=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=DSISS_t2d, predictor=SOSSs_t2, covs=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=DSISS_t2d, predictor=SOSSi_t2, covs=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=DSISS_t2d, predictor=SOSSg_t2, covs=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=DSISS_t2d, predictor=SSOSH_t2_, covs=sex black hispanic asian other sex_minority age19 age20 age21older past_MHT);

/*Time 2 with Time 3*/
	/*BSS*/
%proc_log (data=suistg_1, outcome=BSS_t3d, predictor=mean_ps_2, covs=sex black hispanic other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=BSS_t3d, predictor=mean_bc_2, covs=sex black hispanic other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=BSS_t3d, predictor=SOSSs_t2, covs=sex black hispanic other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=BSS_t3d, predictor=SOSSi_t2, covs=sex black hispanic other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=BSS_t3d, predictor=SOSSg_t2, covs=sex black hispanic other sex_minority age19 age20 age21older past_MHT);
%proc_log (data=suistg_1, outcome=BSS_t3d, predictor=SSOSH_t2_, covs=sex black hispanic other sex_minority age19 age20 age21older past_MHT);

	/*DSI-SS*/
%proc_log (data=suistg_1, outcome=DSISS_t3d, predictor=mean_ps_2, covs=sex hispanic other sex_minority age19 age20older past_MHT);
%proc_log (data=suistg_1, outcome=DSISS_t3d, predictor=mean_bc_2, covs=sex hispanic other sex_minority age19 age20older past_MHT);
%proc_log (data=suistg_1, outcome=DSISS_t3d, predictor=SOSSs_t2, covs=sex hispanic other sex_minority age19 age20older past_MHT);
%proc_log (data=suistg_1, outcome=DSISS_t3d, predictor=SOSSi_t2, covs=sex hispanic other sex_minority age19 age20older past_MHT);
%proc_log (data=suistg_1, outcome=DSISS_t3d, predictor=SOSSg_t2, covs=sex hispanic other sex_minority age19 age20older past_MHT);
%proc_log (data=suistg_1, outcome=DSISS_t3d, predictor=SSOSH_t2_, covs=sex hispanic other sex_minority age19 age20older past_MHT);

/*Time 3 with Time 3*/
	/*DSI-SS*/
%proc_log (data=suistg_1, outcome=DSISS_t3d, predictor=mean_ps_3, covs=sex hispanic other sex_minority age19 age20older past_MHT);
%proc_log (data=suistg_1, outcome=DSISS_t3d, predictor=mean_bc_3, covs=sex hispanic other sex_minority age19 age20older past_MHT);
%proc_log (data=suistg_1, outcome=DSISS_t3d, predictor=SOSSs_t3, covs=sex hispanic other sex_minority age19 age20older past_MHT);
%proc_log (data=suistg_1, outcome=DSISS_t3d, predictor=SOSSi_t3, covs=sex hispanic other sex_minority age19 age20older past_MHT);
%proc_log (data=suistg_1, outcome=DSISS_t3d, predictor=SOSSg_t3, covs=sex hispanic other sex_minority age19 age20older past_MHT);
%proc_log (data=suistg_1, outcome=DSISS_t3d, predictor=SSOSH_t3_, covs=sex hispanic other sex_minority age19 age20older past_MHT);


/*Predicting missing*/
proc genmod data = suistg_;
	class BSS_t3_miss / desc;
	model BSS_t3_miss = SOSSs_t1 / dist=poisson;
	zeromodel BSS_t3_miss / link = logit;
run;

proc genmod data = suistg_;
	class BSS_t3_miss SOSSs_t2_miss / desc;
	model BSS_t3_miss = SOSSs_t2_miss  / dist=poisson;
	zeromodel BSS_t3_miss / link = logit;
run;

proc genmod data = suistg_;
	class BSS_t3_miss SOSSi_t2_miss / desc;
	model BSS_t3_miss = SOSSi_t2_miss  / dist=poisson;
	zeromodel BSS_t3_miss / link = logit;
run;

proc genmod data = suistg_;
	class BSS_t3_miss SOSSg_t2_miss / desc;
	model BSS_t3_miss = SOSSg_t2_miss  / dist=poisson;
	zeromodel BSS_t3_miss / link = logit;
run;

proc genmod data = suistg_;
	class BSS_t3_miss INQPB_t2_miss / desc;
	model BSS_t3_miss =  INQPB_t2_miss / dist=poisson;
	zeromodel BSS_t3_miss / link = logit;
run;

proc genmod data = suistg_;
	class BSS_t3_miss INQTB_t2_miss / desc;
	model BSS_t3_miss = INQTB_t2_miss  / dist=poisson;
	zeromodel BSS_t3_miss;
run;
   
/*Dichotomized */
%proc_log (x=BSS_t1, y=BSS_t2_miss);
%proc_log (x=BSS_t1, y=BSS_t3_miss);
%proc_log (x=BSS_t2, y=BSS_t3_miss);

%proc_log (x=INQPB_t1, y=BSS_t2_miss);
%proc_log (x=INQTB_t1, y=BSS_t2_miss);
%proc_log (x=INQPB_t1, y=BSS_t3_miss);
%proc_log (x=INQTB_t1, y=BSS_t3_miss);

%proc_log (x=SOSSs_t1, y=BSS_t3d);
%proc_log (x=SOSSi_t1, y=BSS_t3d);
%proc_log (x=SOSSg_t1, y=BSS_t3d);
%proc_log (x=SOSSs_t2, y=BSS_t3d);
%proc_log (x=SOSSi_t2, y=BSS_t3d);
%proc_log (x=SOSSg_t2, y=BSS_t3d);


proc freq data = suistg_;
	table (SOSSs_t1 SOSSi_t1 SOSSg_t1 SOSSs_t2 SOSSi_t2 SOSSg_t2 INQPB_t1 INQPB_t2 INQTB_t1 INQTB_t2) * (BSS_t1d BSS_t2d BSS_t3d) / plcorr;
run;


/*Cross-tab correlations among variables*/
proc corr data = suistg;
	var &Vars;
run;

proc corr data = suistg;
	var SOSS_SF_1_1 SOSS_SF_2_1 SOSS_SF_3_1 SOSS_SF_4_1 SOSS_SF_5_1 SOSS_SF_6_1 
	SOSS_SF_7_1 SOSS_SF_8_1 SOSS_SF_9_1 SOSS_SF_10_1 SOSS_SF_11_1 SOSS_SF_12_1 SOSS_SF_13_1
	SOSS_SF_14_1 SOSS_SF_15_1 SOSS_SF_16_1 INQPB_t1 INQPB_t2 INQTB_t1 INQTB_t2 BSS_t3;
run;

%proc_freq (data=suistg, var=SOSS_SF_1_1 SOSS_SF_2_1 SOSS_SF_3_1 SOSS_SF_4_1 SOSS_SF_5_1 SOSS_SF_6_1 
	SOSS_SF_7_1 SOSS_SF_8_1 SOSS_SF_9_1 SOSS_SF_10_1 SOSS_SF_11_1 SOSS_SF_12_1 SOSS_SF_13_1
	SOSS_SF_14_1 SOSS_SF_15_1 SOSS_SF_16_1);
%proc_freq (data=suistg, var=SOSS_SF_1_2 SOSS_SF_2_2 SOSS_SF_3_2 SOSS_SF_4_2 SOSS_SF_5_2 SOSS_SF_6_2 
	SOSS_SF_7_2 SOSS_SF_8_2 SOSS_SF_9_2 SOSS_SF_10_2 SOSS_SF_11_2 SOSS_SF_12_2 SOSS_SF_13_2
	SOSS_SF_14_2 SOSS_SF_15_2 SOSS_SF_16_2);
%proc_freq (data=suistg, var=SOSS_SF_1_3 SOSS_SF_2_3 SOSS_SF_3_3 SOSS_SF_4_3 SOSS_SF_5_3 SOSS_SF_6_3 
	SOSS_SF_7_3 SOSS_SF_8_3 SOSS_SF_9_3 SOSS_SF_10_3 SOSS_SF_11_3 SOSS_SF_12_3 SOSS_SF_13_3
	SOSS_SF_14_3 SOSS_SF_15_3 SOSS_SF_16_3);
%proc_freq (data=suistg, var=BSS_t1 BSS_t2 BSS_t3);

proc corr data = suistg;
	var SOSSs_t1 SOSSi_t1 SOSSg_t1 SOSSs_t2 SOSSi_t2 SOSSg_t2 INQPB_t1 INQPB_t2 INQTB_t1 INQTB_t2 DSISS_t1 DSISS_t2 DSISS_t3;
run;

proc corr data = suistg_;
	var mean_ps_1 mean_bc_1 SOSSs_t1 SOSSi_t1 SOSSg_t1 SSOSH_t1_ BSS_t1
		mean_ps_2 mean_bc_2 SOSSs_t2 SOSSi_t2 SOSSg_t2 SSOSH_t2_ BSS_t2
		mean_ps_3 mean_bc_3 SOSSs_t3 SOSSi_t3 SOSSg_t3 SSOSH_t3_ BSS_t3;
run;

proc corr data = suistg_;
	var mean_ps_1 mean_bc_1 SOSSs_t1 SOSSi_t1 SOSSg_t1 SSOSH_t1_ DSISS_t1 BSS_t1 
		mean_ps_2 mean_bc_2 SOSSs_t2 SOSSi_t2 SOSSg_t2 SSOSH_t2_ DSISS_t2 BSS_t2 
		mean_ps_3 mean_bc_3 SOSSs_t3 SOSSi_t3 SOSSg_t3 SSOSH_t3_ DSISS_t3 BSS_t3 ;
run;

proc corr data = suistg;
	var SSOSH_t1 SSOSH_t2 SSOSH_t3 BSS_t1 BSS_t2 BSS_t3;
run;

proc corr data = suistg;
	var PS_1_1 PS_2_1 PS_3_1 PS_4_1 PS_5_1 PS_6_1 PS_7_1 PS_8_1 PS_9_1 PS_10_1 PS_11_1
	PS_1_2 PS_2_2 PS_3_2 PS_4_2 PS_5_2 PS_6_2 PS_7_2 PS_8_2 PS_9_2 PS_10_2 PS_11_2
	PS_1_3 PS_2_3 PS_3_3 PS_4_3 PS_5_3 PS_6_3 PS_7_3 PS_8_3 PS_9_3 PS_10_3 PS_11_3
	INQPB_t1 INQPB_t2 INQTB_t1 INQTB_t2 BSS_t1 BSS_t2 BSS_t3;
run;

proc freq data = suistg_;
	table (PS_1_1 PS_2_1 PS_3_1 PS_4_1 PS_5_1 PS_6_1 PS_7_1 PS_8_1 PS_9_1 PS_10_1 PS_11_1
	PS_1_2 PS_2_2 PS_3_2 PS_4_2 PS_5_2 PS_6_2 PS_7_2 PS_8_2 PS_9_2 PS_10_2 PS_11_2
	PS_1_3 PS_2_3 PS_3_3 PS_4_3 PS_5_3 PS_6_3 PS_7_3 PS_8_3 PS_9_3 PS_10_3 PS_11_3) * (BSS_t1d BSS_t2d BSS_t3d) / plcorr;
run;


/*Chronbach's alpha*/
%MACRO alpha (dataset=, var=);
	proc corr data = &dataset alpha;
		var &var;
	run;
%MEND;

%alpha (dataset=suistg_, var=PS_1_1 PS_2_1 PS_3_1 PS_4_1 PS_5_1 PS_6_1);
%alpha (dataset=suistg_, var=PS_1_2 PS_2_2 PS_3_2 PS_4_2 PS_5_2 PS_6_2);
%alpha (dataset=suistg_, var=PS_1_3 PS_2_3 PS_3_3 PS_4_3 PS_5_3 PS_6_3);

%alpha (dataset=suistg_, var=PS_7_1 PS_8_1 PS_9_1 PS_10_1 PS_11_1);
%alpha (dataset=suistg_, var=PS_7_2 PS_8_2 PS_9_2 PS_10_2 PS_11_2);
%alpha (dataset=suistg_, var=PS_7_3 PS_8_3 PS_9_3 PS_10_3 PS_11_3);

%alpha (dataset=suistg_, var=SOSS_SF_1_1 SOSS_SF_2_1 SOSS_SF_3_1 SOSS_SF_4_1 SOSS_SF_5_1 SOSS_SF_6_1 SOSS_SF_7_1 SOSS_SF_8_1);
%alpha (dataset=suistg_, var=SOSS_SF_1_2 SOSS_SF_2_2 SOSS_SF_3_2 SOSS_SF_4_2 SOSS_SF_5_2 SOSS_SF_6_2 SOSS_SF_7_2 SOSS_SF_8_2);
%alpha (dataset=suistg_, var=SOSS_SF_1_3 SOSS_SF_2_3 SOSS_SF_3_3 SOSS_SF_4_3 SOSS_SF_5_3 SOSS_SF_6_3 SOSS_SF_7_3 SOSS_SF_8_3);

%alpha (dataset=suistg_, var=SOSS_SF_9_1 SOSS_SF_10_1 SOSS_SF_11_1 SOSS_SF_12_1);
%alpha (dataset=suistg_, var=SOSS_SF_9_2 SOSS_SF_10_2 SOSS_SF_11_2 SOSS_SF_12_2);
%alpha (dataset=suistg_, var=SOSS_SF_9_3 SOSS_SF_10_3 SOSS_SF_11_3 SOSS_SF_12_3);

%alpha (dataset=suistg_, var=SOSS_SF_13_1 SOSS_SF_14_1 SOSS_SF_15_1 SOSS_SF_16_1);
%alpha (dataset=suistg_, var=SOSS_SF_13_2 SOSS_SF_14_2 SOSS_SF_15_2 SOSS_SF_16_2);
%alpha (dataset=suistg_, var=SOSS_SF_13_3 SOSS_SF_14_3 SOSS_SF_15_3 SOSS_SF_16_3);

%alpha (dataset=suistg_, var=SSOSH_1_1 SSOSH_2_rev_1 SSOSH_3_1 SSOSH_4_rev_1 SSOSH_5_rev_1 SSOSH_6_1 SSOSH_7_rev_1 SSOSH_8_1 SSOSH_9_rev_1 SSOSH_10_1);
%alpha (dataset=suistg_, var=SSOSH_1_2 SSOSH_2_rev_2 SSOSH_3_2 SSOSH_4_rev_2 SSOSH_5_rev_2 SSOSH_6_2 SSOSH_7_rev_2 SSOSH_8_2 SSOSH_9_rev_2 SSOSH_10_2);
%alpha (dataset=suistg_, var=SSOSH_1_3 SSOSH_2_rev_3 SSOSH_3_3 SSOSH_4_rev_3 SSOSH_5_rev_3 SSOSH_6_3 SSOSH_7_rev_3 SSOSH_8_3 SSOSH_9_rev_3 SSOSH_10_3);

%alpha (dataset=suistg_, var=BSS_1_1 BSS_2_1 BSS_3_1 BSS_4_1 BSS_5_1 BSS_6_1 BSS_7_1 BSS_8_1 BSS_10_1 BSS_11_1
BSS_13_1 BSS_14_1 BSS_15_1 BSS_16_1 BSS_17_1 BSS_18_1 BSS_19_1);
%alpha (dataset=suistg_, var=BSS_1_2 BSS_2_2 BSS_3_2 BSS_4_2 BSS_5_2 BSS_6_2 BSS_7_2 BSS_8_2 BSS_10_2 BSS_11_2
BSS_13_2 BSS_14_2 BSS_15_2 BSS_16_2 BSS_17_2 BSS_18_2 BSS_19_2);
%alpha (dataset=suistg_, var=BSS_1_3 BSS_2_3 BSS_3_3 BSS_4_3 BSS_5_3 BSS_6_3 BSS_7_3 BSS_8_3 BSS_10_3 BSS_11_3
BSS_13_3 BSS_14_3 BSS_15_3 BSS_16_3 BSS_17_3 BSS_18_3 BSS_19_3);

%alpha (dataset=suistg_, var=DSISS_A_1 DSISS_B_1 DSISS_C_1 DSISS_D_1);
%alpha (dataset=suistg_, var=DSISS_A_2 DSISS_B_2 DSISS_C_2 DSISS_D_2);
%alpha (dataset=suistg_, var=DSISS_A_3 DSISS_B_3 DSISS_C_3 DSISS_D_3);

proc freq data = suistg_;
table DSISS_t1 DSISS_t2 DSISS_t3;
run;

/*EFA*/
	/*Rotation: oblique (promax, correlated)*/
proc factor data=suistg rotate=promax method=ml scree priors=smc;
	var &SOSS;
run;

proc factor data=suistg_ rotate=promax method=ml scree priors=smc;
	var PS_1_1 PS_2_1 PS_3_1 PS_4_1 PS_5_1 PS_6_1 PS_7_1 PS_8_1 PS_9_1 PS_10_1 PS_11_1;
run;

proc factor data=suistg rotate=promax method=ml scree priors=smc;
	var PS_1_2 PS_2_2 PS_3_2 PS_4_2 PS_5_2 PS_6_2 PS_7_2 PS_8_2 PS_9_2 PS_10_2 PS_11_2;
run;

proc factor data=suistg rotate=promax method=ml scree priors=smc;
	var PS_1_3 PS_2_3 PS_3_3 PS_4_3 PS_5_3 PS_6_3 PS_7_3 PS_8_3 PS_9_3 PS_10_3 PS_11_3;
run;

	/*Rotation: othogonal (varimax, uncorrelated)*/
proc factor data=suistg rotate=varimax method=ml scree priors=smc;
	var &SOSS;
run;

proc factor data=suistg_ rotate=varimax method=ml scree priors=smc;
	var PS_1_1 PS_2_1 PS_3_1 PS_4_1 PS_5_1 PS_6_1 PS_7_1 PS_8_1 PS_9_1 PS_10_1 PS_11_1;
run;

proc factor data=suistg rotate=varimax method=ml scree priors=smc;
	var PS_1_2 PS_2_2 PS_3_2 PS_4_2 PS_5_2 PS_6_2 PS_7_2 PS_8_2 PS_9_2 PS_10_2 PS_11_2;
run;

proc factor data=suistg rotate=varimax method=ml scree priors=smc;
	var PS_1_3 PS_2_3 PS_3_3 PS_4_3 PS_5_3 PS_6_3 PS_7_3 PS_8_3 PS_9_3 PS_10_3 PS_11_3;
run;

proc factor data=suistg rotate=varimax method=ml scree priors=smc;
	var &SOSS;
run;

proc factor data=suistg rotate=varimax method=ml scree priors=smc;
	var SOSS_SF_1_2 SOSS_SF_2_2 SOSS_SF_3_2 SOSS_SF_4_2 SOSS_SF_5_2 SOSS_SF_6_2 
	SOSS_SF_7_2 SOSS_SF_8_2 SOSS_SF_9_2 SOSS_SF_10_2 SOSS_SF_11_2 SOSS_SF_12_2 SOSS_SF_13_2
	SOSS_SF_14_2 SOSS_SF_15_2 SOSS_SF_16_2;
run;

proc factor data=suistg rotate=varimax method=ml scree priors=smc;
	var SOSS_SF_1_3 SOSS_SF_2_3 SOSS_SF_3_3 SOSS_SF_4_3 SOSS_SF_5_3 SOSS_SF_6_3 
	SOSS_SF_7_3 SOSS_SF_8_3 SOSS_SF_9_3 SOSS_SF_10_3 SOSS_SF_11_3 SOSS_SF_12_3 SOSS_SF_13_3
	SOSS_SF_14_3 SOSS_SF_15_3 SOSS_SF_16_3;
run;

proc factor data=suistg rotate=varimax method=ml scree priors=smc;
	var PS_1_1 PS_2_1 PS_3_1 PS_4_1 PS_5_1 PS_6_1 PS_7_1 PS_8_1 PS_9_1 PS_10_1 PS_11_1;
run;

proc factor data=suistg rotate=varimax method=ml scree priors=smc;
	var PS_1_2 PS_2_2 PS_3_2 PS_4_2 PS_5_2 PS_6_2 PS_7_2 PS_8_2 PS_9_2 PS_10_2 PS_11_2;
run;

proc factor data=suistg rotate=varimax method=ml scree priors=smc;
	var PS_1_3 PS_2_3 PS_3_3 PS_4_3 PS_5_3 PS_6_3 PS_7_3 PS_8_3 PS_9_3 PS_10_3 PS_11_3;
run;

/*CFA*/
	/*PS and Barriers to Care*/
proc calis data = suistg_ nobs = 284 modification;
factor 
	stigma ---> PS_1_1 PS_2_1 PS_3_1 PS_4_1 PS_5_1 PS_6_1,
	barriers ---> PS_7_1 PS_8_1 PS_9_1 PS_10_1 PS_11_1;
pvar 
	stigma barriers = 2 * 1.;
cov
	stigma barriers;
run;

proc calis data = suistg_ nobs = 259 modification;
factor 
	stigma ---> PS_1_2 PS_2_2 PS_3_2 PS_4_2 PS_5_2 PS_6_2,
	barriers ---> PS_7_2 PS_8_2 PS_9_2 PS_10_2 PS_11_2;
pvar 
	stigma barriers = 2 * 1.;
cov
	stigma barriers;
run;

proc calis data = suistg_ nobs = 229 modification;
factor 
	stigma ---> PS_1_3 PS_2_3 PS_3_3 PS_4_3 PS_5_3 PS_6_3,
	barriers ---> PS_7_3 PS_8_3 PS_9_3 PS_10_3 PS_11_3;
pvar 
	stigma barriers = 2 * 1.;
cov
	stigma barriers;
run;

		/*SOSS-SF - Suicide stigma*/
proc calis data = suistg_ nobs = 286 modification;
factor 
	stigma ---> SOSS_SF_1_1 SOSS_SF_2_1 SOSS_SF_3_1 SOSS_SF_4_1 SOSS_SF_5_1 SOSS_SF_6_1 SOSS_SF_7_1 SOSS_SF_8_1,
	depression ---> SOSS_SF_9_1 SOSS_SF_10_1 SOSS_SF_11_1 SOSS_SF_12_1,
	glorification ---> SOSS_SF_13_1 SOSS_SF_14_1 SOSS_SF_15_1 SOSS_SF_16_1;
pvar 
	stigma depression glorification = 3 * 1.;
cov
	stigma depression glorification;
run;

proc calis data = suistg_ nobs = 258 modification;
factor 
	stigma ---> SOSS_SF_1_2 SOSS_SF_2_2 SOSS_SF_3_2 SOSS_SF_4_2 SOSS_SF_5_2 SOSS_SF_6_2 SOSS_SF_7_2 SOSS_SF_8_2,
	depression ---> SOSS_SF_9_2 SOSS_SF_10_2 SOSS_SF_11_2 SOSS_SF_12_2,
	glorification ---> SOSS_SF_13_2 SOSS_SF_14_2 SOSS_SF_15_2 SOSS_SF_16_2;
pvar 
	stigma depression glorification = 3 * 1.;
cov
	stigma depression glorification;
run;

proc calis data = suistg_ nobs = 258 modification;
factor 
	stigma ---> SOSS_SF_1_3 SOSS_SF_2_3 SOSS_SF_3_3 SOSS_SF_4_3 SOSS_SF_5_3 SOSS_SF_6_3 SOSS_SF_7_3 SOSS_SF_8_3,
	depression ---> SOSS_SF_9_3 SOSS_SF_10_3 SOSS_SF_11_3 SOSS_SF_12_3,
	glorification ---> SOSS_SF_13_3 SOSS_SF_14_3 SOSS_SF_15_3 SOSS_SF_16_3;
pvar 
	stigma depression glorification = 3 * 1.;
cov
	stigma depression glorification;
run;

