::Purpose:
::This .bat file is a one‑click automation: It runs your bronze loading SQL script against the datawarehouse database, updates all staging tables from local CSVs, and then displays a confirmation message so you know the refresh completed successfully.

@echo off

echo Creating Bronze Tables...
"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p datawarehouse < create_bronze_tables.sql

echo Running Bronze Load...
"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p datawarehouse < load_bronze.sql

echo ============================================
echo Bronze Layer Loaded Successfully
echo ============================================
pause
