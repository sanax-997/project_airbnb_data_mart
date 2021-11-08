# Project: Airbnb Data Mart

## Overview
Project: Airbnb Data Mart is a database oriented after the Airbnb use case. The data mart is a SQL database featuring a database structure, as well as stored procedures and test data. The database is for the temporary rental of apartments and bedrooms. There are two different user groups, guests, and hosts, which determine what functions are accessible. It connects guests, who want to stay in accommodations of a specific area, with hosts, who rent out their homes. The product acts as a platform and a mediation between the two parties. The guest is able to make reservations and conduct payments. A host on the other hand can set up his price and the attributes of his accommodation. The overall structure of the database can be separated into 5 major components.

## Guest component
The first major component are the guest users. A guest user consists of the guests, guestadresses, and guestcontacts tables, where personal information like name, currency, location, and contact information is stored. A guest can register themself, with the “GuestRegister“ procedure, which creates an entry for all 3 tables. On the other hand, if a guest wants to leave the platform indefinitely, they can use the “DeleteGuestProfile“ to permanently remove their data records.

## Host component
The second major component is the host, which is structured identically to the guest profile with the difference of being able to create accommodations. A host consists of the host, hostadresses, and hostcontacts tables. A host can register themself, with the “HostRegister“ procedure and delete their profile with the “DeleteHostProfile“ procedure.

## Accommodation component
Like mentioned before, a host can create multiple accommodations. Each accommodation consists of a price, location, interior, exterior, bathroom, bedroom, kitchen, living room, and other room component. The accommodation can be created with the “AccommodationCreation” procedure, which includes the price, location, and interior table. All the other tables like exterior and the individual rooms have their own creation procedures “ExteriorCreation” and e.g. “BathroomCreation”. This allows for complete individualization when creating an accommodation. An accommodation can also be deleted with “DeleteAccommodation”, but only when the host has at least one other accommodation.

## Payment component
When a user has made a reservation for an accommodation with the “GuestBooking” procedure, the payment details are entered in the payments table and an entry for the “payconfirmations” table is created. A guest has then time to either cancel or confirm their payment with the “PayConfirmation” procedure. After payment has been confirmed, the information is sent to the “income” table, where a host can view the revenue of his accommodations.

## Review component
The last major component are the reviews. Reviews can be made about a guest, a host, or a specific accommodation. A review about accommodations is made with the “AccommodationReview” procedure, about a guest with the “GuestReview” procedure, and about the host with the “HostReview” procedure. These recommendations consist of a rating and an optional text. These reviews can also be deleted again with the respective procedures, “DeleteAccommodationReview”, “DeleteGuestReview”, and “DeleteHostReview”.
