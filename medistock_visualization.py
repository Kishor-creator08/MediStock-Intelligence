
import mysql.connector
from getpass import getpass
import matplotlib.pyplot as plt

password = getpass("Enter MySQL root password: ")

conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password=password,
    database="medistock_intelligence",
    port=3306
)

cursor = conn.cursor()

# CHART 1: Hospital-wise Inventory Value
cursor.execute("""
SELECT h.hospital_name,
       SUM(i.stock_quantity * m.unit_price)
FROM hospitals h
JOIN inventory i ON h.hospital_id = i.hospital_id
JOIN medicines m ON i.medicine_id = m.medicine_id
GROUP BY h.hospital_id, h.hospital_name
ORDER BY SUM(i.stock_quantity * m.unit_price) DESC
""")

data = cursor.fetchall()
hospitals = [row[0] for row in data]
values = [float(row[1]) for row in data]

plt.figure(figsize=(10, 5))
plt.bar(hospitals, values)
plt.title("Hospital-wise Inventory Value")
plt.xlabel("Hospitals")
plt.ylabel("Inventory Value (Rs.)")
plt.xticks(rotation=25, ha="right")
plt.tight_layout()
plt.savefig("hospital_inventory_value.png", dpi=300)
plt.show()

# CHART 2: Low Stock Shortage
cursor.execute("""
SELECT CONCAT(h.hospital_name, ' - ', m.medicine_name),
       i.reorder_level - i.stock_quantity
FROM inventory i
JOIN hospitals h ON i.hospital_id = h.hospital_id
JOIN medicines m ON i.medicine_id = m.medicine_id
WHERE i.stock_quantity < i.reorder_level
ORDER BY i.reorder_level - i.stock_quantity DESC
""")

data = cursor.fetchall()
items = [row[0] for row in data]
shortages = [int(row[1]) for row in data]

plt.figure(figsize=(11, 6))
plt.barh(items, shortages)
plt.title("Medicine-wise Stock Shortage")
plt.xlabel("Shortage Units")
plt.ylabel("Hospital - Medicine")
plt.tight_layout()
plt.savefig("low_stock_shortage.png", dpi=300)
plt.show()

# CHART 3: Medicine-wise Stock Distribution
cursor.execute("""
SELECT m.medicine_name, SUM(i.stock_quantity)
FROM medicines m
JOIN inventory i ON m.medicine_id = i.medicine_id
GROUP BY m.medicine_id, m.medicine_name
ORDER BY SUM(i.stock_quantity) DESC
""")

data = cursor.fetchall()
medicines = [row[0] for row in data]
stock = [int(row[1]) for row in data]

plt.figure(figsize=(10, 5))
plt.bar(medicines, stock)
plt.title("Medicine-wise Stock Distribution")
plt.xlabel("Medicines")
plt.ylabel("Total Stock Units")
plt.xticks(rotation=30, ha="right")
plt.tight_layout()
plt.savefig("medicine_stock_distribution.png", dpi=300)
plt.show()

cursor.close()
conn.close()

print("All 3 Visualizations Completed Successfully!")
