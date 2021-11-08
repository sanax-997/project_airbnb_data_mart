CREATE TABLE Currencies (
    CurrencyCode CHAR (3),
    ConversionRate DECIMAL (20,10) NOT NULL,
    PRIMARY KEY (CurrencyCode)
    )

CREATE TABLE Host (
	HostID INT AUTO_INCREMENT,
	HostName VARCHAR (100) NOT NULL,
	HostSurname VARCHAR (100) NOT NULL,
	HostAge DECIMAL (3,0) NOT NULL,
	CurrencyCode CHAR (3) NOT NULL,
	PRIMARY KEY (HostID),
	FOREIGN KEY (CurrencyCode) REFERENCES Currencies (CurrencyCode)
		ON DELETE RESTRICT ON UPDATE CASCADE
)

CREATE TABLE HostAdresses (
	HostAdressesID INT AUTO_INCREMENT,
	HostCountry VARCHAR (100) NOT NULL,
	HostRegion VARCHAR (100),
	HostTown VARCHAR (100),
	HostStreet VARCHAR (100),
	HostHouseNumber VARCHAR (30),
	HostZIPCode VARCHAR (30),
	HostID INT UNIQUE NOT NULL,
	PRIMARY KEY (HostAdressesID),
	FOREIGN KEY (HostID) REFERENCES Host (HostID)
		ON DELETE CASCADE ON UPDATE CASCADE
)

CREATE TABLE HostContacts (
    HostEmailAdress VARCHAR (100) NOT NULL,
    HostPhoneNumber VARCHAR (100) NOT NULL,
    HostID INT UNIQUE NOT NULL,
    PRIMARY KEY (HostEmailAdress,HostPhoneNumber),
    FOREIGN KEY (HostID) REFERENCES host (HostID)
	ON DELETE CASCADE ON UPDATE CASCADE    
    )

CREATE TABLE Guests (
	GuestID INT AUTO_INCREMENT,
	GuestName VARCHAR (100) NOT NULL,
	GuestSurname VARCHAR (100) NOT NULL,
	GuestAge DECIMAL (3,0) NOT NULL,
	CurrencyCode CHAR (3) NOT NULL,
	PRIMARY KEY (GuestID),
	FOREIGN KEY (CurrencyCode) REFERENCES Currencies (CurrencyCode)
		ON DELETE RESTRICT ON UPDATE CASCADE
)

CREATE TABLE GuestAdresses (
	GuestAdressesID INT AUTO_INCREMENT,
	GuestCountry VARCHAR (100) NOT NULL,
	GuestRegion VARCHAR (100),
	GuestTown VARCHAR (100) NOT NULL,
	GuestStreet VARCHAR (100) NOT NULL,
	GuestHouseNumber VARCHAR (30) NOT NULL,
	GuestZIPCode VARCHAR (30) NOT NULL,
	GuestID INT UNIQUE NOT NULL,
	PRIMARY KEY (GuestAdressesID),
	FOREIGN KEY (GuestID) REFERENCES Guests (GuestID)
		ON DELETE CASCADE ON UPDATE CASCADE
)


CREATE TABLE GuestContacts (
    GuestEmailAdress VARCHAR (100) NOT NULL,
    GuestPhoneNumber VARCHAR (100) NOT NULL,
    GuestID INT UNIQUE NOT NULL,
    PRIMARY KEY (GuestEmailAdress,GuestPhoneNumber),
    FOREIGN KEY (GuestID) REFERENCES Guests (GuestID)
	ON DELETE CASCADE ON UPDATE CASCADE 
)

CREATE TABLE HostReviews (
    HostReviewID INT AUTO_INCREMENT,
    HostScore DECIMAL (1,0) NOT NULL,
    HostText TEXT,
    HostReviewDate DATE NOT NULL,
    HostID INT NOT NULL,
    GuestID INT NOT NULL,
    PRIMARY KEY (HostReviewID),
    FOREIGN KEY (HostID) REFERENCES host(HostID)
	ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (GuestID) REFERENCES guests(GuestID)
	ON DELETE CASCADE ON UPDATE CASCADE
)

