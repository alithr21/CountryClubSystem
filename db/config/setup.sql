/*
 * setup.sql
 */

DROP DATABASE IF EXISTS CountryClub; -- Resets database after each run for testing
CREATE DATABASE IF NOT EXISTS CountryClub;
USE CountryClub;

--

/*************
 *** USERS ***
 *************/

/*** User */
CREATE TABLE IF NOT EXISTS User (
    Username VARCHAR(64) NOT NULL PRIMARY KEY,
    PasswordHash VARCHAR(32) NOT NULL,
    AdminPrivilege INT NOT NULL -- 0 = none, 1 = moderate and 2 = full

    -- CONSTRAINT USER_PK PRIMARY KEY (Username)
);
INSERT IGNORE INTO User VALUES ("admin", "21232f297a57a5a743894a0e4a801fc3", 2); -- "admin" MD5 hash: 21232f297a57a5a743894a0e4a801fc3

/*** Membership */
CREATE TABLE IF NOT EXISTS Membership (
    MembershipId INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    MembershipName VARCHAR(64) NOT NULL,
    MembershipDescription VARCHAR(512),
    Price FLOAT NOT NULL
) AUTO_INCREMENT = 0;

/*** Manager */
CREATE TABLE IF NOT EXISTS Manager (
    ManagerId INT AUTO_INCREMENT PRIMARY KEY,
    FName VARCHAR(32) NOT NULL,
    LName VARCHAR(32) NOT NULL,
    MName VARCHAR(32),
    DOB DATE NOT NULL,
    Email VARCHAR(64) NOT NULL,
    PhoneNumber INT,
    Address VARCHAR(512),
    DateJoined DATE NOT NULL,
    Title VARCHAR(32) NOT NULL,
    Username VARCHAR(64) NOT NULL, -- FK User.Username
    SuperManagerId INT, -- FK Manager.ManagerId

    -- CONSTRAINT MANAGER_PK PRIMARY KEY (ManagerId),
    CONSTRAINT MANAGER_FK1 FOREIGN KEY (Username)
        REFERENCES User (Username)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT MANAGER_FK2 FOREIGN KEY (SuperManagerId)
        REFERENCES Manager (ManagerId)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) AUTO_INCREMENT = 0;

/*** Employee */
CREATE TABLE IF NOT EXISTS Employee (
    EmployeeId INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    FName VARCHAR(32) NOT NULL,
    LName VARCHAR(32) NOT NULL,
    MName VARCHAR(32),
    DOB DATE NOT NULL,
    Email VARCHAR(64) NOT NULL,
    PhoneNumber INT,
    Address VARCHAR(512),
    DateJoined DATE NOT NULL,
    Title VARCHAR(32) NOT NULL,
    Username VARCHAR(64), -- FK User.Username
    ManagerId INT, -- FK Manager.ManagerId

    -- CONSTRAINT EMPLOYEE_PK PRIMARY KEY (EmployeeId),
    CONSTRAINT EMPLOYEE_FK1 FOREIGN KEY (Username)
        REFERENCES User (Username)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT EMPLOYEE_FK2 FOREIGN KEY (ManagerId)
        REFERENCES Manager (ManagerId)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) AUTO_INCREMENT = 0;

/*** Customer */
CREATE TABLE IF NOT EXISTS Customer (
    -- CustomerId INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Email VARCHAR(64) NOT NULL PRIMARY KEY,
    FName VARCHAR(32) NOT NULL,
    LName VARCHAR(32) NOT NULL,
    MName VARCHAR(32),
    DOB DATE,
    PhoneNumber INT,
    Address VARCHAR(512),
    DateJoined DATE NOT NULL,
    MembershipId INT, -- FK Membership.MembershipId
    MemberSince DATE,
    Username VARCHAR(64), -- FK User.Username

    -- CONSTRAINT CUSTOMER_PK PRIMARY KEY (CustomerId),
    CONSTRAINT CUSTOMER_FK1 FOREIGN KEY (MembershipId)
        REFERENCES Membership (MembershipId)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT CUSTOMER_FK2 FOREIGN KEY (Username)
        REFERENCES User (Username)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) AUTO_INCREMENT = 0;

--

/************
 *** TIME ***
 ************/

/*** Time_ */
CREATE TABLE IF NOT EXISTS Time_ (
    TimeId INT NOT NULL PRIMARY KEY
);

/*** TimeSlot */
CREATE TABLE IF NOT EXISTS TimeSlot (
    TimeSlotId INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    StartTime INT NOT NULL, -- FK Time_.TimeId
    EndTime INT NOT NULL, -- FK Time_.TimeId

    CONSTRAINT TIME_SLOT_FK1 FOREIGN KEY (StartTime)
        REFERENCES Time_ (TimeId)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT TIME_SLOT_FK2 FOREIGN KEY (EndTime)
        REFERENCES Time_ (TimeId)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) AUTO_INCREMENT = 0;

--

/**************
 *** COURSE ***
 **************/

/*** Course */
CREATE TABLE IF NOT EXISTS Course (
    CourseId INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    CourseName VARCHAR(256) NOT NULL
) AUTO_INCREMENT = 0;

/*** CourseBooking */
CREATE TABLE IF NOT EXISTS CourseBooking (
    BookingId INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    CustomerEmail VARCHAR(64), -- FK Customer.Email
    BookedDate DATE,
    BookedTimeSlot INT, -- FK TimeSlot.TimeSlotId
    CourseId INT, -- FK Course.CourseId
    Notes VARCHAR(512),

    CONSTRAINT COURSE_BOOKING_FK1 FOREIGN KEY(CustomerEmail)
        REFERENCES Customer (Email)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT COURSE_BOOKING_FK2 FOREIGN KEY (BookedTimeSlot)
        REFERENCES TimeSlot (TimeSlotId)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT COURSE_BOOKING_FK3 FOREIGN KEY (CourseId)
        REFERENCES Course (CourseId)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) AUTO_INCREMENT = 0;

