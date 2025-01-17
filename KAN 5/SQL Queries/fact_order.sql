SELECT        co.customer_id, b.book_id, co.shipping_method_id,
			  CAST(format(co.order_date, 'yyyy-MM-dd 00:00:00.000') AS Datetime) AS order_date ,
			  co.order_id ,ol.line_id , status_value , ol.price, s.cost
FROM            cust_order AS co LEFT OUTER JOIN
                         order_line AS ol ON co.order_id = ol.order_id LEFT OUTER JOIN
                         book AS b ON ol.book_id = b.book_id LEFT OUTER JOIN
                         shipping_method AS s ON s.method_id = co.shipping_method_id
						 LEFT OUTER JOIN order_history as oh on co.order_id = oh.order_id
						 LEFT OUTER JOIN order_status as os on oh.status_id = os.status_id 
