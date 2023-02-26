***********************************************************************;
* Project           : UKB 
* Program name      : GP_pain_responder_musskl_main_final.sas
* Author            : song li
* Date created      : 20200619
* Purpose           : generate phenotype files for musskl pain treatment outcome
* Revision History  :
* Date        Author      Ref    Revision 
* 20200421    song li      1      created. 
*
**********************************************************************;

proc datasets lib=work
	nolist kill;
quit;

libname gp "T:\PIgroup-Marieke-Coenen\UKBiobank\Application52524\7.unpacked data\2.gpdata_sas";
libname gpcoding "T:\PIgroup-Marieke-Coenen\UKBiobank\Application52524\7.unpacked data\5.GP_coding_sas";
libname init "T:\PIgroup-Marieke-Coenen\UKBiobank\Application52524\7.unpacked data\1.initial_data";

data popu_passqc;
	set init.popu_passqc;
run;


/*part A: generate binary pain treatment outcome*/
*1. extract GP3 pain cli and scr;
*1.1 extract all pain dignosis records in gp3_clinical;
PROC IMPORT  OUT=Gp3_readv3_pain_clean
     DATAFILE  = "G:\PhD project PTR UKBiobank\3.input\diagnosis of pain\readv3\musskl\Gp3_readv3_pain_clean.xlsx"
     DBMS  = xlsx REPLACE;
	 GETNAMES = YES;
RUN;
proc sql;
    create table Gp3_cli_musskl as 
    select a.*,b.subcategory1,b.subcategory2,b.subcategory3,b.group,b.subgroup
    from gp.Gp_clinical_3 a, Gp3_readv3_pain_clean b
    where a.read_3 = b.read_3 and a.event_dt ^=.
	order by eid,event_dt;
quit;

*1.2 extract all pain medication records in gp3_scripts;
PROC IMPORT  OUT=Gp3_sci_pain_code
     DATAFILE  = "G:\PhD project PTR UKBiobank\3.input\pain medication\BNF\Gp3_scripts_bnf_pain_med.xlsx"
     DBMS  = xlsx REPLACE;
     GETNAMES = YES;
RUN;
proc sql;
    create table Gp3_sci_pain as 
    select a.*,b.ingredient,b.tag
    from gp.Gp_scripts_3 a, Gp3_sci_pain_code b
    where a.drug_name = b.drug_name and a.issue_date ^=. 
	order by eid,issue_date;
quit;


*1.3 merge cli and sci by eid and date;
proc sql;
    create table Gp3_clisci_pain as 
         select a.eid,a.data_provider,a.event_dt,a.read_3,a.subcategory1,a.subcategory2,a.subcategory3,a.group,a.subgroup,b.issue_date,b.drug_name,b.ingredient,b.tag
         from Gp3_cli_musskl a, Gp3_sci_pain b
         where a.eid = b.eid and a.event_dt = b.issue_date;
quit;

*1.4 remove duplicated record in GP(it is duplicated in original GP records);
proc sort data = Gp3_clisci_pain nodupkey;
by eid event_dt read_3 issue_date drug_name ingredient tag;
run;

proc sort data = Gp3_clisci_pain;
by eid event_dt issue_date tag;
run;




*2 extract GP1 pain cli and scr;
*2.1 extract all pain dignosis records in gp1_clinical;
PROC IMPORT  OUT=Gp124_readv2_pain_clean
     DATAFILE  = "G:\PhD project PTR UKBiobank\3.input\diagnosis of pain\readv2\musskl\readv2_pain_diag.xlsx"
     DBMS  = xlsx REPLACE;
     GETNAMES = YES;
RUN;
proc sql;
    create table Gp1_cli_musskl as 
    select a.*,b.subcategory1,b.subcategory2,b.subcategory3,b.group,b.subgroup
    from gp.Gp_clinical_1 a, Gp124_readv2_pain_clean b
    where a.read_2 = b.read_2 and a.event_dt ^=.
	order by eid,event_dt;
quit;

