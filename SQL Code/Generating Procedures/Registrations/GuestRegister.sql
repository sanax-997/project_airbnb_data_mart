DELIMITER //

CREATE PROCEDURE GuestRegister (
    IN guest_name VARCHAR(100),
    IN guest_surname VARCHAR(100),
    IN guest_age DECIMAL(3),
    IN currency_code_user CHAR(3),
    IN guest_country VARCHAR(100),
    IN guest_region VARCHAR(100),
    IN guest_town VARCHAR(100),
    IN guest_street VARCHAR(100),
    IN guest_house_number VARCHAR(30),
    IN guest_ZIPcode VARCHAR(30),
    IN guest_email_adress VARCHAR(100),
    IN guest_phone_number VARCHAR(100),
    OUT message VARCHAR(128)
)
BEGIN

    -- Declare Variables
    DECLARE currency_code CHAR(3);
    DECLARE guest_id INT;

    -- Check if the currency exists
    IF EXISTS(SELECT CurrencyCode FROM currencies WHERE currencies.CurrencyCode = currency_code_user) THEN

        -- Query the currency code
        SELECT CurrencyCode INTO currency_code FROM currencies WHERE currencies.CurrencyCode = currency_code_user;

        -- Check if the exact adress information does not exists 
        IF NOT EXISTS(SELECT * FROM guestadresses WHERE guestadresses.GuestCountry = guest_country AND guestadresses.GuestRegion = guest_region AND guestadresses.GuestTown = guest_town AND guestadresses.GuestStreet = guest_street AND guestadresses.GuestHouseNumber = guest_house_number AND guestadresses.GuestZIPCode = guest_ZIPcode) THEN

            -- Check if the email or phone number exists
            IF NOT EXISTS(SELECT * FROM guestcontacts WHERE guestcontacts.GuestEmailAdress = guest_email_adress OR guestcontacts.GuestPhoneNumber = guest_phone_number) THEN

                -- Register the guest
                START TRANSACTION;
                    -- Insert the guest information into the guests table
                    INSERT INTO guests (GuestName, GuestSurname, GuestAge, CurrencyCode) VALUES (guest_name, guest_surname, guest_age, currency_code);
                    -- Query the GuestID of the guest registration
                    SELECT LAST_INSERT_ID() INTO guest_id;

                    -- Insert the guest adress information into the guestadresses table
                    INSERT INTO guestadresses (GuestCountry, GuestRegion, GuestTown, GuestStreet,GuestHouseNumber,GuestZIPCode,GuestID) VALUES (guest_country,guest_region,guest_town,guest_street,guest_house_number,guest_ZIPcode,guest_id);

                    -- Insert the guest contact information into the guestcontacts table
                    INSERT INTO guestcontacts (GuestEmailAdress,GuestPhoneNumber,GuestID) VALUES (guest_email_adress,guest_phone_number, guest_id);
                    SET message = "Guest registration success";
                COMMIT;

            -- Email or phone number already exists
            ELSE 
                SET message = 'Guest registration failed - email or phone number already exists';
            END IF;
        -- Adress already exists
        ELSE 
            SET message = 'Guest registration failed - adress already exsists';
        END IF;
    -- Invalid currency
    ELSE 
        SET message = 'Guest registration failed - currency not found';
    END IF;
END //