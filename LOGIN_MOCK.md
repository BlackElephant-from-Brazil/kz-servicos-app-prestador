# Sistema de Login Mock - KZ Serviços Prestador

Enquanto a API key do Supabase não estiver configurada corretamente, o sistema usa autenticação mock.

## Credenciais de Teste

### Motorista
- **E-mail:** `motorista@kz.com`
- **Senha:** `123456`

### Prestador de Outros Serviços  
- **E-mail:** `prestador@kz.com`
- **Senha:** `123456`

### Conta do Print (Motorista)
- **E-mail:** `teste@teste.com`
- **Senha:** `123456`

## Funcionalidades Implementadas

✅ **Login apenas para prestadores/motoristas**  
✅ **Proteção de rotas** - redirect automático para login se não autenticado  
✅ **Diferenciação automática** entre motorista e prestador  
✅ **Logout funcional** na tela de perfil  
✅ **Estados de loading** e tratamento de erros  

## Próximos Passos

1. Configurar credenciais corretas do Supabase
2. Descomentar código real de autenticação em `AuthService`  
3. Remover sistema mock
4. Testar com dados reais do banco KZ Serviços