CREATE TABLE GuestReviews (
    GuestReviewID INT AUTO_INCREMENT,
    GuestScore DECIMAL (1,0) NOT NULL,
    GuestText TEXT,
    GuestReviewDate DATE NOT NULL,
    HostID INT NOT NULL,
    GuestID INT NOT NULL,
    PRIMARY KEY (GuestReviewID),
    FOREIGN KEY (HostID) REFERENCES host(HostID)
	ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (GuestID) REFERENCES guests(GuestID)
	ON DELETE CASCADE ON UPDATE CASCADE
    )

CREATE TABLE Accommodations (
    AccommodationID INT AUTO_INCREMENT,
    AccommodationName VARCHAR (100) NOT NULL UNIQUE,
    AccommodationDescription TEXT,
    AccommodationType VARCHAR (100),
    AccommodationRules VARCHAR (100),
    HostID INT NOT NULL,
    PRIMARY KEY (AccommodationID),
    FOREIGN KEY (HostID) REFERENCES host(HostID)
	ON DELETE CASCADE ON UPDATE CASCADE
    )

CREATE TABLE Locations (
    LocationID INT AUTO_INCREMENT,
    LocationCountry VARCHAR (100) NOT NULL,
    LocationRegion VARCHAR (100) NOT NULL,
    LocationTown VARCHAR (100) NOT NULL,
    LocationStreet VARCHAR (100) NOT NULL,
    LocationHouseNumber VARCHAR (30) NOT NULL,
    LocationZIPCode VARCHAR (30) NOT NULL,
    LocationDescription TEXT,
    AccommodationID INT UNIQUE NOT NULL,
    PRIMARY KEY (LocationID),
    FOREIGN KEY (accommodationID) REFERENCES accommodations(accommodationID)
	ON DELETE CASCADE ON UPDATE CASCADE
    )

CREATE TABLE Reservations (
    ReservationID INT AUTO_INCREMENT,
    CheckInDate DATE NOT NULL,
    CheckOutDate DATE NOT NULL,
    GuestNumber DECIMAL (2,0) NOT NULL,
    AccommodationID INT NOT NULL,
    GuestID INT NOT NULL,
    PRIMARY KEY (ReservationID),
    FOREIGN KEY (AccommodationID) REFERENCES accommodations (AccommodationID)
	ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (GuestID) REFERENCES guests (GuestID)
 	ON DELETE CASCADE ON UPDATE CASCADE
    )

CREATE TABLE Prices (
    PriceID INT AUTO_INCREMENT,
    IntialPrice DECIMAL (20,2) NOT NULL,
    NumberOfNights DECIMAL (2,0) NOT NULL,
    Discount DECIMAL (3,0),
    TotalPrice DECIMAL (20,2) NOT NULL,
    AccommodationID INT UNIQUE NOT NULL,
    PRIMARY KEY (PriceID),
    FOREIGN KEY (accommodationID) REFERENCES accommodations(accommodationID)
	ON DELETE CASCADE ON UPDATE CASCADE
    )

CREATE TABLE PaymentMethods(
    PaymentMethod VARCHAR(100) NOT NULL UNIQUE,
    PRIMARY KEY (PaymentMethod)
)

CREATE TABLE Payments (
    PaymentID INT AUTO_INCREMENT,
    PaymentAmount DECIMAL (20,2),
    PaymentMethod VARCHAR (100) NOT NULL,
    PaymentTime DATETIME NOT NULL,
    GuestID INT NOT NULL,
    PriceID INT UNIQUE NOT NULL,
    PRIMARY KEY (PaymentID),
    FOREIGN KEY (PaymentMethod) REFERENCES PaymentMethods(PaymentMethod)
	ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (GuestID) REFERENCES guests(GuestID)
	ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (PriceID) REFERENCES prices(PriceID)
	ON DELETE CASCADE ON UPDATE CASCADE
    )

CREATE TABLE PayConfirmations (
    PayConfirmationID INT AUTO_INCREMENT,
    ConfirmationCancellation BOOLEAN,
    CancellationConfirmationTime DATE,
    PossibleCancellationTime DATE NOT NULL,
    PaymentID INT UNIQUE NOT NULL,
    PRIMARY KEY (PayConfirmationID),
    FOREIGN KEY (PaymentID) REFERENCES payments(PaymentID)
	ON DELETE CASCADE ON UPDATE CASCADE
    )

