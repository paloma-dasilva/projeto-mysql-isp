CREATE TABLE `fato_chamado` (
  `id_chamado` int NOT NULL AUTO_INCREMENT,
  `id_categoria_chamado` int NOT NULL,
  `id_atendente` int NOT NULL,
  `id_cliente` int NOT NULL,
  `canal` enum('E-mail','Whatsapp','Telefone','Site de Ticketing'),
  `data_abertura` datetime,
  `data_aceite` datetime,
  `data_fechamento` datetime,
  `status` enum('aberto','em andamento','fechado','cancelado'),
  `nota` int DEFAULT '10',
  PRIMARY KEY (`id_chamado`),
  KEY `id_categoria_chamado` (`id_categoria_chamado`),
  KEY `id_atendente` (`id_atendente`),
  KEY `id_cliente` (`id_cliente`),
  CONSTRAINT `fato_chamado_chk_1` CHECK ((`data_fechamento` >= `data_abertura`))
);
