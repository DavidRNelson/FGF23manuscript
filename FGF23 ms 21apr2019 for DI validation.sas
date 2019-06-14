/*

Eli Lilly and Company - GPORWE 

Location of specifications (here, as part of metadata): Use of NHANES to support manuscript 
"Estimating the Distribution of a Novel Clinical Biomarker (FGF-23) in the US Population Using Findings from a Regional Research Registry"
1) Read in NHANES data from 1999-2014; make variable names consistent, sort and merge across data sets by SEQN
2) Implement equation to estimate FGF-23 from Haring publication for the sample from NHANES
3) Produce Results, Tables, and Figures

Location of code, if code is separate from the code metadata 
DEV \\indyfiler01\mango-2\GPO\P500062_DISC_NHANES_FGF23_Phosphorus\ToBeValidated\april2019\FGF23 ms 21apr2019 for DI validation.sas
PROD \\ix1dxgp07\EHI_PRODUCTION_ARCHIVE.GRP$\EHI_Production_Archive\GPO\P500062_DISC_NHANES_FGF23_Phosphorus\FGF23 ms 21apr2019 for DI validation.sas

Validation approach: Peer Review

Input(s): NHANES data sets downloaded to '/Mango-2/ELECTRON/PublicDataHub/NHANES/scratch';

OUTPUT: 1 PDF File 
DEV \\indyfiler01\mango-2\GPO\P500062_DISC_NHANES_FGF23_Phosphorus\ToBeValidated\april2019\FGF23 ms 21apr2019 for DI Validation.pdf
PROD \\ix1dxgp07\EHI_PRODUCTION_ARCHIVE.GRP$\EHI_Production_Archive\GPO\P500062_DISC_NHANES_FGF23_Phosphorus\FGF23 ms 21apr2019 for DI Validation.pdf


Author’s name: David R Nelson
Validation (peer review): Siew Hoong Wong-Jacobson (for code up to /* NOTE: TABLE 3 FOR RESUBMISSION )
Validation (peer review): Margaret Hoyt (for code after /* NOTE: TABLE 3 FOR RESUBMISSION )
*/

/*this program imports datasets and selects the desired variables
and merges into 1 dataset (05-10) by seqn*/


libname libraw '/Mango-2/ELECTRON/PublicDataHub/NHANES/scratch';

/*Demographics*/
data libraw.demo_h;
set libraw.demo_h;
dset=2013;
data libraw.demo_g;
set libraw.demo_g;
dset=2011;
data libraw.demo_f;
set libraw.demo_f;
dset=2009;
data libraw.demo_e;
set libraw.demo_e;
dset=2007;
data libraw.demo_d;
set libraw.demo_d;
dset=2005;
data libraw.demo_c;
set libraw.demo_c;
dset=2003;
data libraw.demo_b;
set libraw.demo_b;
dset=2001;
data libraw.demo ;
set libraw.demo ;
dset=1999;
run;

data demo;
	set
libraw.demo  
libraw.demo_b 
libraw.demo_c 
libraw.demo_d 
libraw.demo_e 
libraw.demo_f 
libraw.demo_g 
libraw.demo_h ;

run; 
proc sort data=demo;
	by seqn;

	run;

data diq;
	set libraw.diq  
		libraw.diq_b 
		libraw.diq_c 
	    libraw.diq_d 
		libraw.diq_e 
		libraw.diq_f 
			libraw.diq_g 
			libraw.diq_h ;

run;

proc sort data=diq;
	by seqn;

	run;


data mcq;
	set libraw.mcq  
		libraw.mcq_b 
		libraw.mcq_c 
	    libraw.mcq_d 
		libraw.mcq_e 
		libraw.mcq_f 
			libraw.mcq_g 
			libraw.mcq_h ;
run;

proc sort data=mcq;
	by seqn;

	run;


data glu;
	set  libraw.LAB10AM  libraw.L10AM_b  libraw.L10AM_c libraw.glu_d libraw.glu_e libraw.glu_F libraw.glu_g libraw.glu_h;  
run;

proc sort data=glu;
	by seqn;

	run;

/*CKD part*/

data biopro;
	set libraw.lab18 libraw.l40_b libraw.l40_c  libraw.biopro_d libraw.biopro_e  libraw.biopro_f  libraw.biopro_g libraw.BIOPRO_h ; 

if LBXSCR=. then LBXSCR=LBDSCR; /*due to change in name of creatinine variable*/

run;


proc sort data=biopro;
	by seqn;

	run;

data alb_cr;
	set libraw.lab16 libraw.l16_b libraw.l16_c libraw.alb_cr_d libraw.alb_cr_e libraw.alb_cr_f libraw.ALB_CR_G libraw.ALB_CR_H;  
run;


proc sort data=alb_cr;
	by seqn;

	run;


data alb_cr;
	set alb_cr;

	if URDACT=. then URDACT=(URXUMA*100/URXUCR); /*creates ratio for years it was not derived*/

	/*Albuminuria was defined as a urinary albumin–creatinine ratio of >=30 mg/g.
	http://www.biomedcentral.com/content/pdf/1471-2369-14-132.pdf*/    

if URDACT>=30 then Albuminuria = 1;
		else if .<URDACT<30 then Albuminuria = 0;
		else Albuminuria = .;

	/*Microalbuminuria is defined as a urinary albumin-to-creatinine ratio (ACR) of 30 to 300 mg/g*/
		/*https://academic.oup.com/ajh/article/16/11/952/163776*/

if URDACT>300 then MacroMicroAlb = 2;
	    else if URDACT>=30 then MacroMicroAlb = 1;
		else if .<URDACT<30 then MacroMicroAlb = 0;
		else MacroMicroAlb = .;
run;


data kiq_u;
	set libraw.ohxref libraw.kiq_u_b  libraw.kiq_u_c libraw.kiq_u_d libraw.kiq_u_e libraw.KIQ_U_F libraw.KIQ_U_G libraw.KIQ_U_H;  

 /*KIQ025 Received dialysis in past 12 months, but not included in 1999-2000; 
	for this year, use OHQ144 Has a doctor ever told you that you have kidney disease requiring renal dialysis?*/

	if KIQ025=1 or OHQ144=1 then dialysis=1;
 										    
 keep seqn dialysis;

 run;
 
Proc sort data=kiq_u;
	by seqn;

 run;

/*end of CKD part*/
data bmx;
	set libraw.bmx  
		libraw.bmx_b 
		libraw.bmx_c 
	    libraw.bmx_d 
		libraw.bmx_e 
		libraw.bmx_f 
			libraw.bmx_g 
			libraw.bmx_h ;
run;

proc sort data=bmx;
	by seqn;
	run;

data bpx;
	set libraw.bpx  
		libraw.bpx_b 
		libraw.bpx_c 
	    libraw.bpx_d 
		libraw.bpx_e 
		libraw.bpx_f 
			libraw.bpx_g 
			libraw.bpx_h ;
run;

proc sort data=bpx;
	by seqn;
	run;

data bpq;
	set libraw.bpq  
		libraw.bpq_b 
		libraw.bpq_c 
	    libraw.bpq_d 
		libraw.bpq_e 
		libraw.bpq_f 
			libraw.bpq_g 
			libraw.bpq_h ;

/*I made Yes=100 to simplify my tables of means */

/*BPQ020 Ever told you had high blood pressure*/
		if BPQ020=1 then Hyper=100;
			else if BPQ020=2 then Hyper=0; 

/*BPQ050A Now taking prescribed medicine for hypertension*/
/*BPQ040A Taking prescription for hypertension*/

		if BPQ020=1 and BPQ050A=1 then CurrHyperMed=100;
			else if BPQ020=2 or BPQ040A=2 or BPQ050A =2 then CurrHyperMed=0; 

/*BPQ100D Now taking prescribed medicine for cholesterol*/
/*BPQ060 - Ever had blood cholesterol checked */
/*BPQ080 - Doctor told you - high cholesterol level*/
/*BPQ090D - Told to take prescriptn for cholesterol*/
/*BPQ100D - Now taking prescribed medicine for cholesterol*/

		if BPQ100D=1 then CurrCholMed=100;
			else if BPQ060=2 or BPQ080=2 or BPQ090D=2 or BPQ100D=2 then CurrCholMed=0; 

		keep seqn Hyper CurrHyperMed CurrCholMed  BPQ020 BPQ040A BPQ050A BPQ080 BPQ090D BPQ100D ;

