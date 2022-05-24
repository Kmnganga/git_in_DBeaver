
SELECT
	fad.MiAmCustomerIdr CustomerCIF,
--	fad.MiAmAccountNumber FCRaccount,
	STRING_AGG(cast(PRODUCT_HOLDING_KE as NVARCHAR(MAX)),'; ') ProductHolding,
	kcp.SEGMENT ,
	SCOREGRADE CRBStatus,
	PERFORMING,
	count(distinct MiAmProductCode) loansheld,
	sum(SalAmount) crTurnover
FROM
	ODS.FcrAmDaily fad
INNER JOIN ODS.FcrDimCustomer fdc ON FAD.MiAmCustomerIdr =  fdc.MiCustCde and fdc.EffEndDte = '3499-12-31'
LEFT JOIN DWH.DimProduct dp on 	MiAmProductCode = TRY_CAST(ProductCode AS NUMERIC) and ProductType IN ('RL', 'CL') and dp.EffectiveDateTo = '3499-12-31'
LEFT JOIN ODS.AbsaSalariedCustomer asc2 on MiAmCustomerIdr = asc2.CifNumber
LEFT JOIN dwh.KE_CLM_PORTFOLIO_1 kcp ON kcp.CUSTOMER_ID = fad.MiAmCustomerIdr  and LOAD_DATE = '2022-04-30'
LEFT JOIN stg.Conventional_scrub cs on CS.NATIONALID = fdc.CodeCustomerNationalId
Group by fad.MiAmCustomerIdr,kcp.SEGMENT,SCOREGRADE,PERFORMING  ;

SELECT 
	fad.MiAmCustomerIdr 
FROM ODS.FcrAmDaily fad 
INNER JOIN ODS.FcrDimCustomer fdc ON
	fad.MiAmCustomerIdr = fdc.MiCustCde 
;

SELECT max(Filedate) FROM stg.Conventional_scrub ;

SELECT
	fad.MiAmCustomerIdr CustomerCIF ,
--	STRING_AGG(cast(PRODUCT_HOLDING_KE as NVARCHAR(MAX)),'; ') ProductHolding
	sum(SalAmount) crTurnover
FROM
	ODS.FcrAmDaily fad
INNER JOIN ODS.FcrDimCustomer fdc ON FAD.MiAmCustomerIdr =  fdc.MiCustCde and fdc.EffEndDte = '3499-12-31'
LEFT JOIN DWH.DimProduct dp on 	MiAmProductCode = TRY_CAST(ProductCode AS NUMERIC) and ProductType IN ('RL', 'CL') and dp.EffectiveDateTo = '3499-12-31'
LEFT JOIN ODS.AbsaSalariedCustomer asc2 on MiAmCustomerIdr = asc2.CifNumber
group by 	fad.MiAmCustomerIdr
;