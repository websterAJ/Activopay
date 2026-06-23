import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../services/secure_storage_service.dart';
import '../widgets/bento_card.dart';
import '../data/banks.dart';
import '../data/phone_prefixes.dart';

class PaymentDirectoryScreen extends StatefulWidget {
  const PaymentDirectoryScreen({super.key});

  @override
  State<PaymentDirectoryScreen> createState() => _PaymentDirectoryScreenState();
}

class _PaymentDirectoryScreenState extends State<PaymentDirectoryScreen> {
  List<ContactItem> _contacts = [];
  List<ContactItem> _filteredContacts = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  static const int _pageSize = 10;

  final _searchController = TextEditingController();
  final _formNameController = TextEditingController();
  final _formDocNumberController = TextEditingController();
  final _formPhoneNumberController = TextEditingController();
  final _formAccountController = TextEditingController();
  String _formDocPrefix = 'V';
  String _formBank = '0000';
  String _formPhonePrefix = '0414';
  String _formType = 'phone';
  bool _formEditMode = false;
  String? _formEditingId;
  bool _formIsSaving = false;

  Set<String> _favorites = {};
  bool _sortAsc = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadFavorites();
    _fetchContacts(1);
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favs = prefs.getStringList('favorite_contacts') ?? [];
      if (mounted) {
        setState(() {
          _favorites = favs.toSet();
        });
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  Future<void> _toggleFavorite(String contactId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        if (_favorites.contains(contactId)) {
          _favorites.remove(contactId);
        } else {
          _favorites.add(contactId);
        }
      });
      await prefs.setStringList('favorite_contacts', _favorites.toList());
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  void _toggleSort() {
    setState(() {
      _sortAsc = !_sortAsc;
      if (_sortAsc) {
        _filteredContacts.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      } else {
        _filteredContacts.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
      }
    });
  }

  String _getCleanBankName(String bankCodeOrName) {
    final found = banks.firstWhere(
      (b) => b.code == bankCodeOrName || b.name.toLowerCase() == bankCodeOrName.toLowerCase(),
      orElse: () => Bank(code: '', name: bankCodeOrName),
    );
    String name = found.name;
    if (name == 'Seleccione un banco' || name.isEmpty) return 'Otro Banco';
    
    // Clean up suffixes
    name = name
        .replaceAll(RegExp(r',?\s*S\.A\.?\s*(BANCO UNIVERSAL)?', caseSensitive: false), '')
        .replaceAll(RegExp(r',?\s*C\.A\.?\s*(BANCO UNIVERSAL)?', caseSensitive: false), '')
        .replaceAll(RegExp(r',?\s*BANCO UNIVERSAL.*', caseSensitive: false), '')
        .replaceAll(RegExp(r'\(.*?\)', caseSensitive: false), '')
        .trim();

    // Convert to Title Case
    if (name.toUpperCase() == name) {
      name = name.split(' ').map((word) {
        if (word.isEmpty) return '';
        final lower = word.toLowerCase();
        if (['de', 'del', 'la', 'y', 'el', 'c.a.'].contains(lower)) return lower;
        return word[0] + word.substring(1).toLowerCase();
      }).join(' ');
      // capitalize first word anyway
      if (name.isNotEmpty) {
        name = name[0].toUpperCase() + name.substring(1);
      }
    }
    return name;
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _formNameController.dispose();
    _formDocNumberController.dispose();
    _formPhoneNumberController.dispose();
    _formAccountController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    if (_contacts.isEmpty) return;
    setState(() {
      if (query.isEmpty) {
        _filteredContacts = List.from(_contacts);
      } else {
        _filteredContacts = _contacts.where((c) =>
          c.name.toLowerCase().contains(query) ||
          c.bank.toLowerCase().contains(query) ||
          c.phone.contains(query) ||
          c.account.contains(query)
        ).toList();
      }
    });
  }

  Future<String> _getUser() async {
    final login = await SecureStorageService.getUserLogin();
    if (login != null && login.isNotEmpty) return login;
    final rif = await SecureStorageService.getUserRif();
    if (rif != null && rif.isNotEmpty) return rif;
    return '';
  }

