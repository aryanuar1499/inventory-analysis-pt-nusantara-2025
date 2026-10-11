# Monthly Sales Trend Analysis — Business Insights

**Project:** Inventory Analysis — PT Nusantara Distribution 2025  
**Phase:** 03 — Exploratory Data Analysis  
**Part:** 04 — Monthly Sales Trend Analysis  
**Period:** January–December 2025  
**Database:** PostgreSQL

## 1. Business Objective

Analisis ini bertujuan mengevaluasi tren penjualan bulanan, pertumbuhan revenue, volume penjualan, serta profitabilitas untuk mendukung pengambilan keputusan berbasis data dalam pengelolaan persediaan.

## 2. Key Findings

| Indicator | Result |
|---|---|
| Highest Monthly Revenue | March — Rp364,363,775 |
| Lowest Monthly Revenue | February — Rp309,946,525 |
| Highest MoM Revenue Growth | March — +17.56% |
| Largest MoM Revenue Decline | February — −13.28% |
| Highest Average Daily Units Sold | March — 602.58 units/day |
| Lowest Average Daily Units Sold | June — 558.60 units/day |
| Highest Monthly Gross Profit | March — Rp78,026,775 |
| Highest Monthly Gross Margin | July — 21.90% |
| Lowest Monthly Gross Margin | April — 21.27% |

## 3. Business Insights

### 3.1 Monthly Sales Performance

Maret 2025 mencatat net revenue tertinggi sebesar Rp364.363.775 dengan total 18.680 unit terjual.

Sebaliknya, Februari mencatat net revenue terendah sebesar Rp309.946.525.

Namun, setelah memperhitungkan perbedaan jumlah hari kalender, penurunan rata-rata revenue harian Januari–Februari hanya sekitar 3,99%, dibandingkan penurunan total revenue sebesar 13,28%.

Temuan ini menunjukkan pentingnya normalisasi periode dalam analisis performa penjualan.

### 3.2 Sales Volume & Demand Patterns

Maret mencatat rata-rata volume penjualan tertinggi sebesar 602,58 unit per hari, sedangkan Juni mencatat nilai terendah sebesar 558,60 unit per hari.

Variasi ini dapat digunakan sebagai masukan awal dalam demand planning, tetapi belum cukup untuk membuktikan pola musiman karena data hanya mencakup satu tahun.

### 3.3 Profitability Performance

Maret menghasilkan gross profit nominal tertinggi sebesar Rp78.026.775 dengan gross margin 21,41%.

Sementara itu, Juli mencatat gross margin tertinggi sebesar 21,90% dengan gross profit Rp73.473.255.

Hasil ini menunjukkan bahwa bulan dengan keuntungan kotor nominal terbesar tidak selalu memiliki persentase gross margin tertinggi.

## 4. Inventory Management Implications

Berdasarkan hasil analisis, terdapat beberapa implikasi operasional:

1. Monthly sales trends dapat digunakan sebagai referensi awal dalam perencanaan permintaan.
2. Penambahan atau pengurangan stok tidak boleh hanya didasarkan pada nilai penjualan tertinggi atau terendah.
3. Evaluasi kebutuhan stok perlu dilakukan pada tingkat produk dan gudang.
4. Keputusan replenishment harus mempertimbangkan inventory position, demand variability, supplier lead time, dan safety stock.
5. Profitabilitas produk perlu dipertimbangkan bersama risiko stockout, overstock, dan dead stock.

## 5. Business Recommendations

**Demand Planning:** Menggunakan data penjualan historis untuk menyusun estimasi kebutuhan produk, dengan mempertimbangkan variasi permintaan dan jumlah hari kalender.

**Inventory Control:** Mengembangkan analisis stok per produk dan gudang sebelum menentukan kebijakan penambahan persediaan.

**Profitability Monitoring:** Memantau net revenue, gross profit, dan gross margin secara bersamaan untuk menghindari keputusan berdasarkan revenue saja.

**Future Optimization:** Mengembangkan analisis Safety Stock, Reorder Point (ROP), dan replenishment quantity pada tahap berikutnya dengan parameter yang memadai.

## 6. Analysis Limitations

- Dataset merupakan data sintetis perusahaan.
- Periode observasi hanya mencakup tahun 2025.
- Gross profit menggunakan biaya referensi produk (`products.unit_cost`), bukan historical purchase costs.
- Rata-rata harian menggunakan hari kalender, bukan hari operasional.
- Belum tersedia riwayat supplier lead time yang memadai.
- Penjualan tercatat belum tentu merepresentasikan seluruh permintaan apabila pernah terjadi stockout.
- Belum dilakukan analisis demand variability per produk dan gudang untuk perhitungan safety stock.

## 7. Conclusion

Analisis menunjukkan bahwa performa penjualan PT Nusantara Distribution 2025 mengalami fluktuasi bulanan dalam revenue, volume penjualan, dan profitabilitas.

Maret menjadi bulan dengan revenue dan gross profit tertinggi, sementara Juli menunjukkan gross margin tertinggi.

Hasil ini dapat digunakan sebagai dasar awal evaluasi penjualan dan perencanaan persediaan, tetapi keputusan operasional memerlukan analisis lanjutan pada tingkat produk dan gudang.