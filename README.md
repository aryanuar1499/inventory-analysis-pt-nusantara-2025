# PT Nusantara Distribution — Inventory Analysis 2025

## 📌 Project Overview

Project ini merupakan analisis terhadap aktivitas inventory **PT Nusantara Distribution** selama periode tahun 2025.

Analisis difokuskan untuk memahami pergerakan inventory, demand produk, performa warehouse, serta kondisi stock berdasarkan data transaksi inventory dan penjualan.

Project ini dikembangkan sebagai **end-to-end Data Analytics portfolio project** dengan fokus pada bidang **Supply Chain & Inventory Analytics**.

> **Catatan:** PT Nusantara Distribution beserta seluruh dataset yang digunakan dalam project ini merupakan data synthetic yang dibuat khusus untuk keperluan pembelajaran dan pengembangan portfolio.

---

## 🎯 Project Objectives

Tujuan utama dari project ini adalah:

- Menganalisis pergerakan inventory pada setiap warehouse.
- Memahami demand produk berdasarkan aktivitas penjualan.
- Mengidentifikasi **fast-moving** dan **slow-moving products**.
- Mengevaluasi ketersediaan inventory dan potensi terjadinya **stockout**.
- Mengidentifikasi potensi **overstock**.
- Mengukur berbagai **Key Performance Indicators (KPI)** yang berkaitan dengan inventory.
- Membandingkan performa inventory antar-warehouse.
- Menghasilkan **business insights** dan rekomendasi yang dapat digunakan untuk mendukung pengambilan keputusan.

---

## 🗓️ Analisis Period

**1 Januari 2025 – 31 Desember 2025**

---

## 🗂️ Dataset

Project ini menggunakan lima dataset utama:

| Dataset | Deskripsi |
|---|---|
| `products.csv` | Master data produk yang berisi informasi dan atribut setiap produk. |
| `warehouses.csv` | Master data warehouse yang digunakan dalam operasional distribusi. |
| `opening_inventory.csv` | Data saldo awal inventory setiap produk pada masing-masing warehouse. |
| `sales.csv` | Data transaksi penjualan produk selama tahun 2025. |
| `inventory_transactions.csv` | Data pergerakan inventory yang mencatat berbagai transaksi stock-in dan stock-out. |

Definisi setiap field secara lebih detail akan didokumentasikan pada:

`docs/data_dictionary.md`

---

## 🛠️ Tools

Tools utama yang digunakan dalam project ini:

- **PostgreSQL** — Database Management, Data Validation, Data Transformation, dan Data Analysis.
- **SQL** — Exploratory Data Analysis, perhitungan Inventory KPI, dan Business Analysis.
- **Microsoft Excel** — Supporting Data Validation dan Exploratory Analysis apabila diperlukan.
- **Power BI** — Data Visualization dan pengembangan interactive dashboard.
- **Git & GitHub** — Version Control dan dokumentasi project.

---

## 📁 Repository Structure

```text
inventory-analysis-pt-nusantara-2025/
│
├── README.md
│
├── data/
│   ├── raw/
│   └── processed/
│
├── sql/
│   ├── 01_database_setup.sql
│   ├── 02_data_validation.sql
│   ├── 03_data_cleaning.sql
│   ├── 04_exploratory_analysis.sql
│   ├── 05_inventory_kpi.sql
│   └── 06_business_analysis.sql
│
├── dashboard/
├── images/
└── docs/
    └── data_dictionary.md
```

---

## 🔄 Project Workflow

Project akan dikerjakan melalui beberapa tahapan:

**Data Understanding → Database Setup → Data Validation → Data Cleaning → Exploratory Data Analysis → Inventory KPI Analysis → Business Analysis → Dashboard Development → Business Insights & Recommendations**

Setiap tahapan akan didokumentasikan secara bertahap agar proses analisis dapat ditelusuri dan direproduksi.

---

## 📊 Planned Analysis

Beberapa pertanyaan bisnis yang akan dianalisis dalam project ini antara lain:

- Bagaimana pola pergerakan inventory sepanjang tahun 2025?
- Produk mana yang memiliki demand tertinggi dan terendah?
- Produk mana yang termasuk kategori **fast-moving** dan **slow-moving**?
- Apakah terdapat produk yang sering mengalami kondisi **low stock** atau **stockout**?
- Apakah terdapat indikasi **overstock** pada produk tertentu?
- Bagaimana perbandingan performa inventory antar-warehouse?
- Seberapa efektif inventory yang tersedia dalam memenuhi demand produk?
- Bagaimana hubungan antara aktivitas penjualan dengan pergerakan inventory?

Pertanyaan analisis tambahan dapat dikembangkan apabila ditemukan pola atau anomali menarik selama proses **Exploratory Data Analysis (EDA)**.

---

## 📈 Output Project

Pada akhir project, repository ini direncanakan menghasilkan:

- Database PostgreSQL yang terstruktur.
- Dokumentasi proses **Data Validation** dan **Data Cleaning**.
- SQL queries untuk **Exploratory Data Analysis**.
- Perhitungan **Inventory KPI**.
- Analisis performa produk dan warehouse.
- Interactive dashboard menggunakan Power BI.
- Business insights berdasarkan hasil analisis.
- Rekomendasi yang dapat mendukung pengambilan keputusan terkait inventory.

---

## 🚧 Project Status

**Current Phase:** Repository Setup & Data Understanding

Project masih dalam tahap pengembangan. SQL queries, hasil analisis, visualisasi, dashboard, business insights, dan rekomendasi akan ditambahkan secara bertahap sesuai perkembangan project.

---

## 👤 Author

**Yanuar**

Aspiring **Data Analyst — Supply Chain / Inventory**

GitHub: `aryanuar1499`