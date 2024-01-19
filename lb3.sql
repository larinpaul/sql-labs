-- Лабораторная Работа № 3
-- Ларин Павел Евгеньевич
-- Общая часть:
-- Ознакомиться с теоретическими сведениями о возможности создания пользователей баз данных, использования транзакций в PostgreSQL.
-- Создать нового пользователя и зайти под его именем.

CREATE USER larinpavel WITH PASSWORD 'larin3' SUPERUSER;

-- WHAT IS THIS?
\c post


-- Создать и заполнить базу данных своего варианта.

-- Ларин Павел, Вариант 5
-- Создать и заполнить базу данных с помощью PostgreSQL
-- для осуществления учета работы автосалона, состоящую из четырех таблиц.
-- На основании созданных таблиц создать таблицу, содержащую поля:
-- марка, модель, тип кузова, руль, привод, двигатель, страна сборки, стоимость.
-- Наложить ограничение на поле "привод": оно должно содержать только "полный", "передный", "задний".
-- Поле "руль" может содержать только значения правый и левый.
-- Дата выпуска не должна быть больше текущей даты.

CREATE DATABASE lb3larin
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'Russian_Russia.1251'
    LC_CTYPE = 'Russian_Russia.1251'
    LOCALE_PROVIDER = 'libc'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

-- Создание таблицы "Тип кузова"
CREATE TABLE body_type (
    id SERIAL PRIMARY KEY,
    body_type VARCHAR(255)
);

-- Создание таблицы "Страна сборки"
CREATE TABLE manufacturing_country (
    id SERIAL PRIMARY KEY,
    manufacturing_country VARCHAR(255)
);

-- Создание таблицы "Тип привода"
CREATE TABLE drive_type (
    id SERIAL PRIMARY KEY,
    -- Наложить ограничение на поле "привод": оно должно содержать только "полный", "передный", "задний".
    drive_type VARCHAR(255) CHECK(drive_type IN('полный', 'передний', 'задний'))
); 

-- Создание таблицы "Автомобили"
CREATE TABLE cars (
	id SERIAL PRIMARY KEY,
	brand VARCHAR(255),
	model VARCHAR(255),
	drive_type_id INTEGER REFERENCES drive_type(id),
	engine VARCHAR(255),
	-- Дата выпуска не должна быть больше текущей даты.
	release_date DATE CHECK (release_date <= CURRENT_DATE),
	price NUMERIC CHECK (price > 0),
	-- Поле "руль" может содержать только значения правый и левый.
	steering_wheel VARCHAR(255) CHECK(steering_wheel IN('левый', 'правый')),
	manufacturing_country_id INTEGER REFERENCES manufacturing_country(id),
	body_type_id INTEGER REFERENCES body_type(id)
);

-- Заполнение таблицы "Тип кузова"
INSERT INTO body_type (body_type)
VALUES
    ('Sedan'),
    ('Stationwagon'),
    ('Offroad'),
    ('Hatchback'),
    ('Utility'),
    ('Minivan'),
    ('Pickup'),
    ('Luxury'),
    ('Crossover'),
    ('Truck'),    
    ('Microcar');

-- Заполнение таблицы "Страна сборки"
INSERT INTO manufacturing_country (manufacturing_country)
VALUES
	('Russia'),
	('China'),
	('Japan'),
	('USA'),
	('Spain'),
	('France'),
	('Germany'),
	('Uzbekistan'),
	('Korea'),
	('Swedden');

-- Заполнение таблицы "Тип привода"
INSERT INTO drive_type (drive_type)
VALUES
    ('полный'),
    ('передний'),
    ('задний');

-- Создание таблицы "Автомобили"
INSERT INTO cars (
    brand,
    model,
    engine,
    release_date,
    price,
    steering_wheel,
    manufacturing_country_id,
    body_type_id, 
    drive_type_id
)
VALUES
    (
        'Aada', 'T1', 'Gasoline', '2023-01-01', '11111', 'левый', '1', '1', '1'
    ),
    (
        'Baba', 'B2', 'Gasoline', '2023-01-02', '22222', 'левый', '2', '2', '2'
    ),
    (
        'Ceca', 'C3', 'Diesel', '2023-01-03', '33333', 'левый', '3', '3', '3'
    ),
    (
        'Deda', 'D4', 'Electric', '2023-01-04', '44444', 'левый', '4', '4', '1'
    ),
    (
        'Eea', 'E5', 'Electric', '2023-01-05', '55555', 'левый', '5', '5', '1'
    ),
    (
        'Fofa', 'F6', 'Gasoline', '2023-01-06', '66666', 'правый', '6', '6', '1'
    ),
    (
        'Goga', 'G7', 'Diesel', '2023-01-07', '77777', 'правый', '7', '7', '2'
    ),
    (
        'Hoda', 'H8', 'Hybrid', '2023-01-08', '88888', 'правый', '8', '8', '2'
    ),
    (
        'Iota', 'I9', 'Electric', '2023-01-09', '99999', 'правый', '9', '9', '2'
    ),
    (
        'Jeda', 'J10', 'Electric', '2023-01-10', '10101010', 'правый', '10', '10', '3'
    );


-- Для наложения дополнительных ограничений можно использовать команду ALTER TABLE
-- Поскольку мы наложили ограничения изначально, то они уже существуют в нашей схеме БД,
-- но для дополнительной практики произведем соответствующие манипуляции

-- Поле "руль" может содержать только значения правый и левый.
ALTER TABLE cars
    ADD CONSTRAINT
	check_steering_wheel CHECK(steering_wheel IN('левый', 'правый'));

-- Дата выпуска не должна быть больше текущей даты.
ALTER TABLE cars
    ADD CONSTRAINT
    check_release_date CHECK (release_date <= CURRENT_DATE);

-- Наложить ограничение на поле "привод": оно должно содержать только "полный", "передный", "задний".
ALTER TABLE drive_type
    ADD CONSTRAINT
    check_drive_type CHECK(drive_type IN('полный', 'передний', 'задний'));

-- Проверить работоспособность ограничений путем добавления в таблицы данных,
-- удовлетворяющих и не удовлетворяющих условиям ограничений.
INSERT INTO cars (
    brand,
    model,
    engine,
    release_date,
    price,
    steering_wheel,
    manufacturing_country_id,
    body_type_id, 
    drive_type_id
)
VALUES
    (
        'Aada', 'T1', 'Gasoline', '2023-02-01', '11111', 'нелевый', '1', '1', '1'
    ),
    (
        'Baba', 'B2', 'Gasoline', '9999-02-02', '22222', 'левый', '2', '2', '2'
    ),
    (
        'Ceca', 'C3', 'Diesel', '2023-02-03', '33333', 'левый', '3', '3', '4'
    );
