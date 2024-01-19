-- Разработать БД в соответствии с индивидуальным заданием.
-- Создать функции, реализующие интерфейс для работы с базой данных
-- (Вставка, удаление, редактирование данных).
-- Проверить работоспособность функций путем выполнения этих функций с параметрами,
-- обеспечивающими как успешное выполнение функции, так и невыполнение функции.

-- Вариант 5: База данных сети автосалонов. 
-- Должна содержать следующие данные:
-- информацию об автосалонах, продавцах-консультантах, имеющихся в наличии и проданных автомобилях.
-- Предусмотреть анализ следующих показателей:
-- рейтинг продаж для продавцов-консультантов по различным моделям,
-- рекомендации к заказу моделей на основании имеющегося запаса и популярности модели.

-- Создание базы данных
-- Database: lab2larin

-- Разработать БД в соответствии с индивидуальным заданием.
-- Создать функции, реализующие интерфейс для работы с базой данных
-- (Вставка, удаление, редактирование данных).
-- Проверить работоспособность функций путем выполнения этих функций с параметрами,
-- обеспечивающими как успешное выполнение функции, так и невыполнение функции.

-- Вариант 5: База данных сети автосалонов. 
-- Должна содержать следующие данные:
-- информацию об автосалонах, продавцах-консультантах, имеющихся в наличии и проданных автомобилях.
-- Предусмотреть анализ следующих показателей:
-- рейтинг продаж для продавцов-консультантов по различным моделям,
-- рекомендации к заказу моделей на основании имеющегося запаса и популярности модели.

-- Создание базы данных
-- Database: lab2larin

-- DROP DATABASE IF EXISTS lab2larin;

-- CREATE DATABASE lab2larin
--     WITH
--     OWNER = postgres
--     ENCODING = 'UTF8'
--     LC_COLLATE = 'Russian_Russia.1251'
--     LC_CTYPE = 'Russian_Russia.1251'
--     LOCALE_PROVIDER = 'libc'
--     TABLESPACE = pg_default
--     CONNECTION LIMIT = -1
--     IS_TEMPLATE = False;

-- -- Подключение к базе данных
-- \c lb2larin;

-- Создание таблицы Автомобили
CREATE TABLE cars (
    id SERIAL PRIMARY KEY,
    model VARCHAR(64),
    issue_date INT,
    color VARCHAR(32),
    vin CHAR(17)
);

-- Создание таблицы Автосалоны
CREATE TABLE dealerships (
    id SERIAL PRIMARY KEY,
    name VARCHAR(64),
    address VARCHAR(256)
);

-- Создание таблицы Сотрудники
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(128),
    job_title VARCHAR(64)
);

-- Создание таблицы Автомобили_наличие
CREATE TABLE cars_availability (
    id SERIAL PRIMARY KEY,
    car_id INT REFERENCES cars(id),
    dealership_id INT REFERENCES dealerships(id),
    stock_quantity INT,
    sales_quantity INT
);

-- Создание таблицы Продажи
CREATE TABLE sales (
    id SERIAL PRIMARY KEY,
    car_id INT REFERENCES cars(id),
    dealership_id INT REFERENCES dealerships(id), 
    employee_id INT REFERENCES employees(id)
);

-- Начинаем написание функций согласно заданию

-- Функция добавления новой модели автомобиля
CREATE FUNCTION add_car(
    model VARCHAR(64),
    issue_date INT,
    color VARCHAR(32),
    vin CHAR(17)
) RETURNS void AS $$
BEGIN
    INSERT INTO cars(model, issue_date, color, vin)
    VALUES (model, issue_date, color, vin);
END; $$ LANGUAGE plpgsql;

-- Функция добавления нового автосалона
CREATE FUNCTION add_dealership(
    name VARCHAR(64),
    address VARCHAR(256)
) RETURNS void AS $$
BEGIN
    INSERT INTO dealerships(name, address)
    VALUES (name, address);
END; $$ LANGUAGE plpgsql;

-- Функция добавления нового сотрудника
CREATE FUNCTION add_employee(
    full_name VARCHAR(128),
    job_title VARCHAR(64)
) RETURNS void as $$
BEGIN
    INSERT INTO employees(full_name, job_title)
    VALUES (full_name, job_title);
END; $$ LANGUAGE plpgsql;

-- Функция добавления автомобиля на склад автосалона
CREATE FUNCTION add_car_to_stock(
    car_id INT,
    dealership_id INT
) RETURNS void AS $$
BEGIN
    INSERT INTO cars_availability(car_id, dealership_id)
    VALUES (car_id, dealership_id);
END; $$ LANGUAGE plpgsql;

-- Функция оформления продажи автомобиля
CREATE FUNCTION make_sale(
    car_id INT,
    dealership_id INT,
    employee_id INT
) RETURNS void AS $$
BEGIN
    INSERT INTO sales(car_id, dealership_id, employee_id)
    VALUES (car_id, dealership_id, employee_id);
END; $$ LANGUAGE plpgsql;

-- Теперь напишем функции по соответствующим видам анализа

