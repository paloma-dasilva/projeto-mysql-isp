CREATE TABLE `dim_atendente` (
  `id_atendente` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(100),
  `nivel` enum('Nível 1','Nível 2','Nível 3'),
  PRIMARY KEY (`id_atendente`)
);
