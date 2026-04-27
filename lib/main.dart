import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kz_servicos_prestador/core/theme/app_theme.dart';
import 'package:kz_servicos_prestador/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Inicializar Supabase (temporariamente comentado para evitar erro de API key)
  try {
    await Supabase.initialize(
      url: 'https://wmlsiwjrgjygqdjtsayt.supabase.co',
      anonKey: 'sb_publishable_Uczyit6MEzgq3grhCVqmaA_vT0m5EVS',
      debug: true,
    );
  } catch (e) {
    // Se falhar a inicialização do Supabase, continuar sem ele por enquanto
    debugPrint('Erro ao inicializar Supabase: $e');
  }
  
  runApp(const KzPrestadorApp());
}

class KzPrestadorApp extends StatelessWidget {
  const KzPrestadorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'KZ Serviços Prestador',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
      locale: const Locale('pt', 'BR'),
    );
  }
}
