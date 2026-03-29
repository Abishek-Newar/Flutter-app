import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:naqde_user/util/dimensions.dart';
import 'package:naqde_user/util/styles.dart';
import '../controllers/otp_verification_controller.dart';

/// 6-digit OTP input field.
/// - Each digit gets its own TextField + FocusNode.
/// - Auto-advances focus after each digit.
/// - Backspace moves focus back.
/// - Paste support for all 6 digits at once.
/// - Always LTR direction regardless of locale.
/// - Calls [onCompleted] when all 6 digits are filled.
class OtpDigitInput extends StatefulWidget {
  final void Function(String otp) onCompleted;
  final void Function()? onChanged;

  const OtpDigitInput({
    Key? key,
    required this.onCompleted,
    this.onChanged,
  }) : super(key: key);

  @override
  State<OtpDigitInput> createState() => OtpDigitInputState();
}

class OtpDigitInputState extends State<OtpDigitInput> {
  static const int _length = 6;

  final List<TextEditingController> _controllers =
      List.generate(_length, (_) => TextEditingController());
  final List<FocusNode> _nodes =
      List.generate(_length, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final n in _nodes) n.dispose();
    super.dispose();
  }

  String get _currentOtp =>
      _controllers.map((c) => c.text).join();

  void _onInput(int index, String value) {
    // Handle paste of full OTP
    if (value.length > 1) {
      _handlePaste(value);
      return;
    }

    if (value.length == 1) {
      if (index < _length - 1) {
        _nodes[index + 1].requestFocus();
      } else {
        _nodes[index].unfocus();
        final otp = _currentOtp;
        Get.find<OtpVerificationController>().setOtp(otp);
        widget.onCompleted(otp);
      }
    }
    widget.onChanged?.call();
    setState(() {});
  }

  void _onKeyDown(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _nodes[index - 1].requestFocus();
    }
  }

  void _handlePaste(String text) {
    final digits = text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;

    for (int i = 0; i < _length; i++) {
      if (i < digits.length) {
        _controllers[i].text = digits[i];
      }
    }

    if (digits.length >= _length) {
      _nodes[_length - 1].unfocus();
      final otp = _currentOtp;
      Get.find<OtpVerificationController>().setOtp(otp);
      widget.onCompleted(otp);
    } else {
      _nodes[digits.length].requestFocus();
    }
    setState(() {});
  }

  void clearAll() {
    for (final c in _controllers) c.clear();
    _nodes[0].requestFocus();
    Get.find<OtpVerificationController>().clearOtp();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    // OTP is always LTR regardless of app locale
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_length, (i) {
          final isFilled = _controllers[i].text.isNotEmpty;
          return _OtpBox(
            controller: _controllers[i],
            focusNode: _nodes[i],
            index: i,
            isFilled: isFilled,
            primary: primary,
            onInput: (v) => _onInput(i, v),
            onKeyDown: (e) => _onKeyDown(i, e),
          );
        }),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final int index;
  final bool isFilled;
  final Color primary;
  final void Function(String) onInput;
  final void Function(RawKeyEvent) onKeyDown;

  const _OtpBox({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.index,
    required this.isFilled,
    required this.primary,
    required this.onInput,
    required this.onKeyDown,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Digit ${index + 1}',
      child: SizedBox(
        width: 46,
        height: 58,
        child: RawKeyboardListener(
          focusNode: FocusNode(),
          onKey: onKeyDown,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            textAlign: TextAlign.center,
            maxLength: 1,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: rubikSemiBold.copyWith(
              fontSize: Dimensions.fontSizeExtraOverLarge,
              color: primary,
            ),
            decoration: InputDecoration(
              counterText: '',
              contentPadding: EdgeInsets.zero,
              filled: true,
              fillColor: isFilled
                  ? primary.withOpacity(0.07)
                  : Theme.of(context).cardColor,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isFilled ? primary : Colors.grey.shade300,
                  width: isFilled ? 2 : 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primary, width: 2),
              ),
            ),
            onChanged: onInput,
          ),
        ),
      ),
    );
  }
}
