
options symbolgen;

/********************************************************************/
/*  Code to create Transactional Data Input 						*/
/*  Version:	1.0													*/
/*  Author: 	Matt Broom											*/
/*  Inputs:		Categorised Transactional Data from Account Score	*/
/* 	Outputs:	Input for transactional data chars 					*/	
/********************************************************************/

/********************************************************************/
/*							INSTRUCTIONS							*/
/********************************************************************/

/********************************************************************************************************************************************************/
/*  																																					*/
/* - This code is used to prepare data for the production of the transaction chars. 																	*/
/*  																																					*/
/* - If an application date is available this should be used to drive the month counts on the chars process.   											*/
/*  																																					*/
/* - If there isn't a date provided one will need to be created on a per application basis. 		  													*/
/*   How it is created depends on the number of months of data available: 																				*/
/*   																																					*/
/* 	a) If there are 12 months set the retro date to the first of then month after the latest available transaction date.  Month 0 will be unpopulated. 	*/
/* 	b) If there are 13+ months then set the retro date to the last day of the latest available month. 													*/
/* 	 																																					*/
/* - Variables need to be renamed as listed below for the rest of the process to work correctly. 														*/
/* 	 																																					*/
/*	INSTRUCTIONS:																																		*/
/* 	 																																					*/
/* 	1) Change libname statements and input & output table names. 																						*/
/* 	2) Review the data using print.  Change macros to indicate whether there are joint account & primary/secondary applicant flags and retro dates.		*/
/* 	3) Change the macros for the rename statments.  This will ensure the char code will run correctly. 													*/
/* 	 																																					*/
/********************************************************************************************************************************************************/

/************************************************************************/
/* Transaction Data Char Code File Needs the following variables to run	*/
/************************************************************************/
/*																		*/
/*	Retro_Date	Retro (Application) Date								*/
/*																		*/
/*	ID			Application / Person Identifer							*/
/*																		*/
/*	ACC 		Account Number (Used for Account Level Output)			*/
/*																		*/
/*  JNT_SOLE	Identifies if accounts are joint or sole				*/
/*																		*/
/*  PRIM_SEC	Identifies if applicant is main or secondary			*/
/*																		*/
/*	Outref		Equifax Outref											*/
/*																		*/
/*	Tran_Date	Transaction Date										*/
/*																		*/
/*	Tran_Amt	Transaction Amount										*/
/*																		*/
/*	Tran_Desc	Transaction Description									*/
/*																		*/
/*	Tran_Type	Transaction Type Debit/Credit identifier				*/
/*																		*/
/*	Prim_Cat	Account Score Primary Category							*/
/*																		*/
/*	Sub_Cat		Account Score Sub Category								*/
/*																		*/
/*	Vend_Desc	Account Score Vendor Description						*/
/*																		*/
/************************************************************************/

libname Input  '/encrypted_data3/10_PROJECTS/10_PRJs/prj01886/05_From_AccountScore/';    	/* Libname for the Transactional Data */

%let Input = RBS_Consumerbatch3_Seg2;														/* Name of the input Transactional Data */	

libname Output '/encrypted_data1/10_PROJECTS/21_PDLC_PROGS/MBRO-TRAACT/SJ_TEST/DATA'; 		/* Libname for the output prepped data */

%let Output = RBS_Seg2_Prepped_Test2;															/* Name of the output prepped Transactional Data */

/* proc export data = Output.RBS_Seg2_Prepped_Test outfile = '/encrypted_data1/10_PROJECTS/21_PDLC_PROGS/MBRO-TRAACT/SJ_TEST/DATA/OT_Test.csv'; */
/* run; */

/******************************/
/* Printing to review columns */
/******************************/

proc print data = Input.&Input. (obs = 10);
run;

proc freq data = Input.&Input.;
tables Applic_Date;
run;

/*************************************************************************************************************************/
/* Is there a main/secondary applicant indicator?  If not the first applicant listed will be assigned the main applicant */ 
/*************************************************************************************************************************/

	%let PRIM_SEC_IND = Y;								/* Main/Secondary Applicant Flag Indicator.  If this is in the data then Y else N */
	%let PRIM_SEC = CIN_M_OR_J;							/* If the above is Y what is the Main/Secondary applicant identifier variable.  If N then leave as CIN_M_OR_J */
	%let PRIM_IND = "M";								/* If flag is supplied, what is the code for the main applicant.  Use quotes if character.  If this is not in the data then leave as it is. */

	%let JS_IND = N;									/* Joint Sole Account Flag Indicator.  If this is in the data then Y else N */
	%let JNT_SOLE = JNT_SOLE;							/* If the above is Y what is the Sole/Joint account identifier variable.  If N then leave as JNT_SOLE */
	%let SOLE_IND = "S";								/* If flag is supplied, what is the code for the a sole account */
	
	%let APPDATE_IND = Y;								/* Application Date Indicator. If this is in the data then Y else N */	

	