-- Функция получения рейтинга продаж для сотрудника по заданой модели авто
CREATE FUNCTION get_employee_rating_by_model(
  employee_id INT,
  model_name VARCHAR(64)
) 
RETURNS TABLE(
  employee_name VARCHAR,
  model VARCHAR, 
  count BIGINT
) AS $$
BEGIN

  RETURN QUERY

  SELECT
    employees.full_name,
    cars.model,
    COUNT(*)
  FROM 
    sales
    JOIN employees ON sales.employee_id = employees.id
    JOIN cars ON sales.car_id = cars.id  
  WHERE
     employees.id = sales.employee_id AND  
     cars.model = model_name
  GROUP BY
    employees.full_name, cars.model;

END; $$ LANGUAGE plpgsql;

-- Функция рекомендации моделей для заказа на основе наличия и популярности
CREATE FUNCTION get_order_recommendations()
RETURNS TABLE(
    model VARCHAR,
    stock_quantity INT,
    sales_quantity INT
) AS $$
BEGIN
	RETURN QUERY
    SELECT
        cars.model,
        cars_availability.stock_quantity,
        cars_availability.sales_quantity
    FROM cars
    JOIN cars_availability
    ON cars.id = cars_availability.car_id;
END;
$$ LANGUAGE plpgsql;

-- Итак, теперь перейдем к наполнению БД

-- Добавим 2 автосалона
SELECT add_dealership('АвтоМир1','Ул. Ленина 1');
SELECT add_dealership('АвтоМир2','Ул. Сталина 2');

-- Добавим 5 сотрудников
SELECT add_employee('Антон Антонов','Менеджер');
SELECT add_employee('Борис Борисов','Консультант');
SELECT add_employee('Вера Веровна','Менеджер');
SELECT add_employee('Грегор Григорьев','Консультан');
SELECT add_employee('Дарья Дарьина','Консультант');

-- Добавим 10 автомобилей
SELECT add_car('Abibas Abeba',2011,'Белый','1111AAAA1111AAAA1');
SELECT add_car('Bentley Broom',2012,'Синий','2222BBBB2222BBBB2');
SELECT add_car('Cherry Carry',2013,'Красный','3333CCCC3333CCCC3');
SELECT add_car('Daewoo Daemon',2014,'Зеленый','4444DDDD4444DDDD4');
SELECT add_car('Exceed Exit',2015,'Фиолетовый','5555EEEE5555EEEE5');
SELECT add_car('Ford Fine',2016,'Бирюзовый','6666FFFF6666FFFF6');
SELECT add_car('Google Granta',2017,'Оранжевый','7777GGGG7777GGGG7');
SELECT add_car('Honda High',2018,'Белый','8888HHHH8888HHHH8');
SELECT add_car('Isuzu Izi',2019,'Черный','999IIII9999IIII9');
SELECT add_car('Jaguar Jipovich',2020,'Серый','J1010JJJJ1010JJJJ');

-- Добавим модели на склад
SELECT add_car_to_stock(1,1);
SELECT add_car_to_stock(2,2);
SELECT add_car_to_stock(3,1);
SELECT add_car_to_stock(4,2);
SELECT add_car_to_stock(5,1);
SELECT add_car_to_stock(6,2);
SELECT add_car_to_stock(7,1);
SELECT add_car_to_stock(8,2);
SELECT add_car_to_stock(9,1);
SELECT add_car_to_stock(10,2);

-- -- Пробуем вызвать функцию с ошибочным параметром
-- SELECT add_car('Jaguar Jipovich','Текстовый Год Две Тысячи 22','Серый','J1010JJJJ1010JJJJ');

-- Теперь попробуем вызвать наши функции с рекомендациями:

-- Заполним столбцы таблиц данными о количестве продаж

UPDATE cars_availability
SET stock_quantity = 10, sales_quantity = 5
WHERE car_id = 1;

UPDATE cars_availability
SET stock_quantity = 20, sales_quantity = 15
WHERE car_id = 2;

UPDATE cars_availability
SET stock_quantity = 23, sales_quantity = 15
WHERE car_id = 3;

UPDATE cars_availability
SET stock_quantity = 24, sales_quantity = 15
WHERE car_id = 4;

UPDATE cars_availability
SET stock_quantity = 25, sales_quantity = 15
WHERE car_id = 5;

UPDATE cars_availability
SET stock_quantity = 26, sales_quantity = 15
WHERE car_id = 6;

UPDATE cars_availability
SET stock_quantity = 27, sales_quantity = 15
WHERE car_id = 7;

UPDATE cars_availability
SET stock_quantity = 28, sales_quantity = 15
WHERE car_id = 8;

UPDATE cars_availability
SET stock_quantity = 29, sales_quantity = 15
WHERE car_id = 9;

UPDATE cars_availability
SET stock_quantity = 30, sales_quantity = 15
WHERE car_id = 10;

-- -- Проверим рекомендации моделей
-- SELECT * FROM get_order_recommendations();

-- Внесем новые данные о продажах

INSERT INTO sales
(car_id, dealership_id, employee_id)
VALUES
(1, 1, 1),
(2, 2, 1),
(1, 1, 2);

-- Проверим получение рейтинга продавца
SELECT * FROM get_employee_rating_by_model(1, 'Abibas Abeba');