proc sort data=bpq;
	by seqn;
	run;

data rhq;
	set libraw.rhq  
		libraw.rhq_b 
		libraw.rhq_c 
	    libraw.rhq_d 
		libraw.rhq_e 
		libraw.rhq_f 
			libraw.rhq_g 
			libraw.rhq_h ;

		keep seqn RHQ554 RHQ570 RHQ580 Rhq596;
run;

proc sort data=rhq;
	by seqn;
	run;



data smq;
	set libraw.smq  
		libraw.smq_b 
		libraw.smq_c 
	    libraw.smq_d 
		libraw.smq_e 
		libraw.smq_f 
			libraw.smq_g 
			libraw.smq_h ;

data smq;
	set smq;

/* 
1999-2002 SMD090 / Avg # cigarettes/day during past 30 days / During the past 30 days, on the days that {you/SP} smoked, about how many cigarettes did 
	{you/s/he} smoke per day?
2003-2014 SMD650 / Avg # cigarettes/day during past 30 days / During the past 30 days, on the days that {you/SP} smoked, 
	about how many cigarettes did {you/s/he} smoke per day?

1999-2002 SMD080 / # days smoked cigs during past 30 days / On how many of the past 30 days did {you/SP} smoke a cigarette?
2003-2014 SMD641 / # days smoked cigs during past 30 days / On how many of the past 30 days did {you/SP} smoke a cigarette?
*/	

	/*so if 2003-2014 variable name is missing, use 1999-2002 variable name*/
	if SMD650=. then SMD650=SMD090;
	if SMD641=. then SMD641=SMD080;

run;

proc sort data=smq;
	by seqn;
	run;

data tchol;
	set libraw.Lab13  
		libraw.l13_b 
		libraw.l13_c 
	    libraw.TCHOL_D 
		libraw.TCHOL_E 
		libraw.TCHOL_F 
			libraw.TCHOL_G 
			libraw.TCHOL_H ;


		keep seqn LBXTC;

proc sort data=tchol;
	by seqn;
	run;


data hdl;
	set libraw.Lab13  
		libraw.l13_b 
		libraw.l13_c 
	    libraw.HDL_D 
		libraw.HDL_E 
		libraw.HDL_F 
			libraw.HDL_G 
			libraw.HDL_H ;

proc sort data=hdl;
	by seqn;
	run;

data hdl;
	set hdl;

/*HDL name changes over the years*/
	if LBDHDD>. and LBDHDL=. then HDL=LBDHDD;
		else if LBXHDD>. and LBDHDL=. then HDL=LBXHDD;
		else HDL=LBDHDL;

		keep seqn HDL;
run;

data ldl;
	set libraw.Lab13AM  
		libraw.l13AM_b 
		libraw.l13AM_c 
	    libraw.TRIGLY_D 
		libraw.TRIGLY_E 
		libraw.TRIGLY_F 
			libraw.TRIGLY_G 
			libraw.TRIGLY_H ; 

		keep seqn LBDLDL LBXTR;

proc sort data=ldl;
	by seqn;
	run;

/*From Haring table 1; n=3236*/

title "Creating SD for categorical Haring data for use in standardized regression equation";

data design;
	do i = 1 to 3236;
	if i<=1760 then male=0; /* 1760/3236 = 54.4%, Table 1 Haring, 45.6% males*/
		else male=1;
	if i<=136 then Hisp=1; /* 136/3263 = 4.2%, Table 1 Haring, 4.2% Hisp*/
		else Hisp=0;
	if i<=97 then Asian=1; /* 97/3263 = 3.0%, Table 1 Haring, 3.0% Asian*/
		else Asian=0;
	if i<=155 then AfAm=1; /* 155/3263 = 4.8%, Table 1 Haring, 4.8% Af Am*/
		else AfAm=0;
	if i<=421 then smoker=1; /* 421/3263 = 13.0%, Table 1 Haring, 13.0% current smoker*/
		else smoker=0;
	if i<=401 then cvd=1; /* 401/3263 = 12.4%, Table 1 Haring, 12.4% History of CVD*/
		else cvd=0;
	if i<=1061 then HyperMeds=1; /* 1061/3263 = 32.8%, Table 1 Haring, 32.8% AntiHyper meds*/
		else HyperMeds=0;
	if i<=602 then HRT=1; /* 602/3263 = 18.6%, Table 1 Haring, 18.6% Hormone replacement therapy*/
		else HRT=0;
	output;
	end;
	drop i;
	run;

proc means; run;

data demodiq;
	merge demo diq mcq kiq_u biopro alb_cr bmx smq bpq rhq glu TCHOL hdl ldl bpx;
	by SEQN;

/*8 cycles of NHANES so divide fasting sampling weight by 8*/
FastWeight=WTSAF2YR/8;

/*Yes = 100 for tables*/
	if RIAGENDR=1 then Male=100;
		else if RIAGENDR=2 then Male=0; 

/*ridreth1
Code or Value	Value Description
1	Mexican American
2	Other Hispanic
3	Non-Hispanic White
4	Non-Hispanic Black
5	Other Race - Including Multi-Racial
*/
	if ridreth1=3 then White=100;
		else if ridreth1>. then White=0;

	if ridreth1=4 then AfAmer=100;
		else if ridreth1>. then AfAmer=0;

	if 1<=ridreth1<=2 then Hispanic=100;
		else if ridreth1>. then Hispanic=0;

	if ridreth1=5 then Other=100;
		else if ridreth1>. then Other=0;

/*Correction of serum creatinine values in NHANES 2005-2006 is highly recommended: 
The following formula should be used to adjust the NHANES serum creatinine values to ensure comparability with standard creatinine:
https://wwwn.cdc.gov/Nchs/Nhanes/2005-2006/BIOPRO_D.htm

Standard creatinine (mg/dL) = -0.016 + 0.978 X (NHANES 05-06 uncalibrated serum creatinine, mg/dL)*/

if SDDSRVYR=4 then LBXSCR = -0.016 + 0.978 * LBXSCR;

/*https://www.niddk.nih.gov/health-information/communication-programs/nkdep/laboratory-evaluation/glomerular-filtration-rate/estimating
Table 1: CKD EPI Equation for Estimating GFR Expressed for Specified Race, Sex and Serum Creatinine in mg/dL (From Ann Intern Med 2009;150:604–612, used with permission)
Race	Sex	Serum Creatinine,
Scr (mg/dL)	Equation (age in years for ≥ 18)
Black	Female	≤ 0.7	GFR = 166 × (Scr/0.7)-0.329 × (0.993)Age
Black	Female	> 0.7	GFR = 166 × (Scr/0.7)-1.209 × (0.993)Age
Black	Male	≤ 0.9	GFR = 163 × (Scr/0.9)-0.411 × (0.993)Age
Black	Male	> 0.9	GFR = 163 × (Scr/0.9)-1.209 × (0.993)Age
White or other	Female	≤ 0.7	GFR = 144 × (Scr/0.7)-0.329 × (0.993)Age
White or other	Female	> 0.7	GFR = 144 × (Scr/0.7)-1.209 × (0.993)Age
White or other	Male	≤ 0.9	GFR = 141 × (Scr/0.9)-0.411 × (0.993)Age
White or other	Male	> 0.9	GFR = 141 × (Scr/0.9)-1.209 × (0.993)Age*/

