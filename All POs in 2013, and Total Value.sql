USE AimsTransfer

SELECT DISTINCT pds.PO_NUM
FROM dbo.PO_DETD_SQL pds
WHERE YEAR(pds.POST_DATE) = 2013

SELECT CONVERT(MONEY,SUM(pds.PRICE* pds.QTY_RECD))
FROM dbo.PO_DETD_SQL pds
WHERE YEAR(pds.POST_DATE) = 2013