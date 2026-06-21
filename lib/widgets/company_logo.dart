import 'package:flutter/material.dart';

class CompanyLogo extends StatelessWidget {
  final String? logoUrl;
  final IconData fallbackIcon;
  final Color fallbackColor;
  final Color borderColor;
  final double size;

  const CompanyLogo({
    super.key,
    required this.logoUrl,
    required this.fallbackIcon,
    required this.fallbackColor,
    required this.borderColor,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    final hasLogo = logoUrl != null && logoUrl!.trim().isNotEmpty;

    return SizedBox.square(
      dimension: size,
      child: AspectRatio(
        aspectRatio: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: hasLogo
                ? Padding(
                    padding: const EdgeInsets.all(5),
                    child: Image.network(
                      logoUrl!.trim(),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          _fallback(),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                    ),
                  )
                : _fallback(),
          ),
        ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: fallbackColor.withValues(alpha: 0.18),
      child: Icon(fallbackIcon, color: fallbackColor, size: 24),
    );
  }
}
