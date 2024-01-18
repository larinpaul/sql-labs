-- Лабораторная Работа № 1
-- Ларин Павел Евгеньевич
-- Общая часть:
-- Получение практических навыков работы с СУБД и языком SQL

-- Создание таблицы
CREATE TABLE cars (
    id SERIAL PRIMARY KEY,
    body_type VARCHAR(50) NOT NULL,
    manufacturing_country VARCHAR(50) NOT NULL,
    manufacturing_year INT
);

-- Добаввление данных в таблицу
INSERT INTO cars (body_type, manufacturing_country, manufacturing_year)
VALUES
    ('Sedan','Russia',2000),
    ('Stationwagon','China',2001),
    ('Offroad','Japan',2002),
    ('Hatchback','USA',2003),    
    ('Utility','Spain',2004),
    ('Minivan','France',2005),
    ('Pickup','Germany',2006),
    ('Luxury','Uzbekistan',2007),
    ('Crossover','Korea',2008),
    ('Microcar','Sweden',2009);

-- Показ таблицы:
SELECT * FROM cars



-- 1) Разработать в базе данных, созданной и заполненной на предыдущих лабораторных работах, следующие виды функций:

-- a. функция с пустыми входными параметрами, результат которой скалярное выражение;

CREATE FUNCTION getAverageManufacturingYear()
RETURNS INT
AS
$$
DECLARE
    average_manufacturing_year INT;
BEGIN
    SELECT AVG(manufacturing_year) INTO average_manufacturing_year
    FROM cars;

    RETURN average_manufacturing_year;
END;
$$
LANGUAGE plpgsql;

-- lb1.sql# SELECT getAverageManufacturingYear();



-- b. функция со скалярным аргументом, результат которой соответствует типу существующей таблицы;

CREATE FUNCTION getBodyTypeByManufacturingYear(year INT)
RETURNS VARCHAR(50)
AS $$
DECLARE
    car_body_type VARCHAR(50);
BEGIN
    SELECT body_type INTO car_body_type FROM cars WHERE year = manufacturing_year;

    RETURN car_body_type;
END;
$$
LANGUAGE plpgsql;

-- lb1=# SELECT getBodyTypeByManufacturingYear(2000);


-- c. функция с выходными аргументами, определенными с помощью OUT;

CREATE FUNCTION getCarInfoById(
    car_id INT,
    OUT car_body_type VARCHAR(50),
    OUT car_manufacturing_year INT,
    OUT car_manufacturing_country VARCHAR(50)
)
RETURNS record
AS $$
BEGIN
    SELECT body_type, manufacturing_year, manufacturing_country
    INTO car_body_type, car_manufacturing_year, car_manufacturing_country
    FROM cars
    WHERE id = car_id; 
END;
$$
LANGUAGE plpgsql;

-- lb1=# SELECT * FROM getCarInfoById(1);
