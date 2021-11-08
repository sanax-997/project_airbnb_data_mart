DELIMITER //

CREATE PROCEDURE AccommodationCreation(
    IN host_email_adress VARCHAR(100),
    IN host_phone_number VARCHAR(100),
    IN accommodation_name VARCHAR(100),
    IN accommodation_description TEXT,
    IN accommodation_type VARCHAR(100),
    IN accommodation_rules VARCHAR(100),
    IN location_country VARCHAR(100),
    IN location_region VARCHAR(100),
    IN location_town VARCHAR(100),
    IN location_street VARCHAR(100),
    IN location_house_number VARCHAR(100),
    IN location_ZIPcode VARCHAR(100),
    IN location_description TEXT,
    IN initial_price DECIMAL(20,2),
    IN number_of_nights DECIMAL (2,0),
    IN discount DECIMAl(3,0),
    IN interior_description TEXT,
    OUT message VARCHAR(128)
)
BEGIN
    -- Declare variables
    DECLARE host_id INT;
    DECLARE accommodation_id INT;

    -- Check if the exact location of the accommodation exists
    IF NOT EXISTS(SELECT * FROM locations WHERE locations.LocationCountry = location_country AND locations.LocationRegion = location_region AND locations.LocationTown = location_town AND locations.LocationStreet = location_street AND locations.LocationHouseNumber = location_house_number AND locations.LocationZIPCode = location_ZIPcode) THEN

        -- Check if the host exists
        IF EXISTS(SELECT * FROM hostcontacts WHERE hostcontacts.HostEmailAdress = host_email_adress AND hostcontacts.HostPhoneNumber = host_phone_number) THEN

            -- Query the HostID
            SELECT HostID INTO host_id FROM hostcontacts WHERE hostcontacts.HostEmailAdress = host_email_adress AND hostcontacts.HostPhoneNumber = host_phone_number;

                -- Create the Accommodation
                START TRANSACTION;
                    -- Insert the accommodation information into the accommodations table
                    INSERT INTO accommodations (AccommodationName, AccommodationDescription, AccommodationType, AccommodationRules, HostID) VALUES (accommodation_name, accommodation_description, accommodation_type, accommodation_rules, host_id);
                    -- Query the AccommodationID of the accommodation registration
                    SELECT LAST_INSERT_ID() INTO accommodation_id;

                    -- Insert location information in the locations table
                    INSERT INTO locations (LocationCountry,LocationRegion,LocationTown,LocationStreet,LocationHouseNumber,LocationZIPCode,LocationDescription,AccommodationID) VALUES (location_country, location_region, location_town, location_street, location_house_number, location_ZIPcode, location_description, accommodation_id);

                    -- Insert price information in the price table
                    INSERT INTO prices (IntialPrice,NumberOfNights,Discount,TotalPrice,AccommodationID) VALUES (initial_price, number_of_nights, discount, initial_price/number_of_nights - initial_price/number_of_nights*discount/100 ,accommodation_id);

                    -- Insert the interior information in the interior table
                    INSERT INTO interiors (InteriorDescription,RoomNumber,AccommodationID) VALUES (interior_description,0,accommodation_id);

                    SET message = "Accommodation creation success";
                COMMIT;

        -- Host does not exist
        ELSE 
            SET message = 'Accommodation creation failed - host does not exist';
        END IF;
    -- Location already already exists
    ELSE 
        SET message = 'Accommodation creation failed - location of the accommodation already exists';
    END IF;

END //