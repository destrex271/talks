-- Read Data from Iceberg Tables
SELECT * FROM iceberg_scan('/var/lib/postgresql/iceberg_data/data/iceberg/lineitem_iceberg', allow_moved_paths => TRUE);

-- Direct Queries on Iceberg

-- -- Late supply design

SELECT
  COUNT(*) AS late_shipments
FROM
  iceberg_scan('/var/lib/postgresql/iceberg_data/data/iceberg/lineitem_iceberg', allow_moved_paths => TRUE) AS r
WHERE
  r['l_receiptdate'] > r['l_commitdate'];

--  -- Sales summary
SELECT
  r['l_returnflag'] AS return_flag,
  r['l_linestatus'] AS line_status,
SUM(r['l_quantity']) AS sum_qty,
  SUM(r['l_extendedprice']) AS sum_base_price,
  SUM(r['l_extendedprice'] * (1 - r['l_discount'])) AS sum_disc_price,
  SUM(r['l_extendedprice'] * (1 - r['l_discount']) * (1 + r['l_tax'])) AS sum_charge,
  AVG(r['l_quantity']) AS avg_qty,
  AVG(r['l_extendedprice']) AS avg_price,
  AVG(r['l_discount']) AS avg_disc,
  COUNT(*) AS count_order
FROM
  iceberg_scan('/var/lib/postgresql/iceberg_data/data/iceberg/lineitem_iceberg', allow_moved_paths => TRUE) r
WHERE
  r['l_shipdate'] <= DATE '1998-12-01' - INTERVAL '90' DAY
GROUP BY
  r.r['l_returnflag'],
  r.r['l_linestatus']
ORDER BY
  r['l_returnflag'],
  r['l_linestatus'];

-- -- Monthly Shipping volume

SELECT
  DATE_TRUNC('month', r['l_shipdate']) AS ship_month,
  r['l_shipmode'],
  SUM(r['l_quantity']) AS total_quantity
FROM
  iceberg_scan('/var/lib/postgresql/iceberg_data/data/iceberg/lineitem_iceberg', allow_moved_paths => TRUE) AS r
GROUP BY
  ship_month,
  r.r['l_shipmode']
ORDER BY
  ship_month,
  r['l_shipmode'];


-- Import data inside PostgreSQL
CREATE TABLE data_for_oltp AS SELECT * FROM iceberg_scan('/var/lib/postgresql/iceberg_data/data/iceberg/lineitem_iceberg', allow_moved_paths => TRUE);

-- execute same queries in Postgres

-- -- sales analytics
SELECT
  l_returnflag,
  l_linestatus,
  SUM(l_quantity) AS sum_qty,
  SUM(l_extendedprice) AS sum_base_price,
  SUM(l_extendedprice * (1 - l_discount)) AS sum_disc_price,
  SUM(l_extendedprice * (1 - l_discount) * (1 + l_tax)) AS sum_charge,
  AVG(l_quantity) AS avg_qty,
  AVG(l_extendedprice) AS avg_price,
  AVG(l_discount) AS avg_disc,
  COUNT(*) AS count_order
FROM
  data_for_oltp
WHERE
  l_shipdate <= DATE '1998-12-01' - INTERVAL '90' DAY
GROUP BY
  l_returnflag,
  l_linestatus
ORDER BY
  l_returnflag,
  l_linestatus;

-- -- monthly shipping volume
SELECT
  DATE_TRUNC('month', l_shipdate) AS ship_month,
  l_shipmode,
  SUM(l_quantity) AS total_quantity
FROM
  data_for_oltp
GROUP BY
  ship_month,
  l_shipmode
ORDER BY
  ship_month,
  l_shipmode;

-- -- Late Shipment analysis
SELECT
  COUNT(*) AS late_shipments
FROM
  data_for_oltp
WHERE
  l_receiptdate > l_commitdate;
