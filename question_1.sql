-- How many staff are there in all of the UK stores? 
SELECT SUM(staff_numbers) AS total_staff_uk
FROM dim_stores
WHERE country = 'United Kingdom';