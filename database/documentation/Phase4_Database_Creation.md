# Phase IV: Database Creation – Hospital ER Triage System

## 1. Objective

Create and configure an Oracle pluggable database (PDB) to host the Hospital ER Triage and Resource Allocation schema.

---

## 2. Database Setup

- **Pluggable database name:** `mon_12345_denyse_ertriage_db`  
  (Follows pattern `GrpName_StudentId_FirstName_ProjectName_DB`.)
- **Admin user:** `DENYSE_ADMIN`  
  - Password: `Denyse` (first name, per assignment)  
  - Privileges: `DBA` within the PDB

The PDB is created from the seed database under the Oracle XE container using the script `phase4_create_pluggable_db.sql`.

---

## 3. Configuration Details

### 3.1 Tablespaces

Inside the PDB `mon_12345_denyse_ertriage_db` the following tablespaces are created:

- **`er_data_tbs`** – main tablespace for application tables.  
  - Datafile: `C:\APP\DELL\PRODUCT\21C\ORADATA\XE\mon_12345_denyse_ertriage_db\er_data01.dbf`  
  - Size: 500 MB, **AUTOEXTEND ON** (50 MB increment, max 2 GB)

- **`er_index_tbs`** – dedicated tablespace for indexes.  
  - Datafile: `C:\APP\DELL\PRODUCT\21C\ORADATA\XE\mon_12345_denyse_ertriage_db\er_index01.dbf`  
  - Size: 200 MB, **AUTOEXTEND ON** (20 MB increment, max 1 GB)

- **`er_temp_tbs`** – temporary tablespace.  
  - Tempfile: `C:\APP\DELL\PRODUCT\21C\ORADATA\XE\mon_12345_denyse_ertriage_db\er_temp01.dbf`  
  - Size: 200 MB, **AUTOEXTEND ON** (20 MB increment, max 1 GB)

### 3.2 Admin User Configuration

The admin user is configured inside the PDB as follows:

```sql
ALTER USER DENYSE_ADMIN
  DEFAULT TABLESPACE er_data_tbs
  TEMPORARY TABLESPACE er_temp_tbs
  QUOTA UNLIMITED ON er_data_tbs;

GRANT DBA TO DENYSE_ADMIN;
```

This user will later be used to create all application tables, PL/SQL objects, and load data.

### 3.3 Memory Parameters (SGA/PGA)

- Memory parameters are managed at the **container database (CDB)** level.  
- Suggested example values (if adjusted by the DBA):
  - `sga_target = 2G`
  - `pga_aggregate_target = 1G`
- Changes would be applied with:

```sql
ALTER SYSTEM SET sga_target = 2G SCOPE = SPFILE;
ALTER SYSTEM SET pga_aggregate_target = 1G SCOPE = SPFILE;
```

(These statements are commented in the script and executed only if the environment allows changes.)

### 3.4 Archive Logging and Autoextend

- **Archive logging** is enabled at the CDB level (outside the PDB) using the standard sequence:

```sql
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE ARCHIVELOG;
ALTER DATABASE OPEN;
```

- **Autoextend** is explicitly turned on for the data, index and temporary tablespace files using `AUTOEXTEND ON NEXT ... MAXSIZE ...`, satisfying the requirement for autoextend parameters.

---

## 4. How to Run the Creation Script

1. Open a terminal and start SQL*Plus as SYSDBA in the container database:

```sql
sqlplus / as sysdba
```

2. Execute the Phase IV script from the project directory:

```sql
@c:/Users/Denyse/Documents/Mine/Hospital-ER_Triage-ResourceAllocationSystem/phase4_create_pluggable_db.sql
```

3. Verify that the new PDB exists and is open:

```sql
SHOW PDBS;
ALTER SESSION SET CONTAINER = mon_12345_denyse_ertriage_db;
SELECT name, open_mode FROM v$pdbs;
```

4. Test connecting as the admin user (from a new session):

```sql
sqlplus DENYSE_ADMIN/Denyse@localhost:1521/mon_12345_denyse_ertriage_db
```

(Adjust host, port, and service name according to your XE configuration.)

---

## 5. Project Structure Notes

- `phase4_create_pluggable_db.sql` – SQL script that creates and configures the PDB, tablespaces, and admin user.
- `Phase4_Database_Creation.md` – this document, explaining configuration and how to run the script.

These artifacts, combined with the ERD and logical model from Phase III, complete the Database Creation requirements for Phase IV.
