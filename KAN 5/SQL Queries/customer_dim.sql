SELECT customer.customer_id, 
       customer.first_name, 
       customer.last_name, 
       customer.email, 
       country.country_name, 
       address.street_name, 
       address.street_number, 
       address.city, 
       address_status.address_status
FROM   address 
       INNER JOIN country 
               ON address.country_id = country.country_id 
       INNER JOIN customer_address 
               ON address.address_id = customer_address.address_id 
       INNER JOIN address_status 
               ON customer_address.status_id = address_status.status_id 
       INNER JOIN customer 
               ON customer_address.customer_id = customer.customer_id;