if RIDRETH1=4 and RIAGENDR=2 and .<LBXSCR<=0.7 then CKDEPI=166*((LBXSCR/0.7)**-0.329)*(0.993**RIDAGEYR);
else if RIDRETH1=4 and RIAGENDR=2 and LBXSCR>0.7 then CKDEPI=166*((LBXSCR/0.7)**-1.209)*(0.993**RIDAGEYR);
else if RIDRETH1=4 and RIAGENDR=1 and .<LBXSCR<=0.9 then CKDEPI=163*((LBXSCR/0.9)**-0.411)*(0.993**RIDAGEYR);
else if RIDRETH1=4 and RIAGENDR=1 and LBXSCR>0.9 then CKDEPI=163*((LBXSCR/0.9)**-1.209)*(0.993**RIDAGEYR);
else if RIAGENDR=2 and .<LBXSCR<=0.7 then CKDEPI=144*((LBXSCR/0.7)**-0.329)*(0.993**RIDAGEYR);
else if RIAGENDR=2 and LBXSCR>0.7 then CKDEPI=144*((LBXSCR/0.7)**-1.209)*(0.993**RIDAGEYR);
else if RIAGENDR=1 and .<LBXSCR<=0.9 then CKDEPI=141*((LBXSCR/0.9)**-0.411)*(0.993**RIDAGEYR);
else if RIAGENDR=1 and LBXSCR>0.9 then CKDEPI=141*((LBXSCR/0.9)**-1.209)*(0.993**RIDAGEYR);

/****************/

/*Equation to scale to Framingham, ie, reduced GFR*/

/*includes those 20+ and with waist, fasting glucose, and eGFR; lnFGF23FramePop=0 so starting point for regression*/
if BMXWAIST>. and LBXGLU>. and CKDEPI>. and RIDAGEYR>=20 then lnFGF23FramePop=0; 

/*If lnFGF23FramePop=. then include=0 because missing one of the variables above*/
if lnFGF23FramePop>. then include=1;
	else include = 0;

/*The following calculates lnFGF23FramePop which is the expected ln log of FGF from Framingham population*/
/*Using Haring Table 2 regression coefficients and summary stats from Haring Table 1; for categorical variables, SD from calculations, from data design*/

lnFGF23FramePop=lnFGF23FramePop+(((RIDAGEYR-58.8)/11.2)* 0.011); /*age, #'s from Haring Reference*/

if RIAGENDR=1 then lnFGF23FramePop=lnFGF23FramePop-0.194*((1-0.4561187)/0.4981477) ; /*males, beta from Haring Reference; #'s from calculating Framingham SD table in output*/

if RIDRETH1=4 then lnFGF23FramePop=lnFGF23FramePop+0.044*((1-0.0478986)/0.2135848); /*African Americanbeta from Haring Reference; #'s from calculating Framingham SD table in output*/

if 1<=RIDRETH1<=2 then lnFGF23FramePop=lnFGF23FramePop-0.005*((1-0.0420272)/0.2006822) ; /*Hispanic,beta from Haring Reference; #'s from calculating Framingham SD table in output*/

if RIDRETH3=6 then lnFGF23FramePop=lnFGF23FramePop+0.057*((1-0.0299753)/0.1705454); /*Asian, beta from Haring Reference; #'s from calculating Framingham SD table in output*/

lnFGF23FramePop=lnFGF23FramePop+(((BMXWAIST-99.6)/14.5)*0.098); /*Waist Circumference, #'s from Haring Reference*/

if (SMD641<77 and SMD650<777 and SMD641*SMD650>=30) then lnFGF23FramePop=lnFGF23FramePop+0.118*((1-0.1300989 )/0.3364642);  /*Smoking, beta from Haring Reference; #'s from calculating Framingham SD table in output*/

lnFGF23FramePop=lnFGF23FramePop+(((LBXGLU-104)/30)*0.052) ;  /*Fasting Glucose, #'s from Haring Reference*/

if (MCQ160b=1 or MCQ160c=1 or MCQ160d=1 or MCQ160e=1 or MCQ160f=1) then lnFGF23FramePop=lnFGF23FramePop+0.099*((1-0.1239184)/0.3295394); /*CVD, beta from Haring Reference; #'s from calculating Framingham SD table in output*/

if BPQ050A=1 then lnFGF23FramePop=lnFGF23FramePop+0.059*((1-0.3278739)/0.4695112); /*Hypertension Meds, beta from Haring Reference; #'s from calculating Framingham SD table in output*/

if (RHQ554=1 or RHQ570=1 or RHQ580=1 or Rhq596=1) then  lnFGF23FramePop=lnFGF23FramePop-0.078*((1-0.1860321)/0.3891927); /*HRT, beta from Haring Reference; #'s from calculating Framingham SD table in output*/

/*SCALING TO MAKE SAME MEDIAN Q1 Q3 AS FRAMINGHAM*/
CKDEPI2=(((CKDEPI*70.6/83.55018)-(70.6))*16.3/15.6881269)+70.6 ; /*NHANES age>42 ave egfr divided by Framingham egfr then SD ratio to create the same SD*/ 

/*STEP 1*/lnFGF23FramePopN=lnFGF23FramePop+(((CKDEPI2-70.6)/16.3)*(-0.162)) ; /*eGFR with transformed Framingham CKD epi*/

/*STEP 2*/lnFGF23FramePopN=lnFGF23FramePopN+0.027360218; /*to center at zero, subtract median for PREVIOUS lnFGF23FramePopN*/

/*STEP 3*/if .<lnFGF23FramePopN<0 then lnFGF23FramePopN=lnFGF23FramePopN*(-0.215708573/-0.165601) ; /*divide by Q1 from Haring by Q1 PREVIOUS lnFGF23FramePopN, */
	else if lnFGF23FramePopN>0 then lnFGF23FramePopN=lnFGF23FramePopN*(0.237958637/0.213126) ; /*divide by Q3 from Haring by Q3 PREVIOUS lnFGF23FramePopN, */	

/*STEP 4*/ eFGF23scale=exp(lnFGF23FramePopN+log(67)); /* Same Median Q1 Q3 as Haring paper */
/*END SCALING TO MAKE SAME MEDIAN Q1 Q3 AS FRAMINGHAM*/

/* THIS CODE WAS USED TO FILL IN THE MEDIAN AND Q1 and Q3 VALUES FROM ABOVE 
if white=100 then FastWeightF=FastWeight*88.0/75.7; 
if AfAmer=100 then FastWeightF=FastWeight*4.8/9.6;
if Hispanic=100 then FastWeightF=FastWeight*4.2/9.3;
if Other=100 then FastWeightF=FastWeight*3.0/5.3;

if lnFGF23FramePop>. and 42<RIDAGEYR<=85 then IncludeFGFscale=1;
		else IncludeFGFscale=0;
run;
proc surveymeans data=demodiq median quartiles mean; 
	var lnFGF23FramePopN eFGF23scale CKDEPI; 
	domain IncludeFGFscale;
	CLUSTER SDMVPSU;
	STRATA SDMVSTRA;
	weight FastWeightF;
run; */

/*USE SAME SCALING WITH CKDEPI and not CKDEPI2, which was to mirror Framingham*/
/*STEP 1*/lnFGF23FramePop=lnFGF23FramePop+(((CKDEPI-70.6)/16.3)*(-0.162)) ; /*eGFR with actual CKDEPI CKD epi*/

/*STEP 2*/lnFGF23FramePop=lnFGF23FramePop+0.027360; /*to center at zero, subtract median for PREVIOUS lnFGF23FramePopN*/

/*STEP 3*/if .<lnFGF23FramePop<0 then lnFGF23FramePop=lnFGF23FramePop*(-0.215708573/-0.165601) ; /*divide by Q1 from Haring by Q1 PREVIOUS lnFGF23FramePopN, */
	else if lnFGF23FramePop>0 then lnFGF23FramePop=lnFGF23FramePop*(0.237958637/0.213126) ; /*divide by Q3 from Haring by Q3 PREVIOUS lnFGF23FramePopN, */	

/*STEP 4*/ eFGF23=exp(lnFGF23FramePop+log(67)); /*standardized regression result plus ln(median) from Haring, ln(67)*/

eFGF23perSD = eFGF23/16.6133712;

if lnFGF23FramePop>. and 42<RIDAGEYR<=85 then IncludeFGFscale=1;
		else IncludeFGFscale=0;

