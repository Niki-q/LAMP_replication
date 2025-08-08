-- Создание базы данных
CREATE DATABASE IF NOT EXISTS db_app;
USE db_app;

-- Создание таблиц
CREATE TABLE IF NOT EXISTS Movie (
                                     mID INT AUTO_INCREMENT PRIMARY KEY,
                                     title TEXT,
                                     year INT,
                                     director TEXT
);

CREATE TABLE IF NOT EXISTS Reviewer (
                                        rID INT PRIMARY KEY,
                                        name TEXT
);

CREATE TABLE IF NOT EXISTS Rating (
                                      rID INT,
                                      mID INT,
                                      stars INT,
                                      ratingDate DATE,
                                      FOREIGN KEY (rID) REFERENCES Reviewer(rID),
    FOREIGN KEY (mID) REFERENCES Movie(mID) ON DELETE CASCADE
    );

-- Наполнение таблиц
INSERT INTO Movie VALUES
                      (101, 'Gone with the Wind', 1939, 'Victor Fleming'),
                      (102, 'Star Wars', 1977, 'George Lucas'),
                      (103, 'The Sound of Music', 1965, 'Robert Wise'),
                      (104, 'E.T.', 1982, 'Steven Spielberg'),
                      (105, 'Titanic', 1997, 'James Cameron'),
                      (106, 'Snow White', 1937, NULL),
                      (107, 'Avatar', 2009, 'James Cameron'),
                      (108, 'Raiders of the Lost Ark', 1981, 'Steven Spielberg');

INSERT INTO Reviewer VALUES
                         (201, 'Sarah Martinez'),
                         (202, 'Daniel Lewis'),
                         (203, 'Brittany Harris'),
                         (204, 'Mike Anderson'),
                         (205, 'Chris Jackson'),
                         (206, 'Elizabeth Thomas'),
                         (207, 'James Cameron'),
                         (208, 'Ashley White');

INSERT INTO Rating VALUES
                       (201, 101, 2, '2011-01-22'),
                       (201, 101, 4, '2011-01-27'),
                       (202, 106, 4, NULL),
                       (203, 103, 2, '2011-01-20'),
                       (203, 108, 4, '2011-01-12'),
                       (203, 108, 2, '2011-01-30'),
                       (204, 101, 3, '2011-01-09'),
                       (205, 103, 3, '2011-01-27'),
                       (205, 104, 2, '2011-01-22'),
                       (205, 108, 4, NULL),
                       (206, 107, 3, '2011-01-15'),
                       (206, 106, 5, '2011-01-19'),
                       (207, 107, 5, '2011-01-20'),
                       (208, 104, 3, '2011-01-02');

-- Проверяем, существует ли пользователь, прежде чем создавать его
SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = 'repl_user') INTO @user_exists;
SET @create_user_sql = IF(@user_exists = 0, "CREATE USER 'repl_user'@'%' IDENTIFIED BY 'replpass';", "SELECT 'User already exists';");
PREPARE stmt FROM @create_user_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

GRANT REPLICATION SLAVE ON *.* TO 'repl_user'@'%';
FLUSH PRIVILEGES;