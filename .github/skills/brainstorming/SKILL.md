---
name: brainstorming
description: "Você DEVE usar isto antes de qualquer trabalho criativo - criar features, construir componentes, adicionar funcionalidades ou modificar comportamento. Explora intenção do usuário, requisitos e design antes da implementação."
---

# Brainstorming - Transformando Ideias em Designs

Ajude a transformar ideias em designs completos através de diálogo colaborativo natural.

Comece entendendo o contexto atual do projeto, depois faça perguntas uma de cada vez para refinar a ideia. Quando entender o que deve ser construído, apresente o design e obtenha aprovação do usuário.

<HARD-GATE>
NÃO invoque nenhuma skill de implementação, escreva código, scaffolde projeto ou tome qualquer ação de implementação até ter apresentado um design e o usuário ter aprovado. Isso se aplica a TODOS os projetos, independente da simplicidade aparente.
</HARD-GATE>

## Anti-Padrão: "Isso é Simples Demais Para Precisar de Design"

Todo projeto passa por este processo. Um todo list, uma função utilitária, uma mudança de config — todos. "Simples" é onde suposições não examinadas causam mais retrabalho. O design pode ser curto (poucas frases para projetos realmente simples), mas você DEVE apresentá-lo e obter aprovação.

## Checklist

Você DEVE criar uma tarefa para cada item e completá-los em ordem:

1. **Explorar contexto do projeto** — verificar arquivos, docs, commits recentes
2. **Fazer perguntas de esclarecimento** — uma de cada vez, entender propósito/restrições/critérios de sucesso
3. **Propor 2-3 abordagens** — com trade-offs e sua recomendação
4. **Apresentar design** — em seções proporcionais à complexidade, obter aprovação após cada seção
5. **Escrever doc de design** — salvar em `docs/specs/YYYY-MM-DD-<topico>-design.md` e commitar
6. **Auto-revisão da spec** — verificar placeholders, contradições, ambiguidade, escopo
7. **Usuário revisa spec escrita** — pedir ao usuário para revisar antes de prosseguir
8. **Transição para implementação** — invocar a skill writing-plans

## O Processo

**Entendendo a ideia:**
- Verifique o estado atual do projeto (arquivos, docs, commits recentes)
- Faça perguntas uma de cada vez para refinar a ideia
- Prefira perguntas de múltipla escolha quando possível
- Apenas uma pergunta por mensagem
- Foque em entender: propósito, restrições, critérios de sucesso

**Explorando abordagens:**
- Proponha 2-3 abordagens diferentes com trade-offs
- Apresente opções conversacionalmente com sua recomendação e raciocínio
- Lidere com a opção recomendada e explique o porquê

**Apresentando o design:**
- Apresente o design quando entender o que será construído
- Dimensione cada seção à sua complexidade
- Pergunte após cada seção se está correto
- Cubra: arquitetura, componentes, fluxo de dados, tratamento de erros, testes
- Esteja pronto para voltar e esclarecer

**Design para isolamento e clareza:**
- Quebre o sistema em unidades menores com propósito claro
- Interfaces bem definidas entre componentes
- Cada unidade deve ser compreensível e testável independentemente

## Após o Design

**Documentação:**
- Escreva o design validado em `docs/specs/YYYY-MM-DD-<topico>-design.md`
- Commite o documento de design

**Auto-Revisão da Spec:**
1. **Scan de placeholders:** "TBD", "TODO", seções incompletas? Corrija.
2. **Consistência interna:** Seções se contradizem? Arquitetura bate com features?
3. **Verificação de escopo:** Focado o suficiente para um único plano?
4. **Verificação de ambiguidade:** Algum requisito com dupla interpretação? Escolha um e explicite.

**Implementação:**
- Invoque a skill writing-plans para criar o plano de implementação

## Princípios-Chave

- **Uma pergunta por vez** - Não sobrecarregue
- **Múltipla escolha quando possível** - Mais fácil de responder
- **YAGNI implacável** - Remova features desnecessárias
- **Explore alternativas** - Sempre proponha 2-3 abordagens
- **Validação incremental** - Apresente design, obtenha aprovação
- **Seja flexível** - Volte e esclareça quando algo não fizer sentido
