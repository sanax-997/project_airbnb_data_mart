DELIMITER //

CREATE PROCEDURE HostReview (
    IN guest_email_adress VARCHAR(100),
    IN host_email_adress VARCHAR(100),
    IN host_score DECIMAL (1,0), 
    IN host_text TEXT,
    OUT message VARCHAR(128)
)
BEGIN

    -- Declare Variables
    DECLARE guest_id INT;
    DECLARE host_id INT;

    -- Check if the host email exists
    IF EXISTS(SELECT * FROM hostcontacts WHERE hostcontacts.HostEmailAdress = host_email_adress) THEN

        -- Query the HostID
        SELECT HostID INTO host_id FROM hostcontacts WHERE hostcontacts.HostEmailAdress = host_email_adress;

            -- Check if the host exists
            IF EXISTS(SELECT * FROM host WHERE host.HostID = host_id) THEN

                -- Check if the guest exists
                IF EXISTS(SELECT * FROM guestcontacts WHERE guestcontacts.GuestEmailAdress = guest_email_adress) THEN

                    -- Query the GuestID
                    SELECT GuestID INTO guest_id FROM guestcontacts WHERE guestcontacts.GuestEmailAdress = guest_email_adress;

                    -- Check if the score is a number between 1 and 5
                    IF host_score BETWEEN 1 AND 5 THEN

                        -- Create the host review
                        START TRANSACTION;
                            -- Insert the information in the hostreviews table
                            INSERT INTO hostreviews (HostScore,HostText,HostReviewDate,HostID,GuestID) VALUES (host_score,host_text,CURRENT_DATE,host_id,guest_id);

                            SET message = "Review was successfull";
                        COMMIT;
                    -- Score is not a number between 1 and 5
                    ELSE
                        SET message = 'Review failed - the score must be between 1 and 5';
                    END IF;
                -- Guest does not exist
                ELSE 
                    SET message = 'Review failed - guest not found';
                END IF;  
            -- Host does not exist
            ELSE 
                SET message = 'Review failed - host not found';
            END IF;             
    -- Accommodation does not exist
    ELSE 
        SET message = 'Review failed - host email does not exist';
    END IF;
END //