# Implementação do fluxo do Prestador de Serviços

**Data:** 2026-04-29
**Status:** Aprovado para implementação

## Contexto

O app já tem o fluxo do motorista totalmente integrado ao Supabase. O fluxo do prestador de serviços (não motorista) ainda usa dados mockados em três páginas: Solicitações de Serviço, Carteira e Perfil. Esta spec descreve a integração com o banco real seguindo o mesmo padrão arquitetural do motorista.

## Escopo

1. **Solicitações de Serviço** (`provider-home`): listar solicitações filtradas por categoria do prestador, com tabs Todos/Pendentes/Aceitos e ações Aceitar/Recusar.
2. **Carteira** (`provider-earnings`): refatorar para o mesmo layout da carteira do motorista, alimentada por `service_requests`.
3. **Perfil** (`provider-profile`): trocar mock por dados reais do `provider_profiles` + categorias.

## Arquitetura

Mantém o padrão existente:
- Models em `lib/core/models/`
- Services em `lib/core/services/` (Supabase direto, sem repositório intermediário, igual `DriverService`/`TripService`)
- Páginas em `lib/features/other_services/presentation/`
- `AuthState.providerProfileId` e `AuthState.userId` já populados no login

## Componentes

### 1. `lib/core/constants/category_colors.dart`

Extrai o mapa `_categoryColors` (hoje duplicado no `provider_profile_page.dart`) para constante compartilhada.

```dart
const Map<String, Color> kCategoryColors = { /* nome → cor */ };
Color categoryColorFor(String name) => kCategoryColors[name] ?? AppColors.secondary;
```

### 2. `lib/core/models/service_request_data.dart`

```dart
class ServiceRequestData {
  final String id;
  final String clientName;
  final String categoryName;
  final String? serviceCategoryId;
  final String description;
  final String address;
  final DateTime serviceDate;
  final double? estimatedPrice;
  final double? finalPrice;
  final String status; // service_request_status enum
  final String? providerProfileId;
  final bool isPaid;
  final DateTime createdAt;
  factory ServiceRequestData.fromMap(Map<String, dynamic> map);
}
```

Lê de `service_requests` com joins:
`*, service_categories(name), addresses(formatted_address), client:users!client_id(full_name)`.

### 3. `lib/core/models/provider_profile_data.dart`

```dart
class ProviderProfileData {
  final String userId;
  final String providerProfileId;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final double averageRating;
  final int totalRatings;
  final String? bio;
  final String? bankName;
  final String? bankAgency;
  final String? bankAccount;
  final String? bankAccountType;
  final String? pixKey;
  final List<String> serviceCategories;
  final DateTime createdAt;
  String get memberSince => createdAt.year.toString();
  factory ProviderProfileData.fromMap(Map<String, dynamic> map);
}
```

### 4. `lib/core/services/service_request_service.dart`

```dart
class ServiceRequestService {
  Future<List<ServiceRequestData>> getProviderRequests(String providerProfileId);
  Future<bool> acceptRequest(String requestId, String providerProfileId);
}
```

**`getProviderRequests`:**
1. Busca categorias do prestador em `provider_category_services` (`service_category_id`).
2. Busca em `service_requests`:
   - `service_category_id IN (categorias)` ou
   - `provider_profile_id == providerProfileId`
   - Ordena por `service_date asc`
3. Retorna lista combinada de pendentes (sem provider) e aceitas pelo prestador atual.

**`acceptRequest`:** `update { provider_profile_id, status: 'assigned' }` em `service_requests` por `id`.

**Recusar:** não persiste — apenas oculta na sessão atual (mesmo padrão de baixa fricção). Documentado no card.

### 5. `lib/core/services/provider_service.dart`

```dart
class ProviderService {
  Future<ProviderProfileData?> getProviderProfile(String userId);
  Future<EarningsData> getProviderEarnings(String providerProfileId);
}
```

**`getProviderProfile`:** select de `users` com `provider_profiles(*, provider_category_services(service_categories(name)))`. Constrói lista `serviceCategories` planificada.

**`getProviderEarnings`:** select de `service_requests` por `provider_profile_id`, retorna `EarningsData` (model já existente em `trip_service.dart`). Cria método `EarningsData.fromServiceRequests(...)` similar a `fromTrips`, usando `is_paid` em vez de `is_driver_paied` e `service_date` em vez de `scheduled_datetime`.

### 6. Página `service_requests_page.dart`

- `_load()`: usa `ServiceRequestService.getProviderRequests(AuthState.providerProfileId!)`.
- Filtro local:
  - "Todos" → tudo.
  - "Pendentes" → `providerProfileId == null`.
  - "Aceitos" → `providerProfileId == AuthState.providerProfileId`.
- Botões Aceitar/Recusar só quando `providerProfileId == null`.
- Aceitar: chama `acceptRequest`, mostra snackbar e recarrega.
- Recusar: oculta da lista local (mantém in-memory), snackbar.

### 7. Página `provider_earnings_page.dart`

Refatora para layout idêntico ao `earnings_page.dart` do motorista:
- Header "Carteira"
- `_BalanceCard` com "Valor a receber" (sem solicitar saque, alinhar com motorista)
- `_TotalReceivedCard`
- `EarningsChartCard` (já existente, reutilizado)
- `_BankInfoCard` (com dados reais do prestador)
- `_StatementSection`

Carrega via `ProviderService.getProviderEarnings()` + `getProviderProfile()` em paralelo.

### 8. Página `provider_profile_page.dart`

- Loading + RefreshIndicator (igual `profile_page.dart` do motorista).
- Carrega via `ProviderService.getProviderProfile(AuthState.userId!)`.
- Stats: avaliação real, total de serviços (`totalRatings`), "Desde {ano}".
- Seção "Categorias de serviço" com `serviceCategories` reais.
- Logout via `AppRouter.logout`.

## Out of scope

- Persistência de "recusas" (não há tabela própria).
- Edição de dados bancários e foto de perfil persistida.
- Push notifications de novas solicitações.
- Chat com cliente a partir do card de solicitação aceita.

## Riscos

- Mock LOGIN: `LOGIN_MOCK.md` pode não cobrir um prestador de serviço com categorias atribuídas. Verificar antes do teste manual.
- RLS: políticas devem permitir SELECT em `service_requests` por categoria. Caso negue, ajusta no plano.
