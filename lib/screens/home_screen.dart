import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/secure_storage_service.dart';
import '../config/app_modules.dart';
import '../theme/app_colors.dart';
import 'amount_pin_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final name = await SecureStorageService.getUserName() ?? '';
    final email = await SecureStorageService.getEmailAliado() ?? '';
    if (mounted) setState(() { _userName = name; _userEmail = email; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activopay'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await AuthService.logout();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            child: Image.asset(
              'lib/assets/activo_4_2.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      _userName.isNotEmpty ? _userName[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 40, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _userName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _userEmail,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 48),
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 48,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Dispositivo Autorizado',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        ),
      );
  }
}

class OperationsGridScreen extends StatelessWidget {
  const OperationsGridScreen({super.key});

  void _onModuleTap(BuildContext context, ModuleItem item) {
    switch (item.id) {
      case '1':
      case '3':
      case '6':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AmountPinScreen(
              operationId: item.id,
              operationName: item.name,
              params: item.params,
            ),
          ),
        );
        break;
      case '4':
        _showServiceModal(context);
        break;
      default:
        if (item.screen.isNotEmpty) {
          Navigator.pushNamed(context, item.screen, arguments: item.params);
        }
    }
  }

  void _showServiceModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Selecciona un servicio',
              style: Theme.of(
                ctx,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: AppModules.serviceOptions
                  .map(
                    (svc) => SizedBox(
                      width: (MediaQuery.of(ctx).size.width - 80) / 3,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          Navigator.pushNamed(
                            context,
                            svc.screen,
                            arguments: svc.params,
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.slate800
                                    : AppColors.slate100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                svc.icon,
                                size: 32,
                                color: isDark
                                    ? Colors.white70
                                    : AppColors.slate700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              svc.name,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.white70
                                    : AppColors.slate700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final modules = AppModules.enabledGridModules;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 64 - 16) / 2;

    return Stack(
      children: [
        Positioned(
          bottom: -MediaQuery.of(context).size.height / 9,
          left: 0,
          right: 0,
          child: Opacity(
            opacity: 0.5,
            child: Image.asset(
              'lib/assets/activo_4_2.png',
              height: screenWidth * 0.9,
              width: screenWidth * 0.9,
              fit: BoxFit.contain,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Operaciones',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  itemCount: modules.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: cardWidth / (cardWidth * 0.85),
                  ),
                  itemBuilder: (context, index) {
                    final item = modules[index];
                    return _GridCard(
                      item: item,
                      onTap: () => _onModuleTap(context, item),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GridCard extends StatelessWidget {
  final ModuleItem item;
  final VoidCallback onTap;

  const _GridCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? AppColors.slate800 : Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              size: 40,
              color: isDark ? Colors.white : AppColors.purpleBlue,
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                item.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.slate800,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
