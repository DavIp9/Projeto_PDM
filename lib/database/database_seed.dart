import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/badge_model.dart';

class DatabaseSeed {
  static Future<void> seed(Database db) async {
    final commands = r'''UPDATE BADGE SET ID_NIVEL = NULL;

DELETE FROM FICHEIROSEVIDENCIA;
DELETE FROM FEEDBACKEVIDENCIA;
DELETE FROM EVIDENCIA;
DELETE FROM COMPROVATIVO;
DELETE FROM PARTILHA;
DELETE FROM NOTIFICACOES;
DELETE FROM VALIDACAOCANDIDATURA;
DELETE FROM CANDIDATURA;
DELETE FROM BADGE_OBTIDO;
DELETE FROM SUGESTAOMETAS;
DELETE FROM TIMELINEEVOLUCAO;
DELETE FROM EXPORTACAODADOS;
DELETE FROM RANKING_HISTORICO;

DELETE FROM REQUISITO;
DELETE FROM NIVEL;
DELETE FROM BADGE;
DELETE FROM UTILIZADOR;
DELETE FROM AREA;
DELETE FROM SERVICE_LINE;
DELETE FROM LEARNING_PATHS;

DELETE FROM PERFILPERMISSAO;
DELETE FROM PERMISSOES;
DELETE FROM PERFIL;
DELETE FROM ALERTAGLOBAL;
DELETE FROM CONFIGURACOES;



-- =========================================================================
-- PERFIS E PERMISSÕES
-- =========================================================================
INSERT INTO PERFIL (ID_PERFIL, NOME_PERFIL, DESCRICAO) VALUES 
(1, 'Consultor', 'Pode ver catálogo e submeter candidaturas.'),
(2, 'Service Line Leader', 'Pode avaliar candidaturas da sua área.'),
(3, 'Talent Manager', 'Avaliador geral do Sistema.'),
(4, 'Admin', 'Acesso total ao sistema.');

INSERT INTO PERMISSOES (IDPERMISSAO, NOME, ESTADO, CATEGORIA) VALUES 
(1, 'Validar Candidatura', 'Ativo', 'Operacional'), 
(2, 'Criar Badges', 'Ativo', 'Administrativo'),
(3, 'Submeter Evidencia', 'Ativo', 'Operacional'), 
(4, 'Extrair Relatorios', 'Ativo', 'Gestão');

INSERT INTO PERFILPERMISSAO (ID_PERFIL, IDPERMISSAO) VALUES 
(4, 1),
(4, 2),
(4, 3),
(4, 4),
(2, 1),
(2, 2),
(2, 4),
(3, 1),
(3, 4),
(1, 3);

-- =========================================================================
-- ESTRUTURA CORPORATIVA
-- =========================================================================
INSERT INTO LEARNING_PATHS (ID_LEARNING_PATH, NOME_LEARNINGPATH, DESCRICAO, URLIMAGEM, FASE) VALUES 
(1, 'Jornada Técnica', 'Caminhos técnicos', 'img.com/jt.png', 'Ativo');

INSERT INTO SERVICE_LINE (ID_SERVICE_LINE, ID_LEARNING_PATH, NOME_SERVICE_LINE, DESCRICAO, URLIMAGEM, FASE) VALUES 
(1, 1, 'Hybrid Cloud', 'Cloud e LowCode', 'img.com/hc.png', 'Ativo'),
(2, 1, 'DevOps', 'Automação', 'img.com/do.png', 'Ativo'),
(3, 1, 'Digital Business', 'Data', 'img.com/db.png', 'Ativo');

INSERT INTO AREA (ID_AREA, ID_SERVICE_LINE, NOME_AREA, DESCRICAO, URLIMAGEM, FASE) VALUES 
(1, 1, 'LowCode (Outsystems)', 'Dev', 'img/os.png', 'Ativo'),
(2, 2, 'DevOps & Automation', 'Infra', 'img/do.png', 'Ativo'),
(3, 3, 'Data & Analytics', 'BI', 'img/da.png', 'Ativo');

-- =========================================================================
-- UTILIZADORES
-- =========================================================================
INSERT INTO UTILIZADOR (ID_UTILIZADOR, ID_SERVICE_LINE, ID_AREA, ID_PERFIL, NOME_UTILIZADOR, EMAIL, PASSWORD, TELEFONE, PONTUACAOTOTAL, BADGES_TOTAL, DATAINGRESSO, ESTADO, URLCERTIFICADO, URLFOTOPERFIL) VALUES 
(1, NULL, 1, 1, 'Rodrigo', 'rodrigo@softinsa.pt', 'pw', '910000001', 0, 0, '2025-01-01', 'Ativo', NULL, 'p1.png'),
(2, 1, NULL, 2, 'Filipe Sá', 'filipe.sa@softinsa.pt', 'pw', '910000002', 0, 0, '2025-01-01', 'Ativo', NULL, 'p2.png'),
(3, NULL, NULL, 3, 'Miguel', 'miguel@softinsa.pt', 'pw', '910000003', 0, 0, '2025-01-01', 'Ativo', NULL, 'p3.png'),
(4, NULL, NULL, 4, 'Francisco', 'francisco@softinsa.pt', 'pw', '910000004', 0, 0, '2025-01-01', 'Ativo', NULL, 'p4.png'),
(5, NULL, 1, 1, 'Rodrigo Lopes', 'rlopes@softinsa.pt', 'pw', '910000005', 0, 0, '2025-02-01', 'Ativo', NULL, 'p5.png'),
(6, NULL, 2, 1, 'Filipe', 'filipe@softinsa.pt', 'pw', '910000006', 0, 0, '2025-02-01', 'Ativo', NULL, 'p6.png'),
(7, 2, NULL, 2, 'Líder DevOps', 'ldevops@softinsa.pt', 'pw', '910000007', 0, 0, '2025-03-01', 'Ativo', NULL, 'p7.png'),
(8, 3, NULL, 2, 'Líder Data', 'ldata@softinsa.pt', 'pw', '910000008', 0, 0, '2025-03-01', 'Ativo', NULL, 'p8.png'),
(9, NULL, 1, 1, 'Ana LC', 'ana@softinsa.pt', 'pw', '910000009', 0, 0, '2025-04-01', 'Ativo', NULL, 'p9.png'),
(10, NULL, 1, 1, 'Bruno LC', 'bruno@softinsa.pt', 'pw', '910000010', 0, 0, '2025-04-01', 'Ativo', NULL, 'p10.png'),
(11, NULL, 1, 1, 'Carla LC', 'carla@softinsa.pt', 'pw', '910000011', 0, 0, '2025-04-01', 'Ativo', NULL, 'p11.png'),
(12, NULL, 1, 1, 'Diana LC', 'diana@softinsa.pt', 'pw', '910000012', 0, 0, '2025-04-01', 'Ativo', NULL, 'p12.png'),
(13, NULL, 1, 1, 'Eduardo LC', 'eduardo@softinsa.pt', 'pw', '910000013', 0, 0, '2025-05-01', 'Ativo', NULL, 'p13.png'),
(14, NULL, 1, 1, 'Fábio LC', 'fabio@softinsa.pt', 'pw', '910000014', 0, 0, '2025-05-01', 'Ativo', NULL, 'p14.png'),
(15, NULL, 2, 1, 'Hugo DO', 'hugo@softinsa.pt', 'pw', '910000015', 0, 0, '2025-06-01', 'Ativo', NULL, 'p15.png'),
(16, NULL, 2, 1, 'Inês DO', 'ines@softinsa.pt', 'pw', '910000016', 0, 0, '2025-06-01', 'Ativo', NULL, 'p16.png'),
(17, NULL, 2, 1, 'João DO', 'joao@softinsa.pt', 'pw', '910000017', 0, 0, '2025-07-01', 'Ativo', NULL, 'p17.png'),
(18, NULL, 2, 1, 'Kátia DO', 'katia@softinsa.pt', 'pw', '910000018', 0, 0, '2025-07-01', 'Ativo', NULL, 'p18.png'),
(19, NULL, 2, 1, 'Luís DO', 'luis@softinsa.pt', 'pw', '910000019', 0, 0, '2025-08-01', 'Ativo', NULL, 'p19.png'),
(20, NULL, 2, 1, 'Marta DO', 'marta@softinsa.pt', 'pw', '910000020', 0, 0, '2025-08-01', 'Ativo', NULL, 'p20.png'),
(21, NULL, 2, 1, 'Nuno DO', 'nuno@softinsa.pt', 'pw', '910000021', 0, 0, '2025-09-01', 'Ativo', NULL, 'p21.png'),
(22, NULL, 3, 1, 'Olga DA', 'olga@softinsa.pt', 'pw', '910000022', 0, 0, '2025-09-01', 'Ativo', NULL, 'p22.png'),
(23, NULL, 3, 1, 'Paulo DA', 'paulo@softinsa.pt', 'pw', '910000023', 0, 0, '2025-10-01', 'Ativo', NULL, 'p23.png'),
(24, NULL, 3, 1, 'Rita DA', 'rita@softinsa.pt', 'pw', '910000024', 0, 0, '2025-10-01', 'Ativo', NULL, 'p24.png'),
(25, NULL, 3, 1, 'Sara DA', 'sara@softinsa.pt', 'pw', '910000025', 0, 0, '2025-11-01', 'Ativo', NULL, 'p25.png'),
(26, NULL, 3, 1, 'Tiago DA', 'tiago@softinsa.pt', 'pw', '910000026', 0, 0, '2025-11-01', 'Ativo', NULL, 'p26.png'),
(27, NULL, 3, 1, 'Vera DA', 'vera@softinsa.pt', 'pw', '910000027', 0, 0, '2025-12-01', 'Ativo', NULL, 'p27.png'),
(28, NULL, 3, 1, 'Xavier DA', 'xavier@softinsa.pt', 'pw', '910000028', 0, 0, '2025-12-01', 'Ativo', NULL, 'p28.png'),
(29, NULL, 1, 1, 'Zeca LC', 'zeca@softinsa.pt', 'pw', '910000029', 0, 0, '2026-01-01', 'Ativo', NULL, 'p29.png'),
(30, NULL, 2, 1, 'Alice DO', 'alice@softinsa.pt', 'pw', '910000030', 0, 0, '2026-01-01', 'Ativo', NULL, 'p30.png');


-- =========================================================================
-- BADGES E NÍVEIS 
-- =========================================================================
INSERT INTO BADGE (ID_BADGE, ID_NIVEL, NOME_BADGE, DESCRICAO, VALIDADE, DATACRIACAO, URL_IMAGEM, PONTOS, RARIDADE, TIPOBADGE) VALUES 
(1, NULL, 'Júnior LowCode', 'Base OutSystems', 365, '2025-01-01', 'b1.png', 10, 'Bronze', 'Normal'),
(2, NULL, 'Mid LowCode', 'Apps Web/Mobile', 365, '2025-01-01', 'b2.png', 20, 'Prata', 'Normal'),
(3, NULL, 'Sénior LowCode', 'Arquitetura', 730, '2025-01-01', 'b3.png', 30, 'Ouro', 'Normal'),
(4, NULL, 'Esp. LowCode', 'Referência', 730, '2025-01-01', 'b4.png', 40, 'Diamante', 'Normal'),
(5, NULL, 'Líder LowCode', 'Tech Lead', 1095, '2025-01-01', 'b5.png', 50, 'Platina', 'Normal'),
(6, NULL, 'Júnior DevOps', 'Linux/Git', 365, '2025-01-01', 'b6.png', 10, 'Bronze', 'Normal'),
(7, NULL, 'Mid DevOps', 'CI/CD', 365, '2025-01-01', 'b7.png', 20, 'Prata', 'Normal'),
(8, NULL, 'Sénior DevOps', 'Kubernetes', 730, '2025-01-01', 'b8.png', 30, 'Ouro', 'Normal'),
(9, NULL, 'Esp. DevOps', 'Terraform', 730, '2025-01-01', 'b9.png', 40, 'Diamante', 'Normal'),
(10, NULL, 'Líder DevOps', 'Cloud Arch', 1095, '2025-01-01', 'b10.png', 50, 'Platina', 'Normal'),
(11, NULL, 'Júnior Data', 'SQL/BI', 365, '2025-01-01', 'b11.png', 10, 'Bronze', 'Normal'),
(12, NULL, 'Mid Data', 'Python/ETL', 365, '2025-01-01', 'b12.png', 20, 'Prata', 'Normal'),
(13, NULL, 'Sénior Data', 'Big Data', 730, '2025-01-01', 'b13.png', 30, 'Ouro', 'Normal'),
(14, NULL, 'Esp. Data', 'Machine Learning', 730, '2025-01-01', 'b14.png', 40, 'Diamante', 'Normal'),
(15, NULL, 'Líder Data', 'IA Strategist', 1095, '2025-01-01', 'b15.png', 50, 'Platina', 'Normal'),
(16, NULL, 'Badge Cooperativo', 'Concluir projeto com 2 pessoas' , 0, '2025-01-01', 'b15.png', 50, 'Especial', 'Especial');

INSERT INTO NIVEL (ID_NIVEL, ID_BADGE, ID_AREA, NOME_NIVEL, DESCRICAO, URLIMAGEM, FASE, DIFICULDADE) VALUES 
(1, 1, 1, 'Lvl 1 LC', 'Base', 'n1.png', 'Ativo', 'Fácil'), 
(2, 2, 1, 'Lvl 2 LC', 'Médio', 'n2.png', 'Ativo', 'Médio'),
(3, 3, 1, 'Lvl 3 LC', 'Avançado', 'n3.png', 'Ativo', 'Difícil'),
(4, 4, 1, 'Lvl 4 LC', 'Especialista', 'n4.png', 'Ativo', 'Muito Difícil'),
(5, 5, 1, 'Lvl 5 LC', 'Mestre', 'n5.png', 'Ativo', 'Mestre'),
(6, 6, 2, 'Lvl 1 DO', 'Linux Base', 'n6.png', 'Ativo', 'Fácil'),
(7, 7, 2, 'Lvl 2 DO', 'Pipelines', 'n7.png', 'Ativo', 'Médio'),
(8, 8, 2, 'Lvl 3 DO', 'Containers', 'n8.png', 'Ativo', 'Difícil'),
(9, 9, 2, 'Lvl 4 DO', 'Cloud', 'n9.png', 'Ativo', 'Muito Difícil'),
(10, 10, 2, 'Lvl 5 DO', 'Mestre', 'n10.png', 'Ativo', 'Mestre'),
(11, 11, 3, 'Lvl 1 DA', 'SQL Base', 'n11.png', 'Ativo', 'Fácil'),
(12, 12, 3, 'Lvl 2 DA', 'Python', 'n12.png', 'Ativo', 'Médio'),
(13, 13, 3, 'Lvl 3 DA', 'Data Warehouse', 'n13.png', 'Ativo', 'Difícil'),
(14, 14, 3, 'Lvl 4 DA', 'Modelos', 'n14.png', 'Ativo', 'Muito Difícil'),
(15, 15, 3, 'Lvl 5 DA', 'Estratégia', 'n15.png', 'Ativo', 'Mestre');

UPDATE BADGE SET ID_NIVEL = ID_BADGE WHERE ID_BADGE <= 15;

-- =========================================================================
-- REQUISITOS 
-- =========================================================================
INSERT INTO REQUISITO (ID_REQUISITO, ID_NIVEL, NOME_REQUISITO, DESCRICAO, TIPOEVIDENCIA, URLIMAGEM) VALUES 
-- Nível 1
(1, 1, 'Certificação Reactive', 'Cert.', 'PDF', 'r.png'), 
(2, 1, 'Aggregates', 'Query.', 'Print', 'r.png'),
(3, 1, 'Variáveis', 'Scope.', 'OML', 'r.png'), 
(4, 1, 'Service Studio', 'Dev.', 'Link', 'r.png'), 
(5, 1, 'List Detail', 'Ecrã.', 'Print', 'r.png'),
-- Nível 2
(6, 2, 'REST', 'API.', 'OML', 'r.png'), 
(7, 2, 'Exceções', 'Log.', 'Print', 'r.png'),
(8, 2, 'Client Var', 'State.', 'Doc', 'r.png'), 
(9, 2, 'Modelação', 'BD.', 'ERD', 'r.png'), 
(10, 2, 'Web Blocks', 'Comp.', 'OML', 'r.png'),
-- Nível 3
(11, 3, '4-Layer', 'Arch.', 'Doc', 'r.png'), 
(12, 3, 'Perf.', 'Query.', 'Print', 'r.png'),
(13, 3, 'Merge', 'Git.', 'Print', 'r.png'), 
(14, 3, 'RBAC', 'Sec.', 'OML', 'r.png'), 
(15, 3, 'JS', 'Code.', 'OML', 'r.png'),
-- Nível 4
(16, 4, 'BPT', 'Process.', 'OML', 'r.png'), 
(17, 4, 'MultiTenant', 'DB.', 'Doc', 'r.png'),
(18, 4, 'Plugins', 'Mob.', 'Code', 'r.png'), 
(19, 4, 'Deploy', 'Plan.', 'Doc', 'r.png'), 
(20, 4, 'Troubleshoot', 'Logs.', 'Print', 'r.png'),
-- Nível 5
(21, 5, 'Mentoria', 'Lead.', 'Doc', 'r.png'), 
(22, 5, 'Standards', 'Guide.', 'PDF', 'r.png'),
(23, 5, 'Architecture', 'Design.', 'Visio', 'r.png'), 
(24, 5, 'CodeReview', 'Rev.', 'Doc', 'r.png'), 
(25, 5, 'Planning', 'Est.', 'XLSX', 'r.png'),
-- Nível 6
(26, 6, 'Linux', 'CLI.', 'Log', 'r.png'), 
(27, 6, 'Git Base', 'Push.', 'Link', 'r.png'),
(28, 6, 'Docker', 'Dfile.', 'Code', 'r.png'), 
(29, 6, 'YAML', 'Config.', 'YAML', 'r.png'), 
(30, 6, 'Redes', 'IP.', 'Doc', 'r.png'),
-- Nível 7
(31, 7, 'Multistage', 'Img.', 'Code', 'r.png'), 
(32, 7, 'Compose', 'Orch.', 'YAML', 'r.png'),
(33, 7, 'Bash', 'Script.', 'SH', 'r.png'), 
(34, 7, 'Cloud CLI', 'AWS.', 'Log', 'r.png'), 
(35, 7, 'GitFlow', 'Branch.', 'Doc', 'r.png'),
-- Nível 8
(36, 8, 'CI/CD', 'Pipe.', 'Code', 'r.png'), 
(37, 8, 'K8s', 'Pods.', 'YAML', 'r.png'),
(38, 8, 'IaC', 'TF.', 'TF', 'r.png'), 
(39, 8, 'ELK', 'Logs.', 'Print', 'r.png'), 
(40, 8, 'BlueGreen', 'Dep.', 'Doc', 'r.png'),
-- Nível 9
(41, 9, 'Helm', 'Charts.', 'Code', 'r.png'), 
(42, 9, 'Istio', 'Mesh.', 'YAML', 'r.png'),
(43, 9, 'Vault', 'Sec.', 'Doc', 'r.png'), 
(44, 9, 'Serverless', 'Arch.', 'Visio', 'r.png'), 
(45, 9, 'FinOps', 'Cost.', 'XLSX', 'r.png'),
-- Nível 10
(46, 10, 'Agile', 'Scrum.', 'Doc', 'r.png'), 
(47, 10, 'SRE', 'SLO.', 'XLSX', 'r.png'),
(48, 10, 'DevSec', 'Scan.', 'Print', 'r.png'), 
(49, 10, 'DRP', 'Rec.', 'Doc', 'r.png'), 
(50, 10, 'Stakeholders', 'Man.', 'PDF', 'r.png'),
-- Nível 11
(51, 11, 'SQL Joins', 'Query.', 'SQL', 'r.png'), 
(52, 11, 'PowerBI', 'Dash.', 'PBIX', 'r.png'),
(53, 11, 'Limpeza', 'Nulls.', 'Code', 'r.png'), 
(54, 11, 'Excel', 'Pivot.', 'XLSX', 'r.png'), 
(55, 11, 'Estruturas', 'Tipos.', 'Doc', 'r.png'),
-- Nível 12
(56, 12, 'Pandas', 'Py.', 'PY', 'r.png'), 
(57, 12, 'StarSchema', 'Mod.', 'ERD', 'r.png'),
(58, 12, 'DAX', 'Meas.', 'Code', 'r.png'), 
(59, 12, 'DW', 'Base.', 'Doc', 'r.png'), 
(60, 12, 'Outliers', 'Stat.', 'Print', 'r.png'),
-- Nível 13
(61, 13, 'ETL', 'Flow.', 'Doc', 'r.png'), 
(62, 13, 'Scikit', 'ML.', 'PY', 'r.png'),
(63, 13, 'SQL Perf', 'Idx.', 'SQL', 'r.png'), 
(64, 13, 'TimeIntel', 'DAX.', 'Code', 'r.png'), 
(65, 13, 'CloudData', 'ADF.', 'Print', 'r.png'),
-- Nível 14
(66, 14, 'PySpark', 'BigD.', 'PY', 'r.png'), 
(67, 14, 'RandomFor', 'ML.', 'PY', 'r.png'),
(68, 14, 'Databricks', 'Lake.', 'Doc', 'r.png'), 
(69, 14, 'Kafka', 'Stream.', 'Code', 'r.png'), 
(70, 14, 'DataGov', 'Pol.', 'PDF', 'r.png'),
-- Nível 15
(71, 15, 'IA Strat', 'Bus.', 'PPT', 'r.png'), 
(72, 15, 'TechStack', 'Def.', 'Visio', 'r.png'),
(73, 15, 'ROI ML', 'Fin.', 'XLSX', 'r.png'), 
(74, 15, 'Storytell', 'CLevel.', 'Video', 'r.png'), 
(75, 15, 'Hiring', 'Tal.', 'Doc', 'r.png');

-- =========================================================================
-- CANDIDATURAS
-- =========================================================================
INSERT INTO CANDIDATURA (ID_CANDIDATURA, ID_UTILIZADOR, ID_NIVEL, ID_BADGEOBTIDO, FASE, DATASUBMISSAO) VALUES 
(1, 1, 1, NULL, 'Aprovada', '2025-03-01'),
(2, 5, 1, NULL, 'Aprovada', '2025-03-05'),
(3, 1, 2, NULL, 'Aprovada', '2025-05-01'),
(4, 5, 2, NULL, 'Em Avaliacao Talent', '2025-06-01'),
(5, 1, 3, NULL, 'Rejeitada', '2025-08-01'),
(6, 9, 3, NULL, 'Em Correcao', '2025-08-05'),
(7, 10, 4, NULL, 'Submetida', '2025-09-01'),
(8, 11, 4, NULL, 'Em Submissao', '2025-09-05'),
(9, 12, 5, NULL, 'Aprovada', '2025-10-01'),
(10, 13, 5, NULL, 'Em Avaliacao Service', '2025-10-05'),
(11, 6, 6, NULL, 'Aprovada', '2025-03-01'),
(12, 15, 6, NULL, 'Aprovada', '2025-03-05'),
(13, 6, 7, NULL, 'Aprovada', '2025-05-01'),
(14, 15, 7, NULL, 'Em Avaliacao Talent', '2025-06-01'),
(15, 6, 8, NULL, 'Rejeitada', '2025-08-01'),
(16, 16, 8, NULL, 'Em Correcao', '2025-08-05'),
(17, 17, 9, NULL, 'Submetida', '2025-09-01'),
(18, 18, 9, NULL, 'Em Submissao', '2025-09-05'),
(19, 19, 10, NULL, 'Aprovada', '2025-10-01'),
(20, 20, 10, NULL, 'Em Avaliacao Service', '2025-10-05'),
(21, 8, 11, NULL, 'Aprovada', '2025-03-01'),
(22, 22, 11, NULL, 'Aprovada', '2025-03-05'),
(23, 8, 12, NULL, 'Aprovada', '2025-05-01'),
(24, 22, 12, NULL, 'Em Avaliacao Talent', '2025-06-01'),
(25, 8, 13, NULL, 'Rejeitada', '2025-08-01'),
(26, 23, 13, NULL, 'Em Correcao', '2025-08-05'),
(27, 24, 14, NULL, 'Submetida', '2025-09-01'),
(28, 25, 14, NULL, 'Em Submissao', '2025-09-05'),
(29, 26, 15, NULL, 'Aprovada', '2025-10-01'),
(30, 27, 15, NULL, 'Em Avaliacao Service', '2025-10-05');

-- =========================================================================
-- EVIDÊNCIAS
-- =========================================================================
INSERT INTO EVIDENCIA (ID_EVIDENCIA, ID_CANDIDATURA, ID_REQUISITO, DATA_SUBMISSAO, FASE) VALUES 
(1, 1, 1, '2025-03-01', 'Submetida'), (2, 1, 2, '2025-03-01', 'Submetida'), (3, 1, 3, '2025-03-01', 'Submetida'), (4, 1, 4, '2025-03-01', 'Submetida'), (5, 1, 5, '2025-03-01', 'Submetida'),
(6, 2, 1, '2025-03-05', 'Submetida'), (7, 2, 2, '2025-03-05', 'Submetida'), (8, 2, 3, '2025-03-05', 'Submetida'), (9, 2, 4, '2025-03-05', 'Submetida'), (10, 2, 5, '2025-03-05', 'Submetida'),
(11, 3, 6, '2025-05-01', 'Submetida'), (12, 3, 7, '2025-05-01', 'Submetida'), (13, 3, 8, '2025-05-01', 'Submetida'), (14, 3, 9, '2025-05-01', 'Submetida'), (15, 3, 10, '2025-05-01', 'Submetida'),
(16, 4, 6, '2025-06-01', 'Submetida'), (17, 4, 7, '2025-06-01', 'Submetida'), (18, 4, 8, '2025-06-01', 'Submetida'), (19, 4, 9, '2025-06-01', 'Submetida'), (20, 4, 10, '2025-06-01', 'Submetida'),
(21, 5, 11, '2025-08-01', 'Submetida'), (22, 5, 12, '2025-08-01', 'Submetida'), (23, 5, 13, '2025-08-01', 'Submetida'), (24, 5, 14, '2025-08-01', 'Submetida'), (25, 5, 15, '2025-08-01', 'Submetida'),
(26, 6, 11, '2025-08-05', 'Submetida'), (27, 6, 12, '2025-08-05', 'Submetida'), (28, 6, 13, '2025-08-05', 'Submetida'), (29, 6, 14, '2025-08-05', 'Submetida'), (30, 6, 15, '2025-08-05', 'Submetida'),
(31, 7, 16, '2025-09-01', 'Submetida'), (32, 7, 17, '2025-09-01', 'Submetida'), (33, 7, 18, '2025-09-01', 'Submetida'), (34, 7, 19, '2025-09-01', 'Submetida'), (35, 7, 20, '2025-09-01', 'Submetida'),
(36, 8, 16, '2025-09-05', 'Submetida'), (37, 8, 17, '2025-09-05', 'Submetida'), (38, 8, 18, '2025-09-05', 'Submetida'),
(41, 9, 21, '2025-10-01', 'Submetida'), (42, 9, 22, '2025-10-01', 'Submetida'), (43, 9, 23, '2025-10-01', 'Submetida'), (44, 9, 24, '2025-10-01', 'Submetida'), (45, 9, 25, '2025-10-01', 'Submetida'),
(46, 10, 21, '2025-10-05', 'Submetida'), (47, 10, 22, '2025-10-05', 'Submetida'), (48, 10, 23, '2025-10-05', 'Submetida'), (49, 10, 24, '2025-10-05', 'Submetida'), (50, 10, 25, '2025-10-05', 'Submetida'),
(51, 11, 26, '2025-03-01', 'Submetida'), (52, 11, 27, '2025-03-01', 'Submetida'), (53, 11, 28, '2025-03-01', 'Submetida'), (54, 11, 29, '2025-03-01', 'Submetida'), (55, 11, 30, '2025-03-01', 'Submetida'),
(56, 12, 26, '2025-03-05', 'Submetida'), (57, 12, 27, '2025-03-05', 'Submetida'), (58, 12, 28, '2025-03-05', 'Submetida'), (59, 12, 29, '2025-03-05', 'Submetida'), (60, 12, 30, '2025-03-05', 'Submetida'),
(61, 13, 31, '2025-05-01', 'Submetida'), (62, 13, 32, '2025-05-01', 'Submetida'), (63, 13, 33, '2025-05-01', 'Submetida'), (64, 13, 34, '2025-05-01', 'Submetida'), (65, 13, 35, '2025-05-01', 'Submetida'),
(66, 14, 31, '2025-06-01', 'Submetida'), (67, 14, 32, '2025-06-01', 'Submetida'), (68, 14, 33, '2025-06-01', 'Submetida'), (69, 14, 34, '2025-06-01', 'Submetida'), (70, 14, 35, '2025-06-01', 'Submetida'),
(71, 15, 36, '2025-08-01', 'Submetida'), (72, 15, 37, '2025-08-01', 'Submetida'), (73, 15, 38, '2025-08-01', 'Submetida'), (74, 15, 39, '2025-08-01', 'Submetida'), (75, 15, 40, '2025-08-01', 'Submetida'),
(76, 16, 36, '2025-08-05', 'Submetida'), (77, 16, 37, '2025-08-05', 'Submetida'), (78, 16, 38, '2025-08-05', 'Submetida'), (79, 16, 39, '2025-08-05', 'Submetida'), (80, 16, 40, '2025-08-05', 'Submetida'),
(81, 17, 41, '2025-09-01', 'Submetida'), (82, 17, 42, '2025-09-01', 'Submetida'), (83, 17, 43, '2025-09-01', 'Submetida'), (84, 17, 44, '2025-09-01', 'Submetida'), (85, 17, 45, '2025-09-01', 'Submetida'),
(86, 18, 41, '2025-09-05', 'Submetida'), (87, 18, 42, '2025-09-05', 'Submetida'),
(91, 19, 46, '2025-10-01', 'Submetida'), (92, 19, 47, '2025-10-01', 'Submetida'), (93, 19, 48, '2025-10-01', 'Submetida'), (94, 19, 49, '2025-10-01', 'Submetida'), (95, 19, 50, '2025-10-01', 'Submetida'),
(96, 20, 46, '2025-10-05', 'Submetida'), (97, 20, 47, '2025-10-05', 'Submetida'), (98, 20, 48, '2025-10-05', 'Submetida'), (99, 20, 49, '2025-10-05', 'Submetida'), (100, 20, 50, '2025-10-05', 'Submetida'),
(101, 21, 51, '2025-03-01', 'Submetida'), (102, 21, 52, '2025-03-01', 'Submetida'), (103, 21, 53, '2025-03-01', 'Submetida'), (104, 21, 54, '2025-03-01', 'Submetida'), (105, 21, 55, '2025-03-01', 'Submetida'),
(106, 22, 51, '2025-03-05', 'Submetida'), (107, 22, 52, '2025-03-05', 'Submetida'), (108, 22, 53, '2025-03-05', 'Submetida'), (109, 22, 54, '2025-03-05', 'Submetida'), (110, 22, 55, '2025-03-05', 'Submetida'),
(111, 23, 56, '2025-05-01', 'Submetida'), (112, 23, 57, '2025-05-01', 'Submetida'), (113, 23, 58, '2025-05-01', 'Submetida'), (114, 23, 59, '2025-05-01', 'Submetida'), (115, 23, 60, '2025-05-01', 'Submetida'),
(116, 24, 56, '2025-06-01', 'Submetida'), (117, 24, 57, '2025-06-01', 'Submetida'), (118, 24, 58, '2025-06-01', 'Submetida'), (119, 24, 59, '2025-06-01', 'Submetida'), (120, 24, 60, '2025-06-01', 'Submetida'),
(121, 25, 61, '2025-08-01', 'Submetida'), (122, 25, 62, '2025-08-01', 'Submetida'), (123, 25, 63, '2025-08-01', 'Submetida'), (124, 25, 64, '2025-08-01', 'Submetida'), (125, 25, 65, '2025-08-01', 'Submetida'),
(126, 26, 61, '2025-08-05', 'Submetida'), (127, 26, 62, '2025-08-05', 'Submetida'), (128, 26, 63, '2025-08-05', 'Submetida'), (129, 26, 64, '2025-08-05', 'Submetida'), (130, 26, 65, '2025-08-05', 'Submetida'),
(131, 27, 66, '2025-09-01', 'Submetida'), (132, 27, 67, '2025-09-01', 'Submetida'), (133, 27, 68, '2025-09-01', 'Submetida'), (134, 27, 69, '2025-09-01', 'Submetida'), (135, 27, 70, '2025-09-01', 'Submetida'),
(136, 28, 66, '2025-09-05', 'Submetida'), (137, 28, 67, '2025-09-05', 'Submetida'),
(141, 29, 71, '2025-10-01', 'Submetida'), (142, 29, 72, '2025-10-01', 'Submetida'), (143, 29, 73, '2025-10-01', 'Submetida'), (144, 29, 74, '2025-10-01', 'Submetida'), (145, 29, 75, '2025-10-01', 'Submetida'),
(146, 30, 71, '2025-10-05', 'Submetida'), (147, 30, 72, '2025-10-05', 'Submetida'), (148, 30, 73, '2025-10-05', 'Submetida'), (149, 30, 74, '2025-10-05', 'Submetida'), (150, 30, 75, '2025-10-05', 'Submetida');

-- =========================================================================
-- FICHEIROS DAS EVIDÊNCIAS
-- =========================================================================
INSERT INTO FICHEIROSEVIDENCIA (ID_FICHEIROEVIDENCIA, ID_EVIDENCIA, NOMEFICHEIRO, URL_FICHEIRO, TAMANHOBYTES) VALUES 
(1, 1, 'c1.pdf', 'u/c1.pdf', 100), (2, 1, 'c2.png', 'u/c2.png', 200), (3, 1, 'c3.txt', 'u/c3.txt', 50),
(4, 2, 'c4.png', 'u/c4.png', 150), (5, 3, 'f.oml', 'u/f.oml', 50), (6, 4, 'l.txt', 'u/l.txt', 10), (7, 5, 'p.png', 'u/p.png', 200),
(8, 6, 'r.oml', 'u/r.oml', 50), (9, 7, 'e.png', 'u/e.png', 100), (10, 8, 'cv.pdf', 'u/cv.pdf', 200), 
(11, 9, 'erd.pdf', 'u/erd.pdf', 500), (12, 10, 'wb.oml', 'u/wb.oml', 60), (13, 11, 'sql1.sql', 'u/1.sql', 10), 
(14, 12, 'pbix1.pbix', 'u/1.pbix', 1000), (15, 13, 'py1.py', 'u/1.py', 20), (16, 14, 'xls1.xlsx', 'u/1.xlsx', 500), 
(17, 15, 'doc1.pdf', 'u/1.pdf', 200), (18, 16, 'd1.txt', 'u/d1.txt', 10), (19, 17, 'd2.txt', 'u/d2.txt', 10), 
(20, 18, 'd3.txt', 'u/d3.txt', 10), (21, 19, 'd4.txt', 'u/d4.txt', 10), (22, 20, 'd5.txt', 'u/d5.txt', 10),
(23, 21, 'e1.txt', 'u/e1.txt', 10), (24, 22, 'e2.txt', 'u/e2.txt', 10), (25, 23, 'e3.txt', 'u/e3.txt', 10),
(26, 24, 'e4.txt', 'u/e4.txt', 10), (27, 25, 'e5.txt', 'u/e5.txt', 10), (28, 26, 'e6.txt', 'u/e6.txt', 10),
(29, 27, 'e7.txt', 'u/e7.txt', 10), (30, 28, 'e8.txt', 'u/e8.txt', 10), (31, 29, 'e9.txt', 'u/e9.txt', 10),
(32, 30, 'e10.txt', 'u/e10.txt', 10), (33, 31, 'e11.txt', 'u/e11.txt', 10), (34, 32, 'e12.txt', 'u/e12.txt', 10),
(35, 33, 'e13.txt', 'u/e13.txt', 10), (36, 34, 'e14.txt', 'u/e14.txt', 10), (37, 35, 'e15.txt', 'u/e15.txt', 10),
(38, 36, 'e16.txt', 'u/e16.txt', 10), (39, 37, 'e17.txt', 'u/e17.txt', 10), (40, 38, 'e18.txt', 'u/e18.txt', 10),
(41, 41, 'f1.txt', 'u/f1.txt', 10), (42, 42, 'f2.txt', 'u/f2.txt', 10), (43, 43, 'f3.txt', 'u/f3.txt', 10),
(44, 44, 'f4.txt', 'u/f4.txt', 10), (45, 45, 'f5.txt', 'u/f5.txt', 10), (46, 46, 'f6.txt', 'u/f6.txt', 10),
(47, 47, 'f7.txt', 'u/f7.txt', 10), (48, 48, 'f8.txt', 'u/f8.txt', 10), (49, 49, 'f9.txt', 'u/f9.txt', 10),
(50, 50, 'f10.txt', 'u/f10.txt', 10), (51, 51, 'g1.txt', 'u/g1.txt', 10), (52, 52, 'g2.txt', 'u/g2.txt', 10),
(53, 53, 'g3.txt', 'u/g3.txt', 10), (54, 54, 'g4.txt', 'u/g4.txt', 10), (55, 55, 'g5.txt', 'u/g5.txt', 10),
(56, 56, 'g6.txt', 'u/g6.txt', 10), (57, 57, 'g7.txt', 'u/g7.txt', 10), (58, 58, 'g8.txt', 'u/g8.txt', 10),
(59, 59, 'g9.txt', 'u/g9.txt', 10), (60, 60, 'g10.txt', 'u/g10.txt', 10), (61, 61, 'h1.txt', 'u/h1.txt', 10),
(62, 62, 'h2.txt', 'u/h2.txt', 10), (63, 63, 'h3.txt', 'u/h3.txt', 10), (64, 64, 'h4.txt', 'u/h4.txt', 10),
(65, 65, 'h5.txt', 'u/h5.txt', 10), (66, 66, 'h6.txt', 'u/h6.txt', 10), (67, 67, 'h7.txt', 'u/h7.txt', 10),
(68, 68, 'h8.txt', 'u/h8.txt', 10), (69, 69, 'h9.txt', 'u/h9.txt', 10), (70, 70, 'h10.txt', 'u/h10.txt', 10),
(71, 71, 'i1.txt', 'u/i1.txt', 10), (72, 72, 'i2.txt', 'u/i2.txt', 10), (73, 73, 'i3.txt', 'u/i3.txt', 10),
(74, 74, 'i4.txt', 'u/i4.txt', 10), (75, 75, 'i5.txt', 'u/i5.txt', 10), (76, 76, 'i6.txt', 'u/i6.txt', 10),
(77, 77, 'i7.txt', 'u/i7.txt', 10), (78, 78, 'i8.txt', 'u/i8.txt', 10), (79, 79, 'i9.txt', 'u/i9.txt', 10),
(80, 80, 'i10.txt', 'u/i10.txt', 10), (81, 81, 'j1.txt', 'u/j1.txt', 10), (82, 82, 'j2.txt', 'u/j2.txt', 10),
(83, 83, 'j3.txt', 'u/j3.txt', 10), (84, 84, 'j4.txt', 'u/j4.txt', 10), (85, 85, 'j5.txt', 'u/j5.txt', 10),
(86, 86, 'j6.txt', 'u/j6.txt', 10), (87, 87, 'j7.txt', 'u/j7.txt', 10), (91, 91, 'k1.txt', 'u/k1.txt', 10),
(92, 92, 'k2.txt', 'u/k2.txt', 10), (93, 93, 'k3.txt', 'u/k3.txt', 10), (94, 94, 'k4.txt', 'u/k4.txt', 10),
(95, 95, 'k5.txt', 'u/k5.txt', 10), (96, 96, 'k6.txt', 'u/k6.txt', 10), (97, 97, 'k7.txt', 'u/k7.txt', 10),
(98, 98, 'k8.txt', 'u/k8.txt', 10), (99, 99, 'k9.txt', 'u/k9.txt', 10), (100, 100, 'k10.txt', 'u/k10.txt', 10),
(101, 101, 'l1.txt', 'u/l1.txt', 10), (102, 102, 'l2.txt', 'u/l2.txt', 10), (103, 103, 'l3.txt', 'u/l3.txt', 10),
(104, 104, 'l4.txt', 'u/l4.txt', 10), (105, 105, 'l5.txt', 'u/l5.txt', 10), (106, 106, 'l6.txt', 'u/l6.txt', 10),
(107, 107, 'l7.txt', 'u/l7.txt', 10), (108, 108, 'l8.txt', 'u/l8.txt', 10), (109, 109, 'l9.txt', 'u/l9.txt', 10),
(110, 110, 'l10.txt', 'u/l10.txt', 10), (111, 111, 'm1.txt', 'u/m1.txt', 10), (112, 112, 'm2.txt', 'u/m2.txt', 10),
(113, 113, 'm3.txt', 'u/m3.txt', 10), (114, 114, 'm4.txt', 'u/m4.txt', 10), (115, 115, 'm5.txt', 'u/m5.txt', 10),
(116, 116, 'm6.txt', 'u/m6.txt', 10), (117, 117, 'm7.txt', 'u/m7.txt', 10), (118, 118, 'm8.txt', 'u/m8.txt', 10),
(119, 119, 'm9.txt', 'u/m9.txt', 10), (120, 120, 'm10.txt', 'u/m10.txt', 10), (121, 121, 'n1.txt', 'u/n1.txt', 10),
(122, 122, 'n2.txt', 'u/n2.txt', 10), (123, 123, 'n3.txt', 'u/n3.txt', 10), (124, 124, 'n4.txt', 'u/n4.txt', 10),
(125, 125, 'n5.txt', 'u/n5.txt', 10), (126, 126, 'n6.txt', 'u/n6.txt', 10), (127, 127, 'n7.txt', 'u/n7.txt', 10),
(128, 128, 'n8.txt', 'u/n8.txt', 10), (129, 129, 'n9.txt', 'u/n9.txt', 10), (130, 130, 'n10.txt', 'u/n10.txt', 10),
(131, 131, 'o1.txt', 'u/o1.txt', 10), (132, 132, 'o2.txt', 'u/o2.txt', 10), (133, 133, 'o3.txt', 'u/o3.txt', 10),
(134, 134, 'o4.txt', 'u/o4.txt', 10), (135, 135, 'o5.txt', 'u/o5.txt', 10), (136, 136, 'o6.txt', 'u/o6.txt', 10),
(137, 137, 'o7.txt', 'u/o7.txt', 10), (141, 141, 'p1.txt', 'u/p1.txt', 10), (142, 142, 'p2.txt', 'u/p2.txt', 10),
(143, 143, 'p3.txt', 'u/p3.txt', 10), (144, 144, 'p4.txt', 'u/p4.txt', 10), (145, 145, 'p5.txt', 'u/p5.txt', 10),
(146, 146, 'p6.txt', 'u/p6.txt', 10), (147, 147, 'p7.txt', 'u/p7.txt', 10), (148, 148, 'p8.txt', 'u/p8.txt', 10),
(149, 149, 'p9.txt', 'u/p9.txt', 10), (150, 150, 'p10.txt', 'u/p10.txt', 10);

-- =========================================================================
-- BADGES OBTIDOS E ATUALIZAÇÕES
-- =========================================================================
INSERT INTO BADGE_OBTIDO (ID_BADGEOBTIDO, ID_BADGE, ID_UTILIZADOR, DATAOBTENCAO, DATAEXPIRACAO, PONTUACAO, FASE) VALUES 
(1, 1, 1, '2025-03-05', '2026-03-05', 10, 'Ativo'),
(2, 2, 1, '2025-05-05', '2026-05-05', 20, 'Ativo'),
(3, 1, 5, '2025-03-20', '2026-03-20', 10, 'Ativo'),
(4, 6, 6, '2025-03-05', '2026-03-05', 10, 'Ativo'),
(5, 7, 6, '2025-05-05', '2026-05-05', 20, 'Ativo'),
(6, 6, 15, '2025-03-10', '2026-03-10', 10, 'Ativo'),
(7, 7, 15, '2025-05-10', '2026-05-10', 20, 'Ativo'),
(8, 11, 8, '2025-03-05', '2026-03-05', 10, 'Ativo'),
(9, 12, 8, '2025-05-05', '2026-05-05', 20, 'Ativo'),
(10, 11, 22, '2025-03-10', '2026-03-10', 10, 'Ativo'),
(11, 15, 26, '2025-10-05', '2028-10-05', 50, 'Ativo');

UPDATE CANDIDATURA SET ID_BADGEOBTIDO = 1 WHERE ID_CANDIDATURA = 1;
UPDATE CANDIDATURA SET ID_BADGEOBTIDO = 2 WHERE ID_CANDIDATURA = 3;
UPDATE CANDIDATURA SET ID_BADGEOBTIDO = 3 WHERE ID_CANDIDATURA = 2;
UPDATE CANDIDATURA SET ID_BADGEOBTIDO = 4 WHERE ID_CANDIDATURA = 11;
UPDATE CANDIDATURA SET ID_BADGEOBTIDO = 5 WHERE ID_CANDIDATURA = 13;
UPDATE CANDIDATURA SET ID_BADGEOBTIDO = 6 WHERE ID_CANDIDATURA = 12;
UPDATE CANDIDATURA SET ID_BADGEOBTIDO = 7 WHERE ID_CANDIDATURA = 14;
UPDATE CANDIDATURA SET ID_BADGEOBTIDO = 8 WHERE ID_CANDIDATURA = 21;
UPDATE CANDIDATURA SET ID_BADGEOBTIDO = 9 WHERE ID_CANDIDATURA = 23;
UPDATE CANDIDATURA SET ID_BADGEOBTIDO = 10 WHERE ID_CANDIDATURA = 22;
UPDATE CANDIDATURA SET ID_BADGEOBTIDO = 11 WHERE ID_CANDIDATURA = 29;

UPDATE UTILIZADOR SET PONTUACAOTOTAL = 30, BADGES_TOTAL = 2 WHERE ID_UTILIZADOR = 1;
UPDATE UTILIZADOR SET PONTUACAOTOTAL = 10, BADGES_TOTAL = 1 WHERE ID_UTILIZADOR = 5;
UPDATE UTILIZADOR SET PONTUACAOTOTAL = 30, BADGES_TOTAL = 2 WHERE ID_UTILIZADOR = 6;
UPDATE UTILIZADOR SET PONTUACAOTOTAL = 30, BADGES_TOTAL = 2 WHERE ID_UTILIZADOR = 15;
UPDATE UTILIZADOR SET PONTUACAOTOTAL = 30, BADGES_TOTAL = 2 WHERE ID_UTILIZADOR = 8;
UPDATE UTILIZADOR SET PONTUACAOTOTAL = 10, BADGES_TOTAL = 1 WHERE ID_UTILIZADOR = 22;
UPDATE UTILIZADOR SET PONTUACAOTOTAL = 50, BADGES_TOTAL = 1 WHERE ID_UTILIZADOR = 26;

-- =========================================================================
-- VALIDAÇÕES E FEEDBACKS
-- =========================================================================
INSERT INTO VALIDACAOCANDIDATURA (ID_VALIDACAO, ID_CANDIDATURA, ID_UTILIZADOR, DATAAVALIACAO, ACAO, COMENTARIO, FASE) VALUES 
(1, 1, 2, '2025-03-05', 'Aprovar', 'Bom projeto', 'Finalizada'), 
(2, 3, 2, '2025-05-05', 'Aprovar', 'Muito bem estruturado', 'Finalizada'), 
(3, 2, 2, '2025-03-20', 'Aprovar', 'Certificado válido', 'Finalizada'),
(4, 5, 2, '2025-08-05', 'Rejeitar', 'O código não compila', 'Finalizada'), 
(5, 6, 2, '2025-08-10', 'Pedir Correcao', 'Falta incluir prints de segurança', 'Finalizada'), 
(6, 11, 7, '2025-03-05', 'Aprovar', 'Docker impecável', 'Finalizada'),
(7, 13, 7, '2025-05-05', 'Aprovar', 'Pipelines a funcionar a 100%', 'Finalizada'), 
(8, 15, 7, '2025-08-05', 'Rejeitar', 'Muitos erros no K8s', 'Finalizada'), 
(9, 16, 7, '2025-08-10', 'Pedir Correcao', 'Falta expor o porto 80', 'Finalizada'),
(10, 21, 8, '2025-03-05', 'Aprovar', 'Queries bem feitas', 'Finalizada'), 
(11, 23, 8, '2025-05-05', 'Aprovar', 'ETL validado', 'Finalizada'), 
(12, 25, 8, '2025-08-05', 'Rejeitar', 'Dados inconsistentes', 'Finalizada'),
(13, 26, 8, '2025-08-10', 'Pedir Correcao', 'Falta o modelo ER', 'Finalizada'),
(14, 29, 8, '2025-10-05', 'Aprovar', 'Visão brilhante de IA', 'Finalizada');

INSERT INTO FEEDBACKEVIDENCIA (IDFEEDBACK, ID_EVIDENCIA, ID_VALIDACAO, ESTADO) VALUES 
(1, 1, 1, 'Aprovado'), (2, 2, 1, 'Aprovado'), (3, 3, 1, 'Aprovado'), (4, 4, 1, 'Aprovado'), (5, 5, 1, 'Aprovado'),
(6, 11, 3, 'Aprovado'), (7, 12, 3, 'Aprovado'), (8, 13, 3, 'Aprovado'), (9, 14, 3, 'Aprovado'), (10, 15, 3, 'Aprovado'),
(11, 26, 6, 'Rejeitado'), (12, 27, 6, 'Aprovado'), (13, 28, 6, 'Rejeitado'), (14, 29, 6, 'Aprovado'), (15, 30, 6, 'Rejeitado');

-- =========================================================================
-- SISTEMA E NOTIFICAÇÕES GERAIS
-- =========================================================================
INSERT INTO CONFIGURACOES (IDCONFIGURACAO, NOME, VALOR, DESCRICAO) VALUES 
(1, 'Notifs', 1, 'Ligar/Desligar'),
(2, 'Manutencao', 0, 'Off');

INSERT INTO ALERTAGLOBAL (IDALERTAGLOBAL, MENSAGEM, DESTINATARIO, DATA, ESTADO) VALUES 
(1, 'Sistema Resetado.', 'Todos', '2025-06-01', 'Ativo'),
(2, 'Novos Badges em DevOps.', 'DevOps', '2025-06-15', 'Ativo');

INSERT INTO RANKING_HISTORICO (ID_RANKING, ID_UTILIZADOR, TIPO, ANO, MES, PONTOSGANHOS, BADGESGANHOS) VALUES 
(1, 1, 'Mensal', 2025, 3, 10, 1), 
(2, 6, 'Mensal', 2025, 4, 10, 1),
(3, 15, 'Mensal', 2025, 5, 20, 1),
(4, 26, 'Mensal', 2025, 10, 50, 1);

INSERT INTO SUGESTAOMETAS (ID_SUGESTAO, ID_UTILIZADOR, UTI_ID_UTILIZADOR, TITULO, DESCRICAO, DATASUGESTAO, DATALIMITE, PONTOS, ESTADO, URLFICHEIRO) VALUES 
(1, 1, 2, 'Ir para Senior', 'Avança para a Arq 4-Layer.', '2025-05-01', '2025-12-31', 30, 'Aceite', NULL),
(2, 16, 7, 'Melhorar Terraform', 'Tira a certificação.', '2025-06-01', '2025-12-31', 40, 'Pendente', NULL),
(3, 22, 8, 'Aprender PySpark', 'O futuro é Big Data.', '2025-06-05', '2025-12-31', 30, 'Pendente', NULL);

INSERT INTO NOTIFICACOES (ID_NOTIFICACAO, ID_BADGEOBTIDO, ID_CANDIDATURA, ID_UTILIZADOR, TIPO_NOTIFICACAO, MENSAGEM, DATACRIACAO, FASE, TITULO) VALUES 
(1, 1, 1, 1, 'Sucesso', 'Badge ganho!', '2025-03-05', 'Lida', 'Novo Badge'),
(2, NULL, 5, 1, 'Alerta', 'Rejeitada', '2025-08-01', 'Lida', 'Candidatura Rejeitada'),
(3, NULL, 6, 9, 'Ação Necessária', 'Ana, o avaliador pediu correção.', '2025-08-05', 'Não Lida', 'Correção Solicitada'),
(4, NULL, 8, 3, 'Ação Necessária', 'Miguel (Talent): Nova candidatura.', '2025-09-05', 'Não Lida', 'Nova Submissão'),
(5, NULL, 10, 7, 'Info', 'Líder DevOps: Avalia o código do Eduardo.', '2025-10-05', 'Não Lida', 'Validação Pendente'),
(6, 11, 29, 26, 'Sucesso', 'Badge Líder Data ganho!', '2025-10-05', 'Lida', 'Novo Badge');

'''
        .split(';');

    print('🚀 A iniciar seed da base de dados...');

    for (int i = 0; i < commands.length; i++) {
      final command = commands[i].trim();

      if (command.isEmpty) continue;

      final cleanCommand = command
          .split('\n')
          .where(
            (line) => !line.trim().startsWith('--'),
          )
          .join('\n')
          .trim();

      if (cleanCommand.isEmpty) continue;

      if (cleanCommand.toUpperCase() == 'GO') continue;

      try {
        await db.execute(cleanCommand);

        print(
          '✅ Comando ${i + 1}/${commands.length} executado com sucesso',
        );
      } catch (e) {
        print(
          '❌ Erro no comando ${i + 1}/${commands.length}',
        );

        print('---------------- SQL ----------------');
        print(cleanCommand);

        print('-------------- ERRO ----------------');
        print(e);

        print('------------------------------------');
      }
    }

    print(' Seed concluído.');
  }
}
