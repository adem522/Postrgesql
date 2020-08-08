--Creating Database
--create database rapor2
/*
--TABLES
-- Table: policys
 create table policys (
    id SERIAL,
    description varchar(255),
    CONSTRAINT policys_pk PRIMARY KEY  (id)
);

-- Table: insurance
create table insurance (
    id SERIAL,
    name varchar(255),
    description varchar(255),
    cost money,
	CONSTRAINT insurance_pk PRIMARY KEY  (id)    
);

--Table: insurance_policys
create table insurance_policys (
    insurance_id int                NOT NULL,
    policys_id int                  NOT NULL
);

-- Table: fuel_option
create table fuel_option (
    id SERIAL,
    name varchar(255)               NOT NULL,
    CONSTRAINT fuel_option_pk PRIMARY KEY(id)
);

-- Table: car_category
CREATE TABLE car_category (
	id SERIAL,
	name varchar(255)               NOT NULL,
	rental_value money              NOT NULL,
	CONSTRAINT car_category_pk PRIMARY KEY  (id)
);

-- Table: car
CREATE TABLE car (
	id SERIAL,
	available boolean DEFAULT(TRUE), 
	license_plate VARCHAR(255) UNIQUE NOT NULL,	
	brand VARCHAR(255),      
	model VARCHAR(255),     
	production_year INT,    
    number_seats INT,       
    gear_type VARCHAR(50),   
	mileage INT,     
	color VARCHAR(255),
	fuel_option VARCHAR(255),
	car_category_id INT             NOT NULL,
	current_location_id INT         NOT NULL,
	CONSTRAINT car_pk PRIMARY KEY  (id)
);

-- Table: customer
CREATE TABLE customer (
	id SERIAL,
	name varchar(255)               NOT NULL,
    surname varchar(255)            NOT NULL,
	birth_date date                 NOT NULL check(date_part('year',age(birth_date))>=18),
	driving_license_number varchar(255) UNIQUE NOT NULL,
	CONSTRAINT customer_pk PRIMARY KEY  (id)
);

-- Table: equipment
CREATE TABLE equipment (
	id SERIAL,
	name varchar(255)               NOT NULL,
	rental_value money default(50),
	equipment_category_id int       NOT NULL,
	current_location_id int         NOT NULL,
	CONSTRAINT equipment_pk PRIMARY KEY  (id)
);

-- Table: equipment_category
CREATE TABLE equipment_category (
	id SERIAL,
	name varchar(255)               NOT NULL,
	CONSTRAINT equipment_category_pk PRIMARY KEY  (id)
);

-- Table: location
CREATE TABLE location (
	id SERIAL,
	street_address varchar(100)     NOT NULL,
	city varchar(50)                NOT NULL,
	state varchar(50)               NOT NULL,	
	zip varchar(50)                 NOT NULL,
	country_id INT                  NOT NULL,
	CONSTRAINT location_zip_ux UNIQUE (zip),
	CONSTRAINT location_pk PRIMARY KEY  (id)
);

-- Table: country
 create table country (
    id SERIAL,
    name varchar(255),
    CONSTRAINT country_pk PRIMARY KEY  (id)
);

-- Table: rental
CREATE TABLE rental (
	id SERIAL,
	start_date date                 NOT NULL,
	end_date date                   NOT NULL,
	delivery_date date              NOT NULL,
	customer_id int                 NOT NULL,
	car_id int                      NOT NULL,
	pick_up_location_id int         NOT NULL,
	drop_off_location_id int        NOT NULL,
	department_id int               NOT NULL,
    equipment_id int,    
    insurance_id int,
	CONSTRAINT rental_pk PRIMARY KEY  (id)
);

-- Table: rental_invoice
CREATE TABLE rental_invoice (
	id SERIAL,	
	car_rent                money   NOT NULL,
	equipment_rent_total    money,
	insurance_cost_total    money,
	net_amount_payable      money   NOT NULL,
    rental_id               int     NOT NULL,
	CONSTRAINT rental_invoice_pk PRIMARY KEY  (id)
);

-- Table: staff
CREATE TABLE staff (
	id SERIAL,
	name varchar(255),
	surname varchar(255),
	CONSTRAINT staff_pk PRIMARY KEY  (id)
);
-- Table: department
CREATE TABLE department (
	id SERIAL,
    department_name varchar(255),
	location_id int                 NOT NULL,
	staff_id int                    NOT NULL,
	CONSTRAINT department_pk PRIMARY KEY  (id)
);

--FOREIGN KEYS (REFERENCES)

-- Reference : insurance-policys-policys (table: insurance_policys)
ALTER TABLE insurance_policys ADD CONSTRAINT insurance_policys_policys
	FOREIGN KEY (policys_id)
	REFERENCES policys (id);

-- Reference : insurance-policys (table: insurance_policys)
ALTER TABLE insurance_policys ADD CONSTRAINT insurance_policys_insurance
	FOREIGN KEY (insurance_id)
	REFERENCES insurance (id);
	
-- Reference: car_category (table: car)
ALTER TABLE car ADD CONSTRAINT car_category_car
	FOREIGN KEY (car_category_id)
	REFERENCES car_category (id);
	
-- Reference: car_location (table: car)
ALTER TABLE car ADD CONSTRAINT car_location
	FOREIGN KEY (current_location_id)
	REFERENCES LOCATION (id);
	
-- Reference: location_country (table: location)
ALTER TABLE location ADD CONSTRAINT location_country
	FOREIGN KEY (country_id)
	REFERENCES country (id);
	
-- Reference: equipment_equipment_category (table: equipment)
ALTER TABLE equipment ADD CONSTRAINT equipment_equipment_category
	FOREIGN KEY (equipment_category_id)
	REFERENCES equipment_category (id);

-- Reference: equipment_location (table: equipment)
ALTER TABLE equipment ADD CONSTRAINT equipment_location
	FOREIGN KEY (current_location_id)
	REFERENCES location (id);

-- Reference: rental_equipment (table: rental)
ALTER TABLE rental ADD CONSTRAINT rental_equipment
   FOREIGN KEY (equipment_id)
   REFERENCES equipment (id);

-- Reference: rental_car (table: rental)
ALTER TABLE rental ADD CONSTRAINT rental_car
	FOREIGN KEY (car_id)
	REFERENCES car (id);
	
-- Reference: rental_customer (table: rental)
ALTER TABLE rental ADD CONSTRAINT rental_customer
	FOREIGN KEY (customer_id)
	REFERENCES customer (id);
	
-- Reference: rental_insurance (table: rental)
ALTER TABLE rental ADD CONSTRAINT rental_insurance
	FOREIGN KEY (insurance_id)
	REFERENCES insurance (id);	

-- Reference : department_staff (table: department)
ALTER TABLE department ADD CONSTRAINT department_staff
   FOREIGN KEY (staff_id)
   REFERENCES staff (id);

-- Reference : department_location (table: department)
ALTER TABLE department ADD CONSTRAINT department_location
   FOREIGN KEY (location_id)
   REFERENCES location (id);

-- Reference: rental_invoice_rental (table: rental_invoice)
ALTER TABLE rental_invoice ADD CONSTRAINT rental_invoice_rental
	FOREIGN KEY (rental_id)
	REFERENCES rental (id) ON DELETE CASCADE;
	
-- Reference: rental_pick_up_location (table: rental)
ALTER TABLE rental ADD CONSTRAINT rental_pick_up_location
	FOREIGN KEY (pick_up_location_id)
	REFERENCES location (id);
	
-- Reference: rental_drop_off_location (table: rental)
ALTER TABLE rental ADD CONSTRAINT rental_drop_off_location
	FOREIGN KEY (drop_off_location_id)
	REFERENCES location (id);
	
-- Reference: rental_department (table: rental)
ALTER TABLE rental ADD CONSTRAINT rental_department
	FOREIGN KEY (department_id)
	REFERENCES department (id);

-- FUNCTIONS
-------------------id'si gönderilen ekipman kaç kere kullanılmış--------------------------------
drop function if EXISTS equipmentUseCount;
CREATE OR REPLACE FUNCTION equipmentUseCount(equipmentId INT)
RETURNS TABLE(customerName varchar(255),departmentName varchar(255),sehir varchar(255)) 
LANGUAGE "plpgsql"
AS 
$function$
BEGIN
    RETURN QUERY 
        SELECT customerTemp.name, 
        departmentTemp.department_name,  
        locationTemp.city                 
        FROM rental rentTemp
        inner join equipment equipmentTemp       on equipmentTemp.id=rentTemp.equipment_id and equipmentTemp.id=equipmentId
        inner join customer customerTemp         on customerTemp.id = rentTemp.customer_id
        inner join department departmentTemp     on departmentTemp.id = rentTemp.department_id
        inner join staff staffTemp               on departmentTemp.staff_id = staffTemp.id
        inner join location locationTemp         on departmentTemp.location_id=locationTemp.id
        group by rentTemp.id,customerTemp.name,departmentTemp.department_name,locationTemp.city
        order by count(rentTemp.equipment_id) desc ;
END
$function$ ;
--select * from equipmentUseCount(2);
------------------------------------------------------------------------------------------------------------------------------

-----------------------id'si verilen müşterinin ne kadar harcama yaptığın döndüren fonksiyon----------------
drop function if EXISTS netAmountPay;
create or replace FUNCTION netAmountPay(customerId int)
returns table (customerName varchar(255),net_pay money)
LANGUAGE "plpgsql"
as
$function$
begin
    return query 
        SELECT customerTemp.name, 
        SUM(rental_invoiceTemp.net_amount_payable)                   
        FROM rental rentTemp
        inner join customer customerTemp             on rentTemp.customer_id=customerTemp.id and customerTemp.id = customerId
        inner join rental_invoice rental_invoiceTemp on rental_invoiceTemp.rental_id = rentTemp.id
        group by rentTemp.id,customerTemp.name
        order by count(rental_invoiceTemp.rental_id) desc ;
end $function$;
--select * from netAmountPay(1);
------------------------------------------------------------------------------------------------------------------------------
    
---------------------Her personelin kaç tane kiralamada bulunduğunu döndüren fonksiyon----------------------------------
drop function if exists countStaffRent;
create or replace function countStaffRent()
returns table (staffName varchar(255),countStaff BIGINT)
language "plpgsql"
as
$function$
begin
    return query 
        select  staffTemp.name,
                COUNT(staffTemp.id)
                from rental rentTemp
                inner join department departmentTemp on departmentTemp.id = rentTemp.department_id
                inner join staff staffTemp on departmentTemp.staff_id=staffTemp.id
                group by staffTemp.name;                
end $function$;
--select * from countStaffRent();
------------------------------------------------------------------------------------------------------------------------------

------------------------------------------YENİ KİRALAMA YAPILDIĞINDA DEVREYE GİREN TRIGGER -----------------------------------
---------------------------insurance id'sine göre  cost dönen fonksiyon-----------------------------------------
drop function if exists insuranceRentalValue;
create or replace function insuranceRentalValue(insuranceId int)
returns money 
language "plpgsql"
as
$function$
begin
    if insuranceId is null then
        return(0);
    else
        return(select cost from insurance where insurance.id = insuranceId);
    end if;
end $function$;
----------------------------------------------------------------------------------------------------------------------------
----------------------------equipment id'sine göre rental valuesini dönen fonksiyon----deneme---------------------------
drop function if exists equipmentRentalValue;
create or replace function equipmentRentalValue(equipmentId int)
returns money 
language "plpgsql"
as
$function$
begin
    if equipmentId is null then
        return(0);-- 
    ELSE
        return(select rental_value from equipment where equipment.id = equipmentId);
    end if;
end $function$;
-------------------------------------------------------------------------------------------------------------------------
--------------------------car id'sine göre rental valuesini dönen fonksiyon-----------------------------------------
drop function if exists carRentalValue;
create or replace function carRentalValue(carId int)
returns money 
language "plpgsql"
as
$function$
begin
    if carId is null then
        return(0);
    else
    return(select car_category_temp.rental_value from car car_temp
        inner JOIN car_category car_category_temp on car_category_temp.id=car_temp.car_category_id
        where car_temp.id = carId);
    end if;
end $function$;
--------------------------------------------------------------------------------------------------------------------------
--------------------------gelen idlerin rental valuesini toplayıp dönen fonksiyon-----------------------------------------
drop function if exists sumRentalValue;
create or replace function sumRentalValue(carId int,equipmentId int,insuranceId int)
returns money 
language "plpgsql"
as
$function$
begin
    return(carRentalValue(carId)+equipmentRentalValue(equipmentId)+insuranceRentalValue(insuranceId));
end $function$;
---------------------------------------------------------------------------------------------------------------------------

DROP TRIGGER if EXISTS insert_update_rental_trigger on rental;
DROP FUNCTION if EXISTS insert_update_rental_trigger;
CREATE OR REPLACE FUNCTION insert_update_rental_trigger() 
   RETURNS TRIGGER 
   LANGUAGE "plpgsql"
AS $insert_update_rental_trigger$
    DECLARE 
        rental_idTemp       int;
        insurance_idTemp    int;
        equipment_idTemp    int;
        car_idTemp          int;
        delay_price_value   money;
        end_date_temp       date;
        delivery_date_temp  date;
    BEGIN
        IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN 
            rental_idTemp           = NEW.id;
            insurance_idTemp        = NEW.insurance_id;
            equipment_idTemp        = NEW.equipment_id;
            car_idTemp              = NEW.car_id;
            delay_price_value       = carRentalValue(NEW.car_id);
            end_date_temp           = NEW.end_date;
            delivery_date_temp      = NEW.delivery_date;
        END IF;
        IF end_date_temp::date < delivery_date_temp::date THEN
            delay_price_value = delay_price_value*(0.5);
        ELSE
            delay_price_value = 0;
        END IF;
            <<insert_update>>        
            LOOP
                UPDATE rental_invoice
                    SET car_rent         = carRentalValue(car_idTemp),
                    equipment_rent_total = equipmentRentalValue(equipment_idTemp),
                    insurance_cost_total = insuranceRentalValue(insurance_idTemp),
                    net_amount_payable   = sumRentalValue(car_idTemp,equipment_idTemp,insurance_idTemp) + delay_price_value
                    WHERE rental_id = rental_idTemp;
                EXIT insert_update WHEN FOUND;
                BEGIN
                    INSERT INTO rental_invoice (
                                    car_rent,
                                    equipment_rent_total,
                                    insurance_cost_total,
                                    net_amount_payable,
                                    rental_id
                                )
                                VALUES(
                                    carRentalValue(car_idTemp),
                                    equipmentRentalValue(equipment_idTemp),
                                    insuranceRentalValue(insurance_idTemp),
                                    sumRentalValue(car_idTemp,equipment_idTemp,insurance_idTemp) + delay_price_value,
                                    rental_idTemp
                                );
                    EXIT insert_update;

                    EXCEPTION
                    WHEN UNIQUE_VIOLATION THEN
                END;
            END LOOP insert_update;
        RETURN NULL;
END; $insert_update_rental_trigger$;

drop trigger if EXISTS insert_update_rental_trigger on rental;
CREATE TRIGGER insert_update_rental_trigger
AFTER INSERT OR UPDATE ON rental
    FOR EACH ROW EXECUTE PROCEDURE insert_update_rental_trigger();
   
-------------------------------------------------------------------------------------------------------------------------------
------------------------------------------SEÇİLEN ARABAYI NOT AVAILABE YAPAN TRIGGER-------------------------------------------
CREATE OR REPLACE FUNCTION car_status_function() 
   RETURNS TRIGGER 
   LANGUAGE "plpgsql"
AS $car_status_trigger$
        BEGIN
            UPDATE car SET available = FALSE WHERE id = NEW.car_id;
        RETURN NULL;
END; $car_status_trigger$;

drop trigger if EXISTS car_status_trigger on rental;
CREATE TRIGGER car_status_trigger
AFTER INSERT OR UPDATE ON rental
    FOR EACH ROW EXECUTE PROCEDURE car_status_function();  --------------------------------------------------------------------------------------------------------------------------------

------------------------------SİLİNEN COUNTRY'E BAĞLI LOCATIONLARI SİLEN TRIGGER--------------------------------
CREATE OR REPLACE FUNCTION country_location_function() 
   RETURNS TRIGGER 
   LANGUAGE "plpgsql"
AS $country_location_function$
        BEGIN
            DELETE FROM location WHERE country_id=OLD.id; 
        RETURN NULL;
END; $country_location_function$;

drop trigger if EXISTS country_location_trigger on country;
CREATE TRIGGER country_location_trigger
AFTER DELETE ON country
    FOR EACH ROW EXECUTE PROCEDURE country_location_function(); 
--------------------------------------------------------------------------------------------------------------------------------
------------------------------SİLİNEN DEPARTMANA BAĞLI STAFF SİLEN TRIGGER--------------------------------
-- CREATE OR REPLACE FUNCTION department_staff_function() 
--    RETURNS TRIGGER 
--    LANGUAGE "plpgsql"
-- AS $department_staff_function$
--         BEGIN
--             DELETE FROM staff WHERE id=OLD.id; 
--         RETURN NULL;
-- END; $department_staff_function$;
-- 
-- drop trigger if EXISTS department_staff_trigger on country;
-- CREATE TRIGGER department_staff_trigger
-- AFTER DELETE ON department
--     FOR EACH ROW EXECUTE PROCEDURE department_staff_function(); 
--------------------------------------------------------------------------------------------------------------------------------

--INSERT CODES

--First inserts
-- Insert into policys (table: policys)
insert into policys (description) values('police1');
insert into policys (description) values('police2');
insert into policys (description) values('police3');

-- Insert into insurance (table: insurance)
insert into insurance (name,description,cost) values('Kaza Sigortası','Kazaları karşılayan sigorta',50);
insert into insurance (name,description,cost) values('Sağlık Sigortası','Sağlık giderlerini karşılayan sigorta',75);

-- Insert into countrys (table: country)
insert into country (name) values('Country 1');
insert into country (name) values('Country 2');
insert into country (name) values('Country 3');
insert into country (name) values('Country 4');
insert into country (name) values('Irak');

-- Insert into staff (table: staff)
insert into staff(name, surname) values('Staff1','Staff1');
insert into staff(name, surname) values('Staff2','Staff2');
insert into staff(name, surname) values('Staff3','Staff3');
insert into staff(name, surname) values('Staff4','Staff4');
insert into staff(name, surname) values('Staff5','Staff5');

-- Insert into customer (table: customer)
insert into customer(name, surname, birth_date, driving_license_number) values('Costumer1','Costumer1','29-05-1998',314);
insert into customer(name, surname, birth_date, driving_license_number) values('Costumer2','Costumer2','28-05-1998',3141);
insert into customer(name, surname, birth_date, driving_license_number) values('Costumer3','Costumer3','27-05-1998',31416);
insert into customer(name, surname, birth_date, driving_license_number) values('Costumer4','Costumer4','29-05-1998',314158);
insert into customer(name, surname, birth_date, driving_license_number) values('Costumer5','Costumer5','26-05-1998',3141592);

-- Insert into car category (table: car_category)
insert into car_category(name, rental_value) values('Ekonomik',100);
insert into car_category(name, rental_value) values('Normal',170);
insert into car_category(name, rental_value) values('Lüks',250);

-- Insert into equipment category (table: equipment_category)
insert into equipment_category(name) values('Elektronik');
insert into equipment_category(name) values('Güvenlik');
 */-- you can execute to one go 

