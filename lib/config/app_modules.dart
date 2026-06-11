import 'package:flutter/material.dart';

class ModuleItem {
  final String id;
  final String name;
  final IconData icon;
  final String screen;
  final Map<String, dynamic>? params;
  final bool Function()? isVisible;

  const ModuleItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.screen,
    this.params,
    this.isVisible,
  });
}

class NavTab {
  final String id;
  final String label;
  final IconData icon;
  final bool enabled;

  const NavTab({
    required this.id,
    required this.label,
    required this.icon,
    this.enabled = true,
  });
}

class AppModules {
  // ====================================================================
  // NAVBAR TABS — toggle enabled/disabled
  // ====================================================================
  static const List<NavTab> navbarTabs = [
    NavTab(id: 'operaciones', label: 'Operaciones', icon: Icons.grid_view_rounded),
    NavTab(id: 'qr', label: 'Código QR', icon: Icons.qr_code_rounded),
    NavTab(id: 'directorio', label: 'Directorio', icon: Icons.bookmark_border_rounded),
    NavTab(id: 'configuracion', label: 'Configuración', icon: Icons.settings_rounded),
  ];

  static List<NavTab> get enabledNavTabs =>
      navbarTabs.where((t) => t.enabled).toList();

  // ====================================================================
  // GRID MODULES (operaciones)
  // ====================================================================
  static const List<ModuleItem> gridModules = [
    ModuleItem(
      id: '1',
      name: 'Vuelto',
      icon: Icons.change_circle_rounded,
      screen: '/operations',
      params: {'id': 1, 'service': ''},
    ),
    ModuleItem(
      id: '2',
      name: 'Cobro C2P',
      icon: Icons.payments_rounded,
      screen: '/operations',
      params: {'id': 2, 'service': ''},
      isVisible: _isJuridico,
    ),
    ModuleItem(
      id: '3',
      name: 'Transferencia',
      icon: Icons.swap_horiz_rounded,
      screen: '/operations',
      params: {'id': 3, 'service': ''},
    ),
    /* ModuleItem(
      id: '4',
      name: 'Pago de Servicios',
      icon: Icons.receipt_long_rounded,
      screen: '', // handled via modal
    ), */
    ModuleItem(
      id: '5',
      name: 'Validar Pago',
      icon: Icons.verified_rounded,
      screen: '/validate-payment',
    ),
    ModuleItem(
      id: '6',
      name: 'Débito Inmediato',
      icon: Icons.flash_on_rounded,
      screen: '/operations',
      params: {'id': 6, 'service': ''},
    ),
  ];

  static List<ModuleItem> get enabledGridModules =>
      gridModules.where((m) => m.isVisible?.call() ?? true).toList();

  // ====================================================================
  // SERVICE SUB-OPTIONS (Pago de Servicios)
  // ====================================================================
  static const List<ModuleItem> serviceOptions = [
    ModuleItem(id: '7', name: 'Movistar', icon: Icons_extra.movistar, screen: '/operations', params: {'id': 7, 'service': ''}),
    ModuleItem(id: '8', name: 'Digitel', icon: Icons_extra.digitel, screen: '/operations', params: {'id': 8, 'service': ''}),
    ModuleItem(id: '9', name: 'Inter', icon: Icons_extra.inter, screen: '/operations', params: {'id': 9, 'service': ''}),
    ModuleItem(id: '10', name: 'Corpoelec', icon: Icons_extra.corpoelec, screen: '/operations', params: {'id': 10, 'service': ''}),
    ModuleItem(id: '11', name: 'Simpletv', icon: Icons_extra.simpletv, screen: '/operations', params: {'id': 11, 'service': ''}),
  ];

  static bool _isJuridico() => _userType == 'juridico';
  static String _userType = '';
  static void setUserType(String type) => _userType = type;
}

// Custom icons for services (using available Material icons as fallback)
class Icons_extra {
  static const IconData movistar = Icons.phone_android_rounded;
  static const IconData digitel = Icons.phone_android_rounded;
  static const IconData inter = Icons.wifi_rounded;
  static const IconData corpoelec = Icons.bolt_rounded;
  static const IconData simpletv = Icons.tv_rounded;
}
