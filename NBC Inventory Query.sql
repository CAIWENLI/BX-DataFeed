SELECT WW.CustomerName
      ,WW.Isbn
	  ,WW.Condition
	  ,SUM(WW.Quantity) AS Quantity
	  ,AVG(WW.SellPrice) AS SellPrice
	  ,WW.LeadTime
	  ,WW.[TimeStamp]
FROM
(SELECT 'NBC' AS CustomerName
      ,WP.Isbn
	  ,WP.Warehouse
	  ,'New' AS Condition
      ,WP.Inventory AS Quantity
	  ,WP.WP_F AS SellPrice
	  ,7 AS LeadTime
	  ,GETDATE() AS [TimeStamp]
 FROM PROCUREMENTDB.Wholesale.WholesalePriceView WP
 WHERE WP.Warehouse IN ('WSpec', 'AW', 'FBM', 'TR'))WW
 GROUP BY WW.Isbn, WW.CustomerName, WW.Condition, WW.LeadTime, WW.[TimeStamp]

 SELECT * FROM [BookXCenterProduction].[Customer].[SellableInventoryNBC]