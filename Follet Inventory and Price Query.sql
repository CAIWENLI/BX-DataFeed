--TABLE NAME Customer.SellableInventoryFollet 
SELECT CONVERT(VARCHAR(13), II.Isbn) AS ISBN
      ,CONVERT(DECIMAL(7,0),SUM(Quantity)) AS Quantity
	  ,CONVERT(DECIMAL(7,2),MAX(Listing_Price*0.7)) AS Price
	  ,'New' AS Condition 
	  ,CONVERT(VARCHAR(10), GETDATE(), 101) AS Comments 
FROM
(SELECT I.item_no AS Isbn, SUM(I.instock_inventory) AS Quantity, MAX(I.item_price) AS Fifo FROM PROCUREMENTDB.Retail.InventoryReportView I WHERE I.whse_code IN ('AW', 'TR', 'FBM', 'TB') GROUP BY I.item_no)II
LEFT JOIN (SELECT LP.Isbn AS Isbn_LP, LP.Price AS Listing_Price FROM BookxcenterProduction.isbn.listprice LP WHERE Currency = 'USD')LL ON II.Isbn = LL.Isbn_LP
LEFT JOIN (SELECT F.ISBN, AVG(F.FIFO) AS FIFO FROM PROCUREMENTDB.Retail.FIFO F GROUP BY F.ISBN)FF ON II.Isbn = FF.ISBN
WHERE LL.Listing_Price IS NOT NULL AND FF.FIFO IS NOT NULL AND LL.Listing_Price*0.7  >= FF.FIFO*1.15
GROUP BY II.Isbn;

SELECT * FROM BookXCenterProduction.Customer.SellableInventoryFollet