/*
--Second inserts (second execute)

-- Insert into location (table: location)
insert into location (street_address,city,state,country_id,zip) values('adress1','city1','state1',1,16200);
insert into location (street_address,city,state,country_id,zip) values('adress2','city2','state2',2,11300);
insert into location (street_address,city,state,country_id,zip) values('adress3','city3','state3',3,9800);
insert into location (street_address,city,state,country_id,zip) values('adress4','city4','state4',4,9700);
insert into location (street_address,city,state,country_id,zip) values('Yafa St.s5','Bağdat','Tahrir',1,898);

-- Insert into equipment (table: equipment)
insert into equipment(name, rental_value, equipment_category_id, current_location_id) values('Bebek Koltuğu',    50,2,1);
insert into equipment(name, rental_value, equipment_category_id, current_location_id) values('Navigasyon Cihazı',55,1,3);
insert into equipment(name, rental_value, equipment_category_id, current_location_id) values('Laptop',           100,1,1);

-- Insert into car (table: car)
insert into car(license_plate,brand, model,car_category_id, current_location_id) values('11aa527','Nissan',     'Qashqai',3,1);
insert into car(license_plate,brand, model,car_category_id, current_location_id) values('11aa528','Nissan',     'Juke',2,2);
insert into car(license_plate,brand, model,car_category_id, current_location_id) values('11aa529','Tofaş',      'Şahin',1,3);
insert into car(license_plate,brand, model,car_category_id, current_location_id) values('11aa535','Tofaş',      'Şahin',1,3);
insert into car(license_plate,brand, model,car_category_id, current_location_id) values('11aa530','Bmw',        '320i',2,4);
insert into car(license_plate,brand, model,car_category_id, current_location_id) values('11aa531','Mercedes',   '300SEL',3,5);
insert into car(license_plate,brand, model,car_category_id, current_location_id) values('11aa532','Cadillac',   'Escalade',3,5);
insert into car(license_plate,brand, model,car_category_id, current_location_id) values('11aa533','Land Rover', 'Defender',3,4);

-- Insert into insurance_policys (table: insurance_policys)
insert into insurance_policys (insurance_id,policys_id) values(1,1);
insert into insurance_policys (insurance_id,policys_id) values(1,2);
insert into insurance_policys (insurance_id,policys_id) values(2,3);

-- Insert into department (table: department)
insert into department(department_name, location_id, staff_id) values('department1',  1,1);
insert into department(department_name, location_id, staff_id) values('department2',  2,2);
insert into department(department_name, location_id, staff_id) values('department3',  3,3);
insert into department(department_name, location_id, staff_id) values('department4',  4,4);
insert into department(department_name, location_id, staff_id) values('Bağdat Şubesi',5,5);
*/

/*
--Third inserts
-- Insert into rental (table: rental)
insert into rental(start_date, end_date, delivery_date, customer_id, car_id, pick_up_location_id, drop_off_location_id, equipment_id, department_id,insurance_id) 
values('22-07-2020','25-07-2020','25-07-2020',1,1,1,1,1,1,1);
insert into rental(start_date, end_date, delivery_date, customer_id, car_id, pick_up_location_id, drop_off_location_id, department_id,insurance_id) 
values('21-07-2020','25-07-2020','26-07-2020',2,2,3,3,2,2);
insert into rental(start_date, end_date, delivery_date, customer_id, car_id, pick_up_location_id, drop_off_location_id, department_id) 
values('14-07-2020','19-07-2020','20-07-2020',3,3,4,4,3);
insert into rental(start_date, end_date, delivery_date, customer_id, car_id, pick_up_location_id, drop_off_location_id, equipment_id, department_id) 
values('27-07-2020','29-07-2020','29-07-2020',1,1,1,1,1,1);
*/