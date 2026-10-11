-- Report: Herd summary (direct numeric readouts — Ivy's preference)
-- Params: :tenant_id
SELECT a.species,
       count(*)                                             AS herd_size,
       count(*) FILTER (WHERE a.status = 'active')          AS active,
       count(*) FILTER (WHERE a.status = 'sold')            AS sold,
       count(*) FILTER (WHERE a.status = 'dead')            AS dead,
       count(*) FILTER (WHERE a.sex = 'female' AND a.status = 'active') AS breeding_females,
       round(avg(a.age_years), 1)                           AS avg_age_years
FROM dim_animal a
WHERE a.tenant_id = :tenant_id
GROUP BY a.species
ORDER BY herd_size DESC;
