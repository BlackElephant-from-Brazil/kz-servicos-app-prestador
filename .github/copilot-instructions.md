# KZ Serviços - App Prestador

## Sobre o Projeto

App Flutter para prestadores de serviço (motoristas) da plataforma KZ Serviços. Existe um app separado para clientes. Por enquanto, todos os dados são mockados — integração com banco será feita no futuro.

## Stack

- **Linguagem:** Dart
- **Framework:** Flutter
- **State Management:** BLoC/Cubit (flutter_bloc)
- **Navegação:** GoRouter
- **DI:** GetIt + Injectable
- **Models:** Freezed
- **Testes:** flutter_test + mocktail
- **Análise:** dart analyze com regras estritas

## Comandos

```bash
# Instalar dependências
flutter pub get

# Rodar testes
flutter test

# Análise estática
flutter analyze

# Build
flutter build apk --debug

# Gerar código (freezed, injectable, etc.)
dart run build_runner build --delete-conflicting-outputs
```

## Convenções

- **Código:** Inglês (nomes de variáveis, classes, funções)
- **UI/Comentários:** Português (textos de tela, comentários de negócio)
- **Commits:** Português, formato convencional (`feat:`, `fix:`, `refactor:`, `test:`, `docs:`)
- **Arquitetura:** Clean Architecture (data → domain → presentation)
- **Testes:** TDD obrigatório — teste falhando antes de código
- **Dados:** Todos mockados com repositórios mock implementando interfaces

## Features do App

1. **Cadastro do Prestador**: autocadastro com documentos (RG, CNH, comprovante), foto pessoal com orientações, aprovação de docs
2. **Veículos**: cadastro com CRLV, fotos com dicas, informações do veículo
3. **Corridas**: tela de disponíveis, aceitar com observação, fluxo completo de viagem
4. **Chat**: comunicação direta com cliente durante viagem
5. **Notificações**: push notifications para corridas e status
6. **Perfil**: dados de pagamento, faturamento, configurações

## Fluxo de Viagem

```
criação → análise → aguardando_motoristas → aguardando_cliente_aceitar →
confirmação_central → pagamento → agendado → iniciada → finalizada
```

## Skills Disponíveis

Este projeto usa skills baseadas no framework Superpowers:
- `brainstorming` — antes de qualquer feature nova
- `writing-plans` — antes de implementar
- `test-driven-development` — durante implementação
- `systematic-debugging` — para bugs
- `executing-plans` — executar planos
- `verification-before-completion` — antes de afirmar conclusão
- `requesting-code-review` / `receiving-code-review` — reviews
- `subagent-driven-development` — execução com subagentes
- `dispatching-parallel-agents` — tarefas paralelas independentes
- `finishing-a-development-branch` — finalizar branches
