* Importation et exploitation de la base de données *********;
proc import datafile="/home/u44791576/thesis/data/sbf.csv"
					 out=sbf
					 dbms=csv replace;
run;

ods excel file="/home/u44791576/thesis/sbf120/SBF ANOVA Cluster and CART.xlsx" 
          options(sheet_interval="proc"
          embedded_titles="yes");
 
************ 1. Description de la base ************; 
proc contents data=sbf; run;
proc means data=sbf n mean range std median q1 q3 qrange min max kurtosis skewness; run;
ods graphics on;
proc freq data=work.sbf; 
	tables _character_ / plots=freqplot; 
run;

proc freq data=work.sbf; 
	tables _character_ /plots=cumfreqplot(scale=percent type=dotplot); 
run;

proc freq data=work.sbf; 
	tables _character_ /chisq plots=deviationplot; 
run;

proc univariate data=work.sbf;
	var _numeric_;
	histogram / normal;
run;

************ 2. Analyse des clusters produits dans Python cah01 et Cah02 ************;
proc sgplot data=work.sbf;
	vbox ROA / category=cah01
				connect=mean;
	title "CAH01 par Return-on-Assets en % boxplot";
run;

proc sgplot data=work.sbf;
	vbox ROA / category=cah02
				connect=mean;
	title "CAH02 par Return-on-Assets boxplot";
run;

proc sgplot data=work.sbf;
	vbox DPR / category=cah01
				connect=mean;
	title "CAH01 par Dividend Yield boxplot";
run;

proc sgplot data=work.sbf;
	vbox DPR / category=cah02
				connect=mean;
	title "CAH02 par Dividend Yield boxplot";
run;

proc sgplot data=work.sbf;
	vbox BMR / category=cah01
				connect=mean;
	title "CAH01 par Book-to-Market boxplot";
run;

proc sgplot data=work.sbf;
	vbox BMR / category=cah02
				connect=mean;
	title "CAH01 par Book-to-Market boxplot";
run;

proc sgplot data=work.sbf;
	vbox PER / category=cah01
				connect=mean;
	title "CAH01 par Price-to-Earnings boxplot";
run;

proc sgplot data=work.sbf;
	vbox PER / category=cah02
				connect=mean;
	title "CAH01 par Price-to-Earnings boxplot";
run;


/* ************************ 3. ANOVA avec proc Anova*********************** */
ods graphics on;
proc anova data=work.sbf;
	class cah01;
	model DPR = cah01;
	means cah01 / duncan waller;
	title "Analyse de la variance cah01 - Dividend Yield";
run;

proc anova data=work.sbf;
	class cah01;
	model PER = cah01;
	means cah01 / duncan waller;
	title "Analyse de la variance cah01 - Price-to-Earnings";
run;
ods graphics off;

/* ********************* 4. ANOVA avec proc glm *********************** */
ods graphics;
proc glm data=work.sbf plots=diagnostics;
    class cah01;
    model DPR = cah01;
	means cah01 / hovtest=levene;
    title "ANOVA sur les clusterscah01 comme prédicteur et Dividend Yield en target";
run;

proc glm data=work.sbf plots=all;
    class cah01;
    model PER = cah01;
	means cah01 / hovtest=levene;
    title "ANOVA sur les clusters cah01 et le Price-to-Earnings en target avec tous les graphs";
run;

proc glm data=work.sbf plots=all;
    class cah01;
    model PBR = cah01;
	lsmeans cah01 / pdiff=all adjust=tukey;
    title "ANOVA sur les clusters cah01 et Price-to-Book en target avec tous les graphs";
run;

proc glm data=work.sbf plots=all;
    class cah01;
    model DPR = cah01;
	lsmeans cah01 / pdiff=all adjust=tukey;
    title "ANOVA sur les clusters cah01 et Dividend Yield en target avec tous les graphs";
run;

proc glm data=work.sbf plots=all;
    class cah01;
    model PER = cah01;
	lsmeans cah01 / pdiff=all adjust=tukey;
    title "ANOVA sur les clusters cah01 et Price-to-Earnings en target avec tous les graphs";
run;

proc glm data=work.sbf plots=all;
    class cah02;
    model PER = cah02;
	lsmeans cah02 / pdiff=all adjust=tukey;
    title "ANOVA sur les clusters cah02 et Price-to-Earnings en target avec tous les graphs";
run;

proc glm data=work.sbf plots=diagnostics;
    class cah02;
    model DPR = cah02;
	means cah02 / hovtest=levene;
    title "ANOVA sur les clusters avec cah02 comme prédicteur et Dividend Yield en target";
run;

