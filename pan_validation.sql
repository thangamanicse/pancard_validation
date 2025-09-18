--we load the pancard_dataset,which contains almost 100000 pan_numbers
select * from pancard  

--1) DATA cleaning
--To identitfy and handling the missing data 

select * from pancard where pan_number is null;

--check for duplicates

select pan_number,count(1)
from pancard group by pan_number 
having count(1)>1

--Handle leading/trailing spaces: 
select * from pancard 
where pan_number != trim(pan_number)

--Correct letter case: Ensure that the PAN numbers are in uppercase letters
--(if any lowercase letters are present).
select * from pancard
where pan_number != upper(pan_number)

--cleaned pan_numbers
select distinct upper(trim(pan_number))
as pan_number from pancard
where pan_number is  not null and 
trim(pan_number) !=''

--pan validation --

-- to create a user define functio to check adjacent characters are same or not
create  or replace function pancard_validation(p_str text)
returns boolean
language plpgsql

as $$
begin 
    for i in 1 .. (length(p_str)-1)
	loop
	   if substring(p_str,i,1)= substring(p_str,i+1,1)
	   then 
	       return true; --the character are adjacent
		end if ;
	end loop;
	return false;-- the character are not adjacent
end
$$
select pancard_validation('XXDVE')

create or replace function pan_sequence_checker(p_str text)
returns boolean
language plpgsql
as $$
begin 
    for i in 1 .. (length(p_str)-1)
    loop 
       if ascii(substring(p_str,i+1,1))- ascii(substring(p_str,i,1))!=1
       then 
      return false;
      end if; 
    end loop;
return true;
end;
$$;
select pan_sequence_checker('ACDFGE')

--regular expression to validate the pannumbers ,The format is as follows: AAAAA1234A

select * from pancard
where pan_number ~ '^[A-Z]{5}[0-9]{4}[A-Z]$'



--VALID AND INVALID PAN
create or replace view valid_invalid_pan as
with cleaned_pan as 
(select distinct upper(trim(pan_number))
as pan_number from pancard
where pan_number is  not null and 
trim(pan_number) !=''),
 valid_pan as (select * from cleaned_pan 
where pancard_validation(pan_number)=false
and  pan_sequence_checker(substring(pan_number,1,5))=false and
pan_sequence_checker(substring(pan_number,6,4))=false
and pan_number ~ '^[A-Z]{5}[0-9]{4}[A-Z]$')

select clp.pan_number,
case when vp.pan_number is not null then 'valid pan'
else 'invalid pan' end as status
from cleaned_pan clp left join valid_pan vp
on clp.pan_number=vp.pan_number


select * from valid_invalid_pan
WITH cte AS (
    SELECT 
        (SELECT COUNT(*) FROM pancard) AS total_pan_numbers,
        COUNT(*) FILTER (WHERE status = 'valid pan') AS total_valid,
        COUNT(*) FILTER (WHERE status = 'invalid pan') AS total_invalid
    FROM valid_invalid_pan
)
SELECT 
    total_pan_numbers,
    total_valid,
    total_invalid,
    total_pan_numbers - (total_valid + total_invalid) AS incomplete_pan
FROM cte;




