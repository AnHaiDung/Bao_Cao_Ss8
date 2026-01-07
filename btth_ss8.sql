create database ss8_miniproj;
-- drop database ss8_miniproj;
use ss8_miniproj;

create table customers (
	customer_id int primary key auto_increment,
    full_name varchar(100) Not null,
    city varchar(100) Not null Unique,
    phone varchar(10) Not null Unique
);

create table categories(
	category_id int Primary key auto_increment,
    category_name varchar(255) Not null Unique
);

create table orders (
	order_id int primary key auto_increment,
    customer_id int not null,
    order_date date default(curdate()),
    status enum('pending', 'completed', 'cancelled') default('pending'),
    foreign key (customer_id) references customers(customer_id),
    total_amount decimal(10,2)
);

create table products (
    product_id int primary key auto_increment,
    product_name varchar(255) not null unique,
    price decimal(10,2) Not null,
    category_id int Not null,
    check ( price > 0),
    foreign key (category_id) references categories(category_id)
);

create table order_items (
    order_item_id int Primary key auto_increment,
    order_id int,
    product_id int,
    quantity int,
    check (quantity > 0),
    foreign key (order_id) references orders(order_id),
    foreign key (product_id) references products(product_id)
);

insert into customers (full_name, city, phone) values
('nguyen van an', 'ha noi', '0123456789'),
('tran thi binh', 'tp ho chi minh', '0987654321'),
('le van cuong', 'da nang', '0111222333'),
('pham hong dao', 'can tho', '0444555666'),
('hoang minh em', 'hai phong', '0777888999');

insert into categories (category_name) values
('electronics'),
('clothing'),
('books'),
('home & kitchen'),
('sports');

insert into orders (customer_id, order_date, status, total_amount) values
(1, '2026-01-01', 'completed', 1019.98),
(2, '2026-01-02', 'pending', 89.99),
(3, '2026-12-25', 'completed', 1314.98),
(4, '2026-01-05', 'cancelled', 0.00),
(5, '2026-03-06', 'pending', 44.98),
(1, '2026-01-08', 'pending', 59.99);

insert into products (product_name, price, category_id) values
('smartphone', 999.99, 1),
('laptop', 1299.99, 1),
('t-shirt', 19.99, 2),
('jeans', 59.99, 2),
('fiction novel', 14.99, 3),
('cookware set', 89.99, 4),
('yoga mat', 29.99, 5);

insert into order_items (order_id, product_id, quantity) values
(1, 1, 1),
(1, 3, 1),
(2, 6, 1),
(3, 2, 1),
(3, 5, 1),
(5, 5, 1),
(5, 7, 1);

-- Phan A
-- Lấy danh sách tất cả danh mục sản phẩm trong hệ thống.
select * from categories;

-- Lấy danh sách đơn hàng có trạng thái là COMPLETED
select * from orders where status = 'completed';

-- Lấy danh sách sản phẩm và sắp xếp theo giá giảm dần
select * from products
order by price desc;

-- Lấy 5 sản phẩm có giá cao nhất, bỏ qua 2 sản phẩm đầu tiên
select * from products
order by price desc limit 5 offset 2;

-- Phan B
-- Lấy danh sách sản phẩm kèm tên danh mục
select p.*, ca.category_name
from products p
join categories ca on p.category_id = ca.category_id;

-- Lấy danh sách đơn hàng
select o.order_id,o.order_date,cu.full_name,o.status 
from orders o
join customers cu on o.customer_id = cu.customer_id;

-- Tính tổng số lượng sản phẩm trong từng đơn hàng
select order_id, sum(quantity)
from order_items 
group by order_id
order by order_id;

-- Thống kê số đơn hàng của mỗi khách hàng
select cu.customer_id, cu.full_name, count(o.order_id) 
from customers cu
join orders o on cu.customer_id = o.customer_id
group by cu.customer_id;

-- Lấy danh sách khách hàng có tổng số đơn hàng ≥ 2
select cu.customer_id, cu.full_name, count(o.order_id) 
from customers cu
join orders o on cu.customer_id = o.customer_id
group by cu.customer_id
having count(o.order_id) >= 2;

-- Thống kê giá trung bình, thấp nhất và cao nhất của sản phẩm theo danh mục
select c.category_name, avg(p.price), min(p.price), max(p.price)	
from products p
join categories c on p.category_id = c.category_id
group by c.category_id;

-- Phần C
-- Lấy danh sách sản phẩm có giá cao hơn giá trung bình của tất cả sản phẩm	
select product_name, format(price,0,'vi_VN') from products 
where price > (select avg(price) from products);

-- Lấy danh sách khách hàng đã từng đặt ít nhất một đơn hàng
select *
from customers
where customer_id in (select customer_id from orders);

-- Lấy danh sách khách hàng đã từng đặt ít nhất một đơn hàng
select o.*, sum(oi.quantity) as total 
from orders o
join order_items oi on o.order_id = oi.order_id
group by o.order_id
having total >= ALL( select sum(quantity) from order_items group by order_id order by sum(quantity));

-- Lấy tên khách hàng đã mua sản phẩm thuộc danh mục có giá trung bình cao nhất
select cu.full_name
from customers cu
where cu.customer_id in (
    select o.customer_id
    from orders o
    join order_items oi on o.order_id = oi.order_id
    join products p on oi.product_id = p.product_id
    where p.category_id = (
        select category_id
        from (
            select c.category_id, avg(p.price) as avg_price
            from categories c
            join products p on c.category_id = p.category_id
            group by c.category_id
            order by avg_price desc
            limit 1
        ) sub
    )
);
-- Từ bảng tạm (subquery), thống kê tổng số lượng sản phẩm đã mua của từng khách hàng
select cu.customer_id, cu.full_name, coalesce(sub.total_quantity, 0) as total_quantity_purchased
from customers cu
left join (
    select o.customer_id, sum(oi.quantity) as total_quantity
    from orders o
    join order_items oi on o.order_id = oi.order_id
    group by o.customer_id
) sub on cu.customer_id = sub.customer_id
order by cu.customer_id;
-- Viết lại truy vấn lấy sản phẩm có giá cao nhất
select product_id, product_name, price
from products
where price = (select max(price) from products);