/************************************************************************************/
/* Is there an MCC Code? Update this section to run the MCC Enhanced Categorisation */
/************************************************************************************/

	%let MCC_ENHNC = N;									/* MCC Enhance - if you want Categorisation enhanced using MCC then Y else N */						
	%let MCC_IND = N;									/* MCC Indicator.  If this is in the data then Y else N */
	%let MCC = Merchant_MCC;							/* If MCC is present what is it called */

/*************************************/
/* Is balance and/or limit provided? */
/*************************************/

	%let BAL_IND = N;									/* If this is in the data then Y else N */
	%let LIM_IND = N;									/* If this is in the data then Y else N */
	
	
/********************************************************************************************************************************************/
/* Is there a transaction ID?  If not transaction date will be used to identify the order of transactions.  PLEASE NOT THIS MUST BE NUMERIC */
/********************************************************************************************************************************************/

	%let TRID_IND = N;									/* If this is in the data then Y else N */


/*******************************************************************************************************************************/
/* Macro for renaming Chars to Fit List Above - CHANGE THE SECOND ONE.  If any are not in the data then leave them as they are */
/*******************************************************************************************************************************/

	%let Retro_Date = Applic_Date;						/* Application / 'Retro' Date.  If this isn't in the data leave it as Retro_Date.  THIS MUST BE IN SAS DATE FORMAT (i.e. numeric) */
	
	%let APP = ZZ_APP_ID;								/* Application ID */

	%let CUS = ZZ_CIN_ID;								/* Customer ID */
	
	%let ACC = ZZ_ACCT_ID;  							/* Account ID */
	
	%let Tran_Date = Transaction_Date;							/* Transaction Date.  THIS MUST BE IN SAS DATE FORMAT (i.e. numeric) */
	
	%let Tran_Amt = Transaction_Amount;								/* Transaction Amount */
	
	%let Tran_Desc = Transaction_Description2;						/* Transaction Description */
	
	%let Tran_Type = Deb_Cred_Flag;					/* Transaction Type Debit/Credit identifier */
	
	%let Prim_Cat = PrimaryCategoryDescription;			/* Account Score Primary Category */
	
	%let Sub_Cat = SubCategoryDescription;				/* Account Score Sub Category */
	
	%let Vend_Desc = VendorDescription;					/* Account Score Vendor Description */
	
	%let Bal = Balance;									/* Account Balance Field */

	%let Lim = Limit;									/* Account Balance Field */
	
	%let TRID = TransactionID;							/* Transaction ID */


/********************************************************************************************************************************************************************/
/* 													DO NOT CHANGE ANY CODE BELOW THIS LINE																			*/
/********************************************************************************************************************************************************************/

	%let Outref = Outref;								/* Equifax Outref.  LEAVE THIS ONE AS IS */


%macro Apps;

%if %upcase (&APPDATE_IND.) ^= Y %then %do;

proc sql;
create table Months_Of_Data as
select &APP. as APP, min(&Tran_Date.) as Min format = date9., max(&Tran_Date.) as Max format = date9., (intck('month', min(&Tran_Date.), max(&Tran_Date.)) + 1) as Num_Months,
case when (calculated Num_Months >= 13) then 1 else 0 end as Months_13, case when (calculated Num_Months <= 12) then 1 else 0 end as Months_12
from Input.&Input.
group by 1;
quit;

proc sql;
select (sum(Months_12)/count (*))*100, (sum(Months_13)/count (*))*100 into :Perc_12, :Perc_13
from Months_Of_Data;
quit;

%if &Perc_12. > 70 %then %do;

proc sql;
create table Retro_Date as 
select &APP as APP, max(&Tran_Date.) as Max_Date format = date9., intnx('month', max(&Tran_Date.), 1, 'b') as Retro_Date format = date9.
from Input.&Input.
group by 1;
quit;

proc sql;
create table With_Retro as
select a.*, b.Retro_Date
from INput.&Input. as a
left join Retro_Date as b
on a.&APP. = b.APP;
quit;

