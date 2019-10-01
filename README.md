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
