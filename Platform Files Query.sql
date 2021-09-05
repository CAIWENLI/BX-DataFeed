--- E-commerce platform pricing and quantities - formatted 
--- Method: right click "Save Results As" csv

--- Create an temp table for inventory table: it has been used by too many users, this will help speed up the query run 
SELECT * INTO #TempIRV FROM BookXCenterProduction.sap.InventoryReportView;

--- TextbookX: inventory 40% 
--- Price: 1.2*((fifo cost + 1.35 + 3.3 - 2.35)/.85)
--- Warehouse: AW + TR + TB + FBM + AWU 
SELECT tt.Isbn AS ISBN
      ,tt.Condition AS Condition
	  ,CAST(tt.Instock AS INT) AS Quantity
	  ,ROUND(CASE WHEN ww.fifo_new IS NULL AND tt.LandedCost <> 0 THEN 0.2*((tt.LandedCost + 1.35 + 3.3 - 2.35)/0.85) 
	              WHEN ww.fifo_new IS NULL AND tt.LandedCost  = 0 THEN CAST(0 AS INT) ELSE 0.2*((ww.fifo_new + 1.35 + 3.3 - 2.35)/0.85) END, 2)AS Price 
	  ,CAST('NEW' AS NVARCHAR) AS [Comment (255 character max)]
	  ,CONCAT(tt.Isbn, '_', UPPER(tt.WhsCode), 'NEW') AS [SKU (255 character max)]
	  ,CAST('a' AS NVARCHAR) AS [Action] 
FROM
(SELECT t1.ItemCode AS Isbn,
	    CASE WHEN t1.OnHand = 1 THEN 1 ELSE t1.OnHand*0.4 END AS Instock,
	    t1.WhsCode AS WhsCode,
		t1.UnitLandedCost AS LandedCost,
	    CAST(6 AS INT) AS Condition
FROM  #TempIRV t1
WHERE t1.WhsCode IN ('AW', 'TR', 'TB', 'FBM', 'AWU')
  AND t1.OnHand > 0)tt
LEFT JOIN (SELECT w.item_no
	             ,w.fifo_new
		   FROM PROCUREMENTDB.Retail.FIFOTotal w)ww
ON tt.Isbn = ww.item_no
WHERE tt.Instock >= 1;


--- Valore: 40% inventory
--- Price: 1.2*((fifo cost + 3.3 - 2.69)/.85)
--- Warehouse: AW + TR + TB + FBM + AWU 
SELECT CAST('A' AS NVARCHAR) AS [add-modify-delete]
      ,CAST(1 AS INT) AS [product-code-type]
	  ,tt.Isbn AS [product-code]
	  ,CONCAT(tt.Isbn, '_', UPPER(tt.WhsCode), 'NEW') AS sku
	  ,ROUND(CASE WHEN ww.fifo_new IS NULL AND tt.LandedCost <> 0 THEN 1.2*((tt.LandedCost + 3.3 - 2.69)/0.85)
	              WHEN ww.fifo_new IS NULL AND tt.LandedCost  = 0 THEN CAST(0 AS INT) ELSE 1.2*((ww.fifo_new + 3.3 - 2.69)/0.85) END, 2)AS price 
	  ,CAST(tt.Instock AS INT) AS quantity
	  ,CAST('NEW' AS NVARCHAR) AS [item-condition]
	  ,CAST('Brand new book. ' AS NVARCHAR) AS [item-note]
FROM
(SELECT t1.ItemCode AS Isbn,
	    CASE WHEN t1.OnHand = 1 THEN 1 ELSE t1.OnHand*0.4 END AS Instock,
	    t1.WhsCode AS WhsCode,
		t1.UnitLandedCost AS LandedCost
FROM  #TempIRV t1
WHERE t1.WhsCode IN ('AW', 'TR', 'TB', 'FBM', 'AWU')
  AND t1.OnHand > 0)tt
LEFT JOIN (SELECT w.item_no
	             ,w.fifo_new
		   FROM PROCUREMENTDB.Retail.FIFOTotal w)ww
ON tt.Isbn = ww.item_no
WHERE tt.Instock >= 1;

--- Listing Mirror: 80% inventory 
--- Price: no price
--- Warehouse: AW + TB + TB2 + 05 + TR + FBM + AWU
SELECT S.Sku AS sku
      ,CAST(I.Instock AS INT) AS MF
FROM 
(SELECT t1.ItemCode AS Isbn,
	    CASE WHEN t1.OnHand = 1 THEN 1 ELSE t1.OnHand*0.8 END AS Instock,
	    t1.WhsCode AS WhsCode
FROM  #TempIRV t1
WHERE t1.WhsCode IN ('AW', 'TR', 'TB', 'FBM', 'AWU', 'TB-2', '05'))I
LEFT JOIN
(SELECT CASE WHEN SellerSku IS NULL THEN SKU ELSE SellerSku END AS Sku
       ,CASE WHEN ISBN IS NULL AND SellerSku LIKE '978%' THEN SUBSTRING(SellerSku, 1, 13) ELSE ISBN END AS Isbn
FROM 
(SELECT CAST(SellerSku AS NVARCHAR(50))  AS SellerSku
       ,CAST(Asin1 AS NVARCHAR(50)) AS AsinNum
  FROM [BookXCenterProduction].[Data].AllListings) Amazon
FULL JOIN 
 (SELECT CAST([AMAZON SKU] AS NVARCHAR(50)) AS SKU
        ,CAST(ISBN AS NVARCHAR(50)) AS ISBN
   FROM PROCUREMENTDB.Retail.SkuListOrg) Org_List
ON Amazon.SellerSku = Org_List.SKU)S
ON I.Isbn = S.Isbn
WHERE I.Instock >= 1;
