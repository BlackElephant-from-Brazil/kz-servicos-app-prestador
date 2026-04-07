---
name: test-driven-development
description: "Use quando implementar qualquer feature ou bugfix, antes de escrever código de implementação"
---

# Test-Driven Development (TDD)

## Visão Geral

Escreva o teste primeiro. Veja falhar. Escreva código mínimo para passar.

**Princípio central:** Se você não viu o teste falhar, não sabe se testa a coisa certa.

**Violar a letra das regras é violar o espírito das regras.**

## Quando Usar

**Sempre:**
- Novas features
- Correções de bugs
- Refatoração
- Mudanças de comportamento

**Exceções (pergunte ao usuário):**
- Protótipos descartáveis
- Código gerado
- Arquivos de configuração

## A Lei de Ferro

```
NENHUM CÓDIGO DE PRODUÇÃO SEM UM TESTE FALHANDO PRIMEIRO
```

Escreveu código antes do teste? Delete. Comece de novo.

**Sem exceções:**
- Não guarde como "referência"
- Não "adapte" enquanto escreve testes
- Não olhe para ele
- Deletar significa deletar

## Red-Green-Refactor

### RED - Escreva Teste Falhando

Escreva um teste mínimo mostrando o que deveria acontecer.

**Requisitos:**
- Um comportamento
- Nome claro
- Código real (mocks apenas se inevitável)

### Verifique RED - Veja Falhar

**OBRIGATÓRIO. Nunca pule.**

```bash
flutter test path/to/test.dart
```

Confirme:
- Teste falha (não erro)
- Mensagem de falha é esperada
- Falha porque feature está faltando (não typos)

### GREEN - Código Mínimo

Escreva o código mais simples para passar o teste. Não adicione features, refatore outro código ou "melhore" além do teste.

### Verifique GREEN - Veja Passar

**OBRIGATÓRIO.**

```bash
flutter test path/to/test.dart
```

Confirme:
- Teste passa
- Outros testes ainda passam
- Output limpo (sem erros, warnings)

### REFACTOR - Limpe

Após green apenas:
- Remova duplicação
- Melhore nomes
- Extraia helpers

Mantenha testes verdes. Não adicione comportamento.

### Repita

Próximo teste falhando para a próxima feature.

## Bons Testes

| Qualidade | Bom | Ruim |
|-----------|-----|------|
| **Mínimo** | Uma coisa. "e" no nome? Divida. | `test('valida email e domínio e espaço')` |
| **Claro** | Nome descreve comportamento | `test('test1')` |
| **Mostra intenção** | Demonstra API desejada | Obscurece o que código deve fazer |

## Racionalizações Comuns

| Desculpa | Realidade |
|----------|-----------|
| "Simples demais para testar" | Código simples quebra. Teste leva 30 segundos. |
| "Vou testar depois" | Testes passando imediatamente não provam nada. |
| "Preciso explorar primeiro" | Ok. Jogue fora exploração, comece com TDD. |
| "TDD vai me atrasar" | TDD mais rápido que debugar. |

## Red Flags - PARE e Recomece

- Código antes de teste
- Teste após implementação
- Teste passa imediatamente
- Não consegue explicar por que teste falhou
- "Só dessa vez"

**Todos significam: Delete o código. Recomece com TDD.**

## Checklist de Verificação

Antes de marcar trabalho como completo:

- [ ] Toda nova função/método tem um teste
- [ ] Assistiu cada teste falhar antes de implementar
- [ ] Cada teste falhou pela razão esperada
- [ ] Escreveu código mínimo para passar cada teste
- [ ] Todos os testes passam
- [ ] Output limpo
- [ ] Testes usam código real (mocks apenas se inevitável)
- [ ] Edge cases e erros cobertos