CREATE TABLE Income (
    IncomeID INT AUTO_INCREMENT,
    Income DECIMAL (20,2),
    IncomeTime DATETIME NOT NULL,
    AccommodationID INT NOT NULL,
    PayConfirmationID INT UNIQUE NOT NULL,
    PRIMARY KEY (IncomeID),
    FOREIGN KEY (accommodationID) REFERENCES accommodations(accommodationID)
	ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (PayConfirmationID) REFERENCES payconfirmations(PayconfirmationID)
	ON DELETE CASCADE ON UPDATE CASCADE
    )

CREATE TABLE Interiors (
    InteriorID INT AUTO_INCREMENT,
    InteriorDescription TEXT,
    RoomNumber DECIMAL (3,0),
    AccommodationID INT UNIQUE NOT NULL,
    PRIMARY KEY (InteriorID),
    FOREIGN KEY (accommodationID) REFERENCES accommodations(accommodationID)
	ON DELETE CASCADE ON UPDATE CASCADE
    )

CREATE TABLE Exteriors (
    ExteriorID INT AUTO_INCREMENT, 
    ExteriorType VARCHAR (100),
    ExteriorDescription TEXT,
    AccommodationID INT UNIQUE NOT NULL,
    PRIMARY KEY (ExteriorID),
    FOREIGN KEY (AccommodationID) REFERENCES accommodations(AccommodationID)
	ON DELETE CASCADE ON UPDATE CASCADE
    )

CREATE TABLE AccommodationReviews (
    AccommodationReviewID INT AUTO_INCREMENT,
    AccommodationScore DECIMAL (1,0) NOT NULL,
    AccommodationText TEXT,
    AccommodationReviewDate DATE NOT NULL,
    GuestID INT NOT NULL,
    AccommodationID INT NOT NULL,
    PRIMARY KEY (AccommodationReviewID),
    FOREIGN KEY (GuestID) REFERENCES guests(GuestID)
	ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (AccommodationID) REFERENCES accommodations(AccommodationID)
	ON DELETE CASCADE ON UPDATE CASCADE
    )


CREATE TABLE Bedrooms (
    BedroomID INT AUTO_INCREMENT,
    BedroomName VARCHAR (100) NOT NULL,
    BedsNumber DECIMAL (2,0) NOT NULL,
    BedroomDescription TEXT,
    InteriorID INT NOT NULL,
    PRIMARY KEY (BedroomID),
    FOREIGN KEY (InteriorID) REFERENCES interiors(InteriorID)
	ON DELETE CASCADE ON UPDATE CASCADE
    )

CREATE TABLE Bathrooms (
    BathroomID INT AUTO_INCREMENT,
    BathroomName VARCHAR (100) NOT NULL,
    BathroomDescription TEXT,
    InteriorID INT NOT NULL,
    PRIMARY KEY (BathroomID),
    FOREIGN KEY (InteriorID) REFERENCES interiors(InteriorID)
	ON DELETE CASCADE ON UPDATE CASCADE
    )

CREATE TABLE Kitchens (
    KitchenID INT AUTO_INCREMENT,
    KitchenName VARCHAR(100) NOT NULL,
    KitchenDescription TEXT,
    InteriorID INT NOT NULL,
    PRIMARY KEY (KitchenID),
    FOREIGN KEY (InteriorID) REFERENCES interiors(InteriorID)
	ON DELETE CASCADE ON UPDATE CASCADE
    )

CREATE TABLE LivingRooms (
    LivingRoomID INT AUTO_INCREMENT,
    LivingRoomName VARCHAR(100) NOT NULL,
    LivingRoomDescription TEXT,
    InteriorID INT NOT NULL,
    PRIMARY KEY (LivingRoomID),
    FOREIGN KEY (InteriorID) REFERENCES interiors(InteriorID)
	ON DELETE CASCADE ON UPDATE CASCADE
    )

CREATE TABLE OtherRooms (
    OtherRoomID INT AUTO_INCREMENT,
    OtherRoomName VARCHAR(100) NOT NULL,
    OtherRoomDescription TEXT,
    InteriorID INT NOT NULL,
    PRIMARY KEY (OtherRoomID),
    FOREIGN KEY (InteriorID) REFERENCES interiors(InteriorID)
	ON DELETE CASCADE ON UPDATE CASCADE
    )
