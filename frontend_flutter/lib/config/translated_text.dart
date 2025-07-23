import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'translation_provider.dart';

class TranslatedText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const TranslatedText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
  }) : super(key: key);

  @override
  _TranslatedTextState createState() => _TranslatedTextState();
}

class _TranslatedTextState extends State<TranslatedText> {
  String? translatedText;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _translate();
  }

  @override
  void didUpdateWidget(covariant TranslatedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _translate();
    }
  }

  void _translate() async {
    // Listen to TranslationProvider for language changes automatically
    final tp = Provider.of<TranslationProvider>(context);

    final result = await tp.translate(widget.text);

    if (mounted) {
      setState(() {
        translatedText = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // This ensures widget rebuilds when notifyListeners is called on TranslationProvider
    Provider.of<TranslationProvider>(context);

    return Text(
      translatedText ?? widget.text,
      style: widget.style,
      textAlign: widget.textAlign,
    );
  }
}
