create database SS
go

create schema ss
go

create table brands
(
	brand_id int,
	brand_name varchar(255)
)
go

create table categories
(
	category_id int,
	category_name varchar(255)
)
go

create table customer_service_type
(
	id int,
	type varchar(50),
	description varchar(500)
)
go

create table customer_services
(
	id int,
	customer_id int,
	type int,
	date date,
	cost numeric(18),
	description varchar(500)
)
go

create table customers
(
	customer_id int,
	first_name varchar(255),
	last_name varchar(255),
	phone varchar(25),
	email varchar(255),
	street varchar(255),
	city varchar(50),
	state varchar(25),
	zip_code varchar(5)
)
go

create table gift_card_usages
(
	id int,
	card int,
	customer int,
	date date
)
go

create table gift_cards
(
	id int,
	gift_code varchar(50),
	amount numeric(18),
	count int
)
go

create table order_items
(
	order_id int not null,
	item_id int not null,
	product_id int,
	quantity int,
	list_price decimal(10,2),
	discount decimal(4,2) default 0,
	primary key (order_id, item_id)
)
go

create table orders
(
	order_id int,
	customer_id int,
	order_date date,
	required_date date,
	store_id int,
	staff_id int
)
go

create table products
(
	product_id int,
	product_name varchar(255),
	brand_id int,
	category_id int,
	model_year smallint,
	list_price decimal(10,2)
)
go

create table staffs
(
	staff_id int,
	first_name varchar(50),
	last_name varchar(50),
	email varchar(255)
		unique,
	phone varchar(25),
	active tinyint,
	store_id int,
	manager_id int
)
go

create table stocks
(
	store_id int,
	product_id int,
	quantity int
)
go

create table stores
(
	store_id int,
	store_name varchar(255),
	phone varchar(25),
	email varchar(255),
	street varchar(255),
	city varchar(255),
	state varchar(10),
	zip_code varchar(5)
)
go

create table temp_orders
(
	order_id int,
	customer_id int,
	order_date date,
	required_date date,
	store_id int,
	staff_id int
)
go

create   procedure ssupdate_sa @end_date date as
begin
    declare @temp_cur_date date

    insert into Dw.dw.logs
    values (current_timestamp, 'update_sa ', 2, 'start of update_sa ')

    delete
    from sscustomer_service_type
    where 1 > 0

    insert into sscustomer_service_type
    select id, type, description
    from ScootersStores.sales.customer_service_type

    delete
    from sscustomers
    where 1 > 0

    insert into sscustomers
    select customer_id,
           first_name,
           last_name,
           phone,
           email,
           street,
           city,
           state,
           zip_code
    from ScootersStores.sales.customers


    select @temp_cur_date = IIF(max(date) is null, cast('2016-1-1' as date), dateadd(day, 1, max(date)))
    from sscustomer_services

    while @temp_cur_date < @end_date
        begin
            insert into sscustomer_services
            select id, customer_id, type, date, cost, description
            from ScootersStores.sales.customer_services
            where date = @temp_cur_date
            set @temp_cur_date = dateadd(day, 1, @temp_cur_date)
        end


    delete
    from ssgift_cards
    where 1 > 0

    insert into ssgift_cards
    select id, gift_code, amount, count
    from ScootersStores.sales.gift_cards

    select @temp_cur_date = IIF(max(date) is null, cast('2016-1-1' as date), dateadd(day, 1, max(date)))
    from ssgift_card_usages

    while @temp_cur_date < @end_date
        begin
            insert into ssgift_card_usages
            select id, card, customer, date
            from ScootersStores.sales.gift_card_usages
            where date = @temp_cur_date
            set @temp_cur_date = dateadd(day, 1, @temp_cur_date)
        end


    delete
    from ssstores
    where 1 > 0

    insert into ssstores
    select store_id,
           store_name,
           phone,
           email,
           street,
           city,
           state,
           zip_code
    from ScootersStores.sales.stores


    delete
    from ssstaffs
    where 1 > 0

    insert into ssstaffs
    select staff_id,
           first_name,
           last_name,
           email,
           phone,
           active,
           store_id,
           manager_id
    from ScootersStores.sales.staffs


    select @temp_cur_date = IIF(max(order_date) is null, cast('2016-1-1' as date), dateadd(day, 1, max(order_date)))
    from ssorders
    delete from sstemp_orders where 1 > 0
    while @temp_cur_date < @end_date
        begin
            insert into sstemp_orders
            select order_id, customer_id, order_date, required_date, store_id, staff_id
            from ScootersStores.sales.orders
            where order_date = @temp_cur_date
            set @temp_cur_date = dateadd(day, 1, @temp_cur_date)
        end

    insert into ssorders
    select order_id, customer_id, order_date, required_date, store_id, staff_id
    from sstemp_orders

    insert into ssorder_items
    select order_id, item_id, product_id, quantity, list_price, discount
    from ScootersStores.sales.order_items
    where order_id in (select order_id from sstemp_orders)

    delete
    from ssbrands
    where 1 > 0

    insert into ssbrands
    select brand_id, brand_name
    from ScootersStores.production.brands

    delete
    from sscategories
    where 1 > 0

    insert into sscategories
    select category_id, category_name
    from ScootersStores.production.categories

    delete
    from ssproducts
    where 1 > 0

    insert into ssproducts
    select product_id, product_name, brand_id, category_id, model_year, list_price
    from ScootersStores.production.products

    delete
    from ssstocks
    where 1 > 0

    insert into ssstocks
    select store_id, product_id, quantity
    from ScootersStores.production.stocks

        insert into Dw.dw.logs
    values (current_timestamp, 'update_sa ', 3, 'end of update_sa ')

end
go

