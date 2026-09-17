CREATE TABLE `dim_cliente` (
  `id_cliente` int NOT NULL AUTO_INCREMENT,
  `id_localidade` int NOT NULL,
  `nome` varchar(100) NOT NULL,
  `tipo_pessoa` enum('fisica','juridica') NOT NULL,
  `cpf` varchar(11),
  `cnpj` varchar(14),
  `data_cadastro` date,
  PRIMARY KEY (`id_cliente`),
  KEY `id_localidade` (`id_localidade`),
  CONSTRAINT `chk_documento_valido` CHECK ((((`tipo_pessoa` = 'fisica') and (`cpf` is not null) and (`cnpj` is null)) or ((`tipo_pessoa` = 'juridica') and (`cnpj` is not null) and (`cpf` is null))))
);