*2.2 extract all pain medication records in gp1_scripts;
PROC IMPORT  OUT=Gp1_sci_pain_readv2_code
     DATAFILE  = "G:\PhD project PTR UKBiobank\3.input\pain medication\read v2\Gp1_scripts_readv2_pain_med.xlsx"
     DBMS  = xlsx REPLACE;
     GETNAMES = YES;
RUN;

PROC IMPORT  OUT=Gp1_sci_pain_dmd_code
     DATAFILE  = "G:\PhD project PTR UKBiobank\3.input\pain medication\dmd\Gp1_dmd_pain_med.xlsx"
     DBMS  = xlsx REPLACE;
     GETNAMES = YES;
RUN;

proc sql;
	create table Gp1_sci_pain_code as
	select drug_name,ingredient,tag
	from Gp1_sci_pain_readv2_code
	union corr all
	select drug_name,ingredient,tag
	from Gp1_sci_pain_dmd_code;
quit;

proc sort data = Gp1_sci_pain_code nodupkey;
by drug_name ingredient tag;
run;

proc sql;
    create table Gp1_sci_pain as 
    select a.*,b.ingredient,b.tag
    from gp.Gp_scripts_1 a, Gp1_sci_pain_code b
    where a.drug_name = b.drug_name and a.issue_date ^=. 
	order by eid,issue_date;
quit;


*2.3 merge cli and sci by eid and date;
proc sql;
    create table Gp1_clisci_pain as 
         select a.eid,a.data_provider,a.event_dt,a.read_2,a.subcategory1,a.subcategory2,a.subcategory3,a.group,a.subgroup,b.issue_date,b.drug_name,b.ingredient,b.tag
         from Gp1_cli_musskl a, Gp1_sci_pain b
         where a.eid = b.eid and a.event_dt = b.issue_date;
quit;

*2.4 remove duplicated record in GP(it is duplicated in original GP records);
proc sort data = Gp1_clisci_pain nodupkey;
by eid event_dt read_2 issue_date drug_name ingredient tag;
run;

proc sort data = Gp1_clisci_pain;
by eid event_dt issue_date tag;
run;



*3 extract GP2 pain cli and scr;
*3.1 extract all pain dignosis records in gp2_clinical;
proc sql;
    create table Gp2_cli_musskl as 
    select a.*,b.subcategory1,b.subcategory2,b.subcategory3,b.group,b.subgroup
    from gp.Gp_clinical_2 a, Gp124_readv2_pain_clean b
    where a.read_2 = b.read_2 and a.event_dt ^=.
	order by eid,event_dt;
quit;

*3.2 trace all pain medication records in gp2_scripts;
PROC IMPORT  OUT=Gp2_sci_pain_readv2_code
     DATAFILE  = "G:\PhD project PTR UKBiobank\3.input\pain medication\read v2\Gp2_scripts_readv2_pain_med.xlsx"
     DBMS  = xlsx REPLACE;
     GETNAMES = YES;
RUN;

PROC IMPORT  OUT=Gp2_sci_pain_bnf_code
     DATAFILE  = "G:\PhD project PTR UKBiobank\3.input\pain medication\BNF\Gp2_scripts_bnf_pain_med.xlsx"
     DBMS  = xlsx REPLACE;
     GETNAMES = YES;;
RUN;

proc sql;
	create table Gp2_sci_pain_code as
	select drug_name,ingredient,tag
	from Gp2_sci_pain_readv2_code
	union corr all
	select drug_name,ingredient,tag
	from Gp2_sci_pain_bnf_code;
quit;

proc sort data = Gp2_sci_pain_code nodupkey;
by drug_name ingredient tag;
run;

proc sql;
    create table Gp2_sci_pain as 
    select a.*,b.ingredient,b.tag
    from gp.Gp_scripts_2 a, Gp2_sci_pain_code b
    where a.drug_name = b.drug_name and a.issue_date ^=. 
	order by eid,issue_date;
quit;


*3.3 merge cli and sci by eid and date;
proc sql;
    create table Gp2_clisci_pain as 
         select a.eid,a.data_provider,a.event_dt,a.read_2,a.subcategory1,a.subcategory2,a.subcategory3,a.group,a.subgroup,b.issue_date,b.drug_name,b.ingredient,b.tag
         from Gp2_cli_musskl a, Gp2_sci_pain b
         where a.eid = b.eid and a.event_dt = b.issue_date;
