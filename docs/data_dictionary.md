# Data Dictionary — PT Nusantara Distribution 2025

## 1. Tentang Dataset

Dataset PT Nusantara Distribution 2025 merupakan **synthetic dataset** yang digunakan untuk project analisis Supply Chain & Inventory.

Periode data mencakup:

**1 Januari 2025 – 31 Desember 2025**

Dataset terdiri dari dua kelompok utama:

### Master Data
- `products.csv`
- `warehouses.csv`

### Operational Data
- `opening_inventory.csv`
- `sales.csv`
- `inventory_transactions.csv`

Data type yang tercantum dalam dokumentasi ini merupakan **Proposed Data Type** berdasarkan struktur raw data dan business meaning. Data type final akan ditentukan setelah proses **Data Validation**.

---

# 2. Products

**File:** `products.csv`

**Grain:** Satu row merepresentasikan satu produk.

**Candidate Primary Key:** `product_id`

| Column | Deskripsi | Proposed Data Type | Key / Constraint | Catatan |
|---|---|---|---|---|
| `product_id` | Unique identifier untuk setiap produk | VARCHAR | Candidate PK | Digunakan untuk menghubungkan produk dengan tabel lain |
| `product_name` | Nama produk | VARCHAR | - | Deskripsi produk |
| `category` | Kategori produk | VARCHAR | - | Digunakan untuk product segmentation |
| `unit` | Satuan produk | VARCHAR | - | Contoh: Bottle, Pack, Sack |
| `unit_cost` | Cost per unit produk | NUMERIC | - | Digunakan untuk inventory valuation dan analisis biaya |
| `selling_price` | Standard selling price produk | NUMERIC | - | Harga jual dasar produk |
| `shelf_life_days` | Umur simpan produk dalam satuan hari | INTEGER | - | Perlu divalidasi karena raw CSV dapat menampilkan nilai decimal |

---

# 3. Warehouses

**File:** `warehouses.csv`

**Grain:** Satu row merepresentasikan satu warehouse.

**Candidate Primary Key:** `warehouse_id`

| Column | Deskripsi | Proposed Data Type | Key / Constraint | Catatan |
|---|---|---|---|---|
| `warehouse_id` | Unique identifier untuk setiap warehouse | VARCHAR | Candidate PK | Digunakan untuk menghubungkan warehouse dengan tabel operasional |
| `warehouse_name` | Nama warehouse | VARCHAR | - | Nama lokasi operasional |
| `warehouse_type` | Jenis atau fungsi warehouse | VARCHAR | - | Contoh: Main Warehouse dan Distribution Warehouse |
| `capacity_units` | Maximum capacity warehouse dalam unit | INTEGER | - | Digunakan untuk analisis warehouse capacity |

---

# 4. Opening Inventory

**File:** `opening_inventory.csv`

**Grain:** Satu row merepresentasikan opening inventory satu produk pada satu warehouse untuk suatu snapshot date.

**Candidate Composite Primary Key:**

`snapshot_date + warehouse_id + product_id`

| Column | Deskripsi | Proposed Data Type | Key / Constraint | Catatan |
|---|---|---|---|---|
| `snapshot_date` | Tanggal snapshot opening inventory | DATE | Candidate PK | Menunjukkan tanggal posisi awal inventory |
| `warehouse_id` | Identifier warehouse | VARCHAR | Candidate PK, FK | Mengacu pada `warehouses.warehouse_id` |
| `product_id` | Identifier produk | VARCHAR | Candidate PK, FK | Mengacu pada `products.product_id` |
| `opening_qty` | Jumlah opening stock | INTEGER | - | Starting inventory quantity |

---

# 5. Sales

**File:** `sales.csv`

**Grain:** Satu row merepresentasikan satu sales record untuk satu produk dari satu warehouse.

**Candidate Primary Key:** `sales_id`