/*** CourseCheckIn */
CREATE TABLE IF NOT EXISTS CourseCheckIn (
    CustomerEmail VARCHAR(64) NOT NULL, -- FK Customer.Email
    CheckInDate DATE NOT NULL,
    CheckInTime INT NOT NULL, -- FK Time_.TimeId
    BookingId INT NOT NULL, -- FK CourseBooking.BookingId
    EmployeeId INT NOT NULL, -- FK Employee.EmployeeId
    Notes VARCHAR(512),

    CONSTRAINT COURSE_CHECK_IN_PK PRIMARY KEY (CustomerEmail, CheckInDate, CheckInTime, BookingId),
    CONSTRAINT COURSE_CHECK_IN_FK1 FOREIGN KEY (CustomerEmail)
        REFERENCES Customer (Email)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT COURSE_CHECK_IN_FK2 FOREIGN KEY (CheckInTime)
        REFERENCES Time_ (TimeId)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT COURSE_CHECK_IN_FK3 FOREIGN KEY (BookingId)
        REFERENCES CourseBooking (BookingId)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT COURSE_CHECK_IN_FK4 FOREIGN KEY (EmployeeId)
        REFERENCES Employee (EmployeeId)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- 

/******************
 *** RESTAURANT ***
 ******************/

/*** RestaurantBooking */
CREATE TABLE IF NOT EXISTS RestaurantBooking (
    BookingId INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    CustomerEmail VARCHAR(64) NOT NULL, -- FK Customer.Email
    BookedDate DATE NOT NULL,
    BookedTime INT, -- FK Time_.TimeId
    NumGuests INT,
    Notes VARCHAR(512),

    CONSTRAINT RESTAURANT_BOOKING_FK1 FOREIGN KEY(CustomerEmail)
        REFERENCES Customer (Email)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT RESTAURANT_BOOKING_FK2 FOREIGN KEY (BookedTime)
        REFERENCES Time_ (TimeId)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) AUTO_INCREMENT = 0;

/*** RestaurantCheckIn */
CREATE TABLE IF NOT EXISTS RestaurantCheckIn (
    CustomerEmail VARCHAR(64) NOT NULL, -- FK Customer.Email
    CheckInDate DATE NOT NULL,
    CheckInTime INT, -- FK Time_.TimeId
    BookingId INT NOT NULL, -- FK RestaurantBooking.BookingId
    EmployeeId INT, -- FK Employee.EmployeeId
    Notes VARCHAR(512),

    CONSTRAINT RESTAURANT_CHECK_IN_PK PRIMARY KEY (CustomerEmail, CheckInDate, CheckInTime, BookingId),
    CONSTRAINT RESTAURANT_CHECK_IN_FK1 FOREIGN KEY (CustomerEmail)
        REFERENCES Customer (Email)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT RESTAURANT_CHECK_IN_FK2 FOREIGN KEY (CheckInTime)
        REFERENCES Time_ (TimeId)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT RESTAURANT_CHECK_IN_FK3 FOREIGN KEY (BookingId)
        REFERENCES RestaurantBooking (BookingId)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT RESTAURANT_CHECK_IN_FK4 FOREIGN KEY (EmployeeId)
        REFERENCES Employee (EmployeeId)
        ON UPDATE CASCADE
        ON DELETE NO ACTION
);

/*** Product */
CREATE TABLE IF NOT EXISTS Product (
    ProductId INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    ProductName VARCHAR(256) NOT NULL,
    Supplier VARCHAR(256) NOT NULL,
    Stock INT,
    Price FLOAT NOT NULL
) AUTO_INCREMENT = 0;

/*** FoodOrder */
CREATE TABLE IF NOT EXISTS FoodOrder (
    OrderId INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    CustomerEmail VARCHAR(64) NOT NULL, -- FK Customer.Email
    EmployeeId INT, -- FK Employee.EmployeeId
    DateOrdered DATE NOT NULL,
    TimeOrdered INT, -- FK Time_.TimeId
    Notes VARCHAR(512),

    CONSTRAINT FOOD_ORDER_FK1 FOREIGN KEY (CustomerEmail)
        REFERENCES Customer (Email)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT FOOD_ORDER_FK2 FOREIGN KEY (EmployeeId)
        REFERENCES Employee (EmployeeId)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT FOOD_ORDER_FK3 FOREIGN KEY (TimeOrdered)
        REFERENCES Time_ (TimeId)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) AUTO_INCREMENT = 0;

/*** FoodOrderItem */
CREATE TABLE IF NOT EXISTS FoodOrderItem (
    OrderId INT NOT NULL, -- FK FoodOder.OrderId
    ProductId INT, -- FK Product.ProductId
    Quantity INT NOT NULL,
    Price FLOAT NOT NULL,
    Notes VARCHAR(512),

    CONSTRAINT FOOD_ORDER_ITEM_PK PRIMARY KEY (OrderId, ProductId),
    CONSTRAINT FOOD_ORDER_ITEM_FK1 FOREIGN KEY (OrderId)
        REFERENCES FoodOrder (OrderId)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT FOOD_ORDER_ITEM_FK2 FOREIGN KEY (ProductId)
        REFERENCES Product (ProductId)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);