quit;

*3.4 remove duplicated record in GP(it is duplicated in original GP records);
proc sort data = Gp2_clisci_pain nodupkey;
by eid event_dt read_2 issue_date drug_name ingredient tag;
run;

proc sort data = Gp2_clisci_pain;
by eid event_dt issue_date tag;
run;


*4 trace GP4 pain cli and scr;
*4.1 trace all pain dignosis records in gp2_clinical;
proc sql;
    create table Gp4_cli_musskl as 
    select a.*,b.subcategory1,b.subcategory2,b.subcategory3,b.group,b.subgroup
    from gp.Gp_clinical_4 a, Gp124_readv2_pain_clean b
    where a.read_2 = b.read_2 and a.event_dt ^=.
	order by eid,event_dt;
quit;

*4.2 find GP4 participants with pain medication;

PROC IMPORT  OUT=Gp4_sci_pain_code
     DATAFILE  = "G:\PhD project PTR UKBiobank\3.input\pain medication\read v2\Gp4_scripts_readv2_pain_med.xlsx"
     DBMS  = xlsx REPLACE;
     GETNAMES = YES;
RUN;

proc sql;
    create table Gp4_sci_pain as 
    select a.*,b.term_description, b.ingredient,b.tag
    from gp.Gp_scripts_4 a, Gp4_sci_pain_code b
    where a.read_2 = b.read_2 and a.issue_date ^=. 
	order by eid,issue_date;
quit;


*4.3 merge cli and sci by eid and date;
proc sql;
    create table Gp4_clisci_pain as 
         select a.eid,a.data_provider,a.event_dt,a.read_2,a.subcategory1,a.subcategory2,a.subcategory3,a.group,a.subgroup,b.issue_date,b.term_description as drug_name,b.ingredient,b.tag
         from Gp4_cli_musskl a, Gp4_sci_pain b
         where a.eid = b.eid and a.event_dt = b.issue_date;
quit;

*4.4 remove duplicated record in GP(it is duplicated in original GP records);
proc sort data = Gp4_clisci_pain nodupkey;
by eid event_dt read_2 issue_date drug_name ingredient tag;
run;

proc sort data = Gp4_clisci_pain;
by eid event_dt issue_date tag;
run;

*5 QC remove one time user and divide people into 3 groups; 
*merge all gp_cli_sci together;
proc sql;
	create table Gp_clisci_pain_temp as
	select *
	from Gp1_clisci_pain
	union corr all
	select *
	from Gp2_clisci_pain
	union corr all
	select *
	from Gp3_clisci_pain
	union corr all
	select *
	from Gp4_clisci_pain;
quit;

******************************************************************************;
*count number for manuscript;
proc sort data = Gp_clisci_pain_temp out = Gp_clisci_pain_temp_count nodupkey;
by eid;
run;

proc sql;
	create table Gp_cli_musskl as
	select *
	from Gp1_cli_musskl
	union corr all
	select *
	from Gp2_cli_musskl
	union corr all
	select *
	from Gp3_cli_musskl
	union corr all
	select *
	from Gp4_cli_musskl;
quit;

proc sort data = Gp_cli_musskl out = Gp_cli_musskl_count nodupkey;
by eid;
run;

proc sql;
	create table Gp_sci_pain as
	select *
	from Gp1_sci_pain
	union corr all
	select *
	from Gp2_sci_pain
	union corr all
	select *
	from Gp3_sci_pain
	union corr all
	select *
	from Gp4_sci_pain;
quit;
proc sort data = Gp_sci_pain out = Gp_sci_pain_count nodupkey;
by eid;
run;
******************************************************************************;


* 5.1 QC: remove data with wrong date, remove without genotype,non-caucasian, inconsistent gender;
data Gp_clisci_pain_temp;
	set Gp_clisci_pain_temp;
	if event_dt not in ('01/Jan/1901'd, '02/Feb/1902'd, '03/Mar/1903'd, '07/Jul/2037'd);
run;

