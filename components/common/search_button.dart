import 'package:flutter/material.dart';

class SearchButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double size;

  const SearchButton({
    super.key,
    this.onPressed,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Search',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: size,
            height: size,
            child: const Center(
              child: Icon(
                Icons.search_rounded,
                size: 25,
                color: Color(0xFF111111),
              ),
            ),
          ),
        ),
      ),
    );
  }
}