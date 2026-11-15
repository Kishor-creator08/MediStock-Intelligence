   -- =====================================================
-- COMPLETE PROJECT: MEDISTOCK TRANSFER INTELLIGENCE
-- Database: MySQL 8.0
-- Includes: Database, tables, sample data, analysis queries,
-- transfer recommendations, views, summary, and stored procedure.
--
-- Safe to rerun for this sample project:
--   * CREATE DATABASE/TABLE IF NOT EXISTS
--   * INSERT IGNORE
--   * CREATE OR REPLACE VIEW
--   * DROP PROCEDURE IF EXISTS before creating the procedure
--
-- Note: This project uses synthetic sample data.
-- =====================================================


-- =====================================================
-- PROJECT: MEDISTOCK TRANSFER INTELLIGENCE
-- DATABASE: MySQL 8.0
-- =====================================================

-- 1. DATABASE CREATION

CREATE DATABASE IF NOT EXISTS medistock_intelligence;
USE medistock_intelligence;


-- 2. TABLE CREATION

CREATE TABLE IF NOT EXISTS hospitals (
    hospital_id INT PRIMARY KEY,
    hospital_name VARCHAR(100),
    city VARCHAR(50),
    hospital_type VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS medicines (
    medicine_id INT PRIMARY KEY,
    medicine_name VARCHAR(100),
    category VARCHAR(50),
    unit_price DECIMAL(10,2)
);

CREATE TABLE IF NOT EXISTS suppliers (
    supplier_id INT PRIMARY KEY,
    supplier_name VARCHAR(100),
    city VARCHAR(50),
    average_delivery_days INT
);

CREATE TABLE IF NOT EXISTS inventory (
    inventory_id INT PRIMARY KEY,
    hospital_id INT,
    medicine_id INT,
    supplier_id INT,
    batch_number VARCHAR(30),
    stock_quantity INT,
    reorder_level INT,
    expiry_date DATE,
    last_updated DATE,
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id),
    FOREIGN KEY (medicine_id) REFERENCES medicines(medicine_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);


-- 3. INSERT HOSPITAL DATA

INSERT IGNORE INTO hospitals VALUES
(1, 'Apollo Hospital', 'Chennai', 'Multi-Speciality'),
(2, 'Meenakshi Mission Hospital', 'Madurai', 'Multi-Speciality'),
(3, 'Government Hospital', 'Cuddalore', 'Government'),
(4, 'Velammal Medical College', 'Madurai', 'Multi-Speciality'),
(5, 'Kauvery Hospital', 'Trichy', 'Multi-Speciality');


-- 4. INSERT MEDICINE DATA

INSERT IGNORE INTO medicines VALUES
(101, 'Paracetamol', 'Tablet', 2.50),
(102, 'Amoxicillin', 'Antibiotic', 8.00),
(103, 'Cetirizine', 'Tablet', 3.00),
(104, 'Metformin', 'Diabetes', 5.50),
(105, 'Azithromycin', 'Antibiotic', 12.00),
(106, 'Omeprazole', 'Gastric', 6.00),
(107, 'Insulin', 'Injection', 150.00),
(108, 'Ibuprofen', 'Pain Relief', 4.00);


-- 5. INSERT SUPPLIER DATA

INSERT IGNORE INTO suppliers VALUES
(201, 'MedPlus Suppliers', 'Chennai', 3),
(202, 'HealthCare Distributors', 'Madurai', 5),
(203, 'Sri Medical Agencies', 'Trichy', 4),
(204, 'Global Pharma Supply', 'Coimbatore', 7),
(205, 'TamilNadu Med Supplies', 'Salem', 6);


-- 6. INSERT INVENTORY DATA

INSERT IGNORE INTO inventory VALUES
(1, 1, 101, 201, 'BATCH001', 500, 100, '2027-06-30', '2026-10-30'),
(2, 1, 102, 202, 'BATCH002', 40, 100, '2027-02-28', '2026-10-30'),
(3, 1, 103, 201, 'BATCH003', 300, 100, '2027-12-31', '2026-10-30'),
(4, 2, 101, 202, 'BATCH004', 30, 100, '2027-01-31', '2026-10-30'),
(5, 2, 104, 203, 'BATCH005', 250, 80, '2028-03-31', '2026-10-30'),
(6, 2, 105, 203, 'BATCH006', 20, 60, '2027-04-30', '2026-10-30'),
(7, 3, 101, 205, 'BATCH007', 400, 100, '2027-08-31', '2026-10-30'),
(8, 3, 106, 205, 'BATCH008', 25, 75, '2027-03-31', '2026-10-30'),
(9, 4, 107, 204, 'BATCH009', 15, 40, '2027-01-31', '2026-10-30'),
(10, 4, 108, 204, 'BATCH010', 200, 50, '2028-01-31', '2026-10-30'),
(11, 5, 102, 203, 'BATCH011', 180, 70, '2027-11-30', '2026-10-30'),
(12, 5, 104, 205, 'BATCH012', 35, 90, '2027-05-31', '2026-10-30');


-- =====================================================
-- 7. BASIC DATA ANALYSIS
-- =====================================================

SELECT * FROM hospitals;
SELECT * FROM medicines;
SELECT * FROM suppliers;
SELECT * FROM inventory;

SELECT COUNT(*) AS total_hospitals FROM hospitals;
SELECT COUNT(*) AS total_medicines FROM medicines;
SELECT COUNT(*) AS total_suppliers FROM suppliers;
SELECT COUNT(*) AS total_inventory_records FROM inventory;


-- =====================================================
-- 8. INNER JOIN - COMPLETE INVENTORY DETAILS
-- =====================================================

SELECT
    i.inventory_id,
    h.hospital_name,
    h.city,
    m.medicine_name,
    m.category,
    s.supplier_name,
    i.batch_number,
    i.stock_quantity,
    i.reorder_level,
    i.expiry_date
FROM inventory i
INNER JOIN hospitals h
    ON i.hospital_id = h.hospital_id
INNER JOIN medicines m
    ON i.medicine_id = m.medicine_id
INNER JOIN suppliers s
    ON i.supplier_id = s.supplier_id;


-- =====================================================
-- 9. STOCK SHORTAGE ANALYSIS
-- =====================================================

SELECT
    h.hospital_name,
    m.medicine_name,
    i.stock_quantity,
    i.reorder_level,
    (i.reorder_level - i.stock_quantity) AS shortage_quantity
FROM inventory i
INNER JOIN hospitals h
    ON i.hospital_id = h.hospital_id
INNER JOIN medicines m
    ON i.medicine_id = m.medicine_id
WHERE i.stock_quantity < i.reorder_level;


-- =====================================================
-- 10. CASE - STOCK STATUS CLASSIFICATION
-- =====================================================

SELECT
    h.hospital_name,
    m.medicine_name,
    i.stock_quantity,
    i.reorder_level,
    CASE
        WHEN i.stock_quantity < i.reorder_level
            THEN 'Shortage'
        WHEN i.stock_quantity > i.reorder_level * 2
            THEN 'Excess Stock'
        ELSE 'Normal'
    END AS stock_status
FROM inventory i
INNER JOIN hospitals h
    ON i.hospital_id = h.hospital_id
INNER JOIN medicines m
    ON i.medicine_id = m.medicine_id;


-- =====================================================
-- 11. ORDER BY - LOWEST STOCK FIRST
-- =====================================================

SELECT
    h.hospital_name,
    m.medicine_name,
    i.stock_quantity
FROM inventory i
INNER JOIN hospitals h
    ON i.hospital_id = h.hospital_id
INNER JOIN medicines m
    ON i.medicine_id = m.medicine_id
ORDER BY i.stock_quantity ASC;


-- =====================================================
-- 12. GROUP BY - HOSPITAL-WISE INVENTORY
-- =====================================================

SELECT
    h.hospital_name,
    COUNT(i.inventory_id) AS total_inventory_records,
    SUM(i.stock_quantity) AS total_stock_units
FROM hospitals h
LEFT JOIN inventory i
    ON h.hospital_id = i.hospital_id
GROUP BY h.hospital_id, h.hospital_name;


-- =====================================================
-- 13. GROUP BY - MEDICINE-WISE TOTAL STOCK
-- =====================================================

SELECT
    m.medicine_name,
    SUM(i.stock_quantity) AS total_stock
FROM medicines m
INNER JOIN inventory i
    ON m.medicine_id = i.medicine_id
GROUP BY m.medicine_id, m.medicine_name
ORDER BY total_stock DESC;


-- =====================================================
-- 14. HAVING - MEDICINES WITH LOW TOTAL STOCK
-- =====================================================

SELECT
    m.medicine_name,
    SUM(i.stock_quantity) AS total_stock
FROM medicines m
INNER JOIN inventory i
    ON m.medicine_id = i.medicine_id
GROUP BY m.medicine_id, m.medicine_name
HAVING SUM(i.stock_quantity) < 100;


-- =====================================================
-- 15. AGGREGATE FUNCTIONS
-- =====================================================

SELECT
    COUNT(*) AS total_records,
    SUM(stock_quantity) AS total_stock,
    AVG(stock_quantity) AS average_stock,
    MAX(stock_quantity) AS maximum_stock,
    MIN(stock_quantity) AS minimum_stock
FROM inventory;


-- =====================================================
-- 16. EXPIRY RISK ANALYSIS
-- =====================================================

SELECT
    h.hospital_name,
    m.medicine_name,
    i.batch_number,
    i.stock_quantity,
    i.expiry_date,
    DATEDIFF(i.expiry_date, CURDATE()) AS days_to_expiry,
    CASE
        WHEN i.expiry_date < CURDATE()
            THEN 'Expired'
        WHEN i.expiry_date <= DATE_ADD(CURDATE(), INTERVAL 90 DAY)
            THEN 'Near Expiry'
        ELSE 'Safe'
    END AS expiry_status
FROM inventory i
INNER JOIN hospitals h
    ON i.hospital_id = h.hospital_id
INNER JOIN medicines m
    ON i.medicine_id = m.medicine_id
ORDER BY i.expiry_date ASC;


-- =====================================================
-- 17. EXCESS STOCK ANALYSIS
-- =====================================================

SELECT
    h.hospital_name,
    m.medicine_name,
    i.stock_quantity,
    i.reorder_level,
    (i.stock_quantity - i.reorder_level) AS surplus_quantity
FROM inventory i
INNER JOIN hospitals h
    ON i.hospital_id = h.hospital_id
INNER JOIN medicines m
    ON i.medicine_id = m.medicine_id
WHERE i.stock_quantity > i.reorder_level * 2
ORDER BY surplus_quantity DESC;


-- =====================================================
-- 18. SUBQUERY - ABOVE AVERAGE STOCK
-- =====================================================

SELECT
    h.hospital_name,
    m.medicine_name,
    i.stock_quantity
FROM inventory i
INNER JOIN hospitals h
    ON i.hospital_id = h.hospital_id
INNER JOIN medicines m
    ON i.medicine_id = m.medicine_id
WHERE i.stock_quantity > (
    SELECT AVG(stock_quantity)
    FROM inventory
);


-- =====================================================
-- 19. CTE - HOSPITAL STOCK SUMMARY
-- =====================================================

WITH hospital_summary AS (
    SELECT
        hospital_id,
        SUM(stock_quantity) AS total_stock,
        COUNT(*) AS medicine_batches
    FROM inventory
    GROUP BY hospital_id
)
SELECT
    h.hospital_name,
    hs.total_stock,
    hs.medicine_batches
FROM hospital_summary hs
INNER JOIN hospitals h
    ON hs.hospital_id = h.hospital_id
ORDER BY hs.total_stock DESC;


-- =====================================================
-- 20. WINDOW FUNCTION - HOSPITAL STOCK RANKING
-- =====================================================

SELECT
    h.hospital_name,
    m.medicine_name,
    i.stock_quantity,
    RANK() OVER (
        PARTITION BY i.medicine_id
        ORDER BY i.stock_quantity DESC
    ) AS stock_rank
FROM inventory i
INNER JOIN hospitals h
    ON i.hospital_id = h.hospital_id
INNER JOIN medicines m
    ON i.medicine_id = m.medicine_id;


-- =====================================================
-- 21. SUPPLIER DELIVERY TIME ANALYSIS
-- =====================================================

SELECT
    supplier_name,
    city,
    average_delivery_days,
    CASE
        WHEN average_delivery_days <= 3 THEN 'Fast Delivery'
        WHEN average_delivery_days <= 5 THEN 'Medium Delivery'
        ELSE 'Slow Delivery'
    END AS delivery_category
FROM suppliers
ORDER BY average_delivery_days ASC;


-- =====================================================
-- 22. EXPIRY-AWARE TRANSFER + DONOR ALLOCATION
-- =====================================================

WITH donor_batches AS (
    SELECT
        inventory_id,
        hospital_id,
        medicine_id,
        batch_number,
        expiry_date,
        GREATEST(stock_quantity - reorder_level, 0)
            AS available_surplus
    FROM inventory
    WHERE expiry_date >= CURDATE()
      AND stock_quantity > reorder_level
),

recipient_shortages AS (
    SELECT
        hospital_id,
        medicine_id,
        SUM(GREATEST(reorder_level - stock_quantity, 0))
            AS required_quantity
    FROM inventory
    GROUP BY hospital_id, medicine_id
    HAVING SUM(GREATEST(reorder_level - stock_quantity, 0)) > 0
),

transfer_candidates AS (
    SELECT
        db.inventory_id AS donor_batch_id,
        db.hospital_id AS donor_id,
        rs.hospital_id AS recipient_id,
        db.medicine_id,
        db.batch_number,
        db.expiry_date,
        db.available_surplus,
        rs.required_quantity,

        ROW_NUMBER() OVER (
            PARTITION BY rs.hospital_id, rs.medicine_id
            ORDER BY db.expiry_date ASC,
                     db.available_surplus DESC
        ) AS donor_rank,

        ROW_NUMBER() OVER (
            PARTITION BY db.inventory_id
            ORDER BY rs.required_quantity DESC,
                     rs.hospital_id
        ) AS recipient_rank

    FROM donor_batches db
    INNER JOIN recipient_shortages rs
        ON db.medicine_id = rs.medicine_id
       AND db.hospital_id <> rs.hospital_id
)

SELECT
    h1.hospital_name AS donor_hospital,
    h2.hospital_name AS recipient_hospital,
    m.medicine_name,
    tc.batch_number AS donor_batch,
    tc.expiry_date,
    tc.available_surplus,
    tc.required_quantity,
    LEAST(
        tc.available_surplus,
        tc.required_quantity
    ) AS suggested_transfer_quantity

FROM transfer_candidates tc

INNER JOIN hospitals h1
    ON tc.donor_id = h1.hospital_id

INNER JOIN hospitals h2
    ON tc.recipient_id = h2.hospital_id

INNER JOIN medicines m
    ON tc.medicine_id = m.medicine_id

WHERE tc.donor_rank = 1
  AND tc.recipient_rank = 1

ORDER BY tc.expiry_date ASC;


-- =====================================================
-- 23. FINAL PROJECT SUMMARY
-- =====================================================

SELECT
    COUNT(*) AS total_batches,
    SUM(stock_quantity) AS total_stock_units,
    SUM(stock_quantity * m.unit_price) AS total_stock_value,
    SUM(
        CASE
            WHEN stock_quantity < reorder_level THEN 1
            ELSE 0
        END
    ) AS shortage_batches,
    SUM(
        CASE
            WHEN stock_quantity > reorder_level * 2 THEN 1
            ELSE 0
        END
    ) AS excess_batches
FROM inventory i
INNER JOIN medicines m
    ON i.medicine_id = m.medicine_id;


-- =====================================================
-- END OF MEDISTOCK TRANSFER INTELLIGENCE PROJECT
-- =====================================================
USE medistock_intelligence;

-- 1. Complete Inventory Details
CREATE OR REPLACE VIEW vw_inventory_details AS
SELECT
    i.inventory_id,
    h.hospital_name,
    h.city,
    m.medicine_name,
    m.category,
    s.supplier_name,
    i.batch_number,
    i.stock_quantity,
    i.reorder_level,
    i.expiry_date
FROM inventory i
INNER JOIN hospitals h
    ON i.hospital_id = h.hospital_id
INNER JOIN medicines m
    ON i.medicine_id = m.medicine_id
INNER JOIN suppliers s
    ON i.supplier_id = s.supplier_id;


-- 2. Stock Shortage Report
CREATE OR REPLACE VIEW vw_stock_shortages AS
SELECT
    h.hospital_name,
    m.medicine_name,
    i.stock_quantity,
    i.reorder_level,
    (i.reorder_level - i.stock_quantity) AS shortage_quantity
FROM inventory i
INNER JOIN hospitals h
    ON i.hospital_id = h.hospital_id
INNER JOIN medicines m
    ON i.medicine_id = m.medicine_id
WHERE i.stock_quantity < i.reorder_level;


-- 3. Expiry Risk Report
CREATE OR REPLACE VIEW vw_expiry_risk AS
SELECT
    h.hospital_name,
    m.medicine_name,
    i.batch_number,
    i.stock_quantity,
    i.expiry_date,
    DATEDIFF(i.expiry_date, CURDATE()) AS days_to_expiry,
    CASE
        WHEN i.expiry_date < CURDATE() THEN 'Expired'
        ELSE 'Expiring Soon'
    END AS expiry_status
FROM inventory i
INNER JOIN hospitals h
    ON i.hospital_id = h.hospital_id
INNER JOIN medicines m
    ON i.medicine_id = m.medicine_id
WHERE i.expiry_date <= DATE_ADD(CURDATE(), INTERVAL 90 DAY);


-- 4. Hospital-wise Stock Summary
CREATE OR REPLACE VIEW vw_hospital_stock_summary AS
SELECT
    h.hospital_name,
    COUNT(i.inventory_id) AS total_batches,
    SUM(i.stock_quantity) AS total_stock,
    SUM(i.stock_quantity * m.unit_price) AS total_stock_value
FROM hospitals h
LEFT JOIN inventory i
    ON h.hospital_id = i.hospital_id
LEFT JOIN medicines m
    ON i.medicine_id = m.medicine_id
GROUP BY h.hospital_id, h.hospital_name;


-- Test all four views
SELECT * FROM vw_inventory_details;

SELECT * FROM vw_stock_shortages;

SELECT * FROM vw_expiry_risk;

SELECT * FROM vw_hospital_stock_summary;

USE medistock_intelligence;

DROP PROCEDURE IF EXISTS GetStockShortages;

DELIMITER //

CREATE PROCEDURE GetStockShortages()
BEGIN
    SELECT
        h.hospital_name,
        m.medicine_name,
        i.stock_quantity,
        i.reorder_level,
        (i.reorder_level - i.stock_quantity) AS shortage_quantity
    FROM inventory i
    INNER JOIN hospitals h
        ON i.hospital_id = h.hospital_id
    INNER JOIN medicines m
        ON i.medicine_id = m.medicine_id
    WHERE i.stock_quantity < i.reorder_level;
END //

DELIMITER ;

-- Execute the Stored Procedure
CALL GetStockShortages();

USE medistock_intelligence;

SELECT
    h.hospital_name,
    COUNT(DISTINCT i.medicine_id) AS total_medicines,
    SUM(i.stock_quantity) AS total_stock,
    SUM(i.stock_quantity * m.unit_price) AS total_stock_value
FROM hospitals h
JOIN inventory i
    ON h.hospital_id = i.hospital_id
JOIN medicines m
    ON i.medicine_id = m.medicine_id
GROUP BY h.hospital_name
ORDER BY total_stock_value DESC;

DESCRIBE hospitals;

DESCRIBE medicines;

SELECT
    h.hospital_name,
    m.medicine_name,
    i.stock_quantity,
    i.reorder_level,
    (i.reorder_level - i.stock_quantity) AS shortage_quantity
FROM inventory i
JOIN hospitals h
    ON i.hospital_id = h.hospital_id
JOIN medicines m
    ON i.medicine_id = m.medicine_id
WHERE i.stock_quantity <= i.reorder_level
ORDER BY shortage_quantity DESC;


SELECT
    h.hospital_name,
    m.medicine_name,
    i.batch_number,
    i.stock_quantity,
    i.expiry_date,
    DATEDIFF(i.expiry_date, CURDATE()) AS days_to_expiry,

    CASE
        WHEN i.expiry_date < CURDATE()
            THEN 'Expired'
        WHEN i.expiry_date <= DATE_ADD(CURDATE(), INTERVAL 30 DAY)
            THEN 'Critical'
        WHEN i.expiry_date <= DATE_ADD(CURDATE(), INTERVAL 90 DAY)
            THEN 'Warning'
        ELSE 'Safe'
    END AS expiry_status

FROM inventory i
JOIN hospitals h
    ON i.hospital_id = h.hospital_id
JOIN medicines m
    ON i.medicine_id = m.medicine_id

WHERE i.expiry_date <= DATE_ADD(CURDATE(), INTERVAL 90 DAY)

ORDER BY i.expiry_date ASC;

DESCRIBE suppliers;


SELECT
    supplier_name,
    city,
    average_delivery_days,
    CASE
        WHEN average_delivery_days <= 3 THEN 'Fast'
        WHEN average_delivery_days <= 5 THEN 'Moderate'
        ELSE 'Slow'
    END AS delivery_performance
FROM suppliers
ORDER BY average_delivery_days ASC;


SELECT
    h.hospital_name,
    SUM(i.stock_quantity) AS total_stock,
    SUM(i.stock_quantity * m.unit_price) AS total_inventory_value
FROM inventory i
JOIN hospitals h
    ON i.hospital_id = h.hospital_id
JOIN medicines m
    ON i.medicine_id = m.medicine_id
GROUP BY h.hospital_name
ORDER BY total_inventory_value DESC;


SELECT
    m.medicine_name,
    m.category,
    SUM(i.stock_quantity) AS total_stock,
    COUNT(DISTINCT i.hospital_id) AS hospitals_count,
    SUM(i.stock_quantity * m.unit_price) AS total_stock_value
FROM inventory i
JOIN medicines m
    ON i.medicine_id = m.medicine_id
GROUP BY
    m.medicine_id,
    m.medicine_name,
    m.category
ORDER BY total_stock_value DESC;


SELECT
    h.hospital_name,
    m.medicine_name,
    s.supplier_name,
    i.stock_quantity,
    i.reorder_level,

    (i.reorder_level - i.stock_quantity)
        AS reorder_quantity,

    m.unit_price,

    (i.reorder_level - i.stock_quantity)
        * m.unit_price AS estimated_reorder_cost,

    s.average_delivery_days

FROM inventory i

JOIN hospitals h
    ON i.hospital_id = h.hospital_id

JOIN medicines m
    ON i.medicine_id = m.medicine_id

JOIN suppliers s
    ON i.supplier_id = s.supplier_id

WHERE i.stock_quantity <= i.reorder_level

ORDER BY estimated_reorder_cost DESC;


SELECT
    s.supplier_name,
    COUNT(*) AS medicines_to_reorder,
    SUM(i.reorder_level - i.stock_quantity)
        AS total_reorder_quantity,
    SUM(
        (i.reorder_level - i.stock_quantity)
        * m.unit_price
    ) AS total_procurement_cost,
    s.average_delivery_days
FROM inventory i
JOIN medicines m
    ON i.medicine_id = m.medicine_id
JOIN suppliers s
    ON i.supplier_id = s.supplier_id
WHERE i.stock_quantity <= i.reorder_level
GROUP BY
    s.supplier_id,
    s.supplier_name,
    s.average_delivery_days
ORDER BY total_procurement_cost DESC;


SELECT
    h.hospital_name,
    m.medicine_name,
    i.batch_number,
    i.stock_quantity,
    m.unit_price,
    i.expiry_date,

    (i.stock_quantity * m.unit_price)
        AS expiry_risk_value,

    DATEDIFF(i.expiry_date, CURDATE())
        AS days_to_expiry

FROM inventory i
JOIN hospitals h
    ON i.hospital_id = h.hospital_id
JOIN medicines m
    ON i.medicine_id = m.medicine_id

WHERE i.expiry_date <= DATE_ADD(
    CURDATE(), INTERVAL 90 DAY
)

ORDER BY expiry_risk_value DESC;


SELECT
    h.hospital_name,
    m.medicine_name,
    i.stock_quantity,
    i.reorder_level,
    i.expiry_date,

    CASE
        WHEN i.stock_quantity <= i.reorder_level
        THEN 'Low Stock'
        ELSE 'Stock Available'
    END AS stock_status,

    CASE
        WHEN i.expiry_date < CURDATE()
        THEN 'Expired'
        WHEN i.expiry_date <= DATE_ADD(
            CURDATE(), INTERVAL 30 DAY
        )
        THEN 'Critical'
        WHEN i.expiry_date <= DATE_ADD(
            CURDATE(), INTERVAL 90 DAY
        )
        THEN 'Warning'
        ELSE 'Safe'
    END AS expiry_status,

    CASE
        WHEN i.expiry_date < CURDATE()
        THEN 'Immediate Attention'
        WHEN i.stock_quantity <= i.reorder_level
             AND i.expiry_date <= DATE_ADD(
                 CURDATE(), INTERVAL 90 DAY
             )
        THEN 'High Priority'
        WHEN i.stock_quantity <= i.reorder_level
        THEN 'Reorder Required'
        WHEN i.expiry_date <= DATE_ADD(
            CURDATE(), INTERVAL 90 DAY
        )
        THEN 'Expiry Monitoring'
        ELSE 'Normal'
    END AS action_priority

FROM inventory i
JOIN hospitals h
    ON i.hospital_id = h.hospital_id
JOIN medicines m
    ON i.medicine_id = m.medicine_id

ORDER BY
    CASE
        WHEN i.expiry_date < CURDATE() THEN 1
        WHEN i.stock_quantity <= i.reorder_level
             AND i.expiry_date <= DATE_ADD(
                 CURDATE(), INTERVAL 90 DAY
             ) THEN 2
        WHEN i.stock_quantity <= i.reorder_level THEN 3
        WHEN i.expiry_date <= DATE_ADD(
            CURDATE(), INTERVAL 90 DAY
        ) THEN 4
        ELSE 5
    END;

DESCRIBE inventory;

SELECT
    COUNT(*) AS total_inventory_records,
    COUNT(DISTINCT inventory_id) AS unique_records,
    SUM(stock_quantity) AS total_stock
FROM inventory;

SELECT
    SUM(hospital_id IS NULL) AS missing_hospital,
    SUM(medicine_id IS NULL) AS missing_medicine,
    SUM(supplier_id IS NULL) AS missing_supplier,
    SUM(stock_quantity IS NULL) AS missing_stock,
    SUM(reorder_level IS NULL) AS missing_reorder,
    SUM(expiry_date IS NULL) AS missing_expiry
FROM inventory;

SELECT
    hospital_id,
    medicine_id,
    batch_number,
    COUNT(*) AS duplicate_count
FROM inventory
GROUP BY
    hospital_id,
    medicine_id,
    batch_number
HAVING COUNT(*) > 1;

SELECT
    hospital_id,
    medicine_id,
    batch_number,
    COUNT(*) AS duplicate_count
FROM inventory
GROUP BY hospital_id, medicine_id, batch_number
HAVING COUNT(*) > 1;