if white=100 then FastWeightF=FastWeight*88.0/75.7; /*Framingham rate divided by NHANES subgroup rate for reweight*/
if AfAmer=100 then FastWeightF=FastWeight*4.8/9.6;
if Hispanic=100 then FastWeightF=FastWeight*4.2/9.3;
if Other=100 then FastWeightF=FastWeight*3.0/5.3;


if CKDEPI>=60 and MacroMicroAlb<1 then CKDEPIgrp=0;
	else if CKDEPI>=90 and MacroMicroAlb>=1 then CKDEPIgrp=1;
	else if CKDEPI>=60 and MacroMicroAlb>=1 then CKDEPIgrp=2;
	else if CKDEPI>=30 then CKDEPIgrp=3;
	else if CKDEPI>=15 then CKDEPIgrp=4;
	else if CKDEPI>. then CKDEPIgrp=5;

if dialysis=1 then CKDEPIgrp=5;

/*CHF*/
	if MCQ160B>=7 then chf=.;
		else if MCQ160B=1 then chf=1; 
		else if MCQ160B=2 then chf=0; 


/*START Diabetes definition*/

/*
After Cycle 3 SDDSRVYR>3
DID060 - How long taking insulin	
1 to 49	Range of Values
666	Less than 1 month
777	Refused
999	Don't know
.	Missing
DIQ060U - Unit of measure (month/year)	
1	Months
2	Years
7	Refused
9	Don't know
.	Missing

SDDSRVYR=1
DIQ060G - How long taking insulin	
1	Enter number (of months or years)
2	Less than 1 month
7	Refused
9	Don't know
.	Missing
*/

/*Making 1999-2004 consistent with subsequent years for insulin time*/
if (SDDSRVYR=1) and DIQ060G=2 then did060=666;
	else if (SDDSRVYR=1 and .<DIQ060Q<77777) then did060=DIQ060Q;

if (SDDSRVYR=2 or SDDSRVYR=3) and DID060G=2 then did060=666;
	else if (SDDSRVYR=2 or SDDSRVYR=3 and .<DID060Q<77777) then did060=DID060Q;

/*length of time (years) taking insulin*/


/*length of time (years) taking insulin*/

if did060>=777 then instime=.;
else if diq060U=1 and did060^=666 then instime=did060/12;
else if diq060U=2 and did060^=666 then instime=did060;
else if did060=666 then instime=1/12;
else instime=.;

/* age when first took insulin*/

if instime>. then insage=ridageyr-instime;

/*age of diagnosis*/

if SDDSRVYR=1 and diq040g=2 then AgeDiabDiag=0.5;
	else if SDDSRVYR=1 and .<DIQ040Q<77777 then AgeDiabDiag=DIQ040Q;
	else if 2<=SDDSRVYR<=3 and did040g=2 then AgeDiabDiag=0.5;
	else if 2<=SDDSRVYR<=3 and .<DID040Q<77777 then AgeDiabDiag=DID040Q;
	else if did040=666 then AgeDiabDiag=0.5;
	else if .<did040<777 then AgeDiabDiag=DID040;


/*insulin time since diagnosis; if negative, assume zero*/
instsd=insage-AgeDiabDiag;

if instsd<0 then instsd=0;

/*criteria 1: previously diagnosed with diabetes by a physician after age 30--n=_____*/
if diq010=1 and AgeDiabDiag>30  then diab=1;
else if 2<=diq010<=3 then diab=2;

/*criteria 2: previously diagnosed with diabetes at age 30 or younger and was not taking insulin during first 2 year after diagnosis--added 141 diab=1*/
else if diq010=1 and .<AgeDiabDiag<=30 and (instsd>=2 or DIQ050=2) then diab=1;
else if diq010=1 then diab=2;

if Diab=1 then T2DM=100;
	else if Diab=2 then T2DM=0;

/*END Diabetes definition*/

if (MCQ160b=1 or MCQ160c=1 or MCQ160d=1 or MCQ160e=1 or MCQ160f=1) then HistCVD=100;
	else HistCVD=0;
	
if (SMD641<77 and SMD650<777 and SMD641*SMD650>=30) then Smoker=100;
	else Smoker=0;

if (RHQ554=1 or RHQ570=1 or RHQ580=1 or Rhq596=1) then HRT=100;
	else  HRT=0;

MAP = (2/3)*mean(BPXDI1,BPXDI2,BPXDI3,BPXDI4)+(1/3)*mean(BPXSY1,BPXSY2,BPXSY3,BPXSY4);

SBP=mean(BPXSY1,BPXSY2,BPXSY3,BPXSY4);

if white=100 then FastWeightF=FastWeight*88.0/75.7; /*Framingham rate divided by NHANES subgroup rate for reweight*/
if AfAmer=100 then FastWeightF=FastWeight*4.8/9.6;
if Hispanic=100 then FastWeightF=FastWeight*4.2/9.3;
if Other=100 then FastWeightF=FastWeight*3.0/5.3;
run;

proc format;
	value ckdg
	0=">=60 No Albuminuria"
	1=">=90 Albuminuria"
	2="60-89 Albuminuria"
	3="30-59"
	4="15-29"
	5="<15 or dialysis"
	;

	value SVYyear
	1="1999-2000"
	2="2001-2002"
	3="2003-2004"
	4="2005-2006"
	5="2007-2008"
	6="2009-2010"
	7="2011-2012"
	8="2013-2014";

	value agegrp
  20-34="20-34"
  35-49="35-49"
  50-59="50-59"
  60-69="60-69"
  70-79="70-79"
  80 - high="80+"
;

run;
title "FGF-23 NHANES analysis output";
title2 "Table 1; NHANES calibration subgroup; (n=112,401,814)";
title3 "See Mean and use Sumweight for age for (n=112,401,814)";

ods trace off;
ods select none;

/*Table 1 for subgroup NHANES*/
proc surveymeans sumwgt  mean stderr data=demodiq ;
	domain IncludeFGFscale;
	var RIDAGEYR Male White AfAmer Hispanic Other Hyper CurrHyperMed T2DM LBXGLU HistCVD LBXTC HDL LBDLDL CurrCholMed Smoker HRT BMXWAIST BMXBMI CKDEPI2;
	CLUSTER SDMVPSU;
	STRATA SDMVSTRA;
	weight FastWeightF;
	ods output domain=domain;
	run;

data domain;
	set domain;

	if IncludeFGFscale=1;

	drop IncludeFGFscale DomainLabel Stderr;

ods select all;

proc print;

run;

title "FGF-23 NHANES analysis output";
title2 "Table 1; NHANES calibration subgroup; (n=112,401,814) STANDARD DEVIATIONS FOR CONTINUOUS VARIABLES";
title3 "See Std Deviation";

ods trace off;

ods select moments;

/*Table 1 for subgroup NHANES SDs*/;
PROC UNIVARIATE /*PLOT NORMAL*/ data=demodiq ;
	where IncludeFGFscale=1 ;
	VAR RIDAGEYR LBXGLU LBXTC HDL LBDLDL BMXWAIST BMXBMI CKDEPI2 CKDEPI;
	FREQ FastWeightF;

run ;

title "FGF-23 NHANES analysis output";
title2 "Table 1; Overall NHANES (n=203,780,775)";
title3 "See Mean and use Sumweight for age for (n=203,780,775)";

ods trace off;
ods select none;

/*Table 1 for overall NHANES*/
proc surveymeans sumwgt  mean stderr data=demodiq ;
	domain Include;
	var RIDAGEYR Male White AfAmer Hispanic Other Hyper CurrHyperMed T2DM LBXGLU HistCVD LBXTC HDL LBDLDL CurrCholMed Smoker HRT BMXWAIST BMXBMI CKDEPI  ;
	CLUSTER SDMVPSU;
	STRATA SDMVSTRA;
	weight FastWeight;
	ods output domain=domain;
	run;

data domain;
	set domain;

	if Include=1;

	drop Include DomainLabel Stderr;

ods select all;

proc print;

run;

title "FGF-23 NHANES analysis output";
title2 "Table 1; Overall NHANES (n=203,780,775) STANDARD DEVIATIONS FOR CONTINUOUS VARIABLES";
title3 "See Std Deviation";

ods trace off;

ods select moments;

