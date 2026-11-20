create view pareto_analysis as(WITH category_revenue AS (
         SELECT COALESCE(pc.product_category_name_english, p.product_category_name, 'unknown') AS category,
            sum(oi.price) AS revenue
           FROM orders o
             JOIN order_items oi ON o.order_id = oi.order_id
             JOIN products p ON oi.product_id = p.product_id
             LEFT JOIN product_category_english pc ON pc.product_category_name = p.product_category_name
			 where o.order_status='delivered' 
			 AND o.order_purchase_timestamp >='2017-01-01'
			 AND o.order_purchase_timestamp <'2019-01-01'
          GROUP BY (COALESCE(pc.product_category_name_english, p.product_category_name, 'unknown'))
        ), 
		category_revenue_metrics AS (
         SELECT category,
            revenue,
            revenue / sum(revenue) OVER () AS pct_total_revenue,
            sum(revenue) OVER (ORDER BY revenue DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_revenue
           FROM category_revenue
        )
 SELECT category,
    revenue,
    pct_total_revenue,
    cumulative_revenue,
    cumulative_revenue / sum(revenue) OVER () AS pct_cumulative
   FROM category_revenue_metrics
   ORDER BY revenue DESC);