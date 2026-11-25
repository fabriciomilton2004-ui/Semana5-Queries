
USE jardineria;

-- SEMANA 5 - QUERIES

-- 1. Listar información básica de las oficinas
SELECT codigo_oficina, ciudad, pais, telefono
FROM oficina;

-- 2. Obtener los empleados por oficina
SELECT codigo_oficina, nombre, apellido1, apellido2, puesto
FROM empleado
ORDER BY codigo_oficina;

-- 3. Promedio del límite de crédito por región
SELECT region, AVG(limite_credito) AS promedio_credito
FROM cliente
GROUP BY region;

-- 4. Clientes con sus representantes de ventas
SELECT
    c.nombre_cliente,
    CONCAT(e.nombre, ' ', e.apellido1, ' ', e.apellido2) AS representante_ventas
FROM cliente c
LEFT JOIN empleado e
ON c.codigo_empleado_rep_ventas = e.codigo_empleado;

-- 5. Productos disponibles y en stock
SELECT codigo_producto, nombre, cantidad_en_stock
FROM producto
WHERE cantidad_en_stock >= 1;

-- 6. Productos con precios por debajo del promedio
SELECT codigo_producto, nombre, precio_venta
FROM producto
WHERE precio_venta < (
    SELECT AVG(precio_venta) FROM producto
);

-- 7. Pedidos pendientes por cliente
SELECT p.codigo_pedido, p.estado, c.nombre_cliente
FROM pedido p
INNER JOIN cliente c
ON p.codigo_cliente = c.codigo_cliente
WHERE p.estado <> 'Entregado';

-- 8. Total de productos por categoría
SELECT gama, COUNT(*) AS total_productos
FROM producto
GROUP BY gama;

-- 9. Ingresos totales generados por cliente
SELECT
    c.codigo_cliente,
    c.nombre_cliente,
    COALESCE(SUM(pa.total), 0) AS ingresos_totales
FROM cliente c
LEFT JOIN pago pa
ON c.codigo_cliente = pa.codigo_cliente
GROUP BY c.codigo_cliente, c.nombre_cliente;

-- 10. Pedidos realizados en un rango de fechas
SELECT codigo_pedido, fecha_pedido, fecha_esperada, fecha_entrega
FROM pedido
WHERE fecha_pedido BETWEEN '2008-01-01' AND '2009-12-31'
ORDER BY fecha_pedido;

-- 11. Detalles de un pedido específico
SELECT
    dp.codigo_pedido,
    pr.nombre AS producto,
    dp.cantidad,
    dp.precio_unidad,
    dp.cantidad * dp.precio_unidad AS precio_total
FROM detalle_pedido dp
INNER JOIN producto pr
ON dp.codigo_producto = pr.codigo_producto
WHERE dp.codigo_pedido = 1;

-- 12. Productos más vendidos
SELECT
    pr.codigo_producto,
    pr.nombre,
    SUM(dp.cantidad) AS cantidad_total_vendida
FROM detalle_pedido dp
INNER JOIN producto pr
ON dp.codigo_producto = pr.codigo_producto
GROUP BY pr.codigo_producto, pr.nombre
ORDER BY cantidad_total_vendida DESC;

-- 13. Pedidos con valor total superior al promedio
SELECT
    codigo_pedido,
    SUM(cantidad * precio_unidad) AS valor_total
FROM detalle_pedido
GROUP BY codigo_pedido
HAVING SUM(cantidad * precio_unidad) > (
    SELECT AVG(total_pedido)
    FROM (
        SELECT SUM(cantidad * precio_unidad) AS total_pedido
        FROM detalle_pedido
        GROUP BY codigo_pedido
    ) AS pedidos
);

-- 14. Clientes sin representante de ventas
SELECT codigo_cliente, nombre_cliente
FROM cliente
WHERE codigo_empleado_rep_ventas IS NULL;

-- 15. Número total de empleados por oficina
SELECT
    o.codigo_oficina,
    o.ciudad,
    COUNT(e.codigo_empleado) AS total_empleados
FROM oficina o
LEFT JOIN empleado e
ON o.codigo_oficina = e.codigo_oficina
GROUP BY o.codigo_oficina, o.ciudad;

-- 16. Pagos realizados en una forma específica
SELECT codigo_cliente, forma_pago, id_transaccion, fecha_pago, total
FROM pago
WHERE forma_pago = 'PayPal';

-- 17. Ingresos mensuales
SELECT
    DATE_FORMAT(fecha_pago, '%Y-%m') AS mes,
    SUM(total) AS ingresos_mensuales
FROM pago
GROUP BY DATE_FORMAT(fecha_pago, '%Y-%m')
ORDER BY mes;

-- 18. Clientes con múltiples pedidos
SELECT
    c.codigo_cliente,
    c.nombre_cliente,
    COUNT(p.codigo_pedido) AS total_pedidos
FROM cliente c
INNER JOIN pedido p
ON c.codigo_cliente = p.codigo_cliente
GROUP BY c.codigo_cliente, c.nombre_cliente
HAVING COUNT(p.codigo_pedido) > 1;

-- 19. Pedidos con productos agotados
SELECT DISTINCT
    p.codigo_pedido,
    p.estado,
    pr.codigo_producto,
    pr.nombre AS producto,
    pr.cantidad_en_stock
FROM pedido p
INNER JOIN detalle_pedido dp
ON p.codigo_pedido = dp.codigo_pedido
INNER JOIN producto pr
ON dp.codigo_producto = pr.codigo_producto
WHERE pr.cantidad_en_stock = 0;

-- 20. Promedio, máximo y mínimo del crédito por país
SELECT
    pais,
    AVG(limite_credito) AS promedio_credito,
    MAX(limite_credito) AS credito_maximo,
    MIN(limite_credito) AS credito_minimo
FROM cliente
GROUP BY pais;

-- 21. Historial de transacciones de un cliente
SELECT codigo_cliente, id_transaccion, fecha_pago, total, forma_pago
FROM pago
WHERE codigo_cliente = 4
ORDER BY fecha_pago;

-- 22. Empleados sin jefe directo asignado
SELECT codigo_empleado, nombre, apellido1, apellido2, puesto
FROM empleado
WHERE codigo_jefe IS NULL;

-- 23. Productos cuyo precio supera el promedio de su gama
SELECT
    p.codigo_producto,
    p.nombre,
    p.gama,
    p.precio_venta
FROM producto p
WHERE p.precio_venta > (
    SELECT AVG(p2.precio_venta)
    FROM producto p2
    WHERE p2.gama = p.gama
);

-- 24. Promedio de días de entrega por estado
SELECT
    estado,
    AVG(DATEDIFF(fecha_entrega, fecha_pedido)) AS promedio_dias_entrega
FROM pedido
WHERE fecha_entrega IS NOT NULL
GROUP BY estado;

-- 25. Clientes por país con más de un pedido
SELECT
    c.pais,
    COUNT(*) AS cantidad_clientes
FROM cliente c
INNER JOIN (
    SELECT codigo_cliente
    FROM pedido
    GROUP BY codigo_cliente
    HAVING COUNT(codigo_pedido) > 1
) AS clientes_multiples
ON c.codigo_cliente = clientes_multiples.codigo_cliente
GROUP BY c.pais;
