-- Dimensions -----------------------------------------------------------------

-- dim_tenant.sql
CREATE OR REPLACE VIEW dim_tenant AS
SELECT id AS tenant_id, name AS tenant_name, subscription_plan,
       subscription_status, created_at
FROM tenants;

-- dim_animal.sql
CREATE OR REPLACE VIEW dim_animal AS
SELECT a.id AS animal_id, a.tenant_id, a.tag_number, a.name, a.sex,
       a.origin, a.status, a.date_of_birth,
       b.name AS breed_name, a.species,
       a.dam_id, a.sire_id,
       date_part('year', age(a.date_of_birth))::int AS age_years
FROM animals a
LEFT JOIN breeds b ON b.id = a.breed_id;

-- dim_date.sql  (calendar spine; generate a range wide enough for trends)
CREATE OR REPLACE VIEW dim_date AS
SELECT d::date AS date_key,
       extract(year  FROM d)::int  AS year,
       extract(month FROM d)::int  AS month,
       to_char(d, 'Mon')           AS month_name,
       extract(quarter FROM d)::int AS quarter,
       date_trunc('month', d)::date AS month_start
FROM generate_series('2020-01-01'::date, '2035-12-31'::date, '1 day') AS d;

-- Facts -----------------------------------------------------------------------

-- fct_health_event.sql (append-only source → immutable fact)
CREATE OR REPLACE VIEW fct_health_event AS
SELECT h.id AS health_event_id, h.tenant_id, h.animal_id, h.event_type,
       h.occurred_at::date AS occurred_on, h.cost, h.currency, h.medication
FROM health_records h;

-- fct_transaction.sql
CREATE OR REPLACE VIEW fct_transaction AS
SELECT t.id AS transaction_id, t.tenant_id, t.txn_type,
       t.occurred_at::date AS occurred_on, t.amount, t.currency, t.category
FROM transactions t;

-- fct_attendance.sql
CREATE OR REPLACE VIEW fct_attendance AS
SELECT a.id AS attendance_id, a.tenant_id, a.worker_id, a.work_date,
       a.status, (a.acknowledged_at IS NOT NULL) AS acknowledged
FROM attendance a;

-- fct_stock_movement.sql
CREATE OR REPLACE VIEW fct_stock_movement AS
SELECT m.id AS movement_id, m.tenant_id, m.feed_item_id, m.movement_type,
       m.quantity, m.occurred_at::date AS occurred_on
FROM stock_movements m;
