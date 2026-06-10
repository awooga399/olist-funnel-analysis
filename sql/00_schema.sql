CREATE TABLE olist_customers_dataset (
    customer_id              varchar(50) PRIMARY KEY,
    customer_unique_id       varchar(50) NOT NULL,
    customer_zip_code_prefix integer,
    customer_city            varchar(100),
    customer_state           char(2)
);

CREATE TABLE olist_orders_dataset (
    order_id                      varchar(50) PRIMARY KEY,
    customer_id                   varchar(50) NOT NULL,
    order_status                  varchar(20),
    order_purchase_timestamp      timestamp   NOT NULL,
    order_approved_at             timestamp,
    order_delivered_carrier_date  timestamp,
    order_delivered_customer_date timestamp,
    order_estimated_delivery_date timestamp,
    FOREIGN KEY (customer_id) REFERENCES olist_customers_dataset (customer_id)
);

CREATE TABLE olist_order_items_dataset (
    order_id            varchar(50) NOT NULL,
    order_item_id       integer     NOT NULL,
    product_id          varchar(50) NOT NULL,
    seller_id           varchar(50),
    shipping_limit_date timestamp,
    price               numeric(10,2),
    freight_value       numeric(10,2),
    PRIMARY KEY (order_id, order_item_id),
    FOREIGN KEY (order_id) REFERENCES olist_orders_dataset (order_id)
);

CREATE TABLE olist_order_payments_dataset (
    order_id             varchar(50) NOT NULL,
    payment_sequential   integer     NOT NULL,
    payment_type         varchar(20),
    payment_installments integer,
    payment_value        numeric(10,2),
    PRIMARY KEY (order_id, payment_sequential),
    FOREIGN KEY (order_id) REFERENCES olist_orders_dataset (order_id)
);