/*Table 1 for overall NHANES SDs*/;
PROC UNIVARIATE /*PLOT NORMAL*/ data=demodiq ;
	where Include=1 ;
	VAR RIDAGEYR LBXGLU LBXTC HDL LBDLDL BMXWAIST BMXBMI CKDEPI;
	FREQ FastWeight;

run ;

title1 "Of the independent variables needed to calculate eFGF-23, the highest level of missing values was waist circumference at 3.2%.";
title2 "REMOVED FROM MANUSCRIPT";
proc means n nmiss data=demodiq;
	where RIDAGEYR>=20 and FastWeight>0;
	VAR RIDAGEYR BMXWAIST LBXGLU CKDEPI;
	ods output summary=summary;

run;

data summary;
	set summary;
	MissingPct=100*BMXWAIST_Nmiss/(BMXWAIST_Nmiss+BMXWAIST_N);
	keep missingpct;

proc print;

run;

  
ods graphics ;

title "Figure 1";

proc template;
   source Stat.SurveyMeans.Graphics.Summary;
run;


proc template;
define statgraph Stat.SurveyMeans.Graphics.Summary;
   dynamic WeightVar HistVariable BoxVariable EstStat VariableName LowerCLM UpperCLM ConfidenceLabel nbinsoption nbinsvalue
      VariableLabel _byline_ _bytitle_ _byfootnote_;
   begingraph;
      *entrytitle "Distribution of " VARIABLENAME;
      layout lattice / rows=2 columns=1 columndatarange=unionall rowweights=(.8 .2) shrinkfonts=true;
         columnaxes;
            columnaxis / display=(ticks tickvalues label) label=VARIABLELABEL shortlabel=VARIABLENAME griddisplay=auto_on;
         endcolumnaxes;
         layout overlay / xaxisopts=(display=none griddisplay=auto_on label=VARIABLELABEL shortlabel=VARIABLENAME) y2axisopts=(
            display=none);
            if (NBINSOPTION)
               Histogram HISTVARIABLE / scale=PERCENT weight=WEIGHTVAR display=(fill outline) nbins=NBINSVALUE;
            else
               Histogram HISTVARIABLE / scale=PERCENT weight=WEIGHTVAR display=(fill outline);
            endif;
            *densityplot HISTVARIABLE / normal () name="Normal" legendlabel="Normal" weight=WEIGHTVAR lineattrs=GRAPHFIT;
            *densityplot HISTVARIABLE / kernel () name="Kernel" legendlabel="Kernel" weight=WEIGHTVAR lineattrs=GRAPHFIT2;
            *discreteLegend "Normal" "Kernel" / across=1 location=inside Opaque=false AutoAlign=(topright topleft top);
         endlayout;
         layout overlay / xaxisopts=(display=(line ticks tickvalues) griddisplay=auto_on) yaxisopts=(display=none) y2axisopts=(
            display=none);
            boxplotparm x=BOXVARIABLE y=ESTSTAT stat=STATNAME / display=all orient=horizontal tip=(STD MIN MAX MEAN MEDIAN Q1 Q3)
				FILLATTRS=(TRANSPARENCY=0);
            bandplot y=BOXVARIABLE limitlower=LOWERCLM limitupper=UPPERCLM / type=step connectorder=axis tip=(limitlower limitupper
               ) yaxis=y2 extend=true display=(outline) fillattrs=GRAPHDATA3 datatransparency=0.5 extend=true name="ConfInterval"
               legendlabel=CONFIDENCELABEL;
           * discreteLegend "ConfInterval" / location=inside Opaque=false AutoAlign=(topright topleft top);
         endlayout;
      endlayout;
      if (_BYTITLE_)
         entrytitle _BYLINE_ / textattrs=GRAPHVALUETEXT;
      else
         if (_BYFOOTNOTE_)
            entryfootnote halign=left _BYLINE_;
         endif;
      endif;
   endgraph;
end;
run;
ods select SummaryPanel;
ods listing sge=on;
proc surveymeans data=demodiq nobs sumwgt mean median quartiles deciles;
	var eFGF23 ;
	CLUSTER SDMVPSU;
	STRATA SDMVSTRA;
	weight FastWeight;;
	ods output quantiles = quantilesFGF;
	run;

 proc template;
      delete Stat.SurveyMeans.Graphics.Summary;
   run;

data quantilesFGF_ ;
	set quantilesFGF;

	if percentile in (25,50 , 75,90);

	keep percentile estimate;

	run;

title "ABSTRACT + RESULTS SECTION: The eFGF-23 values from the overall weighted NHANES population were lower (median [IQR] 47.4 [35.8, 64.0]";
title2 "vs. 67.0 [54.0, 85.0] RU/mL) than the only published FGF-23 percentiles from the Framingham cohort";
title3 "NOTE Framingham cohort numbers from Haring paper";

proc print;
	run;

data demodiq2;
	set demodiq;

if include=0 then eFGFgeMed=0; /*added so output would work*/
	else if eFGF23>=47.408178 then eFGFgeMed=1;
	else if eFGF23>. then eFGFgeMed=0;

if include=0 then eFGFgeQ3=0; /*added so output would work*/
 	else if eFGF23>=63.957953 then eFGFgeQ3=1;
	else if eFGF23>. then eFGFgeQ3=0;

if include=0 then eFGFge90p=0; /*added so output would work*/
	else if eFGF23>=84.432618 then eFGFge90p=1;
	else if eFGF23>. then eFGFge90p=0;

if include=0 then eFGFgeFQ3=0; /*added so output would work*/
	else if eFGF23>=85 then eFGFgeFQ3=1;
	else if eFGF23>. then eFGFgeFQ3=0;

if eFGF23>=85.0 then eFGFq=5;
	else if eFGF23>=63.957953 then eFGFq=4;
	else if eFGF23>=47.408178 then eFGFq=3;
	else if eFGF23>=35.810929 then eFGFq=2;
	else if eFGF23>. then eFGFq=1;

if CKDEPI>=60 and MacroMicroAlb<1 then CKDCHF=0;
	else if CKDEPI>=90 and MacroMicroAlb>=1 then CKDCHF=1;
	else if CKDEPI>=60 and MacroMicroAlb>=1 then CKDCHF=2;
	else if CKDEPI>=30 then CKDCHF=3;
	else if CKDEPI>=15 then CKDCHF=4;
	else if CKDEPI>. then CKDCHF=5;

if dialysis=1 then CKDCHF=5;

/*CKDCHF+6 added so Mosaic Plot will have CHF Yes group separate (CKDCHF 6-10) compared to CHF No (CKDCHF 1-5) for output*/ 
if chf=1 then CKDCHF=CKDCHF+6;
	else if chf=. then CKDCHF=.;

run;

ods select none;
/*table  NOT USED*/
 proc surveyfreq data=demodiq2;
 	tables include*(RIDAGEYR CKDEPIgrp chf) *(eFGFgeMed eFGFgeQ3 eFGFge90p eFGFgeFQ3) include*chf /row;
	CLUSTER SDMVPSU;
	STRATA SDMVSTRA;
	weight FastWeight;
	format RIDAGEYR agegrp. CKDEPIgrp ckdg.;
	ods output CrossTabs=CrossTabs;

	run;

title "For example, an estimated 79.1%, 46.6% and 19.7% of NHANES subjects aged 60 to 69 have eFGF-23 levels above the 50th (47.4 RU/ml),";
title2 "75th (64.0 RU/ml) and 90th (84.4 RU/ml)";

data CrossTabs1;
	set CrossTabs; 

	if F_RIDAGEYR =:"60"; 

	if include=1 and (eFGFgeMed=1 or eFGFgeQ3=1 or eFGFge90p=1);

	keep F_RIDAGEYR eFGFgeMed eFGFgeQ3 eFGFge90p RowPercent;

	run;

ods select all;

proc print;

run;

title "Similarly, nearly all (93.0%) NHANES subjects with stage 2 CKD have an eFGF-23 above the NHANES median,";
title2 "whereas 66.2% and 30.3% have values above the 75th and 90th percentiles";

