import 'package:flutter/material.dart';
import 'package:ongi/core/app_colors.dart';

class Product {
  final String tempLabel;
  final String title;
  final String image;
  Product(this.tempLabel, this.title, this.image);
}

class RewardProductCard extends StatefulWidget {
  final Product item;
  final VoidCallback? onTap;
  const RewardProductCard({super.key, required this.item, this.onTap});

  @override
  State<RewardProductCard> createState() => _RewardProductCardState();
}

class _RewardProductCardState extends State<RewardProductCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  void _setHovered(bool value) {
    if (_isHovered == value) return;
    setState(() => _isHovered = value);
  }

  void _setPressed(bool value) {
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final bool showOverlay = _isHovered || _isPressed;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: widget.onTap,
          onTapDown: (_) => _setPressed(true),
          onTapCancel: () => _setPressed(false),
          onTapUp: (_) => _setPressed(false),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.fromLTRB(16, 22, 16, 14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Center(
                        child: Image.asset(
                          widget.item.image,
                          fit: BoxFit.contain,
                          height: 100,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.item.title,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // Hover / Press overlay
              Positioned.fill(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 120),
                  opacity: showOverlay ? 1.0 : 0.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      color: Colors.grey.withOpacity(0.45),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200.withOpacity(0.9),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey.shade500,
                                  width: 4,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '구매',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -10,
                left: 15,
                child: TempChip(label: widget.item.tempLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TempChip extends StatelessWidget {
  final String label;
  const TempChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.ongiOrange,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 1.1,
        ),
      ),
    );
  }
}
