DELIMITER //

CREATE PROCEDURE HostRegister (
    IN host_name VARCHAR(100),
    IN host_surname VARCHAR(100),
    IN host_age DECIMAL(3),
    IN currency_code_user CHAR(3),
    IN host_country VARCHAR(100),
    IN host_region VARCHAR(100),
    IN host_town VARCHAR(100),
    IN host_street VARCHAR(100),
    IN host_house_number VARCHAR(30),
    IN host_ZIPcode VARCHAR(30),
    IN host_email_adress VARCHAR(100),
    IN host_phone_number VARCHAR(100),
    OUT message VARCHAR(128)
)
BEGIN

    -- Declare Variables
    DECLARE currency_code CHAR(3);
    DECLARE host_id INT;

    -- Check if the currency exists
    IF EXISTS(SELECT CurrencyCode FROM currencies WHERE currencies.CurrencyCode = currency_code_user) THEN

        -- Query the currency code
        SELECT CurrencyCode INTO currency_code FROM currencies WHERE currencies.CurrencyCode = currency_code_user;

        -- Check if the exact adress information does not exists 
        IF NOT EXISTS(SELECT * FROM hostadresses WHERE hostadresses.HostCountry = host_country AND hostadresses.HostRegion = host_region AND hostadresses.HostTown = host_town AND hostadresses.HostStreet = host_street AND hostadresses.HostHouseNumber = host_house_number AND hostadresses.HostZIPCode = host_ZIPcode) THEN

            -- Check if the email or phone number exists
            IF NOT EXISTS(SELECT * FROM hostcontacts WHERE hostcontacts.HostEmailAdress = host_email_adress OR hostcontacts.HostPhoneNumber = host_phone_number) THEN

                -- Register the host
                START TRANSACTION;
                    -- Insert the host information into the host table
                    INSERT INTO host (HostName, HostSurname, HostAge, CurrencyCode) VALUES (host_name, host_surname, host_age, currency_code);
                    -- Query the HostID of the host registration
                    SELECT LAST_INSERT_ID() INTO host_id;

                    -- Insert the host adress information into the hostadresses table
                    INSERT INTO hostadresses (HostCountry, HostRegion, HostTown, HostStreet,HostHouseNumber,HostZIPCode,HostID) VALUES (host_country,host_region,host_town,host_street,host_house_number,host_ZIPcode,host_id);

                    -- Insert the host contact information into the hostcontacts table
                    INSERT INTO hostcontacts (HostEmailAdress,HostPhoneNumber,HostID) VALUES (host_email_adress,host_phone_number, host_id);

                    -- Insert the accommodation
                    SET message = "Host registration success";
                COMMIT;
                    
            -- Email or phone number already exists
            ELSE 
                SET message = 'Host registration failed - email or phone number already exists';
            END IF;
        -- Adress already exists
        ELSE 
            SET message = 'Host registration failed - adress already exsists';
        END IF;
    -- Invalid currency
    ELSE 
        SET message = 'Host registration failed - currency not found';
    END IF;
END //