import 'package:flutter/material.dart';
import 'package:irma/widgets/theme.dart';

/// Standard premium top app bar designed exactly as per Figma specifications.
/// Handles device status bar padding automatically and applies the multi-layered drop shadows.
class IrmaTopBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final Widget? leading;
  final List<Widget>? actions;

  const IrmaTopBar({
    super.key,
    required this.title,
    this.onBackPressed,
    this.leading,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

    return Container(
      color: IrmaColors.brown10,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4B3425).withValues(alpha: 0.05),
              offset: const Offset(0, 0),
              blurRadius: 0,
            ),
            BoxShadow(
              color: const Color(0xFF4B3425).withValues(alpha: 0.05),
              offset: const Offset(0, 7),
              blurRadius: 15,
            ),
            BoxShadow(
              color: const Color(0xFF4B3425).withValues(alpha: 0.04),
              offset: const Offset(0, 28),
              blurRadius: 28,
            ),
            BoxShadow(
              color: const Color(0xFF4B3425).withValues(alpha: 0.03),
              offset: const Offset(0, 62),
              blurRadius: 37,
            ),
            BoxShadow(
              color: const Color(0xFF4B3425).withValues(alpha: 0.01),
              offset: const Offset(0, 110),
              blurRadius: 44,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: topPadding),
            SizedBox(
              height: 80,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Leading Widget / Back Button
                    if (leading != null)
                      leading!
                    else if (onBackPressed != null)
                      GestureDetector(
                        onTap: onBackPressed,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: IrmaColors.brown10,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chevron_left_rounded,
                            color: IrmaColors.brown80,
                            size: 24,
                          ),
                        ),
                      ),
                    
                    // Gap between leading and title (updated to 16px)
                    if (leading != null || onBackPressed != null)
                      const SizedBox(width: 16.0)
                    else
                      const SizedBox(width: 8.0),
                      
                    // Title Text
                    Expanded(
                      child: Text(
                        title,
                        style: IrmaTextStyles.label2xlBold.copyWith(
                          color: IrmaColors.brown100,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    // Actions List (8px spacing between them)
                    if (actions != null && actions!.isNotEmpty) ...[
                      const SizedBox(width: 8.0),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(actions!.length, (index) {
                          return Padding(
                            padding: EdgeInsets.only(
                              right: index == actions!.length - 1 ? 0.0 : 8.0,
                            ),
                            child: actions![index],
                          );
                        }),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Standard outlined action button used in IrmaTopBar.
class IrmaTopBarActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const IrmaTopBarActionButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: IrmaColors.brown20, width: 1),
      ),
      child: IconButton(
        icon: Icon(icon, color: IrmaColors.brown80, size: 20),
        onPressed: onTap,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