data CrossTabs1;
	set CrossTabs;

	if F_CKDEPIgrp =:"60"; 

	if include=1 and (F_eFGFgeMed=1 or F_eFGFgeQ3=1 or eFGFge90p=1);

	keep F_CKDEPIgrp eFGFgeMed eFGFgeQ3 eFGFge90p RowPercent;

	run;

ods select all;

proc print;

run;

title "Among subjects with CHF, nearly all (96.2%) are above the NHANES median and more than half (67.8%) have values above the 90th percentile.";

data CrossTabs1;
	set CrossTabs;

	if chf=1; 

	if include=1 and (eFGFgeMed=1 or eFGFgeQ3=1 or eFGFge90p=1);

	keep chf eFGFgeMed eFGFgeQ3 eFGFge90p RowPercent;

	run;

ods select all;

proc print;

run;

/******************BOXPLOT*****************/

data demodiq2b;
	set demodiq2;

	if include=0 then efgf23=0; /*to make the domains work in quantiles from SURVEYMEANS*/

	run;
ods select none;
ods trace off;
proc surveymeans data=demodiq2b sumwgt mean median /*min max*/ QUARTILES percentiles= ( /*0*/ 10 90 /*100*/); 
	CLUSTER SDMVPSU;
	STRATA SDMVSTRA;
	var efgf23;
	weight FastWeight;
	domain include include*RIDAGEYR include*CKDEPIgrp include*chf;
	format RIDAGEYR agegrp. CKDEPIgrp ckdg.;
ods output Statistics=Statistics Quantiles=Quantiles  Domain=Domain DomainQuantiles=  DomainQuantiles        ;

run;

data DomainMean;
	set Domain; 

	if include=1; 

	if RIDAGEYR=. and CKDEPIgrp=. and chf=. then grp=0;
	if 20<=RIDAGEYR<=34 then grp=1;
	if 35<=RIDAGEYR<=49 then grp=2;
	if 50<=RIDAGEYR<=59 then grp=3;
	if 60<=RIDAGEYR<=69 then grp=4;
	if 70<=RIDAGEYR<=79 then grp=5;
	if RIDAGEYR>=80 then grp=6;
	if CKDEPIgrp=0 then  grp=7;
	if CKDEPIgrp=1 then  grp=8;
	if CKDEPIgrp=2 then  grp=9;
	if CKDEPIgrp=3 then  grp=10;
	if CKDEPIgrp=4 then  grp=11;
	if CKDEPIgrp=5 then  grp=12;
	if chf=0   then  grp=13;
	if chf=1   then  grp=14;

	_TYPE_="MEAN  ";

	_VALUE_=Mean;

	keep grp _TYPE_ _VALUE_;

RUN;


data DomainWtN;
	set Domain; 

	if include=1; 

	if RIDAGEYR=. and CKDEPIgrp=. and chf=. then grp=0;

	if 20<=RIDAGEYR<=34 then grp=1;
	if 35<=RIDAGEYR<=49 then grp=2;
	if 50<=RIDAGEYR<=59 then grp=3;
	if 60<=RIDAGEYR<=69 then grp=4;
	if 70<=RIDAGEYR<=79 then grp=5;
	if RIDAGEYR>=80 then grp=6;
	if CKDEPIgrp=0 then  grp=7;
	if CKDEPIgrp=1 then  grp=8;
	if CKDEPIgrp=2 then  grp=9;
	if CKDEPIgrp=3 then  grp=10;
	if CKDEPIgrp=4 then  grp=11;
	if CKDEPIgrp=5 then  grp=12;
	if chf=0 then   grp=13;
	if chf=1 then   grp=14;

	_TYPE_="N";

	_VALUE_=SumWgt;

	if _VALUE_>.;

	keep grp _TYPE_ _VALUE_;

RUN;


data DomainQ;
	set DomainQuantiles;

	if include=1; 

	if RIDAGEYR=. and CKDEPIgrp=. and chf=. then grp=0;

	if 20<=RIDAGEYR<=34 then grp=1;
	if 35<=RIDAGEYR<=49 then grp=2;
	if 50<=RIDAGEYR<=59 then grp=3;
	if 60<=RIDAGEYR<=69 then grp=4;
	if 70<=RIDAGEYR<=79 then grp=5;
	if RIDAGEYR>=80 then grp=6;
	if CKDEPIgrp=0 then  grp=7;
	if CKDEPIgrp=1 then  grp=8;
	if CKDEPIgrp=2 then  grp=9;
	if CKDEPIgrp=3 then  grp=10;
	if CKDEPIgrp=4 then  grp=11;
	if CKDEPIgrp=5 then  grp=12;
	if chf=0 then   grp=13;
	if chf=1 then   grp=14;

	_VALUE_=Estimate;

	if percentile=50 then _TYPE_="MEDIAN"; 
	if percentile=10 then _TYPE_="MIN"; /*can change based on outliers*/
	if percentile=25 then _TYPE_="Q1"; 
	if percentile=75 then _TYPE_="Q3"; 
	if percentile=90 then _TYPE_="MAX"; /*can change based on outliers*/

	;
		
	keep grp _TYPE_ _VALUE_;

	run;

data box;
	set  DomainMean DomainWtN DomainQ ;

	   _VAR_="eFGF23";

run;

proc sort;
	by grp;

	run;


proc format;
value Box
	0="Overall" 
	1="20-34"
  2="35-49"
  3="50-59"
  4="60-69"
  5="70-79"
  6="80+" 
	7="0"
	8="1"
	9="2"
	10="3"
	11="4"
	12="5"
	13="No CHF"
	14="CHF"
	;

value CHFCKD
	0="No CHF, CKD 0"
	1="No CHF, CKD 1"
	2="No CHF, CKD 2"
	3="No CHF, CKD 3"
	4="No CHF, CKD 4"
	5="No CHF, CKD 5"
	6="CHF, CKD 0"
	7="CHF, CKD 1"
	8="CHF, CKD 2"
	9="CHF, CKD 3"
	10="CHF, CKD 4"
	11="CHF, CKD 5"
	;

value CHFCKD_
	0="No CHF, CKD 0"
	1="No CHF, CKD 1"
	2="No CHF, CKD 2"
	3="No CHF, CKD 3"
	4="No CHF, CKD 4"
	5="No CHF, CKD 5"
	6="CHF"
	7="CHF"
	8="CHF"
	9="CHF"
	10="CHF"
	11="CHF"
	;

value CKDStg
	0="CKD 0"
	1="CKD 1"
	2="CKD 2"
	3="CKD 3"
	4="CKD 4"
	5="CKD 5"
	;

value efgfq
	1="NHANES Q1"
	2="NHANES Q2"
	3="NHANES Q3"
	4="NHANES Q4"
	5="Framingham Q4"
	;


value efgfq2_
	1="Q1"
	2="Q2"
	3="Q3"
	4="Q4A"
	5="Q4B"
	;
value efgfq3_
	1="Q1"
	2="Q2"
	3="Q3"
	4="Q4"
	5="Q4"
	;
value chf
	0="No CHF"
	1="CHF"
	;
run;

ods select all;

*options nogstyle;
ods graphics off;
axis1  value=(height=1.00);
axis2 /*order = /*(3 to 13 by 1)*/ label = ('eFGF-23 (RU/mL)' height=0.2) value=(height=2)  ;

title1 "Figure 2";

proc boxplot box=box;
format grp box. ;
plot eFGF23*grp / boxwidthscale=1 href=0.5 6.6 12.5 NOHLABEL  HREFLABELS='Age Groups' 'CKD Stage' 'CHF' HREFLABPOS=1
	vaxis=axis2 height=3.5 idheight=2 labelheight=2 haxis=axis1 ;
	;

	run;

/*NOT USED IN MANUSCRIPT*/
ods select none;
ods graphics on;
proc surveyfreq data=demodiq2b;
	CLUSTER SDMVPSU;
	STRATA SDMVSTRA;
	weight FastWeight;
	tables include*eFGFq*CKDCHF /* chf*eFGFq*CKDEPIgrp*/ / plots=mosaicplot;
	format eFGFq efgfq2_. CKDCHF CHFCKD. CKDEPIgrp ckdg.;

