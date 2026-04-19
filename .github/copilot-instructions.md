# KZ Serviços - App Prestador

## Projeto
App Flutter para prestadores/motoristas da KZ Serviços. Foco em recebimento e execução de serviços de transporte/viagens e "outros serviços".

## Stack
- **Framework:** Flutter (Dart)
- **State Management:** A definir (Bloc/Cubit ou Riverpod)
- **Navegação:** GoRouter
- **Mapas:** Google Maps Flutter
- **Notificações:** Firebase Cloud Messaging (FCM)
- **Chat:** Mensagens em tempo real (sem banco de dados externo inicialmente)
- **Arquitetura:** Clean Architecture com separação de camadas

## Idioma
- Código em inglês (variáveis, funções, classes, comentários)
- UI/UX em português brasileiro (textos, labels, mensagens)
- Comunicação com o desenvolvedor em português brasileiro

## Convenções de Código
- Seguir o [Effective Dart](https://dart.dev/effective-dart)
- Nomes de arquivos em snake_case
- Nomes de classes em PascalCase
- Nomes de variáveis e funções em camelCase
- Widgets em arquivos separados, um widget por arquivo
- Máximo 300 linhas por arquivo — dividir se necessário
- Usar `const` sempre que possível
- Preferir composição a herança

## Estrutura do Projeto
```
lib/
  core/              # Constantes, temas, utils, widgets compartilhados
    constants/
    theme/
    utils/
    widgets/
  features/          # Cada feature é independente
    auth/
    home/
    trip/            # Serviço de viagem/corrida (perspectiva do prestador)
      data/
        models/
        repositories/
      domain/
        entities/
        usecases/
      presentation/
        pages/
        widgets/
        bloc/
    other_services/  # Outros serviços
    chat/            # Chat com a central KZ Serviços
    earnings/        # Ganhos e extrato
    notifications/
    payment/
    profile/
  l10n/              # Internacionalização
  routes/            # Configuração de rotas
```

## Ciclo de Vida da Viagem (Prestador)
```
nova_solicitação → análise → aceitar/recusar → a_caminho → chegou →
corrida_iniciada → corrida_finalizada → avaliação
```

Cada estado deve ter sua própria representação visual e lógica de transição.

## Ganhos
- Extrato detalhado por corrida
- Saldo disponível para saque
- Comparação com mês anterior
- Dados bancários para recebimento

## Regras Importantes
- **NÃO conectar com banco de dados inicialmente** — usar dados mockados/locais
- Validação de endereços obrigatória
- Notificações push para novas solicitações e mudanças de status
- Mapa em tempo real mostrando rota até o cliente
- Preset de mensagens no chat ("Estou chegando", "Cheguei no local", etc.)
- Botão de atendimento WhatsApp (número a definir)
- Toggle online/offline para disponibilidade

## Cadastro do Prestador
Campos obrigatórios:
1. Nome completo
2. CPF
3. CNH (número e validade)
4. Dados do veículo (placa, modelo, ano, cor)
5. Foto do veículo
6. Foto do documento (CNH)
7. Dados bancários (banco, agência, conta)
8. Telefone
9. E-mail

## Workflow de Desenvolvimento
Usar as skills do Superpowers para todo desenvolvimento:
1. **brainstorming** — antes de qualquer feature nova
2. **writing-plans** — criar plano detalhado de implementação
3. **test-driven-development** — TDD obrigatório
4. **executing-plans** ou **subagent-driven-development** — execução do plano
5. **systematic-debugging** — para qualquer bug
6. **verification-before-completion** — antes de marcar como pronto

## Testes
- Testes unitários para toda lógica de negócio
- Testes de widget para componentes visuais
- Usar `mocktail` para mocks
- Mínimo 80% de cobertura nas features críticas (trip, payment, chat)
