drop database if exists music_store;
create database if not exists music_store;
use music_store;

SET @@SQL_MODE  = SYS.LIST_DROP(@@SQL_MODE, 'ONLY FULL GROUP BY');
SELECT@@SQL_MODE;


/* Q1: Who is the senior most employee based on job title? */

with cte as 
( select *, dense_rank() over w as sr_no
from
employee_x
window w as (order by levels desc)       
)
select *
from cte 
where sr_no = 1;



/* Q2: Which countries have the most Invoices? */

select billing_country as country, count(total) as no_of_invoices
from
invoice
group by billing_country;


/* Q3: What are top 3 values of total invoice? */

with cte as 
( 
select *, dense_rank() over w as sr
from
invoice
window w as (order by total desc)
)
select *
from
cte 
where sr <= 3;


### to only select the 3 highest valued invoice's amount.

select distinct(total)
from
invoice
order by total desc
limit 3;

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

SELECT billing_city as city , round(sum(total),2) as amount 
FROM
invoice
GROUP BY billing_city
order by amount desc;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

with 
cte as 
(
select customer_id, round(sum(total),2) as amount 
from
invoice
group by customer_id
),
t2 as (
select cte.customer_id, cte.amount,c.first_name,c.last_name,c.city,c.country,c.postal_code,c.phone,c.email,dense_rank() over (order by amount desc)  as sr 
from cte 
join
customer as c
on c.customer_id =  cte.customer_id
) 
select *
from
t2 
where sr <= 3;


/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */


SELECT DISTINCT
    c.first_name, c.last_name, c.email, g.name
FROM
    invoice_line AS il
        JOIN
    invoice AS i ON il.invoice_id = i.invoice_id
        JOIN
    track AS t ON t.track_id = il.track_id
        JOIN
    genre AS g ON g.genre_id = t.genre_id
        JOIN
    customer AS c ON c.customer_id = i.customer_id
WHERE
    g.name = 'Rock'
ORDER BY c.email ASC;


/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT 
    art.artist_id,
    art.name,
    COUNT(t.track_id) AS total_rock_songs
FROM
    track AS t
        JOIN
    album2 AS a ON t.album_id = a.album_id
        JOIN
    genre AS g ON t.genre_id = g.genre_id
        JOIN
    artist AS art ON art.artist_id = a.artist_id
WHERE
    g.name = 'Rock'
GROUP BY art.name , art.artist_id
ORDER BY total_rock_songs DESC;

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */
select track_id,name, milliseconds
from
track
where milliseconds > (select avg(milliseconds) from track)
order by milliseconds desc ;


/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

SELECT 
    b.customer_id, c.first_name, c.last_name, b.x, b.name
FROM
    (SELECT 
        v.customer_id, SUM(v.tot) AS x, v.name
    FROM
        (SELECT 
        i2.customer_id,
            il.track_id,
            (il.unit_price * il.quantity) AS tot,
            t.album_id,
            a.artist_id,
            ar.name
    FROM
        invoice AS i2
    JOIN invoice_line AS il ON i2.invoice_id = il.invoice_id
    JOIN track AS t ON il.track_id = t.track_id
    JOIN album2 AS a ON a.album_id = t.album_id
    JOIN artist AS ar ON ar.artist_id = a.artist_id) AS v
    GROUP BY v.customer_id , v.name) AS b
        JOIN
    customer AS c ON c.customer_id = b.customer_id
ORDER BY b.x DESC
;

/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

select * from
(
select p.billing_country as country,p.name as genre,count(p.quantity) as total_no_of_purchase,
dense_rank() over w as sr
from
(
select i.billing_country,il.quantity,g.name
from 
track as t
join
genre as g
on t.genre_id = g.genre_id
join
invoice_line as il
on t.track_id = il.track_id
join
invoice as i
on i.invoice_id = il.invoice_id
) as p
group by country,genre
window w as (partition by p.billing_country order by count(p.quantity) desc)
) s
where sr = 1;
;


/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

with t as
(
select c.customer_id,c.first_name,c.last_name,c.email,i.billing_country as country,i.total
from
invoice as i
join
customer as c
on i.customer_id = c.customer_id)

select *
from
(select  t.customer_id,t.first_name,t.last_name,t.email,t.country,sum(t.total) as amount,
dense_rank() over w as sr 
from
t 
group by 1,2,3,4,5
window w as (partition by country order by sum(t.total) desc)
) as f
where sr = 1
;



/* thank you :) */






























