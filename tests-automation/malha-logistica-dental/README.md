# 🎯 qa-robot-api-cotacao - Automação de API (Robot Framework)

Este repositório contém a suíte de testes automatizados para validação de contratos e regras de negócio de APIs de cotação de frete e logística, utilizando **Robot Framework** e **RequestsLibrary**.

---

## 📁 Estrutura do Projeto
```text
automacao-api/
├── tests/                  # Cenários de teste (.robot)
├── resources/              # Ações e configurações reutilizáveis
├── RELATORIO-INCIDENTES.md # Relatório técnico de conformidade
└── README.md               # Documentação principal
```

---

## 🛠️ Pré-requisitos Locais
* Python 3.10+
* Dependências: `pip install -r requirements.txt`

---

## 💻 Como Rodar
1. **Executar tudo:** `robot -d results tests/`
2. **Executar teste isolado:** `robot -d results tests/seu_teste.robot`

---

## 📊 Relatório de Incidentes (Swagger vs. API Real)
Foi gerada uma documentação técnica mapeando **4 incidentes reais de não-conformidade**, além de ajustes nos scripts de teste (falsos positivos).

👉 **[Clique aqui para ler o Relatório Técnico de Incidentes Completo](RELATORIO-INCIDENTES.md)**

---

## 🔄 Segurança
* Dados de autenticação e variáveis de ambiente são mantidos protegidos via `.gitignore`.