%end;

%if &Perc_13. > 70 %then %do;

proc sql;
create table Retro_Date as 
select &APP as APP, max(&Tran_Date.) as Max_Date format = date9., intnx('month', max(&Tran_Date.), 0, 'e') as Retro_Date format = date9.
from Input.&Input.
group by 1;
quit;

proc sql;
create table With_Retro as
select a.*, b.Retro_Date
from INput.&Input. as a
left join Retro_Date as b
on a.&APP. = b.APP;
quit;

%end;

%end;

%else %if %upcase (&APPDATE_IND.) = Y %then %do;

data With_Retro;
set Input.&INput.;
run;

%end;

%mend;

%Apps;


/*******************************************************************/
/* Code to determine main/second applicant where flag not provided */
/*******************************************************************/

%macro Main;

%if %upcase(&PRIM_SEC_IND.) ^= Y %then %do;

proc sql;
create table Prim_Sec_Cust as
select distinct &APP. as APP, &CUS. as CUS
from Input.&Input.;
quit;

data Prim_Sec_Cust;
set Prim_Sec_Cust;
by APP;
retain Cus_Num;
Cus_Num + 1;
if first.APP then Cus_Num = 1;
run;

data Prim_Sec_Cust (keep = APP CUS &PRIM_SEC.);
set Prim_Sec_Cust;
if Cus_Num = 1 then &PRIM_SEC. = "P";
else if Cus_Num = 2 then &PRIM_SEC. = "S";
run;


proc sql;
create table Input_Main_Jnt as
select a.*, b.&PRIM_SEC.
from 
With_Retro as a 
left join
Prim_Sec_Cust as b
on a.&APP. = b.APP
and a.&CUS. = b.CUS;
quit;

%end;

%else %if %upcase(&PRIM_SEC_IND.) = Y %then %do;

data Input_Main_Jnt (drop = &PRIM_SEC. rename = (&PRIM_SEC._1 = &PRIM_SEC.));
set With_Retro;
if &PRIM_SEC. = &PRIM_IND. then &PRIM_SEC._1 = "P";
else &PRIM_SEC._1 = "S";
run;

%end;

%mend;

%Main;

/*******************************************************************/
/*  Code to determine sole/joint accounts where flag not provided  */
/*******************************************************************/

%macro SolJnt;

%if %upcase(&JS_IND.) ^= Y %then %do;

proc sql;
create table Jnt_Sol_Acc as
select &ACC. as ACC, count (distinct &CUS.) as Cust_Count
from Input.&Input.
group by 1;
quit;

data Jnt_Sol_Acc;
set Jnt_Sol_Acc;
if Cust_Count = 1 then &JNT_SOLE. = "S";
else if Cust_Count = 2 then &JNT_SOLE. = "J";
run;

proc sql;
create table Input_Jnt_Sol as
select a.*, b.&JNT_SOLE.
from 
Input_Main_Jnt as a 
left join
Jnt_Sol_Acc as b
on a.&ACC. = b.ACC;
quit;

%end;

%else %if %upcase(&JS_IND.) = Y %then %do;

data Input_Jnt_Sol (drop = &JNT_SOLE. rename = (&JNT_SOLE._1 = &JNT_SOLE.));
set Input_Main_Jnt;
if &JNT_SOLE. = &SOLE_IND. then &JNT_SOLE._1 = "S";
else &JNT_SOLE._1 = "J";
run;

%end;

%mend;

%SolJnt;


/**********************************************************/
/* Enhancing Categorisation & MCC Enhanced Categorisation */
/**********************************************************/

/* Own Transfer Overwrite */


* Append Unique Key with _N_;
data start;
set Input_Jnt_Sol;
owntranskey = _N_;

run;

proc sql;
* Find counts to keep only non duplicated transactions;
create table counts as 
select &CUS., &TRAN_AMT., &TRAN_DATE., count(*) as cnt
from start
group by &CUS., &TRAN_AMT., &TRAN_DATE.
;
quit;

proc sql;
create table debits as 
select a.*
from start a 
inner join counts b 
on a.&CUS. = b.&CUS. and 
   a.&TRAN_AMT. =b.&TRAN_AMT. and 
   a.&TRAN_DATE. = b.&TRAN_DATE.
where upper(a.&TRAN_TYPE.) = 'DEBIT' and (upcase(a.&PRIM_CAT.) in ("TRANSFERS / OTHER", "MISC REGULAR PAYMENTS"))
	  and b.cnt=1
