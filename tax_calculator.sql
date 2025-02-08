-- Create the tax_calculator database
CREATE DATABASE IF NOT EXISTS tax_calculator;

-- Use the tax_calculator database
USE tax_calculator;

-- Create countries table
CREATE TABLE countries (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    vat_applicable ENUM('spain', 'eu', 'non_eu') NOT NULL,
    vat_rate DECIMAL(5,2) NOT NULL
);

INSERT INTO countries (id, name, vat_applicable, vat_rate) VALUES
(1, 'Spain', 'spain', 21.00),         -- Country: Spain
(2, 'Germany', 'eu', 19.00),          -- Country: Germany (EU)
(3, 'France', 'eu', 20.00),           -- Country: France (EU)
(4, 'Italy', 'eu', 22.00),            -- Country: Italy (EU)
(5, 'Portugal', 'eu', 23.00),         -- Country: Portugal (EU)
(6, 'Netherlands', 'eu', 21.00),      -- Country: Netherlands (EU)
(7, 'Belgium', 'eu', 21.00),          -- Country: Belgium (EU)
(8, 'United Kingdom', 'non_eu', 20.00),-- Country: United Kingdom (Non-EU)
(9, 'USA', 'non_eu', 7.25),           -- Country: USA (Non-EU)
(10, 'Canada', 'non_eu', 5.00),       -- Country: Canada (Non-EU)
(11, 'Australia', 'non_eu', 10.00),   -- Country: Australia (Non-EU)
(12, 'Japan', 'non_eu', 10.00),       -- Country: Japan (Non-EU)
(13, 'New Zealand', 'non_eu', 15.00); -- Country: New Zealand (Non-EU)


-- Create product_types table
CREATE TABLE product_types (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE
);

INSERT INTO product_types (id, name) VALUES
(2, 'digital'),  -- Product Type: Digital
(1, 'good'),     -- Product Type: Physical (Good)
(3, 'onsite');   -- Product Type: Onsite


-- Create buyers table
CREATE TABLE buyers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    country_id INT NOT NULL,
    is_company BOOLEAN NOT NULL,
    FOREIGN KEY (country_id) REFERENCES countries(id)
);

INSERT INTO buyers (id, name, country_id, is_company) VALUES
(11, 'John Doe', 1, 0),      -- Buyer: John Doe, Country: Spain, Individual
(12, 'Jane Smith', 2, 0),     -- Buyer: Jane Smith, Country: Germany, Individual
(13, 'Acme Corp', 9, 1),      -- Buyer: Acme Corp, Country: USA, Company
(14, 'Munchitos Inc.', 13, 1),-- Buyer: Munchitos Inc., Country: New Zealand, Company
(15, 'Luis Pérez', 1, 0),     -- Buyer: Luis Pérez, Country: Spain, Individual
(16, 'Tech Solutions', 3, 1), -- Buyer: Tech Solutions, Country: France, Company
(17, 'Maria Garcia', 4, 0),   -- Buyer: Maria Garcia, Country: Italy, Individual
(18, 'Global Ventures', 8, 1),-- Buyer: Global Ventures, Country: United Kingdom, Company
(19, 'Emma White', 11, 0),    -- Buyer: Emma White, Country: Australia, Individual
(20, 'Innovative Group', 10, 1); -- Buyer: Innovative Group, Country: Portugal, Company


-- Create products table (Based on Munchitos S.A. business model)
CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    product_type_id INT NOT NULL,
    price_in_euros DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (product_type_id) REFERENCES product_types(id)
);

INSERT INTO products (id, name, product_type_id, price_in_euros) VALUES
(1, 'Spanish Olive Oil', 1, 12.99),                     -- Physical Product: Spanish Olive Oil
(2, 'Paella Kit', 1, 39.99),                            -- Physical Product: Paella Kit
(3, 'Ceramic Mug', 1, 6.99),                            -- Physical Product: Ceramic Mug
(4, 'Flamenco Guitar', 1, 199.99),                      -- Physical Product: Flamenco Guitar
(5, 'Churros Maker', 1, 29.99),                         -- Physical Product: Churros Maker
(6, 'Spanish Language Course Online', 2, 49.99),       -- Digital Product: Spanish Language Course Online
(7, 'Spanish Cooking Class Online', 2, 79.99),         -- Digital Product: Spanish Cooking Class Online
(8, 'Spanish Wine Tasting Webinar', 2, 24.99),         -- Digital Product: Spanish Wine Tasting Webinar
(9, 'Virtual Flamenco Dance Lesson', 2, 39.99),        -- Digital Product: Virtual Flamenco Dance Lesson
(10, 'Spanish History eBook', 2, 14.99),               -- Digital Product: Spanish History eBook
(11, 'Spanish Cuisine Catering', 3, 250.00),           -- Onsite Product: Spanish Cuisine Catering
(12, 'Flamenco Dance Show for Event', 3, 500.00),       -- Onsite Product: Flamenco Dance Show for Event
(13, 'Spanish Festival Organizing', 3, 300.00),        -- Onsite Product: Spanish Festival Organizing
(14, 'Private Chef for Paella Party', 3, 350.00),      -- Onsite Product: Private Chef for Paella Party
(15, 'Private Flamenco Guitar Lesson', 3, 100.00);     -- Onsite Product: Private Flamenco Guitar Lesson


