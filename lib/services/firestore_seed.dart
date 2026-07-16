import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Importa uma única vez os dados que existiam no antigo database_seed.dart.
///
/// Não guarda passwords e não cria contas no Firebase Authentication.
/// Os utilizadores antigos são apenas dados de demonstração com IDs legacy-*.
class FirestoreSeed {
  FirestoreSeed._();

  static const int _seedVersion = 1;
  static const String _metadataCollection = 'systemMetadata';
  static const String _metadataDocument = 'initialSeed';

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Executa o seed apenas quando ainda não foi concluído.
  ///
  /// Retorna true quando importou dados e false quando os dados já existiam.
  static Future<bool> seedIfNeeded() async {
    final metadataRef =
        _db.collection(_metadataCollection).doc(_metadataDocument);

    final metadata = await metadataRef.get();
    final currentVersion = metadata.data()?['version'];

    if (metadata.exists && currentVersion == _seedVersion) {
      print('✅ Firestore seed já estava concluído.');
      return false;
    }

    print('🚀 A iniciar importação automática para o Firestore...');

    final decoded = base64Decode(_compressedSeedData);
    final jsonBytes = gzip.decode(decoded);
    final root = jsonDecode(utf8.decode(jsonBytes));

    if (root is! Map<String, dynamic>) {
      throw const FormatException('Formato inválido dos dados do seed.');
    }

    // O Firestore aceita no máximo 500 operações por batch.
    // Usamos 400 para manter margem de segurança.
    WriteBatch batch = _db.batch();
    var operationsInBatch = 0;
    var totalDocuments = 0;

    Future<void> commitCurrentBatch() async {
      if (operationsInBatch == 0) return;
      await batch.commit();
      batch = _db.batch();
      operationsInBatch = 0;
    }

    for (final collectionEntry in root.entries) {
      final collectionName = collectionEntry.key;
      final documents = collectionEntry.value;

      if (documents is! Map<String, dynamic>) continue;

      for (final documentEntry in documents.entries) {
        final documentId = documentEntry.key;
        final value = documentEntry.value;

        if (value is! Map<String, dynamic>) continue;

        final reference = _db.collection(collectionName).doc(documentId);

        batch.set(
          reference,
          {
            ...value,
            'seedVersion': _seedVersion,
          },
          SetOptions(merge: true),
        );

        operationsInBatch++;
        totalDocuments++;

        if (operationsInBatch >= 400) {
          await commitCurrentBatch();
        }
      }
    }

    await commitCurrentBatch();

    await metadataRef.set({
      'version': _seedVersion,
      'completed': true,
      'documentCount': totalDocuments,
      'completedAt': FieldValue.serverTimestamp(),
    });

    print('✅ Seed concluído: $totalDocuments documentos importados.');
    return true;
  }