;
quit;

proc sql;
create table credits as 
select a.*
from start a 
inner join counts b 
on a.&CUS.=b.&CUS. and 
   a.&TRAN_AMT.=b.&TRAN_AMT. and 
   a.&TRAN_DATE.=b.&TRAN_DATE.
where upper(a.&TRAN_TYPE.) = 'CREDIT' and (upcase(a.&PRIM_CAT.) in ("TRANSFERS / OTHER", "MISC REGULAR PAYMENTS")) and 
      b.cnt=1
;
quit;

* Find own transfers by inner join on credits and debits;
proc sql;
create table Out_Trans as 
select a.&CUS., a.&ACC. as &ACC.t1, b.&ACC. as &ACC.t2,
	a.&TRAN_AMT., a.&TRAN_DATE.,
	a.&TRAN_DESC. as desc1, b.&TRAN_DESC. as desc2,
	a.&PRIM_CAT. as prim1, b.&PRIM_CAT. as prim2,
	a.&SUB_CAT. as sub1, b.&SUB_CAT. as sub2,
	a.owntranskey as id1, b.owntranskey as id2
from credits a
inner join debits b 
on a.&CUS. = b.&CUS. and 
   a.&TRAN_AMT.=-b.&TRAN_AMT. and 
   a.&TRAN_DATE. = b.&TRAN_DATE.
where a.&ACC. ne b.&ACC. and 
      a.&TRAN_AMT. > 0
;
quit;

* Use appended unique key to overwrite specific rows in original dataset;
proc sql;
create table EFX_ENHANCED_OT as
select a.*,
    case when a.owntranskey = b.owntranskey
      then 1 else 0 end as ot_flag,
    case when a.owntranskey = b.owntranskey /*and (a.&PRIM_CAT. in ("TRANSFERS / OTHER", "MISC REGULAR PAYMENTS"))*/
      then 'OWN TRANSFER' else &PRIM_CAT. end as EFX_PRIM_CAT format = $50.,
    case when a.owntranskey = b.owntranskey  /*and (a.&PRIM_CAT. in ("TRANSFERS / OTHER", "MISC REGULAR PAYMENTS"))*/
      then '' else &SUB_CAT. end as EFX_SUB_CAT format = $50.,
    case when a.owntranskey = b.owntranskey  /*and (a.&PRIM_CAT. in ("TRANSFERS / OTHER", "MISC REGULAR PAYMENTS"))*/
      then '' else &VEND_DESC. end as EFX_VEND_DESC format = $50.
from start a
left join (
	select distinct id1 as owntranskey
	from Out_Trans
	union all
	select distinct id2 as owntranskey
	from Out_Trans
) b
on a.owntranskey = b.owntranskey
;
quit;

/* data OT; */
/* set EFX_ENHANCED_OT; */
/* where EFX_PRIM_CAT = "OWN TRANSFER"; */
/* run; */
/*  */
/* proc sort data = OT; */
/* by ZZ_APP_ID &TRan_Date.; */
/* run; */

/* CRA Overwrite */

data EFX_ENHANCED_CR;
set EFX_ENHANCED_OT;

   length EFX_PRIM_CAT EFX_SUB_CAT EFX_VEND_DESC $50;
   
   if UPCASE(&Tran_Type.) = 'DEBIT' and index(compress(upcase(&Tran_Desc.)," "),"CALLCRED")>0 then do;
     EFX_PRIM_CAT = 'SERVICES';
     EFX_SUB_CAT = 'BUDGETING AND CREDIT REPORTING SERVICES';
   end;
   
   else if UPCASE(&Tran_Type.) = 'DEBIT' and index(compress(upcase(&Tran_Desc.)," "),"EQUIFAX")>0 then do;
     EFX_PRIM_CAT = 'SERVICES';
     EFX_SUB_CAT = 'BUDGETING AND CREDIT REPORTING SERVICES';
   end;
   
   else if UPCASE(&Tran_Type.) = 'DEBIT' and index(compress(upcase(&Tran_Desc.)," "),"EXPERIAN")>0 then do;
     EFX_PRIM_CAT = 'SERVICES';
     EFX_SUB_CAT = 'BUDGETING AND CREDIT REPORTING SERVICES';
   end;
 
 /* Foreign Currency Fees, Shares and Child Benefit */
	

	else if prxmatch ("m/SHARE DEALING|SHAREDEALING|ORDINARY SHARE|ORD SHARE|SHARES|DIVD|DIVIDEN/oi", &Tran_Desc.)
	then EFX_PRIM_CAT = "SHARE DEALING";
			
	else if prxmatch ("m/DWP CHILD/oi", &Tran_Desc.)
	then EFX_Prim_Cat = "CHILD BENEFIT";
 
 
