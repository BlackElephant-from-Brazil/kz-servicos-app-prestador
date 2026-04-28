# KZ Serviços — App Prestador

## Contexto do Projeto

App mobile Flutter para **prestadores de serviço** (motoristas/parceiros) da plataforma KZ Serviços. Existe um app separado para clientes. O banco de dados é compartilhado via Supabase — **por enquanto os dados do app Flutter são mockados**, mas a estrutura deve preparar para integração real futura.

## Referência do Banco de Dados

A referência completa do banco de dados Supabase está em `.claude/kz-database/`:
- **`.claude/kz-database/SKILL.md`** — visão geral: tabelas, enums, padrões de query, RLS, Realtime
- **`.claude/kz-database/references/schema.md`** — todas as colunas e constraints
- **`.claude/kz-database/references/rls-policies.md`** — políticas de segurança
- **`.claude/kz-database/references/triggers.md`** — triggers e funções
- **`.claude/kz-database/references/api-endpoints.md`** — endpoints REST

**Ler esses arquivos SEMPRE que** tocar dados, queries, migrações, forms, ou qualquer feature que leia/grave no banco.

## Skills Obrigatórias

**SEMPRE invocar as seguintes skills antes de agir:**

| Skill | Quando Usar |
|-------|-------------|
| `superpowers:brainstorming` | Antes de qualquer feature nova — explorar design e requisitos |
| `superpowers:writing-plans` | Após brainstorming — criar plano detalhado |
| `superpowers:executing-plans` | Executar plano com checkpoints |
| `superpowers:subagent-driven-development` | Executar plano com subagents (preferencial) |
| `superpowers:test-driven-development` | SEMPRE durante implementação — RED-GREEN-REFACTOR |
| `superpowers:systematic-debugging` | Qualquer bug ou comportamento inesperado |
| `superpowers:verification-before-completion` | Antes de marcar qualquer trabalho como completo |
| `superpowers:requesting-code-review` | Após completar tasks ou features |
| `superpowers:receiving-code-review` | Ao receber feedback de review |
| `superpowers:dispatching-parallel-agents` | Quando há 2+ tasks independentes |
| `superpowers:using-git-worktrees` | Para isolar trabalho em branches |
| `superpowers:finishing-a-development-branch` | Quando implementação está completa |

## Funcionalidades Principais

**Cadastro do Prestador (autocadastro):**
- Dados pessoais e documentos: RG, CNH, Comprovante de Residência (upload de fotos)
- Foto pessoal com orientações (fundo neutro, iluminação, enquadramento)
- Processo de aprovação de documentos/fotos (status: pendente, aprovado, rejeitado)
- Dados de pagamento: máquina de cartão? pagamento por aproximação? emite NF? emite recibo?
- Dados de depósito e faturamento

**Cadastro de Veículos:**
- Documento do veículo (foto do CRLV)
- Fotos do veículo com dicas (frente, traseira, lateral, interior)
- Informações do veículo (modelo, ano, cor, placa)

**Fluxo de Viagem:**
```
open → under_review → review_rejected → searching_drivers → awaiting_client_confirmation →
awaiting_driver_confirmation → scheduled → started → finished | cancelled
```

**Corridas Disponíveis:**
- Listagem de corridas disponíveis para aceitar
- Motorista pode adicionar observação ao aceitar viagem
- Comentários na viagem (público e privado)

**Comunicação:**
- Notificações push
- Chat direto com o cliente durante viagem

## Arquitetura

- **Clean Architecture** adaptada para Flutter (presentation, domain, data layers)
- **State management**: BLoC/Cubit (`flutter_bloc`)
- **Navegação**: GoRouter
- **Injeção de dependência**: GetIt + Injectable
- Repositórios com **interface + implementação mock** — preparados para API real
- Models com `freezed`, estados com `freezed`, simples com `equatable`

## Estrutura de Pastas

```
lib/
├── app/                    # App config, tema, rotas
├── core/                   # Utilitários, constantes, extensões
├── features/
│   ├── auth/
│   ├── onboarding/         # Cadastro, documentos, aprovação
│   ├── vehicles/           # Cadastro e gestão de veículos
│   ├── rides/              # Corridas, fluxo de viagem
│   ├── chat/               # Chat com cliente
│   ├── notifications/      # Push notifications
│   └── profile/            # Perfil, configurações
└── shared/                 # Widgets compartilhados, tema
```

Cada feature:
```
feature/
├── data/
│   ├── models/
│   ├── repositories/       # Implementações mock
│   └── datasources/
├── domain/
│   ├── entities/
│   ├── repositories/       # Interfaces
│   └── usecases/
└── presentation/
    ├── bloc/ (ou cubit/)
    ├── pages/
    └── widgets/
```

## Padrões de Código

- Dart com análise estrita (`analysis_options.yaml`)
- Nomes de variáveis, classes e funções em **inglês**
- Comentários e textos de UI em **português**
- Widgets pequenos — máximo ~200 linhas por arquivo
- Separe lógica de negócio de UI sempre

## UI/UX

- Material Design 3 com tema personalizado KZ
- Responsivo para diferentes tamanhos de tela
- Acessibilidade: labels semânticos, contraste adequado
- Feedback visual claro (loading states, erros, sucesso)
- Orientações visuais para upload de fotos
- Cores da marca KZ com modo claro (dark mode futuro)

## Restrições

- NÃO conecte a APIs reais — tudo mockado no app Flutter
- NÃO adicione dependências desnecessárias — YAGNI
- NÃO crie código sem teste falhando primeiro (TDD)
- NÃO faça over-engineering
- NÃO pule o brainstorming para features novas
- SEMPRE verifique `flutter test` e `flutter analyze` antes de afirmar conclusão
- SEMPRE commite frequentemente com mensagens claras em português

## Workflow Padrão

1. Feature nova → skill `superpowers:brainstorming`
2. Com spec/requisitos → skill `superpowers:writing-plans`
3. Implementando → skill `superpowers:test-driven-development` + `superpowers:executing-plans`
4. Bug → skill `superpowers:systematic-debugging`
5. Completou tarefa → skill `superpowers:verification-before-completion`
6. Review → skill `superpowers:requesting-code-review`
7. Qualquer dado/query/form → ler `.claude/kz-database/SKILL.md` e referências