  static Future<void> seedNovosRequisitos() async {
    final requisitosPorNivel = <int, List<Map<String, String>>>{
      // Nível 16 — Badge Cooperativo
      16: [
        {
          'name': 'Identificação da Equipa',
          'description': 'Apresentar os membros que participaram no projeto.',
          'evidenceType': 'PDF',
        },
        {
          'name': 'Plano de Trabalho',
          'description': 'Apresentar a distribuição de tarefas pela equipa.',
          'evidenceType': 'Doc',
        },
        {
          'name': 'Contributos Individuais',
          'description': 'Demonstrar o contributo de cada participante.',
          'evidenceType': 'Print',
        },
        {
          'name': 'Resultado do Projeto',
          'description': 'Apresentar o resultado final desenvolvido em equipa.',
          'evidenceType': 'Link',
        },
        {
          'name': 'Validação dos Colegas',
          'description': 'Apresentar uma declaração dos restantes membros.',
          'evidenceType': 'PDF',
        },
      ],

      // Nível 17 — LowCode Integrator
      17: [
        {
          'name': 'Integração REST',
          'description': 'Apresentar uma integração com uma API REST.',
          'evidenceType': 'OML',
        },
        {
          'name': 'Autenticação da API',
          'description': 'Demonstrar a configuração de autenticação da API.',
          'evidenceType': 'Print',
        },
        {
          'name': 'Tratamento de Respostas',
          'description': 'Apresentar o tratamento das respostas da API.',
          'evidenceType': 'OML',
        },
        {
          'name': 'Tratamento de Erros',
          'description': 'Demonstrar o tratamento de erros da integração.',
          'evidenceType': 'Print',
        },
        {
          'name': 'Documentação da Integração',
          'description': 'Entregar documentação técnica da integração.',
          'evidenceType': 'PDF',
        },
      ],

      // Nível 18 — LowCode Performance
      18: [
        {
          'name': 'Análise de Performance',
          'description': 'Apresentar uma análise de desempenho da aplicação.',
          'evidenceType': 'PDF',
        },
        {
          'name': 'Otimização de Queries',
          'description': 'Demonstrar melhorias em consultas de dados.',
          'evidenceType': 'OML',
        },
        {
          'name': 'Otimização de Ecrãs',
          'description': 'Apresentar melhorias no carregamento dos ecrãs.',
          'evidenceType': 'Print',
        },
        {
          'name': 'Logs de Performance',
          'description': 'Apresentar logs antes e depois da otimização.',
          'evidenceType': 'Log',
        },
        {
          'name': 'Relatório de Resultados',
          'description': 'Comparar os resultados obtidos após as melhorias.',
          'evidenceType': 'PDF',
        },
      ],

      // Nível 19 — LowCode Architect
      19: [
        {
          'name': 'Arquitetura da Solução',
          'description': 'Apresentar o desenho global da arquitetura.',
          'evidenceType': 'Visio',
        },
        {
          'name': 'Separação por Camadas',
          'description': 'Demonstrar a organização lógica por camadas.',
          'evidenceType': 'OML',
        },
        {
          'name': 'Modelo de Dados',
          'description': 'Apresentar o modelo de dados da solução.',
          'evidenceType': 'ERD',
        },
        {
          'name': 'Segurança da Arquitetura',
          'description': 'Documentar os mecanismos de segurança adotados.',
          'evidenceType': 'PDF',
        },
        {
          'name': 'Decisões Técnicas',
          'description': 'Apresentar as principais decisões de arquitetura.',
          'evidenceType': 'Doc',
        },
      ],

      // Nível 20 — DevOps Containers
      20: [
        {
          'name': 'Dockerfile',
          'description': 'Apresentar um Dockerfile funcional.',
          'evidenceType': 'Code',
        },
        {
          'name': 'Imagem Docker',
          'description': 'Demonstrar a criação de uma imagem Docker.',
          'evidenceType': 'Print',
        },
        {
          'name': 'Execução do Container',
          'description': 'Apresentar o container em execução.',
          'evidenceType': 'Print',
        },
        {
          'name': 'Docker Compose',
          'description': 'Apresentar uma configuração Docker Compose.',
          'evidenceType': 'YAML',
        },
        {
          'name': 'Documentação de Deploy',
          'description': 'Documentar o processo de execução da solução.',
          'evidenceType': 'PDF',
        },
      ],

      // Nível 21 — DevOps Security
      21: [
        {
          'name': 'Análise de Vulnerabilidades',
          'description': 'Apresentar um relatório de vulnerabilidades.',
          'evidenceType': 'PDF',
        },
        {
          'name': 'Pipeline de Segurança',
          'description': 'Demonstrar verificações de segurança no pipeline.',
          'evidenceType': 'YAML',
        },
        {
          'name': 'Gestão de Segredos',
          'description': 'Demonstrar uma solução segura de gestão de segredos.',
          'evidenceType': 'Doc',
        },
        {
          'name': 'Scan de Dependências',
          'description': 'Apresentar o resultado de um scan de dependências.',
          'evidenceType': 'Print',
        },
        {
          'name': 'Política DevSecOps',
          'description': 'Documentar práticas de segurança aplicadas.',
          'evidenceType': 'PDF',
        },
      ],

      // Nível 22 — DevOps Architect
      22: [
        {
          'name': 'Arquitetura Cloud',
          'description': 'Apresentar a arquitetura cloud da solução.',
          'evidenceType': 'Visio',
        },
        {
          'name': 'Infraestrutura como Código',
          'description': 'Apresentar recursos definidos como código.',
          'evidenceType': 'TF',
        },
        {
          'name': 'Pipeline Completo',
          'description': 'Demonstrar um pipeline de CI/CD completo.',
          'evidenceType': 'YAML',
        },
        {
          'name': 'Alta Disponibilidade',
          'description': 'Documentar mecanismos de alta disponibilidade.',
          'evidenceType': 'PDF',
        },
        {
          'name': 'Monitorização',
          'description': 'Demonstrar métricas e monitorização da solução.',
          'evidenceType': 'Print',
        },
      ],

      // Nível 23 — Data Analyst
      23: [
        {
          'name': 'Preparação de Dados',
          'description': 'Apresentar o processo de limpeza dos dados.',
          'evidenceType': 'PY',
        },
        {
          'name': 'Análise Exploratória',
          'description': 'Apresentar uma análise exploratória dos dados.',
          'evidenceType': 'PDF',
        },
        {
          'name': 'Dashboard',
          'description': 'Apresentar um dashboard de análise.',
          'evidenceType': 'PBIX',
        },
        {
          'name': 'Indicadores de Negócio',
          'description': 'Documentar os principais indicadores analisados.',
          'evidenceType': 'XLSX',
        },
        {
          'name': 'Conclusões da Análise',
          'description': 'Apresentar conclusões e recomendações.',
          'evidenceType': 'PDF',
        },
      ],

      // Nível 24 — Data Engineer
      24: [
        {
          'name': 'Pipeline ETL',
          'description': 'Apresentar um pipeline ETL funcional.',
          'evidenceType': 'PY',
        },
        {
          'name': 'Modelo de Dados',
          'description': 'Apresentar o modelo de armazenamento utilizado.',
          'evidenceType': 'ERD',
        },
        {
          'name': 'Transformação de Dados',
          'description': 'Demonstrar transformações aplicadas aos dados.',
          'evidenceType': 'Code',
        },
        {
          'name': 'Orquestração',
          'description': 'Apresentar a orquestração do pipeline.',
          'evidenceType': 'YAML',
        },
        {
          'name': 'Monitorização do Pipeline',
          'description': 'Apresentar logs e controlo da execução.',
          'evidenceType': 'Log',
        },
      ],

      // Nível 25 — Data Architect
      25: [
        {
          'name': 'Arquitetura de Dados',
          'description': 'Apresentar a arquitetura global da plataforma.',
          'evidenceType': 'Visio',
        },
        {
          'name': 'Modelo Conceptual',
          'description': 'Apresentar o modelo conceptual dos dados.',
          'evidenceType': 'ERD',
        },
        {
          'name': 'Data Warehouse',
          'description': 'Documentar a organização do Data Warehouse.',
          'evidenceType': 'PDF',
        },
        {
          'name': 'Governança de Dados',
          'description': 'Apresentar políticas de qualidade e governação.',
          'evidenceType': 'PDF',
        },
        {
          'name': 'Integração de Fontes',
          'description': 'Demonstrar a integração das diferentes fontes.',
          'evidenceType': 'Doc',
        },
      ],

      // Nível 26 — Badge Mentor
      26: [
        {
          'name': 'Lista de Mentorados',
          'description': 'Identificar os colegas acompanhados.',
          'evidenceType': 'PDF',
        },
        {
          'name': 'Plano de Mentoria',
          'description': 'Apresentar o plano de acompanhamento.',
          'evidenceType': 'Doc',
        },
        {
          'name': 'Sessões Realizadas',
          'description': 'Apresentar evidência das sessões de mentoria.',
          'evidenceType': 'Print',
        },
        {
          'name': 'Feedback dos Colegas',
          'description': 'Apresentar feedback recebido dos mentorados.',
          'evidenceType': 'PDF',
        },
        {
          'name': 'Resultados da Mentoria',
          'description': 'Descrever os resultados alcançados.',
          'evidenceType': 'Doc',
        },
      ],

      // Nível 27 — Badge Inovação
      27: [
        {
          'name': 'Descrição da Ideia',
          'description': 'Apresentar detalhadamente a solução inovadora.',
          'evidenceType': 'PDF',
        },
        {
          'name': 'Problema Identificado',
          'description': 'Descrever o problema que a solução resolve.',
          'evidenceType': 'Doc',
        },
        {
          'name': 'Protótipo',
          'description': 'Apresentar um protótipo da solução.',
          'evidenceType': 'Link',
        },
        {
          'name': 'Impacto Esperado',
          'description': 'Apresentar os benefícios esperados.',
          'evidenceType': 'PPT',
        },
        {
          'name': 'Validação da Ideia',
          'description': 'Apresentar feedback ou validação da proposta.',
          'evidenceType': 'PDF',
        },
      ],

      // Nível 28 — Badge Persistência
      28: [
        {
          'name': 'Candidatura do Primeiro Mês',
          'description': 'Apresentar comprovativo da primeira candidatura.',
          'evidenceType': 'Print',
        },
        {
          'name': 'Candidatura do Segundo Mês',
          'description': 'Apresentar comprovativo da segunda candidatura.',
          'evidenceType': 'Print',
        },
        {
          'name': 'Candidatura do Terceiro Mês',
          'description': 'Apresentar comprovativo da terceira candidatura.',
          'evidenceType': 'Print',
        },
        {
          'name': 'Histórico de Atividade',
          'description': 'Apresentar o histórico dos três meses.',
          'evidenceType': 'PDF',
        },
        {
          'name': 'Reflexão de Evolução',
          'description': 'Descrever a evolução ao longo do período.',
          'evidenceType': 'Doc',
        },
      ],

      // Nível 29 — Badge Excelência
      29: [
        {
          'name': 'Candidatura Aprovada',
          'description': 'Apresentar comprovativo de aprovação.',
          'evidenceType': 'Print',
        },
        {
          'name': 'Avaliação Sem Correções',
          'description': 'Demonstrar que não existiram pedidos de correção.',
          'evidenceType': 'Print',
        },
        {
          'name': 'Qualidade das Evidências',
          'description': 'Apresentar as evidências submetidas.',
          'evidenceType': 'PDF',
        },
        {
          'name': 'Feedback da Avaliação',
          'description': 'Apresentar o feedback recebido.',
          'evidenceType': 'Doc',
        },
        {
          'name': 'Resumo da Conquista',
          'description': 'Descrever o processo de obtenção do badge.',
          'evidenceType': 'PDF',
        },
      ],

      // Nível 30 — Badge Comunidade
      30: [
        {
          'name': 'Lista de Iniciativas',
          'description': 'Identificar as iniciativas em que participou.',
          'evidenceType': 'PDF',
        },
        {
          'name': 'Comprovativos de Participação',
          'description': 'Apresentar comprovativos das participações.',
          'evidenceType': 'Print',
        },
        {
          'name': 'Contributos Realizados',
          'description': 'Descrever os contributos em cada iniciativa.',
          'evidenceType': 'Doc',
        },
        {
          'name': 'Impacto na Comunidade',
          'description': 'Apresentar o impacto das atividades realizadas.',
          'evidenceType': 'PDF',
        },
        {
          'name': 'Validação da Organização',
          'description': 'Apresentar uma validação das iniciativas internas.',
          'evidenceType': 'PDF',
        },
      ],
    };

    final novosRequisitos = <Map<String, dynamic>>[];
    var proximoLegacyId = 76;

    for (final entry in requisitosPorNivel.entries) {
      final levelId = entry.key;

      for (final requisito in entry.value) {
        novosRequisitos.add({
          'legacyId': proximoLegacyId,
          'levelId': levelId,
          'name': requisito['name'],
          'description': requisito['description'],
          'evidenceType': requisito['evidenceType'],
          'imageUrl': 'r.png',
          'status': 'Ativo',
        });

        proximoLegacyId++;
      }
    }

    WriteBatch batch = _db.batch();
    var operationsInBatch = 0;

    Future<void> commitCurrentBatch() async {
      if (operationsInBatch == 0) return;

      await batch.commit();
      batch = _db.batch();
      operationsInBatch = 0;
    }

    for (final requisito in novosRequisitos) {
      final documentId = requisito['legacyId'].toString();

      final reference = _db.collection('requirements').doc(documentId);

      batch.set(
        reference,
        {
          ...requisito,
          'seedVersion': 2,
        },
        SetOptions(merge: true),
      );

      operationsInBatch++;

      if (operationsInBatch >= 400) {
        await commitCurrentBatch();
      }
    }

    await commitCurrentBatch();
  }