run;

/********************************/   
/* MCC Enchanced Categorisation */
/********************************/

%Macro MCC;

%if %upcase(&MCC_ENHNC.) = Y %then %do;

libname MCC_Fmt "/encrypted_data3/10_PROJECTS/10_PRJs/prj01886/12_Ali";

/* Create var mcc_1 to include some specific cases */

data MCC_ds_v1;
set EFX_ENHANCED_CR;

if &MCC. = "5968" and index(compress(&TRAN_DESC.," "),"NETFLIX")>0 then MCC_1 = "5968-NEFLIX";
else if &MCC. = "5968" then MCC_1="5968-Misc";

if &MCC. = "7392" and index(compress(&TRAN_DESC.," "),"TVLICENSING")>0 then MCC_1 = "7392-TV";
else if &MCC. = "7392" then MCC_1 = "7392-Misc";

if &MCC. = "9311" and index(compress(&TRAN_DESC.," "),"LONDONROADCARPK")>0 then MCC_1 = "9311-CarPk";

if &MCC. = "5122" and index(compress(&TRAN_DESC.," "),"NATIONALVETERINAR")>0 then MCC_1 = "5122-Vet";

if &MCC. = "5965" and (index(compress(&TRAN_DESC.," "),"VIRGINWINES")>0 or index(compress(&TRAN_DESC.," "),"WHSMITH")>0) then MCC_1 = "5965-Supermkt";
if &MCC. = "5965" and index(compress(&TRAN_DESC.," "),"HERBALIFE")>0 then MCC_1 = "5965-Health";
if &MCC. = "5965" and index(compress(&TRAN_DESC.," "),"WAYFAIR")>0 then MCC_1 = "5965-Home";

if &MCC. = "5331" and (index(compress(&TRAN_DESC.," "),"HOMESENSE")>0 or index(compress(&TRAN_DESC.," "),"YORKSHIRETRADING")>0) then MCC_1 = "5331-Home";

if &MCC. = "5722" and index(compress(&TRAN_DESC.," "),"BRIGHTHOUSE")>0 then MCC_1 = "5722-FinancSer";

if &MCC. = "5969" and (index(compress(&TRAN_DESC.," "),"CREDITEXPERT")>0 or index(compress(&TRAN_DESC.," "),"EXPERIAN")>0) then MCC_1 = "5969-Misc";
if &MCC. = "5969" and index(compress(&TRAN_DESC.," "),"BRITISHGAS")>0 then MCC_1 = "5969-Utilities";
if &MCC. = "5969" and index(compress(&TRAN_DESC.," "),"ALLIANZINSURANCE")>0 then MCC_1 = "5969-Insurance";

if &MCC. = "7929" and (index(compress(&TRAN_DESC.," "),"MYPROTEIN")>0 or index(compress(&TRAN_DESC.," "),"LOOKFANTASTIC")>0) then MCC_1 = "7929-Health";

if 3000< = &MCC.*1< = 3999 then MCC_1 = "3000-3999";

else MCC_1 = &MCC.;
run;


/*Creates MCC_Plus and MCC_AS variables using the formats*/

data MCC_ds_v2;
   set MCC_ds_v1;
   options fmtsearch=(MCC_FMT.MCC_FMT);
   MCC_Plus=put(MCC_1,$MCC_Plus.);
   
   options fmtsearch=(MCC_FMT.MCC_AS_FMT);
   MCC_AS=put(&MCC.,$MCC_AS.);
   
   options fmtsearch=(MCC_FMT.MCC_Lable_FMT);
   MCC_Label=put(&MCC,$MCC_Label.);
run;

/*create primary and subcategories from the variable MCC_AS*/

data MCC_AS_TRIAL;
   set MCC_ds_v2;
   length PrimaryCategory_MCC_AS SubCategory_MCC_AS $50;
   PrimaryCategory_MCC_AS=scan(MCC_AS,1,"|");
   SubCategory_MCC_AS=scan(MCC_AS,2,"|");
run;


/*Create the enhanced categorisation*/