proc glm data=work.sbf plots=diagnostics;
    class cah01;
    model BMR = cah01;
	means cah01 / hovtest=levene;
    title "ANOVA sur les clusters avec cah01 comme prédicteur et Book-to-Market en target";
run;

proc glm data=work.sbf plots=diagnostics;
    class cah02;
    model BMR = cah02;
	means cah02 / hovtest=levene;
    title "ANOVA sur les clusters avec cah02 comme prédicteur et Book-to-Market en target";
run;
quit;

/* ********************* 5. CART sur les clusters cah01 & cah02 *********************** */
ods graphics on;
proc hpsplit data=work.sbf seed=12345 nodes;
	class cah01;
	model  cah01 = PER PBR DPR ROA;
	grow gini;
	prune costcomplexity;
	partition fraction(valid=.3 seed=12345);
	code file='/home/u44791576/thesis/sbf120/cah01_score_gini.txt';
    rules file='/home/u44791576/thesis/sbf120/cah01_rules_gini.txt';
	title "SBF 110 Decision tree with Gini criterion on cah01 on target";
run;

proc hpsplit data=work.sbf seed=12345 nodes;
	class cah02;
	model cah02 = PER PBR DPR ROA;
	grow gini;
	prune costcomplexity;
	partition fraction(valid=.3 seed=12345);
	code file='/home/u44791576/thesis/sbf120/cah02_score_gini.txt';
    rules file='/home/u44791576/thesis/sbf120/cah02_rules_gini.txt';
	title "SBF 110 Decision tree with Gini criterion on cah02 on target";
run;

/* ********************* 6. ACP sur la base SFB110 avec SAS *********************** */
proc corr data=work.sbf
	plots=matrix(histogram);
	var BMR DPR EPR CFP TSR PER PBR PCF PSR Payout PM ROA ROE FiLev Beta;
	title "Matrice de corrélation des 15 variables actives";
run;

proc corr data=work.sbf
	plots=all;
	var BMR DPR EPR CFP TSR PER PBR PCF PSR Payout PM ROA ROE FiLev Beta;
	title "Matrice de corrélation des 15 variables actives avec tous les graphs";
run;

proc factor data=work.sbf outstat=res_ACP_var;
	var BMR DPR EPR CFP TSR PER PBR PCF PSR Payout PM ROA ROE FiLev Beta;
	title "ACP sur les 15 variables actives";
run;

proc factor data=work.sbf simple corr;
	var BMR DPR EPR CFP TSR PER PBR PCF PSR Payout PM ROA ROE FiLev Beta;
	title "ACP sur les 15 variables actives";
run;

proc factor data=work.sbf 
	priors=smc msa residuals
	rotate=promax reorder
	plots=(scree initloadings preloadings loadings);
	var BMR DPR EPR CFP TSR PER PBR PCF PSR Payout PM ROA ROE FiLev Beta;
	title "ACP sur les 15 variables actives";
run;

proc factor data=work.sbf 
	priors=smc msa residuals
	rotate=promax reorder
	plots=preloadings(vector);
	var BMR DPR EPR CFP TSR PER PBR PCF PSR Payout PM ROA ROE FiLev Beta;
	title "ACP avec cercle de corrélation sur les 15 variables actives";
run;

proc factor data=work.sbf priors=smc rotate=quartimin plots=pathdiagram;
	var BMR DPR EPR CFP TSR PER PBR PCF PSR Payout PM ROA ROE FiLev Beta;
	title "Pathdiagram avec les 15 variables actives";
run;

proc factor data=work.sbf priors=smc rotate=quartimin plots=pathdiagram;
	var PER PBR DPR ROA;
	title "Pathdiagram sur nos variables choisies pour le clustering";
run;

proc factor data=work.sbf priors=smc rotate=quartimin plots=pathdiagram;
	var BMR DPR TSR PER PBR PSR ROA ROE FiLev;
	title "Pathdiagram sur 9 variables actives les plus pertinentes";
run;

proc prinqual data=work.sbf plots=all;
	transform monotone (PER PBR DPR ROA);
	id Tick;
	title "ACP représentation des individus selon nos variables choisies";
run;

proc distance data=work.sbf method=euclid out=sbfmatrice;
	var interval(PER PBR DPR ROA);
	id Tick;
	title "Clustering CAH sur la base sbf110";
run;

proc print data=sbfmatrice;
	id Tick;
	title "Matrice des distances de l'ensemble de nos 110 actions";
run;

proc cluster data=sbfmatrice outtree=sbftree method=ward pseudo plots=all;
	id Tick;
	title "Dendrogramme des clusters pour les 110 actions";
run;

ods excel close;
ods proctitle;
title;footnote;