  static const String _compressedSeedData =
      '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'
      'IJb53xLvvfhHgX3r9baxENNuTA4dEMz5LfssVk7iXyX4zTdszVTXbLMxOX5AOOePAtyjGvsjNFPNdhiT4wa083OSe+/FP2qzb76h'
      '/VRFdBeTowdENOba9bhnKkQi+orJsQNSGnuaZcv2G1rPVUQ/MTlyQE9jX4fcN4Mc00dMjhxQ1FiXTcSBIeSI9mFy5ICixqEOeWgI'
      'OaJrmDwTAuQ0jnTII0PIEc3C5MgBOaW6GUoNzVBMjzA5ckBNqW6GUlMzFNEaTI4c0FGqm6HU1AxFdASTIweUlOpmKDU1QxGNwOTI'
      'ARWluhlKTc1QRP8vOXJAQ2lPh7xnCDmi7ZccOZST9nXI+2aQY7p9yZEDGkoHOuQDQ8gRTb7kyKGsdKhDPjSEHNHbS74r50JK5Gql'
      'yDWEHdHUS44dVFG9jBrSUUw3Lzl2SEc9rZB6hpQU08ZLjh1SUk8rpZ4hLcX075Jjh7TU04qpZ0hNMY275NghNfW0cuoZ0lNMxy45'
      'dkhPPa2geoYUNYAUNdAoagApqqeVVM+QpoaQpoYaTQ0gTfW0ouoZUlVMizT5wxcgvo914X1sKLpjOqPJkQPRfawL7mNDsR3TEE2O'
      'HHpMpwvtY0ORHdMHTY4ciOxjXWAfG4rrmPZncuRAXB/rwvrYUFTHdD2TIwei+lgX1MeGYjqm15kcORDTx7qQPjYV0REdzuTIgYg+'
      '1gX0sal4juhrJkcOZEljXZY0NpQlYbqZyZ+ou5ASuVopMpQlYbqYybEDKjrRqejEkIpiepfJkQMqOtGp6MSQimI6lsmRAyo60ano'
      'xJCKYvqUyZEDKjrRqejEkIpiupPJkQMqOtGp6MSQimJ6ksmRAyo60anoxJCKYjqRyZEDKjrRqejEkIpi+o/JkQMqOtGp6MSQimK6'
      'jsmRAyo60anoxJCKYnqNyU94uZASuVopMqSimB5jcuyAik51Kjo1pKKYzmJy5ICKTnUqOjWkoph+YnLkgIpOdSo6NaSimC5icuSA'
      'ik51Kjo1pKKY3mFy5ICKTnUqOjWkopiOYXLkgIpOdSo6NaSimD5hcuSAik51Kjo1pKKY7mBy5ICKTnUqOjWkopieYHLkgIpOdSo6'
      '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'
      'H/PRvRBwNpvT0eLLA02M2UmfZYF2Crq1U5tAf8nmNBHrj9whzrhMR+IjJBP/23PdfzVmMn1qBZos6tZkreLYUhxzh2aZ+DflzneD'
      '3Jip9CkUaKpe16baM4qJdaxISrgj/hVri3qJnz1thsmbwAWFNnYN1FYbmI9dfyppxsSMrJZf42oYmhtemPwINFXQranahK+TmzNn'
      'lbUYXHVhOoiDRoq6NVKrgHUsrJNXqwiR2LG8EH+lBocUoms5aK1e19baM2ZxZ8ZjmnDn5MqcwRC90kGDDTs12NbGAm4Ofs/yajl/'
      'm7FkSsTQqtanpwd7mGv9uPnpEfhHSuNbMrpvsSkhf4q+/vn1lgf0jtpOytIIsdlHuvKOldYA6lNxeeMyawD1KbC8m401gPq0U94o'
      'wBpAfWIHXI3TIgwMIdSnVMDFAmsI9RkMcCDWGkJ94gCchrKGELNMBw492cOIWB9rO1IDGHsyjE/rtmYgEetTbfPpJiDbGBKxKtS2'
      'me7ckIiVmLajdNeGBA/3Rvje0eYN+bJGEyvVI56OWbUfufXkSL86S58ei33iBRvnG3hLuvHOmOajjM2f16NnbEKyD8c0T6r/8W7D'
      'cPo11/PPnpO0FNnQRgrw/NMu9NMX4/G7LRtMEn5LkoOEZkUj+jOa52SyhHJd5WUz4lzRnFbGf79GJHIUNmdPi+0bLlK52ilPsYBf'
      'pzu9r1z5omH5CLChkWrgPvEHkT+ujn06dPZ0PgSCuH16ZBtjPZzLMb4YNiPpPUsn3wjj8OyxiWlbnXgsHuercUHTnNR2jB+pGGPV'
      'Q/7a9d4ZT4vpxkJ59Rj2ZHlEVvLQvvYKYvbr/dPqRFgbhmE3DPWZR8tjR204RhBHfy+O+uSl5ZmCNhxr7toiGbUjuY5/nCTX5UR8'
      'sLECtJqn+eq3aHy4fhV8VHctefN6FhWsSJaWPM2cOcmIc02rszPvoOh/8LB86rZ6L3EOsr854Vdn5JFmtXD4gm9re9Orfy2Jq+cu'
      '660X/6v6Xd2XMx2B9EzHSEg03bwJsDron5ZJ0k148eCBWSvOo3JNH+Oa/q5rzmky5RnJnBuaZWTMsxnonhu2dMvo+Zn84u+Ln7nO'
      'M712ngllnrmkaVztr+7hmxaBEXeUS+WbAcY3g13fiBVtxThzLh+vxZy4Bz1z4YyrYyTcWfziHLLJ8mgVwjGRqSmzj2NeAl3KV8Oq'
      '7RGp2v0ZKOghTlHttba5LkdiYVdb8NbWeUtgzoSkU/4vta3ejKqfaonX4yd7SQx/xurbvS8Dp1pTrpaUZrdTtyy84VrEYZm9bLvM'
      'AIjUtM9ZFVHadbARiVrZ9YikcZXriXTMkfyoiQ3hNibuKUw8BE083DXxMqI7n2g1ihdfMiY390FK/uBwh1SJr8imhLbTmJXOqHri'
      's60Jcj/sju8xSXKZIz5VgCBvvPygc82FYZp6A7H73cYbA4U3AtAbQVtvnLNJSRPn329IIkLw7//oiMkvRHo9UtXeGJryxvJnr8vb'
      'GcurR1ZmN/nb+KH+dLLULpdka6QnR5ymY3lIfz7IvMzJ/+gcLCeEmBnPJ/Fi7pzEJcli9YzYejC4hw++X25FrcbNriabeJgBaSxC'
      'ZOv7entmZnqdrZ0xR2iu3AOdaG613Pnd//w/Yq0s1vvvAQA=';
}