data MCC_Enhanced;
   set MCC_AS_TRIAL ;

   if UPCASE(&Tran_Type.) = 'DEBIT' and upcase(&prim_cat) = 'MISC CARD SPEND' then do;
       
       if PrimaryCategory_MCC_AS  =  'Unavailable MCC code' then do;
        EFX_PRIM_CAT = &prim_cat;
        EFX_SUB_CAT = &sub_cat;
       end;
       
       else if &MCC. = "7273" then do;
        EFX_PRIM_CAT = &prim_cat;
        EFX_SUB_CAT = &sub_cat;
       end;
       
       else if &MCC. = "7297" then do;
        EFX_PRIM_CAT = &prim_cat;
        EFX_SUB_CAT = &sub_cat;
       end;
       
       else if &MCC. = "6012" and index(compress(upcase(&Tran_Desc.)," "),"COLLEC")>0   then do;
        EFX_PRIM_CAT = "FINANCIAL SERVICES";
        EFX_SUB_CAT = "DEBT COLLECTION";
       end;
       
       else if &MCC. = "6012" and index(compress(upcase(&Tran_Desc.)," "),"RECOV")>0  then do;
        EFX_PRIM_CAT = "FINANCIAL SERVICES";
        EFX_SUB_CAT = "DEBT MANAGEMENT";
       end;  
       
       else if &MCC. = "8351" and index(compress(upcase(&Tran_Desc.)," "),"FUNWORLD")>0 then do;
        EFX_PRIM_CAT = "ENTERTAINMENT";
        EFX_SUB_CAT = "GENERAL ENTERTAINMENT";
       end;
       
       else if &MCC. = "8351" and index(compress(upcase(&Tran_Desc.)," "),"UNIVERSALSTUDIOS")>0  then do;
        EFX_PRIM_CAT = "ENTERTAINMENT";
        EFX_SUB_CAT = "GENERAL ENTERTAINMENT";
       end;
       
       else do;
        EFX_PRIM_CAT = PrimaryCategory_MCC_AS;
        EFX_SUB_CAT = SubCategory_MCC_AS;
       end;
     end;  
              
   else do;
     EFX_PRIM_CAT = &PRIM_CAT.;
     EFX_SUB_CAT = &SUB_CAT.;
     EFX_VEND_DESC = &VEND_DESC.;
   end;
 
run;  

%end;

%else %if %upcase (&MCC_ENHNC.) ^= Y %then %do;

data MCC_Enhanced;
set EFX_ENHANCED_CR;
run;

%end;

%mend;

%MCC;


/******************************************************/
/* Code to rename variable and create additional ones */
/******************************************************/

data Output.&Output.

(rename = (

&Retro_Date. = Retro_Date
	
&APP. = APP

&CUS. = CUS
	
&ACC. = ACC
	
&JNT_SOLE. = JNT_SOLE
	
&PRIM_SEC. = PRIM_SEC
	
&Outref. = Outref
	
&Tran_Date. = Tran_Date
	
&Tran_Amt. = Tran_Amt
	
&Tran_Desc. = Tran_Desc
	
&Tran_Type. = Tran_Type
	
&Prim_Cat. = Prim_Cat
	
&Sub_Cat. = Sub_Cat
	
&Vend_Desc. = Vend_Desc

%if %upcase (&BAL_IND.) = Y %then %do;

&Bal. = BAL

%end;

%if %upcase (&LIM_IND.) = Y %then %do;

&Lim. = LIM

%end;

%if %upcase (&TRID_IND.) = Y %then %do;

&Trid. = TRID

%end;

));

set MCC_Enhanced;

/* Upcasing the categories and vendors */

	&Prim_Cat. = Upcase(&Prim_Cat.);
	&Sub_Cat. = Upcase(&Sub_Cat.);
	&Vend_Desc. = Upcase(&Vend_Desc.);
	&Tran_Type. = Upcase(&Tran_Type.);
	
	EFX_PRIM_CAT = upcase(EFX_PRIM_CAT);
	EFX_SUB_CAT = upcase(EFX_SUB_CAT);
	EFX_VEND_DESC = upcase(EFX_VEND_DESC);
	
/* Making Debits Negative */

	if upcase(&Tran_Type.) = "DEBIT" and &Tran_Amt. > 0 then do;
		&Tran_Amt. = -&Tran_Amt.;
	end;
	
/* Macro to create Outref */	

if (&PRIM_SEC.) = "P" then do;
Outref = strip(&APP.)||"11";
end;

else if (&PRIM_SEC.) = "S" then do;
Outref = strip(&APP.)||"21";
end;

run;