*proc sort data =  Gp_clisci_pain_temp nodupkey out = test1;
*by eid;
*run;

* 5.2 QC: keep patients in popu_passqc;
proc sql;
    create table Gp_clisci_pain as 
         select *
         from Gp_clisci_pain_temp 
         where Gp_clisci_pain_temp.eid
         in (select n_eid from Popu_passqc);
quit;

proc sort data = Gp_clisci_pain;
by eid event_dt issue_date tag;
run;

proc sort data =  Gp_clisci_pain nodupkey out = count1;
by eid;
run;

*count removed eid;
proc sql;
    create table Gp_clisci_pain_rm as 
         select eid
         from Gp_clisci_pain_temp 
         where Gp_clisci_pain_temp.eid
         not in (select n_eid from Popu_passqc);
quit;

proc sort data = Gp_clisci_pain_rm nodupkey;
by eid;
run;

PROC IMPORT OUT=popu_rm
     DATAFILE  = "T:\PIgroup-Marieke-Coenen\UKBiobank\Application52524\7.unpacked data\1.initial_data\popu_rm.xlsx"
     DBMS  = xlsx REPLACE;
     GETNAMES = YES;
RUN;

proc sort data = popu_rm nodupkey;
by n_eid;
run;

proc sql;
	create table Gp_clisci_pain_rm_reason as
	select a.*, b.rm_reason
	from Gp_clisci_pain_rm a, popu_rm b
	where a.eid = b.n_eid;
quit;

proc freq data = Gp_clisci_pain_rm_reason noprint;
table rm_reason / out= Gp_clisci_pain_rm_reason_freq(drop = PERCENT);
run;

*5.3 QC: remove participant with only one matched record;
data Gp_clisci_pain_QC1;
	retain n;
	set Gp_clisci_pain;
	by eid event_dt issue_date tag;
	if first.eid then n=1;
	else n = n+1;
run;

proc sort data = Gp_clisci_pain_QC1;
by eid descending n;
run;

data Gp_clisci_pain_QC1;
	retain m;
	set Gp_clisci_pain_QC1;
	by eid descending n;
	if first.eid then m=n;
	if m = 1 then delete;
	drop m n;
run;

proc sort data =  Gp_clisci_pain_QC1 nodupkey out = count2;
by eid;
run;

*5.4 QC: make sure the pain step is correct (NSAID < opioid), treat all pain groups as one diagnosis.
*change treatment tag 3 to 2;
data Gp_clisci_pain_QC1;
	set Gp_clisci_pain_QC1;
	if tag = 1 then medtag = 3;
	else medtag = 4;
	drop tag;
run;

*the first occurrence date of lower steps must be prior to the higher steps;
proc sort data =  Gp_clisci_pain_QC1;
by eid medtag event_dt;
run;
*keep the earliest med record;
data Gp_clisci_pain_QC2;
	set Gp_clisci_pain_QC1;
	by eid medtag event_dt;
	if first.medtag then n =1;
	if n ^=1 then delete;
	keep eid event_dt medtag;
run;

proc transpose data= Gp_clisci_pain_QC2 out= Gp_clisci_pain_QC2_trans prefix=c;
   by eid;
   var event_dt;
   id medtag;
run;

data Gp_clisci_pain_QC2_trans;
	set Gp_clisci_pain_QC2_trans;
	if c3 = . then delete;
run;

data  Gp_clisci_pain_QC2_trans;
	set Gp_clisci_pain_QC2_trans;
	if c3^=. and c4=.   then group=3;
	if c3^=. and c4^=. and c3 < c4  then group=4;
	if group = . then delete;
run;

proc sort data = Gp_clisci_pain_QC2_trans;
by group;
run;

proc freq data = Gp_clisci_pain_QC2_trans noprint;
table group / out= Gp_clisci_pain_QC2_freq(drop = PERCENT);
run;











