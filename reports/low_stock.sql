-- Report: Low stock + reorder
-- Params: :tenant_id
SELECT f.name,
       f.unit,
       fi.quantity_on_hand,
       fi.reorder_level,
       (fi.reorder_level - fi.quantity_on_hand) AS shortfall,
       fi.unit_cost,
       (fi.reorder_level - fi.quantity_on_hand) * COALESCE(fi.unit_cost, 0) AS estimated_cost
FROM feed_inventory fi
JOIN feed_items f ON f.id = fi.feed_item_id
WHERE fi.tenant_id = :tenant_id
  AND fi.quantity_on_hand <= fi.reorder_level
ORDER BY shortfall DESC;