CREATE TABLE sales (
    id INT AUTO_INCREMENT PRIMARY KEY,
    buyer_id INT NOT NULL,
    sale_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    calculated_tax DECIMAL(10,2) NOT NULL DEFAULT 0,
    FOREIGN KEY (buyer_id) REFERENCES buyers(id) ON DELETE CASCADE
);


CREATE TABLE sold_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sale_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Insert sales for various buyers
-- Sale for John Doe (buyer in Spain)
INSERT INTO sales (buyer_id) VALUES (11);
-- Spanish Olive Oil (physical product, quantity 1)
INSERT INTO sold_items (sale_id, product_id, quantity) VALUES (LAST_INSERT_ID(), 1, 1);

-- Sale for Jane Smith (buyer in Germany)
INSERT INTO sales (buyer_id) VALUES (12);
-- Paella Kit (physical product, quantity 2)
INSERT INTO sold_items (sale_id, product_id, quantity) VALUES (LAST_INSERT_ID(), 2, 2);

-- Sale for Acme Corp (buyer in USA)
INSERT INTO sales (buyer_id) VALUES (13);
-- Ceramic Mug (physical product, quantity 5)
INSERT INTO sold_items (sale_id, product_id, quantity) VALUES (LAST_INSERT_ID(), 3, 5);

-- Sale for Munchitos Inc. (buyer in New Zealand) - Digital Product
INSERT INTO sales (buyer_id) VALUES (14);
-- Spanish Language Course Online (digital product, quantity 1)
INSERT INTO sold_items (sale_id, product_id, quantity) VALUES (LAST_INSERT_ID(), 6, 1);

-- Sale for Luis Pérez (buyer in Spain)
INSERT INTO sales (buyer_id) VALUES (15);
-- Flamenco Guitar (physical product, quantity 1)
INSERT INTO sold_items (sale_id, product_id, quantity) VALUES (LAST_INSERT_ID(), 4, 1);

-- Sale for Tech Solutions (buyer in France) - Digital Product
INSERT INTO sales (buyer_id) VALUES (16);
-- Spanish Cooking Class Online (digital product, quantity 1)
INSERT INTO sold_items (sale_id, product_id, quantity) VALUES (LAST_INSERT_ID(), 7, 1);

-- Sale for Maria Garcia (buyer in Italy) - Digital Product
INSERT INTO sales (buyer_id) VALUES (17);
-- Spanish Wine Tasting Webinar (digital product, quantity 1)
INSERT INTO sold_items (sale_id, product_id, quantity) VALUES (LAST_INSERT_ID(), 8, 1);

-- Sale for Global Ventures (buyer in United Kingdom) - Digital Product
INSERT INTO sales (buyer_id) VALUES (18);
-- Virtual Flamenco Dance Lesson (digital product, quantity 1)
INSERT INTO sold_items (sale_id, product_id, quantity) VALUES (LAST_INSERT_ID(), 9, 1);

-- Sale for Emma White (buyer in Australia) - Digital Product
INSERT INTO sales (buyer_id) VALUES (19);
-- Spanish History eBook (digital product, quantity 1)
INSERT INTO sold_items (sale_id, product_id, quantity) VALUES (LAST_INSERT_ID(), 10, 1);

-- Sale for Innovative Group (buyer in Portugal) - Onsite Sale (product type 3)
INSERT INTO sales (buyer_id) VALUES (20);
-- Spanish Festival Organizing (onsite product, quantity 3)
INSERT INTO sold_items (sale_id, product_id, quantity) VALUES (LAST_INSERT_ID(), 13, 3);


-- Avoiding recalculating the tax for sales that have already been processed
ALTER TABLE sales
ADD COLUMN processed BOOLEAN NOT NULL DEFAULT FALSE;
