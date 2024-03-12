/*----------------------------------------------------
Project Title: Suicide Stigma and SI
Datasets: suistg_1
		  hom_2
Author: Lauren OReilly
Date: 2/23/23
Revisions: 3/12/2024 Cleaned for GitHub
-----------------------------------------------------*/
/*Create datasets*/
	/*Dataset 1 = Undergrad*/
proc sql;
	create table merge_0 as 
	select dataset, sex, age, race, sex_orient, past_MHT, marital, military, education, employ_ft_work, employ_pt_work,
		 mean_ps_1, mean_bc_1, SOSSs_t1, SOSSi_t1, SOSSg_t1, SSOSH_t1_, DSISS_t1d
	from suistg_1;
quit;

	/*Dataset 2 = Current suicidal ideation*/
proc sql;
	create table merge_1 as 
	select dataset, sex, age, race, sex_orient, past_MHT, marital, military, educ, employ_1, employ_2,
	       mean_ps_1, mean_bc_1, SOSSs_t1, SOSSi_t1, SOSSg_t1, SSOSH_t1, DSISS_t1d
	from hom_2;
quit;

data merge_1;
	set merge_1;
	education = educ;
	employ_ft_work = employ_1;
	employ_pt_work = employ_2;
	SSOSH_t1_ = SSOSH_t1;
	
	sex_ = sex;
	if sex = 2 then sex_ = 0;

	drop educ;
	drop employ_1;
	drop employ_2;
	drop SSOSH_t1;
run;

proc freq data = merge_1;
table sex sex_;
run;

data merge_1;
	set merge_1;
	sex = sex_;
run;

/*Merge datasets*/
data merge_;
	set merge_0 merge_1;
run;

/*Save dataset*/
data suistg.merge_;
	set merge_;
run;

/*T-tests*/
%MACRO ttest (data=, class=, var=);
proc ttest data = &data;
	class &class;
	var &var;
run;
%MEND;

%ttest (data=merge_, class=dataset, var=mean_ps_1); 
%ttest (data=merge_, class=dataset, var=mean_bc_1); 
%ttest (data=merge_, class=dataset, var=SOSSs_t1); 
%ttest (data=merge_, class=dataset, var=SOSSi_t1); 
%ttest (data=merge_, class=dataset, var=SOSSg_t1); 
%ttest (data=merge_, class=dataset, var=SSOSH_t1); 

/*Chi-square*/;
proc freq data = merge_;
	tables (dataset) * (sex race sex_orient age past_MHT marital military education employ_ft_work employ_pt_work DSISS_t1d) / chisq
		plots=(freqplot(twoway=groupvertical scale=percent));
run;

proc freq data = merge_;
	tables (dataset) * (DSISS_t1d) / chisq
		plots=(freqplot(twoway=groupvertical scale=percent));
run;

/*End*/