*6 analysis covariate between three groups;
*6.1 add covar variable to dataset;
*n54_0_0 (assessment center) without missing value, so use first instance directly;
data popu_ethic_covar;
	set Popu_passqc;
	keep n_eid n_31_0_0 n_54_0_0 n_22009_0_1--n_22009_0_10 n_21022_0_0 n_22000_0_0 n_21001_0_0 n_21001_1_0 n_21001_2_0 n_21001_3_0
	n_816_0_0 n_1558_0_0 n_6138_0_0 n_20116_0_0 n_20117_0_0 n_20126_0_0  n_22032_0_0 n_20487_0_0  n_20488_0_0  n_20489_0_0  n_20490_0_0  n_20491_0_0  n_20494_0_0  n_20495_0_0 
	n_20496_0_0  n_20497_0_0  n_20498_0_0  n_20521_0_0  n_20522_0_0  n_20523_0_0  n_20524_0_0  n_20525_0_0  n_20526_0_0  n_20527_0_0  n_20528_0_0  n_20529_0_0  n_20530_0_0 n_20531_0_0;
run;


proc sql;
create table gp_clisci_popu_temp0 as 
select a.group, b.*
from  Gp_clisci_pain_QC2_trans a ,popu_ethic_covar b
where a. eid = b. n_eid;
quit;


*6.2 check covariate depression;
*find depression in hospital registration;
data popu_ethic_desease;
	set Popu_passqc;
	keep n_eid s_41202: s_41204: s_41270:;
run;

proc sql;
create table popu_ethic_desease_clean as 
select *
from  popu_ethic_desease
where n_eid in (select n_eid from gp_clisci_popu_temp0);
quit;


data depression (Keep=n_eid coding);
  length coding $13;
  set popu_ethic_desease_clean;
  array DA s_41270: s_41202: s_41204:;
  do over DA;
    coding=DA;
	if not Missing (coding);
	output;
  End;
Run;

data depression;
	set depression;
	if substr(coding,1,3) in ('F32','F33');
	dep = "Y";
	keep n_eid dep;
run;

*find depression in GP;
PROC IMPORT  OUT=dep_readv2_code
     DATAFILE  = "G:\Collaboration_project\Sophie project\input\diagnosis\readv2\diagnosis_readv2.txt"
     DBMS  = tab REPLACE;
     GETNAMES = YES;
	 guessingrows = 1000;
RUN;

PROC IMPORT  OUT=dep_readv3_code
     DATAFILE  = "G:\Collaboration_project\Sophie project\input\diagnosis\readv3\diagnosis_readv3.txt"
     DBMS  = tab REPLACE;
     GETNAMES = YES;
	 guessingrows = 1000;
RUN;

proc sort data = dep_readv2_code nodupkey;
by code;
run;

proc sort data = dep_readv3_code nodupkey;
by code;
run;


proc sql;
    create table Gp3_cli_dep as 
    select *
    from gp.Gp_clinical_3
    where read_3 in (select code from dep_readv3_code)
	order by eid,event_dt;
quit;

proc sql;
    create table Gp1_cli_dep as 
    select *
    from gp.Gp_clinical_1
    where read_2 in (select code from dep_readv2_code)
	order by eid,event_dt;
quit;

proc sql;
    create table Gp2_cli_dep as 
    select *
    from gp.Gp_clinical_2
    where read_2 in (select code from dep_readv2_code)
	order by eid,event_dt;
quit;

proc sql;
    create table Gp4_cli_dep as 
    select *
    from gp.Gp_clinical_4
    where read_2 in (select code from dep_readv2_code)
	order by eid,event_dt;
quit;

proc sql;
	create table Gp_cli_dep as
	select *
	from Gp1_cli_dep
	union corr all
	select *
	from Gp2_cli_dep
	union corr all
	select *
	from Gp3_cli_dep
	union corr all
	select *
	from Gp4_cli_dep;
quit;

data Gp_cli_dep(rename= eid = n_eid);
	set Gp_cli_dep;
	dep = "Y";
	keep eid dep;
run;

proc sort data =  Gp_cli_dep nodupkey;
by n_eid;
run;

data popu_gp_dep(rename = n_eid = eid);
	set depression Gp_cli_dep;
	by n_eid;
run;

proc sort data =  popu_gp_dep nodupkey;
by eid;
run;


