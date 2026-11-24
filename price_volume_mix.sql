create or replace view price_volume_mix as WITH yearly_data AS (SELECT EXTRACT (year FROM o.order_purchase_timestamp) AS o_year,
							EXTRACT(month FROM o.order_purchase_timestamp) AS o_month,
							COALESCE (pc.product_category_name_english,p.product_category_name,'unknown') AS category,
							sum(oi.price) AS revenue, count(oi.order_item_id) AS qty,
							sum(oi.price)/nullif(count(oi.order_item_id),0) AS avg_price
						FROM orders o 
						JOIN order_items oi 
							ON o.order_id=oi.order_id 
						JOIN products p 
							ON oi.product_id=p.product_id
						left JOIN product_category_english pc
							ON p.product_category_name=pc.product_category_name
						WHERE o.order_status='delivered' 
						AND o.order_purchase_timestamp >='2017-01-01'
						AND o.order_purchase_timestamp<'2019-01-01' 
						AND EXTRACT(month FROM o.order_purchase_timestamp) <=8
						
						GROUP BY EXTRACT(year from o.order_purchase_timestamp),
						EXTRACT(month from o.order_purchase_timestamp),
						COALESCE (pc.product_category_name_english,p.product_category_name,'unknown')
						),
				joined as(SELECT 2018 as o_year,
					COALESCE(c.o_month,p.o_month) AS o_month,
					COALESCE(c.category,p.category) AS category,
					c.revenue as revenue,c.avg_price AS price,c.qty AS qty,
					p.revenue as prev_revenue,p.avg_price AS prev_price, p.qty AS prev_qty
					FROM (SELECT * from yearly_data where o_year=2018)c
					FULL JOIN (SELECT * FROM yearly_data where o_year=2017)p
					ON c.category=p.category and c.o_month=p.o_month),
				total_qty  AS (SELECT o_month,sum(qty) AS monthly_qty,
						sum(prev_qty) AS prev_monthly_qty
						FROM joined
						where qty is not null and prev_qty is not null
						GROUP BY o_month), 
						
						joined_2 as(select j.*, (j.prev_qty::NUMERIC/nullif(tq.prev_monthly_qty,0))* monthly_qty AS expected_qty  from joined j 
						LEFT JOIN total_qty tq
							ON j.o_month=tq.o_month),
				effects AS (SELECT j.o_year,
							j.o_month,category,
							j.price,
							j.prev_price,
							j.revenue,
							j.prev_revenue,
							j.qty,
							j.prev_qty,
						case when j.qty is not null and  j.prev_qty is not null then
						j.qty::NUMERIC * 
											(j.price-j.prev_price) else 0 end  AS price_effect,
						
						case when qty is not null and prev_qty is not null then
						(j.expected_qty-j.prev_qty::NUMERIC) * j.prev_price else 0 end AS volume_effect,
						case when qty is not null and prev_qty is not null then
						(j.qty::NUMERIC - j.expected_qty) * j.prev_price else 0 end AS mix_effect,
						case when j.prev_qty is null then j.revenue else 0 end AS new_effect,
						case when j.qty is null then j.prev_revenue else 0 end AS lost_effect
					from joined_2 j) 
							
						
						
						SELECT *,round(coalesce(revenue,0::numeric) - coalesce(prev_revenue,0::numeric),0) as revenue_change,
						round(price_effect + volume_effect + mix_effect + new_effect - lost_effect,0) as rev_change_effects
						from effects
