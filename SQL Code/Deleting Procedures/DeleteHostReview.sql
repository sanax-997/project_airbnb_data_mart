DELIMITER //

CREATE PROCEDURE DeleteHostReview (
    IN guest_email_adress VARCHAR(100),
    IN host_email_adress VARCHAR(100),
    OUT message VARCHAR(128)
)
BEGIN

    -- Declare Variables
    DECLARE guest_id INT;
    DECLARE host_id INT;

    -- Check if the guest email exists
    IF EXISTS(SELECT * FROM guestcontacts WHERE guestcontacts.GuestEmailAdress = guest_email_adress) THEN

        -- Query the GuestID
        SELECT GuestID INTO guest_id FROM guestcontacts WHERE guestcontacts.GuestEmailAdress = guest_email_adress;

        -- Check if the host email exists
        IF EXISTS(SELECT * FROM hostcontacts WHERE hostcontacts.HostEmailAdress = host_email_adress) THEN

            -- Query the HostID
            SELECT HostID INTO host_id FROM hostcontacts WHERE hostcontacts.HostEmailAdress = host_email_adress;

            -- Check if the review exists
            IF EXISTS(SELECT * FROM hostreviews WHERE hostreviews.HostID = host_id AND hostreviews.GuestID = guest_id) THEN
        
                -- Start the deletion process of the host review
                START TRANSACTION;
                    -- Delete the host review from the hostreviews table
                    DELETE FROM hostreviews WHERE hostreviews.HostID = host_id AND hostreviews.GuestID = guest_id;

                    SET message = "Host review deletion was successfull";
                COMMIT;        

            -- Review does not exist
            ELSE 
                SET message = 'Review deletion failed - review does not exist';
            END IF;  
        -- Host email does not exist
        ELSE 
            SET message = 'Review deletion failed - host email does not exist';
        END IF;        
    -- Guest email does not exist
    ELSE 
        SET message = 'Review deletion failed - guest email does not exist';
    END IF;
END //