*select dep from popu_gp_dep;
proc sql;
	create table gp_clisci_popu_temp1(drop = eid) as
	select *
	from gp_clisci_popu_temp0 
	left join popu_gp_dep 
	on gp_clisci_popu_temp0.n_eid = popu_gp_dep.eid;
quit;

data gp_clisci_popu_temp1;
	set gp_clisci_popu_temp1;
	if n_20126_0_0 in (3,4,5) then dep = "Y";
run;

data gp_clisci_popu_temp1;
	set gp_clisci_popu_temp1;
	if dep = "Y" then depression = "Y";
	else depression = "N";
	drop dep;
run;

*6.4 find non-missing BMI and add to data;
*find non-missing BMI in data;
data bmi_temp;
	set popu_passqc;
	if n_21001_0_0 ne . then n_21001 = n_21001_0_0;
	else if  n_21001_1_0 ne . then n_21001 = n_21001_1_0;
	else if  n_21001_2_0 ne . then n_21001 = n_21001_2_0;
	else n_21001 = n_21001_3_0;
	keep n_eid n_21001:;
run;


proc sql;
create table gp_clisci_popu_temp3 as 
select a.*,b.n_21001
from  gp_clisci_popu_temp1 a ,bmi_temp b
where a.n_eid = b. n_eid;
quit;

*6.5 add chip type to data;
data gp_clisci_popu_temp3;
	set gp_clisci_popu_temp3;
	if n_22000_0_0 < 0 then chip_temp ="1000";
	if n_22000_0_0 > 0 then chip_temp ="2000";
run;

*6.7 tidyup other covariate;
data gp_clisci_popu;
	set gp_clisci_popu_temp3;
	*alcohol frequency;
	if n_1558_0_0 in (1,2) then n_1558_0_1 = "more"; 
	else if n_1558_0_0 in (3,4,5,6) then n_1558_0_1 = "less"; 
	else n_1558_0_1 = "";
	*smoking status;
	if n_20116_0_0 in (0,1,2) then n_20116_0_1 = n_20116_0_0; 
	else n_20116_0_1 = .;
	keep group n_eid n_31_0_0 n_54_0_0 n_21022_0_0 n_22009_0_1--n_22009_0_10 n_20117_0_0 depression n_21001 n_1558_0_1
    n_20116_0_1;
run;

*export phenotype data;
proc export data = gp_clisci_popu
outfile = "G:\PhD project PTR UKBiobank\3.input\musskl_phenotype_file\binary phenotype file\binary_phenotype.xlsx" 
dbms = xlsx REPLACE;
run;

proc export data = gp_clisci_popu
outfile = "G:\PhD project PTR UKBiobank\3.input\musskl_phenotype_file\binary phenotype file\binary_phenotype.csv" 
dbms = csv REPLACE;
run;



/*part B: prepare data for LMM*/
PROC IMPORT OUT=binary_phenotype_lmm
DATAFILE  = 'G:\PhD project PTR UKBiobank\3.input\musskl_phenotype_file\binary phenotype file\binary_phenotype.csv'
DBMS = csv REPLACE;
GETNAMES = YES;
RUN;

data binary_pheno_lmm_temp;
	set binary_phenotype_lmm;
	FID = n_eid;
	IID = n_eid;
	if group = 3 then pheno1 = 1;
	else if group = 4 then pheno1 = 2;
	keep FID IID pheno1;
run;

*prepare binary and continuous covar seperately, this should be done;
data binary_covar_lmm;
	set binary_phenotype_lmm;
	FID = n_eid;
	IID = n_eid;
	if n_31_0_0 = 1 then SEX = n_31_0_0;
	else if n_31_0_0 = 0 then SEX = 2;
	CENTER = 'T'||put(n_54_0_0,5.);
	AGE = n_21022_0_0;
	PC1 = n_22009_0_1;
	PC2 = n_22009_0_2;
	PC3 = n_22009_0_3;
	PC4 = n_22009_0_4;
	PC5 = n_22009_0_5;
	PC6 = n_22009_0_6;
	PC7 = n_22009_0_7;
	PC8 = n_22009_0_8;
	PC9 = n_22009_0_9;
	PC10 = n_22009_0_10;
	DEPRESS = depression;
	if n_21001 ne . then BMI = n_21001;
	else delete;
	CHIP = 'T'||put(chip_temp,4.);
	if n_1558_0_1 ne '' then DRINK = n_1558_0_1;
	else delete;
	if n_20116_0_1 = 0 then SMOKE = 'never   ';
	else if n_20116_0_1 = 1 then SMOKE = 'previous';
	else if n_20116_0_1 = 2 then SMOKE = 'current';
	else delete;
	keep FID -- SMOKE;
	drop chip_temp;
