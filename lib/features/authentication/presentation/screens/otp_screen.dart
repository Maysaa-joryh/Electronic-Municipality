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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت إعادة إرسال الرمز')),
        );
      }
      return true;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل إعادة إرسال الرمز')),
        );
      }
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

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _length,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(_length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _handleChanged(String value, int index) {
    if (value.isNotEmpty && index < _length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    widget.onChanged(_controllers.map((item) => item.text).join());
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = constraints.maxWidth < 240 ? 8.0 : 12.0;
        final availableWidth = constraints.maxWidth - (gap * (_length - 1));
        final fieldWidth =
            (availableWidth / _length).clamp(44.0, 72.0).toDouble();

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _length,
            (index) => Padding(
              padding: EdgeInsetsDirectional.only(
                end: index == _length - 1 ? 0 : gap,
              ),
              child: SizedBox(
                width: fieldWidth,
                height: 64,
                child: TextField(
                  key: ValueKey('otp_digit_$index'),
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  enabled: widget.enabled,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  textInputAction: index == _length - 1
                      ? TextInputAction.done
                      : TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(1),
                  ],
                  maxLength: 1,
                  enableSuggestions: false,
                  autocorrect: false,
                  onTap: () {
                    _controllers[index].selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: _controllers[index].text.length,
                    );
                  },
                  onChanged: (value) => _handleChanged(value, index),
                  onSubmitted:
                      index == _length - 1 ? (_) => widget.onSubmitted() : null,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: const InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(color: AppColors.muted),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(color: AppColors.muted),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(
                        color: Color(0xFF2A68D8),
                        width: 3,
                      ),
                    ),
                  ),
                ),
              ),
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

  bool get _canResend => _secondsRemaining == 0 && !_isResending;

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
    if (!_canResend) return;

    setState(() => _isResending = true);
    final sent = await widget.onResend();

    if (!mounted) return;

    setState(() {
      _isResending = false;
      if (sent) _secondsRemaining = _duration;
    });

    if (sent) _startTimer();
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
        Text(
          'لم تستلم الرمز؟',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.muted,
                fontSize: 17,
              ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextButton(
          key: const ValueKey('otp_resend_button'),
          onPressed: _canResend ? _resend : null,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.gold,
            disabledForegroundColor: AppColors.gold,
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 36),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            textStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
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
              : Text(
                  _secondsRemaining == 0
                      ? 'إعادة إرسال الرمز'
                      : 'إعادة إرسال الرمز ($_formattedTime)',
                ),
        ),
      ],
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
