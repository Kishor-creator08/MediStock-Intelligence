
import mysql.connector
from getpass import getpass

# DATABASE CONNECTION
password = getpass("Enter MySQL root password: ")

conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password=password,
    database="medistock_intelligence",
    port=3306
)

cursor = conn.cursor()

# ANALYSIS FUNCTION
def run_analysis(title, query):
    print("\n")
    print("=" * 90)
    print(title)
    print("=" * 90)

    cursor.execute(query)

    headers = [column[0] for column in cursor.description]
    rows = cursor.fetchall()

    print(" | ".join(headers))
    print("-" * 90)

    for row in rows:
        print(" | ".join(str(value) for value in row))

    print("-" * 90)
    print("Total records:", len(rows))


# 1. HOSPITAL-WISE INVENTORY
run_analysis("1. HOSPITAL-WISE INVENTORY", """
SELECT h.hospital_name,
       COUNT(i.inventory_id) AS total_records,
       SUM(i.stock_quantity) AS total_stock,
       SUM(i.stock_quantity * m.unit_price) AS inventory_value
FROM hospitals h
JOIN inventory i ON h.hospital_id = i.hospital_id
JOIN medicines m ON i.medicine_id = m.medicine_id
GROUP BY h.hospital_id, h.hospital_name
ORDER BY total_stock DESC;
""")


# 2. LOW STOCK ANALYSIS
run_analysis("2. LOW STOCK ANALYSIS", """
SELECT h.hospital_name, m.medicine_name,
       i.stock_quantity, i.reorder_level,
       i.reorder_level - i.stock_quantity AS shortage
FROM inventory i
JOIN hospitals h ON i.hospital_id = h.hospital_id
JOIN medicines m ON i.medicine_id = m.medicine_id
WHERE i.stock_quantity < i.reorder_level
ORDER BY shortage DESC;
""")


# 3. EXPIRY RISK ANALYSIS
run_analysis("3. EXPIRY RISK ANALYSIS", """
SELECT h.hospital_name, m.medicine_name,
       i.batch_number, i.stock_quantity,
       i.expiry_date,
       DATEDIFF(i.expiry_date, CURDATE()) AS days_remaining
FROM inventory i
JOIN hospitals h ON i.hospital_id = h.hospital_id
JOIN medicines m ON i.medicine_id = m.medicine_id
WHERE i.expiry_date <= DATE_ADD(CURDATE(), INTERVAL 90 DAY)
ORDER BY i.expiry_date;
""")


# 4. SUPPLIER DELIVERY PERFORMANCE
run_analysis("4. SUPPLIER DELIVERY PERFORMANCE", """
SELECT supplier_name, city, average_delivery_days,
       CASE
           WHEN average_delivery_days <= 3 THEN 'Fast'
           WHEN average_delivery_days <= 5 THEN 'Moderate'
           ELSE 'Slow'
       END AS delivery_status
FROM suppliers
ORDER BY average_delivery_days;
""")


# 5. HOSPITAL INVENTORY COST
run_analysis("5. HOSPITAL INVENTORY COST", """
SELECT h.hospital_name,
       SUM(i.stock_quantity * m.unit_price) AS total_inventory_value
FROM hospitals h
JOIN inventory i ON h.hospital_id = i.hospital_id
JOIN medicines m ON i.medicine_id = m.medicine_id
GROUP BY h.hospital_id, h.hospital_name
ORDER BY total_inventory_value DESC;
""")


# 6. MEDICINE-WISE INVENTORY
run_analysis("6. MEDICINE-WISE INVENTORY", """
SELECT m.medicine_name, m.category,
       SUM(i.stock_quantity) AS total_stock,
       COUNT(DISTINCT i.hospital_id) AS hospitals_count,
       SUM(i.stock_quantity * m.unit_price) AS inventory_value
FROM medicines m
JOIN inventory i ON m.medicine_id = i.medicine_id
GROUP BY m.medicine_id, m.medicine_name, m.category
ORDER BY total_stock DESC;
""")


