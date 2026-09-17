DELIMITER //

 PROCEDURE `insert_fato_incidente_rede`()
BEGIN
    DECLARE v_contador INT DEFAULT 1;
    DECLARE v_id_incidente INT;
    DECLARE v_id_localidade INT;
    DECLARE v_tipo_incidente VARCHAR(50);
    DECLARE v_data_abertura DATETIME;
    DECLARE v_data_fechamento DATETIME;
    DECLARE v_duracao_horas INT;
    DECLARE v_data_base DATE;
    DECLARE v_hora_abertura INT;
    
    WHILE v_contador <= 30 DO
        SET v_id_incidente = v_contador;

        -- sorteia um bairro aleatório da dim_localidade
        SELECT id_localidade 
        INTO v_id_localidade 
        FROM dim_localidade 
        ORDER BY RAND() 
        LIMIT 1;

        -- sorteia o tipo do incidente
        IF RAND() < 0.40 THEN
            SET v_tipo_incidente = 'Rompimento de Fibra Óptica';
        ELSEIF RAND() < 0.70 THEN
            SET v_tipo_incidente = 'Falha de Equipamento';
        ELSEIF RAND() < 0.90 THEN
            SET v_tipo_incidente = 'Queda de Energia Externa';
        ELSE
            SET v_tipo_incidente = 'Manutenção Programada';
        END IF;

        --  Sorteia uma data base aleatória nos ultimos 2 anos
        SET v_data_base = DATE(NOW() - INTERVAL FLOOR(RAND() * 730) DAY);

        -- gerar o horário de abertura e a duração com base no tipo de evento
        IF v_tipo_incidente = 'Manutenção Programada' THEN
            -- 01:00 às 04:00 
            SET v_hora_abertura = FLOOR(1 + (RAND() * 4));
            SET v_duracao_horas = FLOOR(2 + (RAND() * 3));
        ELSE
            -- horario comercial 08:00 as 18:00 
            SET v_hora_abertura = FLOOR(8 + (RAND() * 11));
            SET v_duracao_horas = FLOOR(2 + (RAND() * 7));
        END IF;

        --  Data de abertura (Data Base + Hora + Minutos Aleatórios)
        SET v_data_abertura = DATE_ADD(
            CAST(v_data_base AS DATETIME), 
            INTERVAL (v_hora_abertura * 60 + FLOOR(RAND() * 60)) MINUTE
        );
        
        --  Data de fechamento + duração horas + variação de minutos
        SET v_data_fechamento = DATE_ADD(
            v_data_abertura, 
            INTERVAL (v_duracao_horas * 60 + FLOOR(RAND() * 30)) MINUTE
        );
        
        --  INSERÇÃO
        INSERT INTO fato_incidente_rede (
            id_incidente, id_localidade, tipo_incidente, data_abertura, data_fechamento
        ) VALUES (
            v_id_incidente, v_id_localidade, v_tipo_incidente, v_data_abertura, v_data_fechamento
        );

        SET v_contador = v_contador + 1;
    END WHILE;
end$$
DELIMITER ;
