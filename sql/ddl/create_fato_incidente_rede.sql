CREATE TABLE `fato_incidente_rede` (
  `id_incidente` int NOT NULL AUTO_INCREMENT,
  `id_localidade` int NOT NULL,
  `tipo_incidente` varchar(20),
  `data_abertura` datetime,
  `data_fechamento` datetime,
  PRIMARY KEY (`id_incidente`),
  KEY `id_localidade` (`id_localidade`),
  CONSTRAINT `fato_incidente_rede_chk_1` CHECK ((`data_fechamento` >= `data_abertura`))
);
