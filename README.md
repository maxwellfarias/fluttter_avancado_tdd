# Flutter Avançado - TDD & Clean Architecture

![Flutter Version](https://img.shields.io/badge/Flutter-3.27.0-02569B?logo=flutter)
![Dart Version](https://img.shields.io/badge/Dart-3.5.4+-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)
![Tests](https://img.shields.io/badge/Tests-14%20files-success)

Projeto Flutter de referência demonstrando a aplicação prática de **Test-Driven Development (TDD)** com **Clean Architecture**, seguindo os princípios SOLID e boas práticas de engenharia de software.

## 📋 Sobre o Projeto

Este projeto implementa um aplicativo para visualização de eventos esportivos (futebol), exibindo informações sobre confirmação de jogadores, posições e status de participação. O foco principal está na **arquitetura**, **testabilidade** e **qualidade de código**.

### Características Principais

- ✅ **100% testado** com TDD (14 arquivos de teste)
- 🏗️ **Clean Architecture** com separação clara de camadas
- 🎯 **MVP Pattern** na camada de apresentação
- 🔄 **Programação Reativa** com RxDart
- 💾 **Cache local** com fallback automático
- 🌐 **Integração com API REST**
- 🧩 **Dependency Injection** com Factory Pattern
- 📱 **Suporte multiplataforma** (iOS, Android, Web, Desktop)

## 🏛️ Arquitetura

O projeto segue os princípios da Clean Architecture dividida em 4 camadas:

```
┌─────────────────────────────────────────┐
│          UI Layer (Flutter)             │
│   - Pages (StatefulWidget)              │
│   - Components (StatelessWidget)        │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│      Presentation Layer (MVP)           │
│   - Presenters (Business Logic)         │
│   - ViewModels (UI State)               │
│   - RxDart Streams                      │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│     Infrastructure Layer (Data)         │
│   - API Repositories                    │
│   - Cache Repositories                  │
│   - Adapters (HTTP, Cache)              │
│   - Mappers (JSON ↔ Entity)             │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│       Domain Layer (Core)               │
│   - Entities (Business Models)          │
│   - Errors (Domain Exceptions)          │
│   - Interfaces (Contracts)              │
└─────────────────────────────────────────┘
```

### Padrões de Design Implementados

| Padrão | Aplicação |
|--------|-----------|
| **MVP** | Separação entre lógica de apresentação e UI |
| **Repository** | Abstração das fontes de dados |
| **Factory** | Injeção de dependências no composition root |
| **Adapter** | Wrapper para bibliotecas externas (HTTP, Cache) |
| **Strategy** | Múltiplas implementações (API vs Cache) |
| **Observer** | RxDart Subjects para gerenciamento de estado |
| **Sealed Class** | Error handling type-safe |

## 📁 Estrutura de Pastas

```
lib/
├── domain/              # Camada de domínio (regras de negócio)
│   └── entities/        # Entidades puras
│
├── infra/               # Camada de infraestrutura (dados)
│   ├── api/            # Comunicação HTTP
│   ├── cache/          # Cache local
│   ├── mappers/        # Transformação de dados
│   └── repositories/   # Implementação dos repositórios
│
├── presentation/        # Camada de apresentação (MVP)
│   ├── presenters/     # Interfaces do presenter
│   └── rx/             # Implementação com RxDart
│
├── ui/                  # Camada de interface
│   ├── pages/          # Telas do app
│   └── components/     # Componentes reutilizáveis
│
├── main/                # Composition root
│   ├── main.dart       # Entry point
│   └── factories/      # Factories para DI
│
└── test/                # Testes (espelha estrutura do lib/)
    ├── domain/
    ├── infra/
    ├── presentation/
    ├── ui/
    ├── e2e/            # Testes end-to-end
    └── mocks/          # Test doubles (spies, fakes)
```

## 🚀 Começando

### Pré-requisitos

- Flutter 3.27.0 ou superior
- Dart 3.5.4 ou superior
- FVM (recomendado para gerenciamento de versões)

### Instalação

1. Clone o repositório:
```bash
git clone https://github.com/seu-usuario/flutter_avancado_tdd.git
cd flutter_avancado_tdd
```

2. Instale as dependências:
```bash
flutter pub get
```

3. Execute o backend mock (opcional, para testar com API):
```bash
cd backend
npm install
npm start
```

4. Execute o aplicativo:
```bash
flutter run
```

## 🧪 Testes

O projeto possui **cobertura completa de testes** seguindo a metodologia TDD.

### Executar todos os testes:
```bash
flutter test
```

### Executar testes com cobertura:
```bash
flutter test --coverage
```

### Estrutura de Testes

| Tipo | Quantidade | Descrição |
|------|------------|-----------|
| **Unit Tests** | 8 | Testes de mappers, repositórios, adapters |
| **Widget Tests** | 5 | Testes de componentes e páginas |
| **E2E Tests** | 1 | Teste de integração completo |

**Estratégias de Teste:**
- ✅ Spy Pattern para verificação de chamadas
- ✅ Fake Data para testes de entidades
- ✅ Stream testing com `expectLater`
- ✅ Widget testing com `tester.pumpWidget`
- ✅ Sem frameworks de mock (Mockito) - spies customizados

## 📦 Principais Dependências

### Produção
- `http: ^1.2.2` - Cliente HTTP
- `rxdart: ^0.28.0` - Programação reativa
- `flutter_cache_manager: ^3.4.1` - Gerenciamento de cache
- `dartx: ^1.2.0` - Extensões Dart úteis
- `awesome_flutter_extensions: ^1.3.0` - Helpers de UI

### Desenvolvimento
- `flutter_test` - Framework de testes
- `flutter_lints: ^4.0.0` - Regras de lint

## 🔄 Fluxo de Dados

```
User Interaction
      ↓
   UI Page (StreamBuilder)
      ↓
   Presenter (RxDart)
      ↓
   Repository (API + Cache Fallback)
      ├→ HTTP Adapter → API REST
      └→ Cache Adapter → Local Storage
```

### Estratégia de Cache

1. **Tenta buscar da API** primeiro
2. Se bem-sucedido: **salva no cache**
3. Se falhar: **busca do cache** (fallback)
4. Exibe dados ou erro ao usuário

## 🎨 Features Implementadas

### Tela de Próximo Evento
- ✅ Carregamento de evento por grupo
- ✅ Exibição de jogadores por categoria:
  - Goleiros confirmados
  - Jogadores de linha confirmados
  - Jogadores que recusaram
  - Jogadores sem resposta
- ✅ Avatar com foto ou iniciais automáticas
- ✅ Tradução de posições para PT-BR
- ✅ Indicador de status de confirmação
- ✅ Pull-to-refresh
- ✅ Tratamento de erros com retry
- ✅ Loading states

## 🔧 Configuração

### FVM (Flutter Version Management)

O projeto usa FVM para garantir consistência da versão do Flutter:

```json
{
  "flutter": "3.27.0"
}
```

### Editor Config

Arquivo `.editorconfig` garante formatação consistente entre editores.

## 📚 Conceitos Avançados Demonstrados

### 1. Clean Architecture
- Separação clara de responsabilidades
- Dependências apontando para dentro (domain)
- Camadas independentes e testáveis

### 2. Test-Driven Development (TDD)
- Red → Green → Refactor
- Testes escritos antes da implementação
- Alta cobertura de testes

### 3. SOLID Principles
- **S**ingle Responsibility: Classes com responsabilidade única
- **O**pen/Closed: Extensível via interfaces
- **L**iskov Substitution: Contratos bem definidos
- **I**nterface Segregation: Interfaces específicas
- **D**ependency Inversion: Dependência de abstrações

### 4. Reactive Programming
- Streams como fonte única de verdade
- BehaviorSubject para estado reativo
- Programação declarativa com StreamBuilder

### 5. Error Handling
- Sealed classes para erros type-safe
- Tratamento específico por tipo de erro (401, unexpected)
- UI resiliente com fallbacks

## 🤝 Contribuindo

Contribuições são bem-vindas! Este é um projeto educacional, então sinta-se à vontade para:

1. Fazer fork do projeto
2. Criar uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abrir um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

## 👨‍💻 Autor

**Maxwell Farias**

## 🙏 Agradecimentos

Este projeto foi desenvolvido como material de estudo para demonstrar boas práticas de desenvolvimento Flutter avançado, incluindo:
- Clean Architecture
- Test-Driven Development
- Reactive Programming
- Dependency Injection
- Design Patterns

---

**⭐ Se este projeto foi útil para você, considere dar uma estrela!**