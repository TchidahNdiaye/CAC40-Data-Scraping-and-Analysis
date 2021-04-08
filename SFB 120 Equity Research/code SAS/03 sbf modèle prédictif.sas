* Importation et exploitation de la base de données *********;
proc import datafile="/home/u44791576/thesis/data/sbfdf.csv"
					 out=sbf
					 dbms=csv replace;
run;

ods excel file="/home/u44791576/thesis/sbf/SBF modèles prédictifs.xlsx" 
          options(sheet_interval="proc"
          embedded_titles="yes");
/* PER PBR PSR PCF DPR ROA  */
/* ********************* 00. ANOVA sur PER *********************** */
proc glm data=work.sbf plots=all;
    class cah;
    model PER = cah;
	means cah / hovtest=levene;
    title "ANOVA sur les clusters cah et le Price-to-Earnings en target avec tous les graphs";
run;

proc glm data=work.sbf plots=all;
    class cah;
    model PER = cah;
	lsmeans cah / pdiff=all adjust=tukey;
    title "ANOVA sur les clusters cah et Price-to-Earnings en target avec tous les graphs";
run;
/* ********************* 1. CART sur les typologie d'actions *********************** */
ods graphics on;
proc hpsplit data=work.sbf seed=12345 nodes;
	class Type;
	model  Type = PER PBR PSR PCF DPR ROA;
	grow gini;
	prune costcomplexity;
	partition fraction(valid=.3 seed=12345);
	code file='/home/u44791576/thesis/sbf/Type_score_gini.txt';
    rules file='/home/u44791576/thesis/sbf/Type_rules_gini.txt';
	title "SBF 110 Decision tree with Gini criterion on Type on target";
run;

/* ********************* 2.1 Neural Network *********************** */
proc hpneural data=work.sbf;
	input PER PBR PSR DPR ROA;
	target Type / level=nom;
	hidden 2;
	train outmodel=model_sbf maxiter=1000;
	score out=scores_sbf;
run;

/* ********************* 6. Regression logistic avec SAS *********************** */
proc logistic data=work.sbf plots=all;
	class Type Sector /param=glm;
	model Type = PER PBR PSR PCF DPR ROA Sector
	/rsquare;
run;

proc hplogistic data=work.sbf;
	class Type Sector;
	model Type = PER PBR PSR PCF DPR ROA Sector;
	partition fraction(test=0.25 validate=0.25);
run;

ods excel close;
ods proctitle;
title;footnote;