# 7. SMART REORDER ANALYSIS
run_analysis("7. SMART REORDER ANALYSIS", """
SELECT h.hospital_name, m.medicine_name,
       s.supplier_name,
       i.stock_quantity, i.reorder_level,
       (i.reorder_level - i.stock_quantity) AS reorder_quantity,
       m.unit_price,
       (i.reorder_level - i.stock_quantity) * m.unit_price AS procurement_cost,
       s.average_delivery_days
FROM inventory i
JOIN hospitals h ON i.hospital_id = h.hospital_id
JOIN medicines m ON i.medicine_id = m.medicine_id
JOIN suppliers s ON i.supplier_id = s.supplier_id
WHERE i.stock_quantity < i.reorder_level
ORDER BY procurement_cost DESC;
""")


# 8. SUPPLIER-WISE PROCUREMENT
run_analysis("8. SUPPLIER-WISE PROCUREMENT", """
SELECT s.supplier_name,
       COUNT(DISTINCT m.medicine_id) AS medicine_count,
       SUM(i.reorder_level - i.stock_quantity) AS total_order_quantity,
       SUM((i.reorder_level - i.stock_quantity) * m.unit_price)
           AS procurement_cost,
       s.average_delivery_days
FROM inventory i
JOIN suppliers s ON i.supplier_id = s.supplier_id
JOIN medicines m ON i.medicine_id = m.medicine_id
WHERE i.stock_quantity < i.reorder_level
GROUP BY s.supplier_id, s.supplier_name,
         s.average_delivery_days
ORDER BY procurement_cost DESC;
""")


# 9. EXPIRY FINANCIAL RISK
run_analysis("9. EXPIRY FINANCIAL RISK", """
SELECT h.hospital_name, m.medicine_name,
       i.batch_number, i.stock_quantity,
       m.unit_price,
       (i.stock_quantity * m.unit_price) AS at_risk_value,
       i.expiry_date,
       DATEDIFF(i.expiry_date, CURDATE()) AS days_remaining
FROM inventory i
JOIN hospitals h ON i.hospital_id = h.hospital_id
JOIN medicines m ON i.medicine_id = m.medicine_id
WHERE i.expiry_date <= DATE_ADD(CURDATE(), INTERVAL 90 DAY)
ORDER BY at_risk_value DESC;
""")


# 10. OVERALL INVENTORY RISK CLASSIFICATION
run_analysis("10. OVERALL INVENTORY RISK", """
SELECT h.hospital_name, m.medicine_name,
       i.stock_quantity, i.reorder_level,
       i.expiry_date,
       CASE
           WHEN i.stock_quantity < i.reorder_level
               THEN 'Low Stock'
           ELSE 'Stock Available'
       END AS stock_status,
       CASE
           WHEN DATEDIFF(i.expiry_date, CURDATE()) < 0
               THEN 'Expired'
           WHEN DATEDIFF(i.expiry_date, CURDATE()) <= 90
               THEN 'Warning'
           ELSE 'Safe'
       END AS expiry_status,
       CASE
           WHEN i.stock_quantity < i.reorder_level
                AND DATEDIFF(i.expiry_date, CURDATE()) <= 90
               THEN 'High Priority'
           WHEN i.stock_quantity < i.reorder_level
               THEN 'Reorder Required'
           WHEN DATEDIFF(i.expiry_date, CURDATE()) <= 90
               THEN 'Expiry Attention'
           ELSE 'Normal'
       END AS overall_risk
FROM inventory i
JOIN hospitals h ON i.hospital_id = h.hospital_id
JOIN medicines m ON i.medicine_id = m.medicine_id
ORDER BY overall_risk, h.hospital_name;
""")

cursor.close()
conn.close()

print("\n")
print("=" * 90)
print("MEDISTOCK INTELLIGENCE - ALL 10 ANALYSES COMPLETED!")
print("=" * 90)
