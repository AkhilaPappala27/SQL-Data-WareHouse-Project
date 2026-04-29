:: ============================================================
:: PURPOSE:
:: One-click execution for Silver layer
:: - Creates silver tables
:: - Loads and transforms data
:: - Executes stored procedure
:: ============================================================

@echo off

echo ============================================
echo Creating Silver Tables...
echo ============================================

"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p datawarehouse < create_silver_tables.sql

echo ============================================
echo Loading Silver Data...
echo ============================================

"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p datawarehouse < load_silver.sql

echo ============================================
echo Executing Silver Procedure...
echo ============================================

"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p -e "CALL load_silver();" datawarehouse

echo ============================================
echo Silver Layer Loaded Successfully
echo ============================================

pause