  Future<void> _fetchContacts(int page, {bool showLoader = true}) async {
    if (showLoader) {
      setState(() => _isLoading = true);
    } else {
      setState(() => _isLoadingMore = true);
    }

    try {
      final user = await _getUser();
      final response = await ApiService.getDirectoryPayments(
        user: user,
        page: page,
        size: _pageSize,
      );

      if (!mounted) return;
      setState(() {
        _contacts = response.directoryPayments;
        _filteredContacts = List.from(response.directoryPayments);
        _totalItems = response.totalItems;
        _totalPages = response.totalPages;
        _currentPage = response.currentPage;
      });
    } catch (_) {
      if (!mounted) return;
      _showError('Error al cargar los contactos');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _goToNextPage() {
    if (_currentPage < _totalPages) {
      _fetchContacts(_currentPage + 1, showLoader: false);
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 1) {
      _fetchContacts(_currentPage - 1, showLoader: false);
    }
  }

  void _resetForm() {
    _formNameController.clear();
    _formDocNumberController.clear();
    _formPhoneNumberController.clear();
    _formAccountController.clear();
    _formDocPrefix = 'V';
    _formBank = '0000';
    _formPhonePrefix = '0414';
    _formType = 'phone';
    _formEditMode = false;
    _formEditingId = null;
    _formIsSaving = false;
  }

  void _openCreateModal() {
    _resetForm();
    _showFormModal();
  }

  void _openEditModal(ContactItem contact) {
    _formNameController.text = contact.name;
    final tp = contact.tpdocument.isNotEmpty ? contact.tpdocument.toUpperCase() : 'V';
    _formDocPrefix = idDocumentPrefixes.contains(tp) ? tp : 'V';
    _formDocNumberController.text = contact.document;
    _formBank = contact.bank.isNotEmpty ? contact.bank : '0000';
    _formPhonePrefix = contact.phone.length >= 4
        ? contact.phone.substring(0, 4)
        : '0414';
    _formPhoneNumberController.text = contact.phone.length > 4
        ? contact.phone.substring(4)
        : '';
    _formAccountController.text = contact.account;
    _formType = contact.type;
    _formEditMode = true;
    _formEditingId = contact.id;
    _showFormModal();
  }

  Future<void> _saveContact() async {
    final name = _formNameController.text.trim();
    if (name.isEmpty || _formBank == '0000') {
      _showError('Por favor, completa todos los campos requeridos.');
      return;
    }
    if (_formType == 'phone' &&
        _formPhoneNumberController.text.trim().isEmpty) {
      _showError('Por favor, ingresa el número de teléfono.');
      return;
    }
    if (_formType == 'account' && _formAccountController.text.trim().isEmpty) {
      _showError('Por favor, ingresa el número de cuenta.');
      return;
    }

    setState(() => _formIsSaving = true);

    try {
      final user = await _getUser();
      final phone = _formType == 'phone'
          ? '$_formPhonePrefix${_formPhoneNumberController.text.trim()}'
          : '';
      final account = _formType == 'account'
          ? _formAccountController.text.trim()
          : '';

      if (_formEditMode && _formEditingId != null) {
        await ApiService.updateDirectoryPayment(
          user: user,
          id: _formEditingId!,
          name: name,
          bank: _formBank,
          tpdocument: _formDocPrefix,
          document: _formDocNumberController.text.trim(),
          phone: phone,
          account: account,
          type: _formType,
        );
      } else {
        await ApiService.createDirectoryPayment(
          user: user,
          name: name,
          bank: _formBank,
          tpdocument: _formDocPrefix,
          document: _formDocNumberController.text.trim(),
          phone: phone,
          account: account,
          type: _formType,
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
      _resetForm();
      _fetchContacts(1);
      _showSuccess(_formEditMode ? 'Contacto actualizado' : 'Contacto creado');
    } catch (_) {
      if (!mounted) return;
      _showError('Error al guardar el contacto');
    } finally {
      if (mounted) setState(() => _formIsSaving = false);
    }
  }

  Future<void> _deleteContact(ContactItem contact) async {
    try {
      await ApiService.deleteDirectoryPayment(id: contact.id);
      if (!mounted) return;
      if (!mounted) return;
      if (_contacts.length == 1 && _currentPage > 1) {
        _fetchContacts(_currentPage - 1);
      } else {
        _fetchContacts(_currentPage);
      }
      _showSuccess('Contacto eliminado');
    } catch (_) {
      if (!mounted) return;
      _showError('Error al eliminar el contacto');
    }
  }

  void _showDeleteConfirmation(BuildContext context, ContactItem contact) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar contacto'),
        content: Text('¿Estás seguro de que deseas eliminar a ${contact.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.slate500)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteContact(contact);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Future<void> _onContactTap(ContactItem contact) async {
    final result = await Navigator.pushNamed(
      context,
      '/contact-operations',
      arguments: contact,
    );
    if (!mounted) return;
    if (result == 'edit') {
      _openEditModal(contact);
    }
  }

  void _showFormModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return _FormModalContent(
          formNameController: _formNameController,
          formDocNumberController: _formDocNumberController,
          formPhoneNumberController: _formPhoneNumberController,
          formAccountController: _formAccountController,
          formDocPrefix: _formDocPrefix,
          formBank: _formBank,
          formPhonePrefix: _formPhonePrefix,
          formType: _formType,
          formEditMode: _formEditMode,
          formIsSaving: _formIsSaving,
          onDocPrefixChanged: (v) => _formDocPrefix = v,
          onBankChanged: (v) => _formBank = v,
          onPhonePrefixChanged: (v) => _formPhonePrefix = v,
          onTypeChanged: (v) => _formType = v,
          onSave: _saveContact,
          onCancel: () => Navigator.pop(ctx),
        );
      },
    );
  }

  void _showOperationsModal(ContactItem contact) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.slate300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Operaciones para ${contact.name}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _OperationOption(
                icon: Icons.swap_horiz,
                label: 'Vuelto',
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(
                    context,
                    '/contact-operations',
                    arguments: contact,
                  );
                },
              ),
              const SizedBox(height: 12),
              _OperationOption(
                icon: Icons.payments,
                label: 'Cobro C2P',
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(
                    context,
                    '/contact-operations',
                    arguments: contact,
                  );
                },
              ),
              const SizedBox(height: 12),
              _OperationOption(
                icon: Icons.account_balance,
                label: 'Transferencia',
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(
                    context,
                    '/contact-operations',
                    arguments: contact,
                  );
                },
              ),
              const SizedBox(height: 12),
              _OperationOption(
                icon: Icons.speed,
                label: 'Débito Inmediato',
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(
                    context,
                    '/contact-operations',
                    arguments: contact,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 70,
        title: const Text(
          'Directorio de Pago',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchContacts(1),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar contacto o banco...',
                prefixIcon: const Icon(Icons.search, color: AppColors.slate400),
                filled: true,
                fillColor: isDark ? AppColors.slate800 : AppColors.slate50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _openCreateModal,
              child: BentoCard(
                backgroundColor: AppColors.purpleBlue,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Agregar Nuevo Contacto',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Crea un nuevo beneficiario para pagos',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tus Contactos',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: _toggleSort,
                  child: Text(
                    'A-Z',
                    style: TextStyle(
                      color: AppColors.purpleBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(color: AppColors.purpleBlue),
                ),
              )
            else if (_filteredContacts.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    'No hay contactos registrados',
                    style: TextStyle(
                      color: AppColors.slate500,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            else
              ..._filteredContacts.map((contact) {
                final isFav = _favorites.contains(contact.id);
                final bName = _getCleanBankName(contact.bank);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ContactCard(
                    contact: contact,
                    isDark: isDark,
                    isFavorite: isFav,
                    bankName: bName,
                    onTap: () => _onContactTap(contact),
                    onToggleFavorite: () => _toggleFavorite(contact.id),
                    onEdit: () => _openEditModal(contact),
                    onDelete: () => _showDeleteConfirmation(context, contact),
                  ),
                );
              }),
            const SizedBox(height: 16),
            if (_totalPages > 1) _buildPagination(isDark),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: _currentPage > 1 && !_isLoadingMore
                  ? _goToPreviousPage
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purpleBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                disabledBackgroundColor: AppColors.slate300,
              ),
              child: const Text('Anterior', style: TextStyle(fontSize: 13)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '$_currentPage / $_totalPages',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.navy,
              ),
            ),
          ),
          SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: _currentPage < _totalPages && !_isLoadingMore
                  ? _goToNextPage
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purpleBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                disabledBackgroundColor: AppColors.slate300,
              ),
              child: const Text('Siguiente', style: TextStyle(fontSize: 13)),
            ),
          ),
          if (_isLoadingMore)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final ContactItem contact;
  final bool isDark;
  final bool isFavorite;
  final String bankName;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ContactCard({
    required this.contact,
    required this.isDark,
    required this.isFavorite,
    required this.bankName,
    required this.onTap,
    required this.onToggleFavorite,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.purpleBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: AppColors.purpleBlue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bankName,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.slate500,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  color: isFavorite ? Colors.orange : AppColors.slate300,
                ),
                onPressed: onToggleFavorite,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.purpleBlue),
                onPressed: onEdit,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: onDelete,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OperationOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OperationOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.purpleBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.purpleBlue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.navy,
              ),
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.slate300),
        ],
      ),
    );
  }
}