run;

title1 "Figure 3";
ods graphics on;
ods select Surveyfreq.Table1of1.MosaicPlot Surveyfreq.Table2of2.MosaicPlot;
proc surveyfreq data=demodiq2b;
	CLUSTER SDMVPSU;
	STRATA SDMVSTRA;
	weight FastWeight;
	tables include*eFGFq*CKDCHF chf*eFGFq*CKDEPIgrp/ plots=mosaicplot;
	format eFGFq efgfq3_. CKDCHF CHFCKD_. CKDEPIgrp CKDStg.;

run;

* DEFINE VARIABLE VALUES FOR REPORTS;

PROC FORMAT;

  VALUE ELIGFMT
    1 = "Eligible"
    2 = "Under age 18"
    3 = "Ineligible" ;

  VALUE MORTFMT
    0 = "Assumed alive"
    1 = "Assumed deceased"
    . = "Ineligible or under age 18";

  VALUE MRSRCFMT
  	1 = "Yes";

 VALUE CAUSEFMT
  	0 = "No"
	1 = "Yes"
	. = "Ineligible, under age 18 or assumed alive";

  VALUE FLAGFMT
    0 = "No"
    1 = "Yes"  
    . = "Ineligible, under age 18, assumed alive or no cause data";

  VALUE QRTFMT
    1 = "January - March"
    2 = "April   - June"
    3 = "July    - September"
    4 = "October - December" 
    . = "Ineligible, under age 18 or assumed alive";

  VALUE DODYFMT
    . = "Ineligible, under age 18 or assumed alive";

  VALUE $UCODFMT
		"001" = "Diseases of heart (I00-I09, I11, I13, I20-I51)"
		"002" = "Malignant neoplasms (C00-C97)"
		"003" = "Chronic lower respiratory diseases (J40-J47)"
		"004" = "Accidents (unintentional injuries) (V01-X59, Y85-Y86)"
		"005" = "Cerebrovascular diseases (I60-I69)"
		"006" = "Alzheimer's disease (G30)"
		"007" = "Diabetes mellitus (E10-E14)"
		"008" = "Influenza and pneumonia (J09-J18)"
		"009" = "Nephritis, nephrotic syndrome and nephrosis (N00-N07, N17-N19, N25-N27)"
		"010" = "All other causes (residual)" 
		"   " = "Ineligible, under age 18, assumed alive or no cause data" ;

RUN ;


libname mort "/Mango-2/GPO/Data Holding Area/WELLS/NHANES Data/mortality/";

DATA NHANESmort2011;
	set mort.NHANESmort2011;

proc sort;
	by seqn;

proc sort data=demodiq2;
	by seqn;

data mortdemodiq2;
	merge demodiq2 NHANESmort2011;
	by seqn;

	if dset>=2011 then delete;

	mortwt=WTSAF2YR/6;

	/*PERMTH_EXM
		UCOD_LEADING
	"001" = "Diseases of heart (I00-I09, I11, I13, I20-I51)"
		"002" = "Malignant neoplasms (C00-C97)"
		"003" = "Chronic lower respiratory diseases (J40-J47)"
		"004" = "Accidents (unintentional injuries) (V01-X59, Y85-Y86)"
		"005" = "Cerebrovascular diseases (I60-I69)"
		"006" = "Alzheimer's disease (G30)"
		"007" = "Diabetes mellitus (E10-E14)"
		"008" = "Influenza and pneumonia (J09-J18)"
		"009" = "Nephritis, nephrotic syndrome and nephrosis (N00-N07, N17-N19, N25-N27)"
		"010" = "All other causes (residual)" 
		"   " = "Ineligible, under age 18, assumed alive or no cause data" ;
	
	VALUE MORTFMT mortstat
    0 = "Assumed alive"
    1 = "Assumed deceased"
    . = "Ineligible or under age 18";


*/
	TotalHDLRatio = LBXTC/HDL;

	if mortstat=1 and (UCOD_LEADING="001" or UCOD_LEADING="005") then CVstat=1;
		else if mortstat>. then CVstat=0;

	run;
ods select none;
ods output productlimitestimates=surv_est;
ods trace off;
proc lifetest data=mortdemodiq2 plots=(survival(nocensor ATRISK)) method=km timelist=(0 to 150 by 1) ;
	time PERMTH_EXM*mortstat(0);
	strata eFGFq;
	freq mortwt;
	format eFGFq efgfq3_. ;
run ;

title "Figure 4a";

ods select all;
proc sgplot data=surv_est;
	series x=PERMTH_EXM y=failure / group=eFGFq;
	format eFGFq efgfq3_. ;
	label PERMTH_EXM='Months of Follow-up from Exam Date' failure='Mortality Rate';
run ;

data surv_est1;
	set surv_est;

	if STRATUM=1 or STRATUM=4;

	if timelist=120;

	keep eFGFq timelist failure failed;

	run;

title "RESULTS: Over a period of 10 years, Kaplan-Meier methods estimate 501,824 (1.6%) subjects with eFGF-23 levels in the lowest quartile died, 84,513 (0.3%)";
title2 "from CV causes.  In contrast, 6,527,151 (23.2%) with eFGF-23 levels in the highest quartile died, 1,714,723 (6.4%) from CV causes.";
title3 "Overall Mortality";

proc print;
run;
ods select none;

ods output productlimitestimates=surv_estCV;
proc lifetest data=mortdemodiq2 plots=(survival(nocensor atrisk)) method=km timelist=(0 to 150 by 1);
	time PERMTH_EXM*cvstat(0);
	strata eFGFq;
	freq mortwt;
	format eFGFq efgfq3_. ;
run ;

ods select all;
ods listing sge=on;

title "Figure 4b";

proc sgplot data=surv_estCV;
	series x=timelist y=failure / group=eFGFq;
	format eFGFq efgfq3_. ;
	label timelist='Months of Follow-up from Exam Date' failure='CV Mortality Rate';
run ;

data surv_est1;
	set surv_estCV;;

	if STRATUM=1 or STRATUM=4;

	/*to get 10 year mortality*/
	if timelist=120;

	keep eFGFq timelist failure failed;

	run;

title "RESULTS: Over a period of 10 years, Kaplan-Meier methods estimate 501,824 (1.6%) subjects with eFGF-23 levels in the lowest quartile died, 84,513 (0.3%)";
title2 "from CV causes.  In contrast, 6,527,151 (23.2%) with eFGF-23 levels in the highest quartile died, 1,714,723 (6.4%) from CV causes.";
title3 "CV Mortality";

proc print;
run;

ods select ParameterEstimates;

title "Table 2; CV Mortality; Age and Sex Adjusted; Continuous per SD (bottom right of table)";

proc surveyphreg data=mortdemodiq2;
	CLUSTER SDMVPSU;
	STRATA SDMVSTRA;
	weight mortwt  ;
	class  riagendr /*ridreth1*/;
	model PERMTH_EXM*cvstat(0) = RIDAGEYR riagendr /*ridreth1*/ eFGF23perSD /rl;

run;

ods select ParameterEstimates;

title "Table 2; CV Mortality; Age and Sex Adjusted; Q2-Q4 (bottom right of table)";

proc surveyphreg data=mortdemodiq2;
	CLUSTER SDMVPSU;
	STRATA SDMVSTRA;
	weight mortwt  ;
	class eFGFq (REF=FIRST) riagendr /*ridreth1*/;
	model PERMTH_EXM*cvstat(0) = RIDAGEYR riagendr /*ridreth1*/ eFGFq /rl;
			format eFGFq  efgfq3_.;
run;

title "Table 2; CV Mortality; Multivariable Adjusted; Continuous per SD (bottom right of table)";
title2 "Methods: For Cox models with CV Death as endpoint, BMI was converted to BMI quartile to allow model convergence.";

proc rank data=mortdemodiq2 out=mortdemodiq2 groups=4;
	var BMXBMI;
	ranks BMI_qntl;
run;

ods select ParameterEstimates;

