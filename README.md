# Bash-DB-manager

A small file-based DBMS implemented in Bash scripts. The project simulates basic SQL-like behavior (create/drop databases and tables, insert/update/delete/select rows) using flat files for storage and shell logic for validation and constraints.

## Architecture — Three Main Layers

The project is organized into three main layers to separate concerns and keep the code modular:

- Presentation / CLI layer
  - Handles user interaction, menus and control flow.
  - Key files: `main.sh`, `db_operations_menu.sh`, any menu-driven scripts under the project root.
- Database layer (`db_layer/`)
  - Manages databases (directories) and connection logic.
  - Key scripts: `create_db.sh`, `drop_db.sh`, `list_db.sh`, `connectDB.sh`, etc.
- Table layer (`table_layer/`)
  - Manages table creation, metadata, and row operations (create, drop, list).
  - Key scripts: `createTable.sh`, `drop_table.sh`, `list_tables.sh`.
- Record layer (`record_layer/`)
  - Manages all CRUD operations into table (insert, update, delete, select).
  - Key scripts: `insert.sh`, `update.sh`, `deleteFromTable.sh`, `selectFromTable.sh`.

Shared utilities (e.g., `Validation.sh`) provide common validation and helper functions used across layers.

## Key Features
- Create and drop databases (directories) and tables (flat files).
- Table metadata (column names, datatypes, primary key) stored in hidden metadata files.
- Strict data typing for columns (int, str).
- Primary key support and enforcement.
- Insert rows with validation against datatypes and PK uniqueness.
- Update rows by primary key, by column value, or all rows.
- Delete rows by primary key or criteria.
- Select/query rows with simple filters.
- Input validation for object names and values.

## Technical Implementation
- Storage: plain files under ./Databases/<dbname>/ — table data stored in `.SQL` files and metadata in `.<table>.metadata`.
- Manipulation: shell builtins and standard Unix tools; high-performance in-place edits use awk (`awk -i inplace`) where needed.
- Validation and control logic are implemented in modular Bash scripts (e.g., `Validation.sh`).

## Prerequisites
- Linux / Unix-like environment (tested on GNU/Linux).
- Bash (POSIX-compatible shell).

## Installation & Usage
1. Make the scripts executable:
```bash
chmod +x *.sh */*.sh
```

2. Start the application from the project root:
```bash
./main.sh
```

Typical workflow:
- Create or choose a database.
- Create tables using interactive prompts (columns, datatypes, primary key).
- Insert, update, delete, and select rows through the menu-driven CLI.

## Example: creating a table
Run `./main.sh`, choose the database, then the "create table" option. The `createTable.sh` script will:
- Prompt for a table name (validated),
- Prompt for number of columns,
- Prompt for datatype (int/str) per column,
- Prompt for column names (unique and validated),
- Ask whether to enable a primary key, and then write metadata and table files.

## Select Operation (Data Retrieval)

This project supports a SELECT operation that retrieves data from tables stored in a flat-file format. Each table is represented by two files:

- Data file: <table_name>.SQL
- Metadata file: .<table_name>.metadata

Fields in data files are separated using a colon (:).

Table structure example
```text
# ./Databases/testdb/.users.metadata
pk:yes
id:name:age
int:str:int
# ./Databases/testdb/users.SQL
1:Alice:30
2:Bob:25
3:Carol:30
```
- Line 1: Indicates whether a primary key exists.
- Line 2: Column names.
- Line 3: Column data types.
- Data file: each line is a row; values follow the metadata column order.

How Select works
- Reads data directly from the .SQL file using ':' as the field delimiter.
- Filters rows using simple comparisons (string or numeric matches via awk).
- Read-only: does not modify data or enforce datatype/PK constraints (those are enforced on insert/update).

Select options
After connecting to a database and choosing Select, the user can choose:

1. Select All Rows  
   - Displays every row in the table.  
   - Example output:
     ```
     1:Alice:30
     2:Bob:25
     3:Carol:30
     ```

2. Select by Primary Key  
   - If pk:yes, retrieve a single row by primary key value.  
   - Example:
     Enter Primary Key value: 1  
     Output:
     ```
     1:Alice:30
     ```

3. Select by Column Value  
   - Filter rows by a column and value (e.g., age = 30).  
   - Example:
     Column: age  
     Value: 30  
     Output:
     ```
     1:Alice:30
     3:Carol:30
     ```

4. Select Specific Column(s)  
   - Display selected columns instead of full rows.  
   - Example (name, age):
     ```
     Alice:30
     Bob:25
     Carol:30
     ```

Notes
- Output is formatted at the CLI level; stored files remain unchanged.
- No joins or complex queries supported — simple, flat-file retrieval only.
