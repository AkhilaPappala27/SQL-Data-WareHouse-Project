::Purpose:
::This .bat file is a one‑click automation: It runs your bronze loading SQL script against the datawarehouse database, updates all staging tables from local CSVs, and then displays a confirmation message so you know the refresh completed successfully.

@echo off
REM Run load_bronze.sql against the datawarehouse database

"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p datawarehouse < "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/load_bronze.sql"

echo ============================================
echo Tables in 'datawarehouse' have been updated
echo ============================================
pause