proc surveyphreg data=mortdemodiq2;
	CLUSTER SDMVPSU;
	STRATA SDMVSTRA;
	weight mortwt  ;
	class  riagendr ridreth1 Smoker T2DM  CurrHyperMed;
	model PERMTH_EXM*cvstat(0) = RIDAGEYR riagendr   ridreth1  BMI_qntl     SBP  CurrHyperMed  TotalHDLRatio Smoker  T2DM   eFGF23perSD /rl;
/*FROM HARING: Multivariable modeling included adjustment for age, sex, BMI, systolic BP, antihyper-tensive treatment, total/HDL cholesterol ratio, smoking,T2DM, and cohort. 
			Multivariable analyses of 10-year all-causemortality were additionally adjusted for prevalent CVD
	THIS ONE NEEDS BMI QUARTILE TO CONVERGE*/

run;


ods select ParameterEstimates;

title "Table 2; CV Mortality; Multivariable Adjusted; Q2-Q4 (bottom right of table)";

proc surveyphreg data=mortdemodiq2;
	CLUSTER SDMVPSU;
	STRATA SDMVSTRA;
	weight mortwt  ;
	class eFGFq (REF=FIRST) riagendr ridreth1 Smoker T2DM   CurrHyperMed;
	model PERMTH_EXM*cvstat(0) =RIDAGEYR riagendr   ridreth1  BMI_qntl     SBP  CurrHyperMed  TotalHDLRatio Smoker  T2DM  eFGFq/rl;
				format eFGFq  efgfq3_.;

run;

ods select ParameterEstimates;

title "Table 2; All Cause Mortality; Age and Sex Adjusted; Continuous per SD (bottom right of table)";
title2 " ";

proc surveyphreg data=mortdemodiq2;
	CLUSTER SDMVPSU;
	STRATA SDMVSTRA;
	weight mortwt  ;
	class  riagendr /*ridreth1*/;
	model PERMTH_EXM*mortstat(0) = RIDAGEYR riagendr /*ridreth1*/  eFGF23perSD /rl;
run;

ods select ParameterEstimates;

title "Table 2; All Cause Mortality; Multivariable Adjusted; Continuous per SD (bottom right of table)";

proc surveyphreg data=mortdemodiq2;
	CLUSTER SDMVPSU;
	STRATA SDMVSTRA;
	weight mortwt  ;
	class  riagendr /*ridreth1*/  CurrHyperMed Smoker T2DM;
	model PERMTH_EXM*mortstat(0) = RIDAGEYR riagendr   ridreth1  BMXBMI     SBP  CurrHyperMed  TotalHDLRatio Smoker  T2DM eFGF23perSD/rl;
run;

ods select ParameterEstimates;

title "Table 2; All Cause Mortality; Age and Sex Adjusted; Q2-Q4 (bottom right of table)";
title2 "ABSTRACT + RESULTS - Subjects from NHANES with the highest quartile eFGF-23 levels were 2.43 (95% confidence interval: 1.42, -4.16) times";
title3 "more likely to die of any cause than those with levels in the lowest quartile after adjustment for age and sex only";

proc surveyphreg data=mortdemodiq2;
	CLUSTER SDMVPSU;
	STRATA SDMVSTRA;
	weight mortwt  ;
	class eFGFq (REF=FIRST) riagendr /*ridreth1*/;
	model PERMTH_EXM*mortstat(0) = RIDAGEYR riagendr /*ridreth1*/ eFGFq  /rl;
	format eFGFq  efgfq3_.;
run;

ods select ParameterEstimates;

title "Table 2; All Cause Mortality; Multivariable Adjusted; Q2-Q4 (bottom right of table)";
title2 " ";
title3 " ";


proc surveyphreg data=mortdemodiq2;
	CLUSTER SDMVPSU;
	STRATA SDMVSTRA;
	weight mortwt  ;
	class eFGFq (REF=FIRST) riagendr /*ridreth1*/  CurrHyperMed Smoker T2DM   ;
	model PERMTH_EXM*mortstat(0) =RIDAGEYR riagendr   ridreth1  BMXBMI     SBP  CurrHyperMed  TotalHDLRatio Smoker  T2DM eFGFq  /rl;
	format eFGFq  efgfq3_.;
run;


title "DISCUSSION: Mean eFGF-23 levels increased steadily with age and CKD, and were more than twice as high among those with versus without CHF.";

ods select none;
ods trace off;
proc surveymeans data=demodiq2b sumwgt mean median /*min max*/ QUARTILES percentiles= ( /*0*/ 10 90 /*100*/); 
	CLUSTER SDMVPSU;
	STRATA SDMVSTRA;
	var efgf23;
	weight FastWeight;
	domain include*RIDAGEYR include*CKDEPIgrp include*chf;
	format RIDAGEYR agegrp. CKDEPIgrp ckdg. chf chf.;
ods output Domain=Domain ;
run;

ods select all;

proc print data=domain;
		where include=1;
		var mean RIDAGEYR   CKDEPIgrp  chf;

	run;

run;
title "DISCUSSION: However, the subgroups with the largest absolute numbers of subjects in the top quartile of eFGF-23 were those with earlier stages of CKD";
title2 "and without CHF";

ods select none;
 proc surveyfreq data=demodiq2;
 	tables include*CKDEPIgrp*chf* eFGFgeQ3;
	CLUSTER SDMVPSU;
	STRATA SDMVSTRA;
	weight FastWeight;
	format chf chf. CKDEPIgrp ckdg.;
	ods output CrossTabs=CrossTabs;

	run;

proc sort;
	by WgtFreq;

 ods select all;

 proc print;
 	where include=1 and  eFGFgeQ3=1 and chf>.;
	var chf CKDEPIgrp WgtFreq;
		format chf chf. CKDEPIgrp ckdg.;

		run;


/* NOTE: TABLE 3 FOR RESUBMISSION *****************************************************************************************************************************************/

data table3;
	set demodiq2;

	if include=0 then efgf23=0; /*to make the domains work in quantiles from SURVEYMEANS; include=0 are those NOT INCLUDED in the analysis, but they must be assigned a value*/

	if CKDEPIgrp>=3 then CKDstage345=1; /*CKD Stage 3+ from Table 3*/
		else if CKDEPIgrp>. then CKDstage345=0;

	if CKDEPIgrp>=4 then CKDstage45=1;/*CKD Stage 4+ from Table 3*/
		else if CKDEPIgrp>. then CKDstage45=0;

	if CKDEPIgrp>=5 then CKDstage5=1;/*CKD Stage 5 from Table 3*/
		else if CKDEPIgrp>. then CKDstage5=0;

	run;

ods graphics off;
ods select none;

 proc surveyfreq data=table3;
 	tables include*(eFGFgeMed eFGFgeQ3 CKDstage345 CKDstage45 CKDstage5 chf ) /row;
	CLUSTER SDMVPSU;
	STRATA SDMVSTRA;
	weight FastWeight;
	ods output CrossTabs=Table3pct;

data table3pct;
	set table3pct;

	if include=1 and (eFGFgeMed=1 or eFGFgeQ3=1 or CKDstage345=1 or CKDstage45=1 or CKDstage5=1 or chf=1);

	run;

ods select all;
title "REVISION: TABLE 3 Percentages";

proc print;
	var eFGFgeMed eFGFgeQ3 CKDstage345 CKDstage45 CKDstage5 chf RowPercent ;

	run;


ods select none;
proc surveymeans data=table3 median ; 
	CLUSTER SDMVPSU;
	STRATA SDMVSTRA;
	var efgf23;
	weight FastWeight;
	domain include*eFGFgeMed include*eFGFgeQ3 include*CKDstage345 include*CKDstage45 include*CKDstage5 include*chf ;
	ods output DomainQuantiles=Table3median;
run;


ods select all;
title "REVISION: TABLE 3 Medians";


data table3median;
	set table3median;

	if include=1 and (eFGFgeMed=1 or eFGFgeQ3=1 or CKDstage345=1 or CKDstage45=1 or CKDstage5=1 or chf=1);

	run;


proc print;
	var eFGFgeMed eFGFgeQ3 CKDstage345 CKDstage45 CKDstage5 chf Estimate PercentileLabel ;

	run;


