---
name: writing-plans
description: "Use quando tiver uma spec ou requisitos para uma tarefa de múltiplos passos, antes de tocar no código"
---

# Escrevendo Planos de Implementação

## Visão Geral

Escreva planos de implementação abrangentes assumindo que o engenheiro tem zero contexto do codebase. Documente tudo: quais arquivos tocar em cada tarefa, código, testes, docs a verificar, como testar. DRY. YAGNI. TDD. Commits frequentes.

**Anuncie no início:** "Estou usando a skill writing-plans para criar o plano de implementação."

**Salve planos em:** `docs/plans/YYYY-MM-DD-<nome-feature>.md`

## Estrutura de Arquivos

Antes de definir tarefas, mapeie quais arquivos serão criados ou modificados. Cada arquivo deve ter uma responsabilidade clara.

## Granularidade das Tarefas

**Cada passo é uma ação (2-5 minutos):**
- "Escrever o teste falhando" - passo
- "Rodar para ver falhar" - passo
- "Implementar código mínimo" - passo
- "Rodar testes e confirmar que passam" - passo
- "Commitar" - passo

## Header do Documento

**Todo plano DEVE começar com:**

```markdown
# [Nome da Feature] - Plano de Implementação

**Objetivo:** [Uma frase descrevendo o que será construído]

**Arquitetura:** [2-3 frases sobre a abordagem]

**Tech Stack:** [Tecnologias/bibliotecas principais]

---
```

## Estrutura das Tarefas

````markdown
### Tarefa N: [Nome do Componente]

**Arquivos:**
- Criar: `caminho/exato/arquivo.dart`
- Modificar: `caminho/existente.dart:123-145`
- Teste: `test/caminho/test_arquivo.dart`

- [ ] **Passo 1: Escrever o teste falhando**

```dart
testWidgets('comportamento específico', (tester) async {
  // código do teste
});
```

- [ ] **Passo 2: Rodar teste para verificar que falha**

Run: `flutter test test/caminho/test_arquivo.dart`
Esperado: FAIL

- [ ] **Passo 3: Implementar código mínimo**

```dart
// implementação
```

- [ ] **Passo 4: Rodar teste para verificar que passa**

Run: `flutter test test/caminho/test_arquivo.dart`
Esperado: PASS

- [ ] **Passo 5: Commitar**

```bash
git add test/caminho/ lib/caminho/
git commit -m "feat: adiciona feature específica"
```
````

## Sem Placeholders

Todo passo deve conter o conteúdo real. Estes são **falhas do plano** — nunca escreva:
- "TBD", "TODO", "implementar depois"
- "Adicione tratamento de erro apropriado"
- "Escreva testes para o acima" (sem código real)
- "Similar à Tarefa N" (repita o código)

## Lembre-se

- Caminhos de arquivo exatos sempre
- Código completo em todo passo
- Comandos exatos com output esperado
- DRY, YAGNI, TDD, commits frequentes

## Auto-Revisão

Após escrever o plano completo:

1. **Cobertura da spec:** Cada requisito tem uma tarefa?
2. **Scan de placeholders:** Algum red flag da seção "Sem Placeholders"?
3. **Consistência de tipos:** Nomes, métodos e propriedades são consistentes entre tarefas?

Se encontrar problemas, corrija inline.

## Handoff de Execução

Após salvar o plano:

**"Plano completo e salvo em `docs/plans/<arquivo>.md`. Duas opções de execução:**

**1. Subagent-Driven (recomendado)** - Subagente fresco por tarefa, review entre tarefas

**2. Execução Inline** - Executa tarefas na sessão atual com checkpoints

**Qual abordagem?"**
