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

-- Insert sample data into countries 
INSERT INTO countries (name, vat_applicable, vat_rate) VALUES
('Spain', 'spain', 21.00),
('France', 'eu', 20.00),
('Germany', 'eu', 19.00),
('Italy', 'eu', 22.00),
('Netherlands', 'eu', 21.00),
('USA', 'non_eu', 23.00),  
('UK', 'non_eu', 20.00); 

-- Create product_types table
CREATE TABLE product_types (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- Insert product types (Aligned with Munchitos S.A. business model)
INSERT INTO product_types (name) VALUES
('physical_goods'),
('digital_services'),
('onsite_services');

-- Create buyers table
CREATE TABLE buyers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    country_id INT NOT NULL,
    is_company BOOLEAN NOT NULL,
    FOREIGN KEY (country_id) REFERENCES countries(id)
);

-- Insert buyers (Majority from EU)
INSERT INTO buyers (name, country_id, is_company) VALUES
('Carlos Gómez', 1, FALSE),  -- Spain (Spain)
('Empresa Innovadora S.L.', 1, TRUE),  -- Spain (Spain)
('Alice Martin', 2, FALSE),  -- France (EU)
('TechCorp GmbH', 3, TRUE),  -- Germany (EU)
('Luca Moretti', 4, FALSE),  -- Italy (EU)
('E-Commerce Solutions B.V.', 5, TRUE), -- Netherlands (EU)
('Michael Johnson', 6, FALSE), -- USA (Non-EU)
('Innovate Ltd.', 7, TRUE); -- UK (Non-EU)

-- Create products table (Based on Munchitos S.A. business model)
CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    product_type_id INT NOT NULL,
    price_in_euros DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (product_type_id) REFERENCES product_types(id)
);

-- Insert products (Relevant to Munchitos S.A. offerings)
INSERT INTO products (name, product_type_id, price_in_euros) VALUES
('Bag of Munchitos Chips', 1, 2.50),  -- Physical good
('Munchitos Cooking Webinar', 2, 30.00), -- Digital service
('In-Person Snack Tasting', 3, 15.00),  -- On-site service
('Munchitos Gift Box', 1, 25.00),  -- Physical good
('Exclusive Snack Recipe E-Book', 2, 5.00); -- Digital service
