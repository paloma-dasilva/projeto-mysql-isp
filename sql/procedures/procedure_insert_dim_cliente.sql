DELIMITER //

CREATE PROCEDURE insert_dim_cliente()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE total_registros INT DEFAULT 750;

    WHILE i <= total_registros DO
        INSERT INTO dim_cliente (
            id_localidade, 
            nome, 
            tipo_pessoa, 
            cpf, 
            cnpj, 
            data_cadastro
        )
        VALUES (
            FLOOR(1 + (RAND() * 100)),
            IF(i % 6 = 0, CONCAT('Empresa PJ ', LPAD(i, 4, '0'), ' LTDA'), CONCAT('Cliente PF ', LPAD(i, 4, '0'))),
            IF(i % 6 = 0, 'juridica', 'fisica'),
            IF(i % 6 = 0, NULL, LPAD(CONCAT('100000', LPAD(i, 5, '0')), 11, '0')),
            IF(i % 6 <> 0, NULL, LPAD(CONCAT('2000000000', LPAD(i, 4, '0')), 14, '0')),
            DATE_ADD('2024-01-01', INTERVAL FLOOR(RAND() * 730) DAY)
        );
        
        SET i = i + 1;
    END WHILE;
END //

DELIMITER ;

CALL insert_dim_cliente();