class _FormModalContent extends StatefulWidget {
  final TextEditingController formNameController;
  final TextEditingController formDocNumberController;
  final TextEditingController formPhoneNumberController;
  final TextEditingController formAccountController;
  final String formDocPrefix;
  final String formBank;
  final String formPhonePrefix;
  final String formType;
  final bool formEditMode;
  final bool formIsSaving;
  final ValueChanged<String> onDocPrefixChanged;
  final ValueChanged<String> onBankChanged;
  final ValueChanged<String> onPhonePrefixChanged;
  final ValueChanged<String> onTypeChanged;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const _FormModalContent({
    required this.formNameController,
    required this.formDocNumberController,
    required this.formPhoneNumberController,
    required this.formAccountController,
    required this.formDocPrefix,
    required this.formBank,
    required this.formPhonePrefix,
    required this.formType,
    required this.formEditMode,
    required this.formIsSaving,
    required this.onDocPrefixChanged,
    required this.onBankChanged,
    required this.onPhonePrefixChanged,
    required this.onTypeChanged,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<_FormModalContent> createState() => _FormModalContentState();
}

class _FormModalContentState extends State<_FormModalContent> {
  late String _docPrefix;
  late String _bank;
  late String _phonePrefix;
  late String _type;

  @override
  void initState() {
    super.initState();
    _docPrefix = widget.formDocPrefix;
    _bank = widget.formBank;
    _phonePrefix = widget.formPhonePrefix;
    _type = widget.formType;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.slate300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.formEditMode ? 'Editar Pago' : 'Agregar Nuevo Pago',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Nombre del contacto:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: widget.formNameController,
              decoration: const InputDecoration(
                hintText: 'Nombre del contacto',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            const Text(
              'Documento de Identidad:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  width: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.slate300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _docPrefix,
                      isExpanded: true,
                      items: idDocumentPrefixes
                          .map(
                            (p) => DropdownMenuItem(value: p, child: Text(p)),
                          )
                          .toList(),
                      onChanged: (v) {
                        setState(() => _docPrefix = v ?? 'V');
                        widget.onDocPrefixChanged(v ?? 'V');
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: widget.formDocNumberController,
                    decoration: const InputDecoration(
                      hintText: 'Número de documento',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      counterText: '',
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 9,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Banco:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.slate300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _bank,
                  isExpanded: true,
                  items: banks
                      .map(
                        (b) => DropdownMenuItem(
                          value: b.code,
                          child: Text(b.name, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    setState(() => _bank = v ?? '0000');
                    widget.onBankChanged(v ?? '0000');
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _RadioButton(
                  label: 'Teléfono',
                  value: 'phone',
                  groupValue: _type,
                  onChanged: (v) {
                    setState(() => _type = v);
                    widget.onTypeChanged(v);
                  },
                ),
                const SizedBox(width: 16),
                _RadioButton(
                  label: 'Cuenta',
                  value: 'account',
                  groupValue: _type,
                  onChanged: (v) {
                    setState(() => _type = v);
                    widget.onTypeChanged(v);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_type == 'phone') ...[
              const Text(
                'Número de teléfono:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    width: 90,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.slate300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _phonePrefix,
                        isExpanded: true,
                        items: phonePrefixesAll
                            .map(
                              (p) => DropdownMenuItem(
                                value: p.value,
                                child: Text(p.label),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          setState(() => _phonePrefix = v ?? '0414');
                          widget.onPhonePrefixChanged(v ?? '0414');
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: widget.formPhoneNumberController,
                      decoration: const InputDecoration(
                        hintText: 'Número',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        counterText: '',
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 7,
                    ),
                  ),
                ],
              ),
            ],
            if (_type == 'account') ...[
              const Text(
                'Número de cuenta:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: widget.formAccountController,
                decoration: const InputDecoration(
                  hintText: 'Número de cuenta bancaria',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  counterText: '',
                ),
                keyboardType: TextInputType.number,
                maxLength: 20,
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: widget.formIsSaving ? null : widget.onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.purpleBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: widget.formIsSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Guardar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: widget.onCancel,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: AppColors.slate300),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(fontSize: 16, color: AppColors.navy),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _RadioButton extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;

  const _RadioButton({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            groupValue == value
                ? Icons.radio_button_checked
                : Icons.radio_button_off,
            color: groupValue == value
                ? AppColors.purpleBlue
                : AppColors.slate400,
            size: 22,
          ),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 14, color: AppColors.navy)),
        ],
      ),
    );
  }
}
