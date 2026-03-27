
CREATE DATABASE OnlineStore;
vw_ordersummaryUSE OnlineStore;

-- 1️⃣ Customers Table
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY AUTO_INCREMENT,
    FullName VARCHAR(100),
    Email VARCHAR(100) UNIQUE,
    Phone VARCHAR(20),
    City VARCHAR(50),
    Country VARCHAR(50)
);

-- 2️⃣ Products Table
CREATE TABLE Products (
    ProductID INT PRIMARY KEY AUTO_INCREMENT,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Price DECIMAL(10,2),
    Stock INT
);

-- 3️⃣ Orders Table
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID INT,
    OrderDate DATE,
    Status VARCHAR(20),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- 4️⃣ OrderItems Table
CREATE TABLE OrderItems (
    OrderItemID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    UnitPrice DECIMAL(10,2),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- 5️⃣ Payments Table
CREATE TABLE Payments (
    PaymentID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT,
    PaymentDate DATE,
    Amount DECIMAL(10,2),
    PaymentMethod VARCHAR(30),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

INSERT INTO Customers (FullName, Email, Phone, City, Country) VALUES
('John Doe', 'john@example.com', '1234567890', 'New York', 'USA'),
('Alice Smith', 'alice@example.com', '9876543210', 'Los Angeles', 'USA'),
('Bob Brown', 'bob@example.com', '5551234567', 'Chicago', 'USA'),
('Diana Ross', 'diana@example.com', '3334445555', 'Miami', 'USA');

INSERT INTO Products (ProductName, Category, Price, Stock) VALUES
('Laptop', 'Electronics', 1200.00, 10),
('Headphones', 'Electronics', 150.00, 25),
('Desk Chair', 'Furniture', 200.00, 15),
('Coffee Mug', 'Home', 12.50, 50),
('Keyboard', 'Electronics', 80.00, 20);

INSERT INTO Orders (CustomerID, OrderDate, Status) VALUES
(1, '2025-10-20', 'Shipped'),
(2, '2025-10-21', 'Pending'),
(3, '2025-10-22', 'Delivered'),
(1, '2025-10-25', 'Delivered');

INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice) VALUES
(1, 1, 1, 1200.00),
(1, 2, 2, 150.00),
(2, 3, 1, 200.00),
(3, 4, 3, 12.50),
(4, 5, 1, 80.00);

INSERT INTO Payments (OrderID, PaymentDate, Amount, PaymentMethod) VALUES
(1, '2025-10-20', 1500.00, 'Credit Card'),
(3, '2025-10-22', 37.50, 'PayPal'),
(4, '2025-10-25', 80.00, 'Cash');

 ---- INNER JOIN
 
 SELECT c.FullName, o.OrderID, o.OrderDate, p.Amount AS PaymentAmount
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
LEFT JOIN Payments p ON o.OrderID = p.OrderID;

----  -- VIEW (Create a view showing order summary)

CREATE VIEW vw_OrderSummary AS
SELECT o.OrderID, c.FullName, o.OrderDate,
       SUM(oi.Quantity * oi.UnitPrice) AS TotalAmount,
       o.Status
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN OrderItems oi ON o.OrderID = oi.OrderID
GROUP BY o.OrderID, c.FullName, o.OrderDate, o.Status;

-- View the data
SELECT * FROM vw_OrderSummary;

----- -- TRIGGER (Auto-update stock after inserting order item)

DELIMITER $$

CREATE TRIGGER trg_UpdateStock
AFTER INSERT ON OrderItems
FOR EACH ROW
BEGIN
    UPDATE Products
    SET Stock = Stock - NEW.Quantity
    WHERE ProductID = NEW.ProductID;
END$$

DELIMITER ;

-- Test trigger
INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
VALUES (2, 2, 1, 150.00);  -- will reduce stock of 'Headphones' by 1

----- -- STORED PROCEDURE (Show all orders for a given customer)

DELIMITER $$

CREATE PROCEDURE GetCustomerOrders(IN custID INT)
BEGIN
    SELECT o.OrderID, o.OrderDate, o.Status, 
           SUM(oi.Quantity * oi.UnitPrice) AS TotalAmount
    FROM Orders o
    JOIN OrderItems oi ON o.OrderID = oi.OrderID
    WHERE o.CustomerID = custID
    GROUP BY o.OrderID, o.OrderDate, o.Status;
END$$

DELIMITER ;

-- Execute procedure
CALL GetCustomerOrders(1);


--- -- INDEX (Improve search performance)

CREATE INDEX idx_ProductName ON Products(ProductName);
CREATE INDEX idx_CustomerEmail ON Customers(Email);

--- -- SUBQUERY (Find customers who spent more than $500)

SELECT FullName
FROM Customers
WHERE CustomerID IN (
    SELECT o.CustomerID
    FROM Orders o
    JOIN Payments p ON o.OrderID = p.OrderID
    GROUP BY o.CustomerID
    HAVING SUM(p.Amount) > 500
);


-------- -- GROUP BY + HAVING (Total sales per customer, only those > $100)

SELECT c.FullName, SUM(p.Amount) AS TotalSpent
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN Payments p ON o.OrderID = p.OrderID
GROUP BY c.FullName
HAVING SUM(p.Amount) > 100;

------- -- LIKE Operator (Search for product names containing “top”)

SELECT * FROM Products
WHERE ProductName LIKE '%top%';

------- -- 
  