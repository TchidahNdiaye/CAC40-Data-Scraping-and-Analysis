* Importation et exploitation de la base de données *********;
proc import datafile="/home/u44791576/thesis/data/sbf_cah.csv"
					 out=sbf
					 dbms=csv replace;
run;

ods excel file="/home/u44791576/thesis/sbf/SBF clusters analysis ANOVA and CART.xlsx" 
          options(sheet_interval="proc"
          embedded_titles="yes");
 
************ 2. Analyse des clusters produits dans Python cah ************;
proc sgplot data=work.sbf;
	vbox ROA / category=cah
				connect=mean;
	title "CAH par Return-on-Assets en % boxplot";
run;

proc sgplot data=work.sbf;
	vbox DPR / category=cah
				connect=mean;
	title "CAH par Dividend Yield boxplot";
run;

proc sgplot data=work.sbf;
	vbox PER / category=cah
				connect=mean;
	title "CAH par Price-to-Earnings boxplot";
run;

/* ************************ 3. ANOVA avec proc Anova*********************** */
ods graphics on;
proc anova data=work.sbf;
	class cah;
	model DPR = cah;
	means cah / duncan waller;
	title "Analyse de la variance cah - Dividend Yield";
run;

proc anova data=work.sbf;
	class cah;
	model PER = cah;
	means cah / duncan waller;
	title "Analyse de la variance cah - Price-to-Earnings";
run;
ods graphics off;

/* ********************* 4. ANOVA avec proc glm *********************** */
ods graphics;
proc glm data=work.sbf plots=diagnostics;
    class cah;
    model DPR = cah;
	means cah / hovtest=levene;
    title "ANOVA sur les clusters cah comme prédicteur et Dividend Yield en target";
run;

proc glm data=work.sbf plots=all;
    class cah;
    model PER = cah;
	means cah / hovtest=levene;
    title "ANOVA sur les clusters cah et le Price-to-Earnings en target avec tous les graphs";
run;

proc glm data=work.sbf plots=all;
    class cah;
    model DPR = cah;
	lsmeans cah / pdiff=all adjust=tukey;
    title "ANOVA sur les clusters cah et Dividend Yield en target avec tous les graphs";
run;

proc glm data=work.sbf plots=all;
    class cah;
    model PER = cah;
	lsmeans cah / pdiff=all adjust=tukey;
    title "ANOVA sur les clusters cah et Price-to-Earnings en target avec tous les graphs";
run;

proc glm data=work.sbf plots=all;
    class cah;
    model ROA = cah;
	lsmeans cah / pdiff=all adjust=tukey;
    title "ANOVA sur les clusters cah et ROA en target avec tous les graphs";
run;

proc glm data=work.sbf plots=all;
    class cah;
    model Payout = cah;
	lsmeans cah / pdiff=all adjust=tukey;
    title "ANOVA sur les clusters cah et EPR en target avec tous les graphs";
run;
quit;

/* ********************* 5. CART sur les clusters cah01 & cah02 *********************** */
ods graphics on;
proc hpsplit data=work.sbf seed=12345 nodes;
	class cah;
	model  cah = PER PBR DPR ROA EPR;
	grow gini;
	prune costcomplexity;
	partition fraction(valid=.3 seed=12345);
	code file='/home/u44791576/thesis/sbf/cah_score_gini.txt';
    rules file='/home/u44791576/thesis/sbf/cah_rules_gini.txt';
	title "SBF 110 Decision tree with Gini criterion on cah01 on target";
run;

/* ********************* 5.1 Sélection de variables *********************** */

ods graphics on; 
proc logistic data=work.sbf plots=all;
	model cah = BMR DPR EPR CFP TSR PER PBR PCF PSR Payout PM ROA ROE FiLev Beta 
			/ clodds=pl 
			selection=stepwise slstay=0.35 slentry=0.3 details lackfit;
	title "Sélection des variables par la méthode Stepwise";
run;

ods graphics on; 
proc logistic data=work.sbf plots=all;
	model cah = BMR DPR EPR CFP TSR PER PBR PCF PSR Payout PM ROA ROE FiLev Beta
			/ clodds=pl 
			selection=backward slstay=0.35 hier=single fast;
			title "Sélection des variables par la méthode Backward";
run;

proc logistic data=work.sbf plots=all;
	class Sector Ind;
	model cah = BMR DPR EPR Sector Ind CFP TSR PER PBR PCF PSR Payout PM ROA ROE FiLev Beta 
			/ clodds=pl 
			selection=stepwise slstay=0.35 slentry=0.3 details lackfit;
	title "Sélection des variables par la méthode Stepwise";
run;

/* ********************* 6. Regression logistic avec SAS *********************** */
proc logistic data=work.sbf plots=all;
   model cah = PER PBR ROA DPR EPR PCF Payout PSR;
run;

ods excel close;
ods proctitle;
title;footnote;