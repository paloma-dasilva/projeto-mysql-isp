// DELIMITER 

PROCEDURE `insert_fato_chamado`()
BEGIN
    DECLARE v_id_chamado INT DEFAULT 1;
    DECLARE v_id_categoria_chamado INT;
    DECLARE v_id_atendente INT;
    DECLARE v_id_cliente INT;
    
    DECLARE v_canal ENUM('E-mail','Whatsapp','Telefone','Site de Ticketing');
    DECLARE v_data_abertura DATETIME;
    DECLARE v_data_aceite DATETIME;
    DECLARE v_data_fechamento DATETIME;
    DECLARE v_status ENUM('aberto','em andamento','fechado','cancelado');
    DECLARE v_nota INT;
    
    -- Variáveis de auxílio
    DECLARE v_hora_abertura INT;
    DECLARE v_duracao_minutos INT;
    DECLARE v_tma_minutos INT; -- Adicionada a declaração do TMA
    DECLARE v_id_localidade_cliente INT;

    -- Variáveis para controle do cursor 
    DECLARE v_fim_loop INT DEFAULT 0;
    DECLARE v_incidente_id INT;
    DECLARE v_incidente_loc INT;
    DECLARE v_incidente_inicio DATETIME;
    DECLARE v_incidente_fim DATETIME;
    DECLARE v_qtd_chamados_incidente INT;
    DECLARE i INT DEFAULT 1;

    -- CURSOR E HANDLER
    DECLARE cur_incidentes CURSOR FOR 
        SELECT id_incidente, id_localidade, data_abertura, data_fechamento 
        FROM fato_incidente_rede;
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_fim_loop = 1;

   --  CHAMADOS VINCULADOS A INCIDENTES DE REDE
    
    OPEN cur_incidentes;

    loop_incidentes: LOOP
        FETCH cur_incidentes INTO v_incidente_id, v_incidente_loc, v_incidente_inicio, v_incidente_fim;
        IF v_fim_loop = 1 THEN
            LEAVE loop_incidentes;
        END IF;

        -- sorteia qtd clientes por incidente
        SET v_qtd_chamados_incidente = FLOOR(10 + (RAND() * 11));
        SET i = 1;
        WHILE i <= v_qtd_chamados_incidente DO
            SET v_id_cliente = NULL;

            SELECT cli.id_cliente
            INTO v_id_cliente
            FROM dim_cliente cli
            WHERE cli.id_localidade = v_incidente_loc
            ORDER BY RAND()
            LIMIT 1;

            -- Fallback
            IF v_id_cliente IS NULL THEN
                SELECT id_cliente 
                INTO v_id_cliente 
                FROM dim_cliente 
                ORDER BY RAND() 
                LIMIT 1;
            END IF;

            -- Garante que a flag do loop do cursor não seja alterada incorretamente
            SET v_fim_loop = 0;

            SELECT cli.id_cliente
            INTO v_id_cliente
            FROM dim_cliente cli
            WHERE cli.id_localidade = v_incidente_loc
            ORDER BY RAND()
            LIMIT 1;

            -- sorteando horario de abertura de chamado
            IF i = 1 THEN
                SET v_data_abertura = v_incidente_inicio;
            ELSE
                SET v_data_abertura = DATE_ADD(v_incidente_inicio, INTERVAL FLOOR(1 + (RAND() * 60)) MINUTE);
            END IF;

            -- Teste lógico para o aceite em horário comercial
            SET v_hora_abertura = HOUR(v_data_abertura);
            IF v_hora_abertura < 8 THEN
                SET v_data_aceite = STR_TO_DATE(CONCAT(DATE_FORMAT(v_data_abertura, '%Y-%m-%d'), ' 08:05:00'), '%Y-%m-%d %H:%i:%s');
            ELSEIF v_hora_abertura >= 18 THEN
                SET v_data_aceite = STR_TO_DATE(CONCAT(DATE_FORMAT(DATE_ADD(v_data_abertura, INTERVAL 1 DAY), '%Y-%m-%d'), ' 08:05:00'), '%Y-%m-%d %H:%i:%s');
            ELSE
                SET v_data_aceite = DATE_ADD(v_data_abertura, INTERVAL FLOOR(2 + (RAND() * 13)) MINUTE);
            END IF;

            -- Sorteio de atendente para incidente (prioridade N1/N2)
            IF RAND() < 0.55 THEN
                SELECT id_atendente INTO v_id_atendente FROM dim_atendente WHERE nivel = 'Nível 1' ORDER BY RAND() LIMIT 1;
            ELSEIF RAND() < 0.75 THEN
                SELECT id_atendente INTO v_id_atendente FROM dim_atendente WHERE nivel = 'Nível 2' ORDER BY RAND() LIMIT 1;
            ELSE
                SELECT id_atendente INTO v_id_atendente FROM dim_atendente WHERE nivel = 'Nível 3' ORDER BY RAND() LIMIT 1;
            END IF;
            
            SET v_data_fechamento = DATE_ADD(v_incidente_fim, INTERVAL FLOOR(5 + (RAND() * 20)) MINUTE);
            SET v_id_categoria_chamado = 1; 
            
            -- Sorteio de canal
            IF RAND() < 0.55 THEN SET v_canal = 'Whatsapp';
            ELSEIF RAND() < 0.85 THEN SET v_canal = 'Telefone';
            ELSEIF RAND() < 0.93 THEN SET v_canal = 'Site de Ticketing';
            ELSE SET v_canal = 'E-mail';
            END IF;

            SET v_status = 'fechado';
            SET v_nota = FLOOR(1 + (RAND() * 8)); 

            -- Inserção
            INSERT INTO fato_chamado (
                id_categoria_chamado, id_atendente, id_cliente, canal, 
                data_abertura, data_aceite, data_fechamento, status, nota
            ) VALUES (
                v_id_categoria_chamado, v_id_atendente, v_id_cliente, v_canal, 
                v_data_abertura, v_data_aceite, v_data_fechamento, v_status, v_nota
            );

            SET v_id_chamado = v_id_chamado + 1;
            SET i = i + 1;
        END WHILE;

    END LOOP loop_incidentes;

    CLOSE cur_incidentes;
    
    -- GERANDO CHAMADOS GERAIS DA OPERAÇÃO ate 4000 linhas
   
    WHILE v_id_chamado <= 4000 DO
        
        -- Sorteia cliente aleatório
        SELECT id_cliente INTO v_id_cliente FROM dim_cliente ORDER BY RAND() LIMIT 1;
        
        -- Sorteia data de abertura nos últimos 730 dias
        SET v_data_abertura = NOW() - INTERVAL FLOOR(RAND() * 730) DAY + INTERVAL FLOOR(7 + (RAND() * 15)) HOUR;

        -- Validação de horário comercial para o aceite
        SET v_hora_abertura = HOUR(v_data_abertura);
        IF v_hora_abertura < 8 THEN
            SET v_data_aceite = STR_TO_DATE(CONCAT(DATE_FORMAT(v_data_abertura, '%Y-%m-%d'), ' 08:15:00'), '%Y-%m-%d %H:%i:%s');
        ELSEIF v_hora_abertura >= 18 THEN
            SET v_data_aceite = STR_TO_DATE(CONCAT(DATE_FORMAT(DATE_ADD(v_data_abertura, INTERVAL 1 DAY), '%Y-%m-%d'), ' 08:15:00'), '%Y-%m-%d %H:%i:%s');
        ELSE
            SET v_data_aceite = DATE_ADD(v_data_abertura, INTERVAL FLOOR(5 + (RAND() * 30)) MINUTE);
        END IF;

        -- sortear atendente por nível
        IF RAND() < 0.55 THEN
            SELECT id_atendente INTO v_id_atendente 
            FROM dim_atendente WHERE nivel = 'Nível 1' ORDER BY RAND() LIMIT 1;
            
            -- TMA nível 1 5 a 25 min
            SET v_tma_minutos = FLOOR(5 + (RAND() * 21));

        ELSEIF RAND() < 0.75 THEN
            SELECT id_atendente INTO v_id_atendente 
            FROM dim_atendente WHERE nivel = 'Nível 2' ORDER BY RAND() LIMIT 1;
            
            -- TMA nível 2 20 a 50 min
            SET v_tma_minutos = FLOOR(20 + (RAND() * 31));

        ELSE
            SELECT id_atendente INTO v_id_atendente 
            FROM dim_atendente WHERE nivel = 'Nível 3' ORDER BY RAND() LIMIT 1;
            
            -- TMA nível 3 45 a 120 min
            SET v_tma_minutos = FLOOR(45 + (RAND() * 76));
        END IF;

        -- Sortear categoria 
        IF RAND() < 0.30 THEN 
            SET v_id_categoria_chamado = 2; -- Lentidão na Conexão
        ELSEIF RAND() < 0.55 THEN 
            SET v_id_categoria_chamado = 3; -- Troca de Senha / Wi-Fi
        ELSEIF RAND() < 0.75 THEN 
            SET v_id_categoria_chamado = 4; -- Segunda Via / Faturamento
        ELSEIF RAND() < 0.85 THEN 
            SET v_id_categoria_chamado = 6; -- Upgrade / Downgrade de Plano
        ELSEIF RAND() < 0.95 THEN 
            SET v_id_categoria_chamado = 7; -- Defeito no Roteador / Equipamento
        ELSE 
            SET v_id_categoria_chamado = 5; -- Mudança de Endereço
        END IF;

        -- Define a data de fechamento + o TMA 
        SET v_data_fechamento = DATE_ADD(v_data_aceite, INTERVAL v_tma_minutos MINUTE);

        -- Sorteio de canal
        IF RAND() < 0.40 THEN SET v_canal = 'Whatsapp';
        ELSEIF RAND() < 0.70 THEN SET v_canal = 'Telefone';
        ELSEIF RAND() < 0.88 THEN SET v_canal = 'Site de Ticketing';
        ELSE SET v_canal = 'E-mail';
        END IF;

        SET v_status = IF(RAND() < 0.94, 'fechado', 'cancelado');
        
        -- sorteio aleatório de nota com base em id_atendente
		CASE v_id_atendente
    -- nivel 1
		WHEN 1 THEN SET v_nota = FLOOR(6 + (RAND() * 4));
		WHEN 2 THEN SET v_nota = FLOOR(4 + (RAND() * 5));  
		WHEN 3 THEN SET v_nota = FLOOR(4 + (RAND() * 7)); 
		WHEN 4 THEN SET v_nota = FLOOR(6 + (RAND() * 4));  
		WHEN 5 THEN SET v_nota = FLOOR(5 + (RAND() * 5));  
		WHEN 6 THEN SET v_nota = FLOOR(3 + (RAND() * 8)); 

		-- nível 2 
		WHEN 7 THEN SET v_nota = FLOOR(4 + (RAND() * 7));  
		WHEN 8 THEN SET v_nota = FLOOR(6 + (RAND() * 5)); 
		WHEN 9 THEN SET v_nota = FLOOR(5 + (RAND() * 6));  
		WHEN 10 THEN SET v_nota = FLOOR(7 + (RAND() * 4)); 

		-- nível 3 de 8 a 9 de média
		WHEN 11 THEN SET v_nota = FLOOR(7 + (RAND() * 4));
		WHEN 12 THEN SET v_nota = FLOOR(8 + (RAND() * 3)); 
		
		ELSE SET v_nota = FLOOR(5 + (RAND() * 6));
	END CASE;

        -- insercao
        INSERT INTO fato_chamado (
            id_categoria_chamado, id_atendente, id_cliente, canal, 
            data_abertura, data_aceite, data_fechamento, status, nota
        ) VALUES (
            v_id_categoria_chamado, v_id_atendente, v_id_cliente, v_canal, 
            v_data_abertura, v_data_aceite, v_data_fechamento, v_status, v_nota
        );

        SET v_id_chamado = v_id_chamado + 1;
    END WHILE;

END$$
DELIMITER ;
