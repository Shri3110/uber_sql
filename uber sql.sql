List all trips where the customer rating is below 3.
select * from ride_details
where customer_ratings <3
Show total earnings (sum of Price) grouped by Vehicle Type.
select vehicle_type,sum(price) as total_earnings
from ride_details
group by vehicle_type
What is the average ride distance for trips paid via 'Card'?
select payment_method,avg(ride_distance) from ride_details
where payment_method='Card'
group by payment_method
How many rides were completed (Status = 'Success') each day?
select count(booking_date),booking_status,booking_date
from booking_details
where booking_status='Success'
group by booking_status,booking_date

Count how many rides were cancelled by riders vs drivers.
select count(booking_id),booking_status
from booking_details
where booking_status <>'Success' and booking_status<>'Incomplete'
group by booking_status

Find all incomplete rides and the reason behind them.
select booking_id,incomplete_ride_reason
from unsuccessful_rides
where incomplete_ride_reason is not null


What is the average VTAT and CTAT for each vehicle type?
select vehicle_type,avg(avg_vtat),avg(avg_ctat) from ride_details
group by vehicle_type
List bookings with zero price or zero ride distance.
select * from ride_details
where price=0 or ride_distance=0
Which payment mode is most commonly used?
select payment_method,count(payment_method) from ride_details
group by payment_method
order by count(payment_method) desc
limit 1
Show the top 3 pickup locations based on number of bookings.
select pickup_location,count(booking_id)
from ride_details
group by pickup_location
order by count(booking_id) desc
limit 3

Find the ride with the highest price for each vehicle type.
select max(price),vehicle_type
from ride_details
group by vehicle_type
Identify bookings where both the rating and ride distance are 0 (suspicious records).
select customer_ratings,ride_distance
from ride_details
where customer_ratings=0 and ride_distance=0

join all three tables and list all information for bookings that were cancelled.
select * from booking_details b
inner join ride_details r
on b.booking_id=r.booking_id
inner join unsuccessful_rides u
on r.booking_id=u.booking_id
where booking_status<> 'Success' and booking_status <>'Incomplete'

Calculate average customer rating by pickup location.
select avg(customer_ratings),pickup_location
from ride_details
group by pickup_location

Show daily cancellation rates (cancelled bookings / total bookings).
select
  booking_date,
  count(*) AS total_bookings,
  sum(case when booking_status IN ('Cancelled by Driver', 'Cancelled by Customer') then 1 else 0 end) AS cancelled_count,
  round(100.0 * sum(case when booking_status IN ('Cancelled by Driver', 'Cancelled by Customer') then 1 else 0 end) / count(*), 2) as cancellation_rate_pct
from booking_details
group by booking_date;
Use a CTE to calculate the number of cancelled rides by day and cancellation reason.
with cte as( select count(b.booking_id),booking_date,u.cancelled_rides_by_driver_reason,
u.cancelled_rides_by_customer_reason from booking_details b
inner join unsuccessful_rides u
on b.booking_id=u.booking_id
where booking_status<> 'Success' and booking_status<> 'Incomplete'
group by booking_date,u.cancelled_rides_by_driver_reason,u.cancelled_rides_by_customer_reason
order by booking_date )
select *
from cte

Rank vehicle types based on total earnings (use RANK()).
select sum(price),vehicle_type,dense_rank() over( order by sum(price)) as rnk
from ride_details
group by vehicle_type
