/// Cleans Quran.com translation text for plain display.
///
/// Strips footnote markers like `<sup foot_note=123>1</sup>`, removes other
/// HTML tags, and decodes common HTML entities.
String cleanTranslationText(String input) {
  if (input.isEmpty) return input;
  var text = input;
  // Remove footnote markers entirely (e.g. <sup foot_note=195932>1</sup>).
  text = text.replaceAll(
    RegExp(r'<sup[^>]*foot_note[^>]*>.*?</sup>', caseSensitive: false),
    '',
  );
  // Remove any remaining <sup>...</sup> blocks.
  text = text.replaceAll(
    RegExp(r'<sup[^>]*>.*?</sup>', caseSensitive: false),
    '',
  );
  // Convert <br> variants to newlines before stripping tags.
  text = text.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
  // Strip remaining HTML tags.
  text = text.replaceAll(RegExp(r'<[^>]+>'), '');
  // Decode common entities.
  text = text
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&apos;', "'")
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>');
  // Collapse excessive whitespace/newlines left behind.
  text = text.replaceAll(RegExp(r'[ \t]+'), ' ');
  text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  return text.trim();
}
