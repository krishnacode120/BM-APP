import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../l10n/app_localizations.dart';
import '../theme/bm_theme.dart';

class BmLogo extends StatelessWidget {
  const BmLogo(
      {this.width = 112, this.white = false, this.mark = false, super.key});

  final double width;
  final bool white;
  final bool mark;

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'BM',
        image: true,
        child: SvgPicture.asset(
          mark
              ? 'assets/branding/bm_logo_mark.svg'
              : white
                  ? 'assets/branding/bm_logo_white.svg'
                  : 'assets/branding/bm_logo.svg',
          width: width,
        ),
      );
}

class BmPrimaryButton extends StatefulWidget {
  const BmPrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;

  @override
  State<BmPrimaryButton> createState() => _BmPrimaryButtonState();
}

class _BmPrimaryButtonState extends State<BmPrimaryButton> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) => AnimatedScale(
        scale: pressed ? .97 : 1,
        duration: const Duration(milliseconds: 140),
        child: Listener(
          onPointerDown: (_) => setState(() => pressed = true),
          onPointerUp: (_) => setState(() => pressed = false),
          onPointerCancel: (_) => setState(() => pressed = false),
          child: FilledButton.icon(
            onPressed: widget.loading ? null : widget.onPressed,
            icon: widget.loading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(widget.icon ?? Icons.arrow_forward_rounded),
            label: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(widget.label, textAlign: TextAlign.center),
            ),
          ),
        ),
      );
}

class BmSectionHeader extends StatelessWidget {
  const BmSectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      );
}

class BmLoading extends StatelessWidget {
  const BmLoading({super.key});

  @override
  Widget build(BuildContext context) => Center(
        child: Semantics(
          label: AppLocalizations.of(context).loading,
          child: const CircularProgressIndicator(),
        ),
      );
}

class BmEmptyState extends StatelessWidget {
  const BmEmptyState({
    required this.title,
    this.message,
    this.icon = Icons.inventory_2_outlined,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: BmColors.lightOrange,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: BmColors.orange),
              ),
              const SizedBox(height: 18),
              Text(title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge),
              if (message != null) ...<Widget>[
                const SizedBox(height: 8),
                Text(message!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
              if (actionLabel != null) ...<Widget>[
                const SizedBox(height: 18),
                OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      );
}

class BmErrorState extends StatelessWidget {
  const BmErrorState({required this.onRetry, super.key});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BmEmptyState(
      title: t.somethingWentWrong,
      message: t.unableToLoadMaterials,
      icon: Icons.error_outline_rounded,
      actionLabel: t.tryAgain,
      onAction: onRetry,
    );
  }
}

class BmImage extends StatelessWidget {
  const BmImage({
    required this.source,
    this.fit = BoxFit.cover,
    this.borderRadius = 16,
    super.key,
  });

  final String? source;
  final BoxFit fit;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      color: BmColors.lightOrange,
      alignment: Alignment.center,
      child: const Icon(Icons.construction_rounded,
          color: BmColors.orange, size: 34),
    );
    final image = source == null || source!.isEmpty
        ? fallback
        : source!.startsWith('assets/')
            ? Image.asset(source!,
                fit: fit, errorBuilder: (_, __, ___) => fallback)
            : Image.network(source!,
                fit: fit,
                loadingBuilder: (_, child, loading) =>
                    loading == null ? child : fallback,
                errorBuilder: (_, __, ___) => fallback);
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: image,
    );
  }
}

class BmStatusChip extends StatelessWidget {
  const BmStatusChip(
      {required this.label, this.tone = BmStatusTone.neutral, super.key});
  final String label;
  final BmStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final (Color foreground, Color background) = switch (tone) {
      BmStatusTone.success => (BmColors.success, const Color(0xFFEAF6EE)),
      BmStatusTone.warning => (BmColors.warning, const Color(0xFFFFF4D9)),
      BmStatusTone.error => (BmColors.error, const Color(0xFFFFECEE)),
      BmStatusTone.info => (BmColors.orange, BmColors.lightOrange),
      BmStatusTone.neutral => (BmColors.secondaryText, const Color(0xFFF2F2F2)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(label,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: foreground, fontWeight: FontWeight.w700)),
    );
  }
}

enum BmStatusTone { success, warning, error, info, neutral }
