import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/design_system.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/di.dart';
import '../../../../shared/widgets/municipality_widgets.dart';

class AuthOtpScreen extends StatefulWidget {
  const AuthOtpScreen({
    super.key,
    required this.contact,
  });

  final String contact;

  @override
  State<AuthOtpScreen> createState() => _AuthOtpScreenState();
}

class _AuthOtpScreenState extends State<AuthOtpScreen> {
  String _otpCode = '';
  bool _isLoading = false;
  String? _errorMessage;

  bool get _sentToEmail => widget.contact.contains('@');

  Future<void> _verifyOtp() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (_otpCode.length != 4) {
      setState(() => _errorMessage = 'أدخل رمز التحقق المكون من 4 أرقام.');
      return;
    }

    if (widget.contact.trim().isEmpty) {
      setState(() => _errorMessage = 'تعذر تحديد وجهة رمز التحقق.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final verified = await DI.auth.verifyOtp(
        contact: widget.contact,
        code: _otpCode,
      );

      if (!mounted) return;

      if (verified) {
        Navigator.of(context).pushNamed(
          AppRoutes.reset,
          arguments: widget.contact,
        );
      } else {
        setState(() {
          _errorMessage = 'الرمز غير صحيح. حاول مرة أخرى.';
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'تعذر التحقق من الرمز. حاول مرة أخرى.';
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _resendOtp() async {
    try {
      await DI.auth.requestOtp(contact: widget.contact);
      return true;
    } catch (_) {
      return false;
    }
  }

  void _onCodeChanged(String value) {
    setState(() {
      _otpCode = value;
      if (_errorMessage != null) _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final destination = _sentToEmail ? 'بريدك الإلكتروني' : 'هاتفك';

    return AuthCenterScaffold(
      verticalPadding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.xxxl,
        ),
        child: AppPanel(
          elevation: true,
          borderColor: AppColors.divider,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxxl,
            AppSpacing.huge,
            AppSpacing.xxxl,
            AppSpacing.huge,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: CircleIcon(
                  icon: Icons.phonelink_lock_outlined,
                  size: 64,
                  color: AppColors.surfaceMuted,
                  iconColor: AppColors.deepPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              Text(
                'رمز التحقق',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.deepPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'أدخل الرمز المكون من 4 أرقام المرسل إلى $destination',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.muted,
                      fontSize: 17,
                      height: 1.7,
                    ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              _OtpCodeInput(
                enabled: !_isLoading,
                onChanged: _onCodeChanged,
                onSubmitted: _verifyOtp,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: AppSpacing.lg),
                _OtpErrorMessage(message: _errorMessage!),
              ],
              const SizedBox(height: AppSpacing.xxxl),
              _ResendCodeSection(onResend: _resendOtp),
              const SizedBox(height: AppSpacing.xxxl),
              SizedBox(
                height: 64,
                child: FilledButton(
                  key: const ValueKey('otp_verify_button'),
                  onPressed: _isLoading ? null : _verifyOtp,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.deepPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    elevation: 8,
                    shadowColor: Colors.black.withOpacity(0.18),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'تحقق',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            const Icon(Icons.east_rounded, size: 27),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              SizedBox(
                height: 60,
                child: OutlinedButton(
                  key: const ValueKey('otp_back_button'),
                  onPressed:
                      _isLoading ? null : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.gold,
                    side: const BorderSide(
                      color: AppColors.gold,
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('رجوع'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpCodeInput extends StatefulWidget {
  const _OtpCodeInput({
    required this.enabled,
    required this.onChanged,
    required this.onSubmitted,
  });

  final bool enabled;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;

  @override
  State<_OtpCodeInput> createState() => _OtpCodeInputState();
}

class _OtpCodeInputState extends State<_OtpCodeInput> {
  static const _length = 4;

  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode()..addListener(_handleFocusChanged);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    if (mounted) setState(() {});
  }

  void _handleChanged(String value) {
    setState(() {});
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = constraints.maxWidth < 240 ? 8.0 : 12.0;
        final availableWidth = constraints.maxWidth - (gap * (_length - 1));
        final fieldWidth =
            (availableWidth / _length).clamp(44.0, 72.0).toDouble();
        final code = _controller.text;
        final activeIndex = code.length.clamp(0, _length - 1);

        return Semantics(
          label: 'رمز التحقق المكون من 4 أرقام',
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
                      children: List.generate(
                        _length,
                        (index) {
                          final isActive = _focusNode.hasFocus &&
                              (index == activeIndex ||
                                  (code.length == _length &&
                                      index == _length - 1));

                          return Padding(
                            padding: EdgeInsets.only(
                              right: index == _length - 1 ? 0 : gap,
                            ),
                            child: AnimatedContainer(
                              key: ValueKey('otp_digit_$index'),
                              duration: const Duration(milliseconds: 120),
                              width: fieldWidth,
                              height: 64,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                border: Border.all(
                                  color: isActive
                                      ? const Color(0xFF2A68D8)
                                      : AppColors.muted,
                                  width: isActive ? 3 : 1,
                                ),
                              ),
                              child: Text(
                                index < code.length ? code[index] : '',
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
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
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.oneTimeCode],
                      inputFormatters: const [_OtpDigitsFormatter(_length)],
                      maxLength: _length,
                      enableSuggestions: false,
                      autocorrect: false,
                      onChanged: _handleChanged,
                      onSubmitted: (_) {
                        if (_controller.text.length == _length) {
                          widget.onSubmitted();
                        }
                      },
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
      },
    );
  }
}

class _ResendCodeSection extends StatefulWidget {
  const _ResendCodeSection({
    required this.onResend,
  });

  final Future<bool> Function() onResend;

  @override
  State<_ResendCodeSection> createState() => _ResendCodeSectionState();
}

class _ResendCodeSectionState extends State<_ResendCodeSection> {
  static const _duration = 60;

  Timer? _timer;
  int _secondsRemaining = _duration;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  Future<void> _resend() async {
    if (_isResending) return;

    if (_secondsRemaining > 0) {
      _showMessage(
        'لا يمكنك إعادة إرسال الرمز قبل انتهاء المدة. '
        'الوقت المتبقي: $_formattedTime',
      );
      return;
    }

    setState(() => _isResending = true);
    final sent = await widget.onResend();

    if (!mounted) return;

    setState(() {
      _isResending = false;
      if (sent) _secondsRemaining = _duration;
    });

    if (sent) {
      _showMessage('تمت إعادة إرسال رمز التحقق بنجاح.');
      _startTimer();
    } else {
      _showMessage('تعذرت إعادة إرسال رمز التحقق. حاول مجددًا.');
    }
  }

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            message,
            textAlign: TextAlign.center,
          ),
        ),
      );
  }

  String get _formattedTime {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          key: const ValueKey('otp_resend_button'),
          onPressed: _isResending ? null : _resend,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.gold,
            disabledForegroundColor: AppColors.muted,
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 44),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            textStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: _isResending
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.gold,
                  ),
                )
              : Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'لم تستلم الرمز؟ ',
                        style: TextStyle(color: AppColors.muted),
                      ),
                      TextSpan(
                        text: _secondsRemaining == 0
                            ? 'إعادة الإرسال'
                            : 'إعادة الإرسال ($_formattedTime)',
                        style: const TextStyle(
                          color: AppColors.gold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
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
    final normalized = StringBuffer();

    for (final rune in newValue.text.runes) {
      final character = String.fromCharCode(rune);
      final westernDigit = int.tryParse(character);
      final arabicIndicDigit = _arabicIndicDigits.indexOf(character);
      final easternArabicDigit = _easternArabicDigits.indexOf(character);

      if (westernDigit != null) {
        normalized.write(westernDigit);
      } else if (arabicIndicDigit >= 0) {
        normalized.write(arabicIndicDigit);
      } else if (easternArabicDigit >= 0) {
        normalized.write(easternArabicDigit);
      }

      if (normalized.length >= maxLength) break;
    }

    final text = normalized.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _OtpErrorMessage extends StatelessWidget {
  const _OtpErrorMessage({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.danger),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.danger,
            ),
      ),
    );
  }
}
