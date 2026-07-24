import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef OtpSubmit = void Function(String code);

class OtpInput extends StatefulWidget {
  const OtpInput({
    super.key,
    this.length = 4,
    required this.onSubmit,
    this.textStyle,
    this.enabled = true,
  });

  final int length;
  final OtpSubmit onSubmit;
  final TextStyle? textStyle;
  final bool enabled;

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode()..addListener(_rebuild);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_rebuild)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  void _onChanged(String value) {
    setState(() {});
    if (value.length == widget.length) {
      widget.onSubmit(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final code = _controller.text;
    final activeIndex = code.length.clamp(0, widget.length - 1);

    return Semantics(
      label: 'رمز التحقق المكون من ${widget.length} أرقام',
      textField: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.enabled ? _focusNode.requestFocus : null,
        child: Stack(
          children: [
            IgnorePointer(
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.length, (index) {
                    final isActive = _focusNode.hasFocus &&
                        (index == activeIndex ||
                            (code.length == widget.length &&
                                index == widget.length - 1));

                    return Container(
                      key: ValueKey('otp_digit_$index'),
                      width: 60,
                      height: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAF8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isActive
                              ? const Color(0xFF2A68D8)
                              : const Color(0xFFD7D8D2),
                          width: isActive ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        index < code.length ? code[index] : '',
                        style: widget.textStyle ??
                            const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                child: TextField(
                  key: const ValueKey('otp_code_field'),
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.center,
                  maxLength: widget.length,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  enableSuggestions: false,
                  autocorrect: false,
                  inputFormatters: [
                    _OtpDigitsFormatter(widget.length),
                  ],
                  onChanged: _onChanged,
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpDigitsFormatter extends TextInputFormatter {
  const _OtpDigitsFormatter(this.maxLength);

  final int maxLength;

  static const _arabicIndicDigits = '٠١٢٣٤٥٦٧٨٩';
  static const _easternArabicDigits = '۰۱۲۳۴۵۶۷۸۹';

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = StringBuffer();

    for (final rune in newValue.text.runes) {
      final character = String.fromCharCode(rune);
      final western = int.tryParse(character);
      final arabicIndic = _arabicIndicDigits.indexOf(character);
      final easternArabic = _easternArabicDigits.indexOf(character);

      if (western != null) {
        digits.write(western);
      } else if (arabicIndic >= 0) {
        digits.write(arabicIndic);
      } else if (easternArabic >= 0) {
        digits.write(easternArabic);
      }

      if (digits.length >= maxLength) break;
    }

    final text = digits.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
