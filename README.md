Existing Process in SAS:

-	Give each transaction a unique key (N) to create the ‘start’ dataset
-	Group up transactions by customer, transaction amount, transaction date.  Count them up (we are only looking to keep non-duplicated transactions).  This creates the ‘counts’ dataset.
-	Identify the DEBITS:
Inner join start with count and start, on cus = cus, tran_amt = tran_amt and tran_date = tran_date
Pull records where the count = 1 and the transaction type = “DEBIT” and the Primary Category is either Transfers / Other r Misc Regular Payments.
-	Identify the CREDITS:
Inner join start with count and start, on cus = cus, tran_amt = tran_amt and tran_date = tran_date
Pull records where the count = 1 and the transaction type = “CREDIT” and the Primary Category is either Transfers / Other r Misc Regular Payments.

Create the ‘Out_Trans’ table, by joining the ‘CREDITS’ table to the ‘DEBITS’ table, on cus = cus, tran_amt = -tran_amt (to get the ‘opposite’ value), primary_category = primary_Category and sub_category = sub_category. Where credits.acc != debits.acc

Join the ‘start’ table to the ‘out_trans’ table.  Where the unique key matches on both tables, then the transaction is labelled as an own Transfer.

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
