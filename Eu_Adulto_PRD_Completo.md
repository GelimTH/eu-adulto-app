# Eu Adulto - PRD Completo

## 1. Visão do Produto
Eu Adulto é um assistente financeiro pessoal focado em jovens adultos que estão aprendendo a administrar dinheiro, quitar dívidas, construir reserva financeira e atingir metas de vida.

## 2. Objetivos
- Desenvolver consciência financeira
- Acompanhar gastos e dívidas
- Planejar o futuro financeiro
- Fornecer insights automáticos
- Incentivar hábitos saudáveis

---

# 3. Stack Tecnológica

## Mobile
- Flutter
- Dart

## Banco Local
- SQLite

## Gerenciamento de Estado
- Riverpod

## Arquitetura
- Clean Architecture
- Repository Pattern
- Feature First

---

# 4. Arquitetura de Pastas

```text
lib/
├── core/
├── shared/
├── features/
│   ├── dashboard/
│   ├── expenses/
│   ├── banks/
│   ├── cards/
│   ├── debts/
│   ├── installments/
│   ├── goals/
│   ├── reserve/
│   ├── reports/
│   ├── advisor/
│   └── settings/
├── database/
└── main.dart
```

---

# 5. Funcionalidades

## Dashboard
- Salário mensal
- Saldo disponível
- Regra 60/30/10 configurável
- Barras de progresso
- Resumo mensal
- Saúde financeira
- Visão rápida de dívidas
- Visão rápida de metas
- Visão rápida da reserva

## Gestão de Gastos
- Adicionar gasto
- Editar gasto
- Excluir gasto
- Histórico
- Filtro por categoria
- Filtro por período
- Classificação automática
- Registro de data e hora

## Gestão de Bancos
- Cadastro
- Edição
- Exclusão
- Associação com dívidas
- Associação com parcelamentos
- Concentração de dívidas
- Dependência por instituição

## Cartões
- Cadastro
- Limite total
- Limite disponível
- Fechamento
- Vencimento
- Histórico de faturas
- Gastos vinculados

## Parcelamentos
- Cadastro
- Parcela atual
- Parcelas restantes
- Linha do tempo
- Valor restante
- Encerramento previsto

## Empréstimos e Dívidas
- Cadastro
- Banco responsável
- Juros
- Parcelas
- Simulação de antecipação
- Economia de juros
- Quitação prevista

## Metas Financeiras
- Criar meta
- Editar meta
- Excluir meta
- Acompanhamento
- Prazo opcional

## Reserva Financeira
- Reserva atual
- Meta ideal
- Evolução histórica

## Compra Consciente
Classificações:
- Necessidade
- Conforto
- Impulso
- Recompensa emocional

## Futuro Eu
Ao registrar compra:
- Dias de trabalho necessários
- Percentual do salário
- Impacto na reserva
- Impacto nas metas
- Impacto nas dívidas

## Alertas Inteligentes
- Gastos excessivos
- Orçamento próximo do limite
- Parcela vencendo
- Dívida vencendo
- Meta atrasada
- Reserva baixa

## Planejamento Mensal
- Receitas previstas
- Despesas previstas
- Parcelas futuras
- Empréstimos futuros
- Projeções de saldo

## Conselheiro Financeiro
Mensagens automáticas:
- Você gastou 80% do orçamento de lazer
- Você está melhor que mês passado
- Antecipar dívida economiza dinheiro
- Compras por impulso aumentaram

---

# 6. Regras de Negócio

## Saldo Disponível

Saldo = Receitas - Gastos - Parcelas - Dívidas

## Saúde Financeira

Pontuação de 0 a 100 baseada em:
- Reserva
- Dívidas
- Parcelamentos
- Evolução mensal
- Percentual de gastos

### Classificação

- 0-39 Crítico
- 40-69 Atenção
- 70-89 Saudável
- 90-100 Excelente

## Reserva Ideal

Reserva Ideal = 6 x Média de Despesas Mensais

## Dependência Bancária

Dependência = (Dívida Banco / Dívida Total) * 100

---

# 7. Modelo de Dados

## Usuario

```sql
id
nome
salario_mensal
data_criacao
```

## Banco

```sql
id
nome
```

## Cartao

```sql
id
banco_id
nome
limite_total
fechamento
vencimento
```

## Gasto

```sql
id
valor
categoria
classificacao
descricao
data
banco_id
cartao_id
```

## Divida

```sql
id
banco_id
descricao
valor_original
valor_restante
juros
parcelas
```

## Parcela

```sql
id
divida_id
numero_atual
total_parcelas
valor
```

## Meta

```sql
id
nome
valor_alvo
valor_atual
prazo
```

## Reserva

```sql
id
valor_atual
```

---

# 8. Fluxos de Navegação

## Primeiro Acesso

1. Cadastro de nome
2. Cadastro de salário
3. Configuração 60/30/10
4. Dashboard

## Registrar Gasto

1. Inserir valor
2. Escolher categoria
3. Escolher banco/cartão
4. Escolher classificação emocional
5. Salvar

## Criar Meta

1. Nome
2. Valor alvo
3. Prazo
4. Salvar

---

# 9. Wireframes

## Dashboard

```text
+--------------------+
| Eu Adulto          |
+--------------------+
| Salário            |
| Saldo Disponível   |
+--------------------+
| Necessidades 60%   |
| Objetivos    30%   |
| Reserva      10%   |
+--------------------+
| Dívidas            |
| Metas              |
| Reserva            |
+--------------------+
```

---

# 10. Casos de Uso

## Registrar Gasto
Como usuário
Quero registrar um gasto
Para controlar meu dinheiro

## Criar Meta
Como usuário
Quero criar metas
Para acompanhar meus objetivos

## Registrar Dívida
Como usuário
Quero registrar dívidas
Para saber exatamente quanto devo

---

# 11. Critérios de Aceite QA

## Cadastro de Gasto

Dado que o usuário informe:
- valor
- categoria

Quando salvar

Então o sistema deve:
- persistir no SQLite
- atualizar dashboard
- recalcular indicadores

## Cadastro de Dívida

Dado um empréstimo

Quando salvo

Então deve:
- aparecer na lista
- impactar score financeiro

---

# 12. Roadmap

## V1
- Dashboard
- Gastos
- Bancos
- Dívidas
- Parcelamentos
- Metas
- Compra Consciente
- Futuro Eu

## V2
- Relatórios completos
- Alertas avançados
- Saúde financeira avançada

## V3
- Assistente conversacional
- IA local baseada em regras
- Insights comportamentais

## V4
- Open Finance
- Sincronização em nuvem
- Modo casal
- IA generativa

---

# 13. Missão

Transformar educação financeira em uma experiência simples, prática e acessível para jovens adultos que desejam assumir o controle da própria vida financeira.
