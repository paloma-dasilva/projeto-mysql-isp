CREATE TABLE `dim_localidade` (
  `id_localidade` int NOT NULL AUTO_INCREMENT,
  `cidade` varchar(30) NOT NULL,
  `estado` varchar(30) NOT NULL,
  `bairro` varchar(100) NOT NULL,
  PRIMARY KEY (`id_localidade`)
);
