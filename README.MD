# Postgres Iceberg integration with pg_duckdb

## Setup pgduck docker image
If you have docker installed on your system, run the following:

```bash
docker pull akshat271/pgduck 
```

To start the container
```bash
docker run -d -e POSTGRES_PASSWORD=duckdb pgduck;
docker exec -it pgduck bash
```

## Read Data from Iceberg table

Execute: `psql` to enter into DB environment

```sql
SELECT * FROM iceberg_scan('/var/lib/postgresql/iceberg_data/data/iceberg/lineitem_iceberg', allow_moved_paths => TRUE);
```
## Load data inside PostgreSQL

```sql
CREATE TABLE data_for_oltp AS SELECT * FROM iceberg_scan('/var/lib/postgresql/iceberg_data/data/iceberg/lineitem_iceberg', allow_moved_paths => TRUE);
```

## Compare query performance

### Direct PostgreSQL Queries

```sql
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
```
Approx time taken on my system `Time: 83.836 ms`

### Querying Iceberg tables directly

```sql
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
```
Approx time taken on my system: `Time: 25.201 ms`


