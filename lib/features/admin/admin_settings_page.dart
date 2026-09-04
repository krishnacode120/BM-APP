part of 'admin_pages.dart';

class AdminSettingsPage extends ConsumerStatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  ConsumerState<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends ConsumerState<AdminSettingsPage> {
  final businessName = TextEditingController();
  final businessPhone = TextEditingController();
  final whatsapp = TextEditingController();
  final email = TextEditingController();
  final currency = TextEditingController();
  final hours = TextEditingController();
  bool initialized = false;
  bool saving = false;

  @override
  void dispose() {
    businessName.dispose();
    businessPhone.dispose();
    whatsapp.dispose();
    email.dispose();
    currency.dispose();
    hours.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = adminText(context);
    final settings = ref.watch(adminBusinessSettingsProvider);
    if (!initialized && settings.valueOrNull != null) {
      initialized = true;
      final value = settings.valueOrNull!;
      businessName.text = value.businessName;
      businessPhone.text = value.businessPhone;
      whatsapp.text = value.whatsappNumber;
      email.text = value.supportEmail;
      currency.text = value.defaultCurrency;
      hours.text = value.supportHours;
    }
    return AdminPageFrame(
      title: t.adminSettings,
      child: settings.when(
        loading: () => const BmAdminSkeleton(),
        error: (_, __) => BmEmptyState(
          title: t.unableSettings,
          actionLabel: t.tryAgain,
          onAction: () => ref.invalidate(adminBusinessSettingsProvider),
        ),
        data: (_) => ListView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          children: <Widget>[
            _RequiredField(controller: businessName, label: t.businessName),
            const SizedBox(height: 12),
            _RequiredField(controller: businessPhone, label: t.businessPhone),
            const SizedBox(height: 12),
            _RequiredField(controller: whatsapp, label: t.whatsappNumber),
            const SizedBox(height: 12),
            _RequiredField(controller: email, label: t.supportEmail),
            const SizedBox(height: 12),
            _RequiredField(controller: currency, label: t.currency),
            const SizedBox(height: 12),
            TextField(
              controller: hours,
              decoration: InputDecoration(labelText: t.supportHours),
            ),
            const SizedBox(height: 18),
            BmPrimaryButton(
              label: t.saveSettings,
              loading: saving,
              onPressed: saving ? null : _saveSettings,
            ),
            const Divider(height: 40),
            OutlinedButton.icon(
              onPressed: _changePassword,
              icon: const Icon(Icons.password_rounded),
              label: Text(t.changePassword),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout_rounded),
              label: Text(t.logout),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSettings() async {
    final t = adminText(context);
    final value = BusinessSettings(
      businessName: businessName.text.trim(),
      businessPhone: businessPhone.text.trim(),
      whatsappNumber: whatsapp.text.trim(),
      supportEmail: email.text.trim(),
      defaultCurrency: currency.text.trim(),
      supportHours: hours.text.trim(),
      isDevelopmentFallback: false,
    );
    if (!value.canCall || !value.canWhatsapp || !value.hasSupportEmail) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.invalidSettings)));
      return;
    }
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(t.saveSettings),
            content: Text(t.confirmSettingsChange),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(t.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(t.confirm),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    setState(() => saving = true);
    try {
      await ref.read(adminRepositoryProvider).updateBusinessSettings(value);
      ref.invalidate(adminBusinessSettingsProvider);
      ref.invalidate(businessSettingsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(t.settingsSaved)));
      }
    } on AdminFailure catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.adminError(error.code))),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> _changePassword() async {
    final t = adminText(context);
    final current = TextEditingController();
    final next = TextEditingController();
    final confirmation = TextEditingController();
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.changePassword),
        content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          TextField(
            controller: current,
            obscureText: true,
            decoration: InputDecoration(labelText: t.currentPassword),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: next,
            obscureText: true,
            decoration: InputDecoration(labelText: t.newPassword),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: confirmation,
            obscureText: true,
            decoration: InputDecoration(labelText: t.confirmNewPassword),
          ),
        ]),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (current.text.isNotEmpty &&
                  next.text.length >= 8 &&
                  next.text == confirmation.text) {
                Navigator.pop(dialogContext, (current.text, next.text));
              }
            },
            child: Text(t.update),
          ),
        ],
      ),
    );
    current.dispose();
    next.dispose();
    confirmation.dispose();
    if (result == null) return;
    try {
      await ref
          .read(adminRepositoryProvider)
          .changePassword(result.$1, result.$2);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(t.passwordUpdated)));
      }
    } on AdminFailure catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.adminError(error.code))),
        );
      }
    }
  }

  Future<void> _logout() async {
    final t = adminText(context);
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(t.logout),
            content: Text(t.logoutConfirmation),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(t.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(t.logout),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    await ref.read(notificationServiceProvider).deactivateCurrentDevice();
    await ref.read(adminRepositoryProvider).signOut();
    ref.invalidate(adminAccessProvider);
    if (mounted) context.go('/admin/login');
  }
}

class _RequiredField extends StatelessWidget {
  const _RequiredField({required this.controller, required this.label});
  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator: (value) => value?.trim().isEmpty == true
            ? adminText(context).requiredField
            : null,
      );
}

String _contentType(String name) {
  final lower = name.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  return 'image/jpeg';
}

String _dateTime(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year} '
    '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