| Column | Deskripsi | Proposed Data Type | Key / Constraint | Catatan |
|---|---|---|---|---|
| `sales_id` | Unique identifier untuk sales record | VARCHAR | Candidate PK | Identifier transaksi penjualan |
| `sales_date` | Tanggal transaksi penjualan | DATE | - | Digunakan untuk time-series analysis |
| `warehouse_id` | Warehouse yang memenuhi penjualan | VARCHAR | FK | Mengacu pada `warehouses.warehouse_id` |
| `product_id` | Produk yang terjual | VARCHAR | FK | Mengacu pada `products.product_id` |
| `quantity` | Jumlah unit yang terjual | INTEGER | - | Digunakan untuk demand analysis |
| `unit_price` | Selling price per unit pada transaksi | NUMERIC | - | Dapat berbeda dari standard selling price |
| `discount_pct` | Persentase discount transaksi | NUMERIC | - | Perlu divalidasi range dan format nilainya |
| `sales_channel` | Channel penjualan | VARCHAR | - | Digunakan untuk sales segmentation |
| `customer_type` | Tipe customer | VARCHAR | - | Digunakan untuk customer segmentation |

---

# 6. Inventory Transactions

**File:** `inventory_transactions.csv`

**Grain:** Satu row merepresentasikan satu inventory movement untuk satu produk pada satu warehouse.

**Candidate Primary Key:** `transaction_id`

| Column | Deskripsi | Proposed Data Type | Key / Constraint | Catatan |
|---|---|---|---|---|
| `transaction_id` | Unique identifier inventory transaction | VARCHAR | Candidate PK | Identifier setiap inventory movement |
| `transaction_date` | Tanggal inventory movement | DATE | - | Digunakan untuk inventory movement analysis |
| `warehouse_id` | Warehouse tempat movement terjadi | VARCHAR | FK | Mengacu pada `warehouses.warehouse_id` |
| `product_id` | Produk yang mengalami inventory movement | VARCHAR | FK | Mengacu pada `products.product_id` |
| `transaction_type` | Jenis inventory movement | VARCHAR | - | Contoh dapat berupa stock-in atau stock-out sesuai data |
| `quantity` | Jumlah unit pada inventory movement | INTEGER | - | Interpretasi movement bergantung pada `transaction_type` |
| `reference_id` | Reference identifier terhadap sumber transaksi terkait | VARCHAR | - | Dapat digunakan untuk menelusuri hubungan dengan transaksi sumber |
| `remarks` | Informasi tambahan mengenai transaksi | TEXT | - | Dapat berisi keterangan operasional |

---

# 7. Relasi Antar-Dataset

Relasi utama dataset adalah:

```text
products
   │
   │ product_id
   ├──────────────► opening_inventory
   ├──────────────► sales
   └──────────────► inventory_transactions


warehouses
   │
   │ warehouse_id
   ├──────────────► opening_inventory
   ├──────────────► sales
   └──────────────► inventory_transactions
```

`products` dan `warehouses` berfungsi sebagai **Master Data**, sedangkan `opening_inventory`, `sales`, dan `inventory_transactions` menyimpan informasi operasional inventory dan penjualan.

---

# 8. Data Validation Plan

Sebelum schema PostgreSQL ditetapkan sebagai final, beberapa aspek berikut perlu divalidasi:

- Null values pada key columns.
- Duplicate pada Candidate Primary Key.
- Referential integrity antara Foreign Key dan Master Data.
- Konsistensi date range selama tahun 2025.
- Validitas nilai `quantity`.
- Validitas `unit_cost`, `selling_price`, dan `unit_price`.
- Range dan format `discount_pct`.
- Konsistensi kategori pada `transaction_type`.
- Validitas `shelf_life_days`.
- Konsistensi hubungan antara `sales` dan inventory movement yang terkait.
- Potensi data quality issue atau business-rule violation lainnya.

Hasil validasi akan didokumentasikan melalui:

`sql/02_data_validation.sql`

---

# 9. Catatan

Dokumentasi ini merupakan bagian dari tahap **Data Understanding**.

Definisi, constraint, dan data type dapat diperbarui apabila proses **Data Validation** menemukan kondisi yang memerlukan perubahan pada schema atau interpretasi business rule.