run;

data binary_covarb_lmm;
	set binary_covar_lmm;
	keep FID IID SEX CENTER DEPRESS CHIP DRINK SMOKE;
run;


data binary_covarc_lmm;
	set binary_covar_lmm;
	keep FID IID AGE PC1--PC10 BMI;
run;

PROC SQL;
create table binary_pheno_lmm as
select * from binary_pheno_lmm_temp
where fid in (select fid from binary_covar_lmm);
quit;


PROC EXPORT DATA = binary_pheno_lmm
OUTFILE = 'G:\PhD project PTR UKBiobank\3.input\musskl_phenotype_file\binary phenotype file\LMM\binary_pheno_lmm.txt'
DBMS = tab REPLACE;
RUN;


PROC EXPORT DATA = binary_covarb_lmm
OUTFILE = 'G:\PhD project PTR UKBiobank\3.input\musskl_phenotype_file\binary phenotype file\LMM\binary_covarb_lmm.txt'
DBMS = tab REPLACE;
RUN;

PROC EXPORT DATA = binary_covarc_lmm
OUTFILE = 'G:\PhD project PTR UKBiobank\3.input\musskl_phenotype_file\binary phenotype file\LMM\binary_covarc_lmm.txt'
DBMS = tab REPLACE;
RUN;





/*part C: compare prescription data for LMM*/
*total prescription number;
Proc sql;
	create table Gp_clisci_pain_qced as 
	select a.eid,a.event_dt,a.ingredient,a.tag, b.pheno1, count (tag) as pres_n
	from Gp_clisci_pain a, binary_pheno_lmm b
	where a.eid = b.FID
	group by eid;
quit;


proc means data=Gp_clisci_pain_qced noprint;
   class pheno1;
   var pres_n;
   output out=count_total_pres;
run;

PROC EXPORT DATA = count_total_pres
OUTFILE = 'G:\PhD project PTR UKBiobank\4.output\characteristics of prescription\count_total_pres.csv'
DBMS = csv REPLACE;
RUN;


*NSAID prescription number;
Proc sql;
	create table Gp_clisci_pain_qced_nsaid as 
	select a.eid,a.event_dt,a.ingredient,a.tag, b.pheno1, count (tag) as pres_n
	from Gp_clisci_pain a, binary_pheno_lmm b
	where a.eid = b.FID and tag = 1
	group by eid;
quit;

proc means data=Gp_clisci_pain_qced_nsaid noprint;
   class pheno1;
   var pres_n;
   output out=count_total_pres_nsaid;
run;

PROC EXPORT DATA = count_total_pres_nsaid
OUTFILE = 'G:\PhD project PTR UKBiobank\4.output\characteristics of prescription\count_total_pres_nsaid.csv'
DBMS = csv REPLACE;
RUN;

*NSAID prescription duration;
data Gp_clisci_pain_qced_nsaid_dur;
	set Gp_clisci_pain_qced_nsaid;
	by eid;
	retain first_date;
	if first.eid or last.eid;
	if first.eid then first_date = event_dt;
	if last.eid then dur = event_dt - first_date;
	if dur ne .;
run;

proc means data=Gp_clisci_pain_qced_nsaid_dur noprint;
   class pheno1;
   var dur;
   output out=count_total_pres_nsaiddur;
run;

PROC EXPORT DATA = count_total_pres_nsaiddur
OUTFILE = 'G:\PhD project PTR UKBiobank\4.output\characteristics of prescription\Gp_clisci_pain_qced_nsaid_dur.csv'
DBMS = csv REPLACE;
RUN;
