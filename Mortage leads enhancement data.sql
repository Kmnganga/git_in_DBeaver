---table 1
insert into tmp.temp1mortgage_cte1
SELECT
	MI_AM_CUST_IDR
--	into  tmp.temp1mortgage_cte1
FROM 
	stg.Am_Daily ad WITH (NOLOCK)
INNER JOIN stg.Cust_Acc_Cross_Ref cacr WITH (NOLOCK) ON
	AD.MI_AM_CUST_IDR = cacr.CDE_CUST
WHERE 
MI_AM_PROD_CDE  in (301,330,10010,10065,10075,10089,10092,394,10004,10005,10006,10103,10104)
and AM_OPEN_DTE > '2021-12-31';

----table 2
SELECT  
	C.MiAmCustomerIdr ,
 	COUNT(A.MI_CDE_ACC_NO) UnpaidCheques
 	into tmp.temp1mortgage_cte2
FROM 
	Stg.Casa_ledger a WITH (NOLOCK)
INNER JOIN ods.FcrDimAccount b WITH (NOLOCK) ON
   	A.MI_CDE_ACC_NO = B.MiAccountNumber AND b.EffectiveEndDate = '3499-12-31'
INNER JOIN ods.FcrAmDaily C WITH (NOLOCK) ON
	B.MiAccountNumber = C.MiAmAccountNumber 
INNER JOIN ods.FcrDimCustomer D WITH (NOLOCK) ON 
	C.MiAmCustomerIdr = D.MiCustCde and d.EffEndDte = '3499-12-31'
Where Txt_txn_desc like '%unpaid%cheque%'
and c.AmOpenDate > '2021-12-31'
GROUP BY C.MiAmCustomerIdr
		   	 
select 
	CustomerCIF,
	crTurnover,
	SUBSTRING(ProductHolding,1,1) ProductHolding ,
	JointMortgages,
	LoansHeldWithOtherBanks,
	ArrearStatus,
	UnpaidChequeStatus,
	CRBStatus,
	SEGMENT 
from tmp.morgageLeads ml WITH (NOLOCK) 
where crTurnover > 1;
/*------------------------------------------------------------------------*/
Insert into tmp.morgageLeads
SELECT top 1000
	fad.MiAmCustomerIdr CustomerCIF 
	,sum(SalAmount) crTurnover 
	,STRING_AGG(cast(PRODUCT_HOLDING_KE as NVARCHAR(MAX)),'; ') ProductHolding 
	,CASE WHEN MI_AM_CUST_IDR IS NULL THEN 'N' ELSE 'Y' END JointMortgages 
	,count(cc.LENDER) LoansHeldWithOtherBanks 
	,CASE WHEN AmDpd > 0 THEN 'Y'  ELSE 'N' END ArrearStatus 
	,count(UnpaidCheques) UnpaidChequeStatus 
	,cs.SCOREGRADE CRBStatus 
	,kcp.SEGMENT 
FROM
	ODS.FcrAmDaily fad WITH (NOLOCK) 
INNER JOIN ODS.FcrDimCustomer fdc WITH (NOLOCK) ON 
	FAD.MiAmCustomerIdr =  fdc.MiCustCde and fdc.EffEndDte = '3499-12-31'
LEFT JOIN DWH.DimProduct dp WITH (NOLOCK) on 
	MiAmProductCode = TRY_CAST(ProductCode AS NUMERIC) and ProductType IN ('RL', 'CL') and dp.EffectiveDateTo = '3499-12-31'
LEFT JOIN ODS.AbsaSalariedCustomer asc2 WITH (NOLOCK) on 
	MiAmCustomerIdr = asc2.CifNumber
LEFT JOIN dwh.KE_CLM_PORTFOLIO_1 kcp WITH (NOLOCK) ON 
	--kcp.CUSTOMER_ID = fad.MiAmCustomerIdr
	kcp.NATIONAL_ID = fdc.CodeCustomerNationalId
	and LOAD_DATE = '2022-04-30' 
LEFT JOIN stg.Conventional_scrub cs WITH (NOLOCK) on
	CS.NATIONALID = fdc.CodeCustomerNationalId
LEFT JOIN stg.Conventional_CRB cc ON
	cc.NATIONALID = fdc.CodeCustomerNationalId
LEFT JOIN tmp.temp1mortgage_cte1 md  ON
	md.MI_AM_CUST_IDR = fad.MiAmCustomerIdr
LEFT JOIN tmp.temp1mortgage_cte2 UC ON
	uc.MiAmCustomerIdr = fad.MiAmCustomerIdr
--WHERE fad.MiAmCustomerIdr = '140000021'
and fad.MiAmAccountBranch in ('094','075')
Group by 
	fad.MiAmCustomerIdr
	,kcp.SEGMENT
	,CASE WHEN AmDpd > 0 THEN 'Y'  ELSE 'N' END 
	,CASE WHEN MI_AM_CUST_IDR IS NULL THEN 'N' ELSE 'Y' END 
	,cs.SCOREGRADE ; 
	
