CREATE TABLE `dim_categoria_chamado` (
  `id_categoria_chamado` int NOT NULL AUTO_INCREMENT,
  `descricao` enum('Sem Conexão / Sinal Queda','Lentidão na Conexão','Troca de Senha / Wi-Fi','Segunda Via / Faturamento','Mudança de Endereço','Upgrade / Downgrade de Plano','Defeito no Roteador / Equipamento','Solicitação de Cancelamento'),
  `prazo_maximo` int,
  PRIMARY KEY (`id_categoria_chamado`)
);
