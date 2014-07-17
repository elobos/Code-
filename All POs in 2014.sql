use AimsTransfer
--TABLES:
--AP_MSTR_SQL E
--GL_MSTR_SQL B
--GL_TRAN_SQL C
--IN_LOC_SQL D
--PO_DETD_SQL A


DECLARE @STARTDATE DATETIME, 
        @ENDDATE   DATETIME; 

SET @STARTDATE = {D '2014-01-01'}; 
SET @ENDDATE = {D '2014-06-30'}; 

SELECT 
	REPORT.[PO #]
	,REPORT.[PO Line #]
	,REPORT.[PO Rec'd #]
	,REPORT.[GL Account #]
	,REPORT.Account
	,REPORT.[GL Account Description]
	,REPORT.Memo
	,REPORT.[PO Description Line 1]
	,REPORT.[PO Description Line 2]
	,REPORT.[PO Description Line 3]
	,REPORT.[Qty Rec'd]
	,REPORT.[U/M]
	,CONVERT(MONEY,REPORT.[Unit Price]) 'Unit Price'
	,CONVERT(MONEY,REPORT.[Total Price]) 'Total Price'
	,CONVERT(VARCHAR, REPORT.[Post Date], 111) 'Post Date'
	,REPORT.Vendor
	,REPORT.Purchaser
	,REPORT.[PO Type]
	,REPORT.[Invoice #]
	,CONVERT(MONEY,REPORT.[AP Invoice Price]) 'AP Invoice Price'
	,CONVERT(MONEY,REPORT.[Amount Paid]) 'Amount Paid'
	,REPORT.Currency
	,REPORT.GLPFLG
	,REPORT.BTCH_NO
FROM
(
SELECT DISTINCT
	A.PO_NUM as 'PO #',
	'' as 'PO Line #',
	A.PO_REC_NUM as 'PO Rec''d #',
	a.ITEM_CODE as 'GL Account #',
	SUBSTRING(A.ITEM_CODE,1,4) as 'Account',
	A.ITEM_CODE AS 'GL Account Description',
	'' as 'Memo',
	ISNULL(A.DESC1,'') as 'PO Description Line 1',
	ISNULL(A.DESC2,'') as 'PO Description Line 2',
	ISNULL(A.DESC3,'') as 'PO Description Line 3',
	A.QTY_RECD as 'Qty Rec''d',
	A.UM_INV as 'U/M',
	A.PRICE as 'Unit Price',
	A.QTY_RECD * PRICE as 'Total Price',
	A.POST_DATE as 'Post Date',
	A.VENDOR as 'Vendor',
	A.PURCHASER as 'Purchaser',
	A.PO_TYPE as 'PO Type',
	A.AP_INV_NUM as 'Invoice #',
	A.AP_INV_PRICE as 'AP Invoice Price',
	A.QTY_RECD * AP_INV_PRICE as 'Amount Paid',
	ISNULL(E.CURRENCY_AP,'') 'Currency',
	'' as 'GLPFLG',
	'' as 'BTCH_NO'
FROM
	PO_DETD_SQL A, GL_MSTR_SQL B, AP_MSTR_SQL E
WHERE
		SUBSTRING(A.ITEM_CODE,1,4) = B.GLACCT
		AND SUBSTRING(A.ITEM_CODE,5,2) = B.GLBRNCH
		AND SUBSTRING(A.ITEM_CODE,7,3) = B.GLCTR
		AND A.VENDOR = E.VENDOR

UNION

SELECT DISTINCT
	'' as 'PO #',
	'' as 'PO Line #',
	'' as 'PO Rec''d #',
	C.GLACCT+C.GLBRNCH+C.GLCTR as 'GL Account #',
	C.GLACCT as 'Account',
	B.ACCT_DESC as 'GL Account Description',
	C.BTCH_MEMO as 'Memo',
	'' as 'PO Description Line 1',
	'' as 'PO Description Line 2',
	'' as 'PO Description Line 3',
	'' as 'Qty Rec''d',
	'' as 'U/M',
	'' as 'Unit Price',
	C.BTCH_AMT as 'Total Price',
	C.BTCH_DATE as 'Post Date',
	'' as 'Vendor',
	'' as 'Purchaser',
	C.BTCH_SRCE as 'PO Type',
	C.BTCH_JOUR as 'Invoice #',
	'' as 'AP Invoice Price',
	C.BTCH_AMT as 'Amount Paid',
	'' 'Currency',
	C.GLPFLG,
	C.BTCH_NO
FROM GL_TRAN_SQL C, GL_MSTR_SQL B
WHERE
	C.GLACCT = B.GLACCT
	AND
	C.GLBRNCH = B.GLBRNCH
	AND
	C.GLCTR = B.GLCTR

UNION

SELECT DISTINCT
	A.PO_NUM as 'PO #',
	'' as 'PO Line #',
	A.PO_REC_NUM as 'PO Rec''d #',
	D.INV_GL 'GL Account #',
	SUBSTRING(D.INV_GL,1,4)'Account',
	B.ACCT_DESC 'GL Account Description',
	'' as 'Memo',
	ISNULL(A.DESC1,'') as 'PO Description Line 1',
	ISNULL(A.DESC2,'') as 'PO Description Line 2',
	ISNULL(A.DESC3,'') as 'PO Description Line 3',
	A.QTY_RECD as 'Qty Rec''d',
	A.UM_INV as 'U/M',
	A.PRICE as 'Unit Price',
	A.QTY_RECD * PRICE as 'Total Price',
	A.POST_DATE as 'Post Date',
	A.VENDOR as 'Vendor',
	A.PURCHASER as 'Purchaser',
	A.PO_TYPE as 'PO Type',
	A.AP_INV_NUM as 'Invoice #',
	A.AP_INV_PRICE as 'AP Invoice Price',
	A.QTY_RECD * AP_INV_PRICE as 'Amount Paid',
	ISNULL(E.CURRENCY_AP,'') 'Currency',
	'' as 'GLPFLG',
	'' as 'BTCH_NO'
FROM
	PO_DETD_SQL A, IN_LOC_SQL D, GL_MSTR_SQL B, AP_MSTR_SQL E
WHERE A.ITEM_CODE = D.ITEM_CODE
AND A.VENDOR = E.VENDOR
AND B.GLACCT+B.GLBRNCH+B.GLCTR = D.INV_GL
AND D.LOCATION = '01'
)
AS REPORT
--WHERE REPORT.[GL Account #] in('765201030','770001010','770001030','770001040','757001030','762801030','765401030','766301030','930201030','941301040','870401030','850301030','807101030','850301010','900401030','845001030','757201030','757301040','757401010','757601030','757701040','764501010','75001020','759001030','835201030','760201030','761380010','761302010','761001030','761001050','760701030','760301040','761101030','78001030','780201050','756401020','785101050','756301010')
--AND
WHERE
	[Post Date] between @STARTDATE and @ENDDATE
--AND [PO Type] IN ('AP-PB','BM-WO','GP','IN-IR','IN-CT','PR-PC','GL-JE','REVER','GP  C','PO-RT','O')
AND [GL Account #] <> [GL Account Description]
ORDER BY [Post Date], [GL Account #], [Invoice #]
