-- №1
-- Проанализировать, какой период данных выгружен
Select Month(o.o_date), Year(o.o_date)
FROM orders_20190822 o
Group By Month(o.o_date), Year(o.o_date)
-- Выгруженные данные за 2016 и 2017 гг

-- №2
-- Посчитать количество строк и количетсво заказов
SELECT COUNT( o.price), COUNT(DISTINCT o.id_o), COUNT( o.user_id), COUNT( o.o_date)
FROM orders_20190822 o
-- 2002804 строк всего, нет пропущенных данных, ни в одном столбце

-- Посчитать количество уникальных пользователей
SELECT COUNT(DISTINCT o.user_id)
FROM orders_20190822 o
-- уникальных пользователей 1015119

-- №3
-- По годам и месяцам посчитать средний чек, среднее кол-во заказов на пользователя, сделать вывод , как изменялись это показатели Год от года.

-- Средний чек по месяцам и годам
Select Month(o.o_date) AS month, Year(o.o_date) AS year, AVG(o.price) AS avg_prise, COUNT(o.id_o)/COUNT(DISTINCT user_id) AS final
FROM orders_20190822 o
Group By Month(o.o_date), Year(o.o_date)
-- средний чек в 2017 году выше, по сравнению с тем же месяцев в 2016
-- в то же время количество заказон на одного покупателя снизилось
-- веротяно средний чек вырос из-за роста цен

-- №4
-- Найти кол-во пользователей, кот покупали в одном году и перестали покупать в следующем
SELECT COUNT(DISTINCT o.user_id)
FROM orders_20190822 o
WHERE NOT EXISTS (
    SELECT 1 
    FROM orders_20190822 t 
    WHERE o.user_id = t.user_id AND t.o_date >= DATE_FORMAT(NOW() ,'2017-01-01')
)

-- №5
-- Найти ID самого активного по кол-ву покупок пользователя.
SELECT COUNT(t.id_o) AS count_ord, t.user_id
    FROM orders_20190822 t
    GROUP BY t.user_id
    ORDER BY count_ord DESC LIMIT 1

-- №6
-- Найти коэффициенты сезонности по месяцам
-- Расчитывала как Коэффициент сезонности месяца = (Продажи в этого месяца / на средние продажи в месяц) * 100
-- Решение несколько костыльное, пошла через переменные ибо запуталась с вложенными талицами.
SET @year2016 = (SELECT count(t.o_date)/12 AS ord_year
                FROM orders_20190822 t 
                Where Year(t.o_date) = 2016);
SET @year2017 = (SELECT count(t.o_date)/12 AS ord_year
                FROM orders_20190822 t 
                Where Year(t.o_date) = 2017);

Select Month(o.o_date) AS month, Year(o.o_date) AS year, count(o.id_o) AS count_order, (count(o.id_o)/@year2016)*100 AS koef_ses
FROM orders_20190822 o
Where Year(o.o_date) = 2016
Group By Month(o.o_date), Year(o.o_date)

Select Month(o.o_date) AS month, Year(o.o_date) AS year, count(o.id_o) AS count_order, (count(o.id_o)/@year2017)*100 AS koef_ses
FROM orders_20190822 o
Where Year(o.o_date) = 2017
Group By Month(o.o_date), Year(o.o_date)

SELECT @year2017, @year2016

-- Всплекс продаж можно наблюдать в марте, возможно из-за 8 марта. В мае из-за смены сезона и появлении свободного времени, чтобы пройтись по магазинам.
-- Февраль самый мертвый сезон, денег обычно нет у населения. В летние месяцы тоже не очень активно подажи идут, все на дачах и в разъездах.
-- В октябре так же смена сезона и все утпеляются. В ноябре черная пятница) и часто стараются скинуть остатки магазины. В декабре перед праздниками все закупаются.