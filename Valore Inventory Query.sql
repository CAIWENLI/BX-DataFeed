--- Valore: 40% inventory
--- Price: 1.2*((fifo cost + 3.3 - 2.69)/.85)
--- Warehouse: AW + TR + TB + FBM
USE BookXCenterProduction;
---- BookXCenterProduction.Customer.SellableInventoryValore 
SELECT CAST('A' AS VARCHAR) AS [add-modify-delete]
      ,CAST(1 AS VARCHAR) AS [product-code-type]
	  ,tt.item_no AS [product-code]
	  ,CONCAT(tt.item_no, '_', UPPER(tt.whse_code), 'NEW') AS sku
	  ,CAST(ROUND(CASE WHEN tt.item_price <> 0 THEN 1.2*((tt.item_price + 3.3 - 2.69)/0.85) ELSE 0 END,2) AS INT) AS price 
	  ,CAST(tt.instock AS INT) AS quantity
	  ,CAST('NEW' AS VARCHAR) AS [item-condition]
	  ,CAST('Brand new book. ' AS VARCHAR) AS [item-note]
FROM
(SELECT t.item_no, t.instock_inventory*0.4 AS instock, t.whse_code, t.item_price FROM PROCUREMENTDB.Retail.InventoryReportView t)tt
WHERE tt.instock >= 1 AND tt.item_price <> 0 AND whse_code NOT IN ('PPE', 'FBA_AW', 'FBA_TR', 'WSpec', 'AWU', 'TB-2');

  
