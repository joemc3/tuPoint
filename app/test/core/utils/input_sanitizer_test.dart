import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/utils/input_sanitizer.dart';

void main() {
  group('InputSanitizer.sanitizeUsername', () {
    test('removes zero-width characters', () {
      // Zero-width space (U+200B)
      expect(InputSanitizer.sanitizeUsername('user\u200Bname'), 'username');

      // Zero-width non-joiner (U+200C)
      expect(InputSanitizer.sanitizeUsername('user\u200Cname'), 'username');

      // Zero-width joiner (U+200D)
      expect(InputSanitizer.sanitizeUsername('user\u200Dname'), 'username');

      // Byte Order Mark (U+FEFF)
      expect(InputSanitizer.sanitizeUsername('user\uFEFFname'), 'username');
    });

    test('removes control characters', () {
      // NULL character (U+0000)
      expect(InputSanitizer.sanitizeUsername('user\x00name'), 'username');

      // Backspace (U+0008)
      expect(InputSanitizer.sanitizeUsername('user\x08name'), 'username');

      // Escape (U+001B)
      expect(InputSanitizer.sanitizeUsername('user\x1Bname'), 'username');

      // DEL (U+007F)
      expect(InputSanitizer.sanitizeUsername('user\x7Fname'), 'username');
    });

    test('removes RTL override characters', () {
      // Right-to-Left Override (U+202E)
      expect(
        InputSanitizer.sanitizeUsername('user\u202Ename'),
        'username',
      );

      // Left-to-Right Override (U+202D)
      expect(
        InputSanitizer.sanitizeUsername('user\u202Dname'),
        'username',
      );

      // Pop Directional Formatting (U+202C)
      expect(
        InputSanitizer.sanitizeUsername('user\u202Cname'),
        'username',
      );

      // Right-to-Left Isolate (U+2067)
      expect(
        InputSanitizer.sanitizeUsername('user\u2067name'),
        'username',
      );
    });

    test('preserves international characters', () {
      // Chinese
      expect(InputSanitizer.sanitizeUsername('用户名'), '用户名');

      // Arabic
      expect(InputSanitizer.sanitizeUsername('المستخدم'), 'المستخدم');

      // Cyrillic
      expect(InputSanitizer.sanitizeUsername('пользователь'), 'пользователь');

      // Japanese
      expect(InputSanitizer.sanitizeUsername('ユーザー名'), 'ユーザー名');

      // Korean
      expect(InputSanitizer.sanitizeUsername('사용자이름'), '사용자이름');

      // Hebrew
      expect(InputSanitizer.sanitizeUsername('שם_משתמש'), 'שם_משתמש');
    });

    test('preserves emoji', () {
      expect(InputSanitizer.sanitizeUsername('user😀name'), 'user😀name');
      expect(InputSanitizer.sanitizeUsername('👍'), '👍');
    });

    test('trims whitespace', () {
      expect(InputSanitizer.sanitizeUsername('  username  '), 'username');
      expect(InputSanitizer.sanitizeUsername('\tusername\t'), 'username');
      expect(InputSanitizer.sanitizeUsername('\nusername\n'), 'username');
    });

    test('handles empty strings', () {
      expect(InputSanitizer.sanitizeUsername(''), '');
      expect(InputSanitizer.sanitizeUsername('   '), '');
    });

    test('handles mixed attacks', () {
      // Multiple attack vectors combined
      expect(
        InputSanitizer.sanitizeUsername(
            'user\u200B\x00\u202Ename\uFEFF\x1B'),
        'username',
      );
    });
  });

  group('InputSanitizer.sanitizeText', () {
    test('removes zero-width characters', () {
      expect(
        InputSanitizer.sanitizeText('Hello\u200BWorld'),
        'HelloWorld',
      );
    });

    test('removes most control characters', () {
      // NULL character should be removed
      expect(InputSanitizer.sanitizeText('Hello\x00World'), 'HelloWorld');

      // Backspace should be removed
      expect(InputSanitizer.sanitizeText('Hello\x08World'), 'HelloWorld');
    });

    test('preserves newlines and tabs', () {
      // Newline should be preserved
      expect(InputSanitizer.sanitizeText('Hello\nWorld'), 'Hello\nWorld');

      // Tab should be preserved
      expect(InputSanitizer.sanitizeText('Hello\tWorld'), 'Hello\tWorld');

      // Both together
      expect(
        InputSanitizer.sanitizeText('Hello\n\tWorld'),
        'Hello\n\tWorld',
      );
    });

    test('removes RTL override characters', () {
      expect(
        InputSanitizer.sanitizeText('Hello\u202EWorld'),
        'HelloWorld',
      );
    });

    test('preserves international text', () {
      // Multi-line Chinese text
      expect(
        InputSanitizer.sanitizeText('你好\n世界'),
        '你好\n世界',
      );

      // Arabic with newlines
      expect(
        InputSanitizer.sanitizeText('مرحبا\nالعالم'),
        'مرحبا\nالعالم',
      );
    });

    test('preserves emoji in text', () {
      expect(
        InputSanitizer.sanitizeText('Hello 😀 World'),
        'Hello 😀 World',
      );
    });

    test('handles long text with multiple issues', () {
      final input = 'Line 1\u200B with zero-width\n'
          'Line 2\u202E with RTL\n'
          'Line 3\x00 with NULL\n'
          'Line 4 clean';

      final expected = 'Line 1 with zero-width\n'
          'Line 2 with RTL\n'
          'Line 3 with NULL\n'
          'Line 4 clean';

      expect(InputSanitizer.sanitizeText(input), expected);
    });
  });

  group('InputSanitizer.sanitizeMaidenhead', () {
    test('converts to uppercase', () {
      expect(InputSanitizer.sanitizeMaidenhead('fn20xr'), 'FN20XR');
      expect(InputSanitizer.sanitizeMaidenhead('aa00aa'), 'AA00AA');
    });

    test('removes non-alphanumeric characters', () {
      expect(InputSanitizer.sanitizeMaidenhead('fn-20-xr'), 'FN20XR');
      expect(InputSanitizer.sanitizeMaidenhead('fn 20 xr'), 'FN20XR');
      expect(InputSanitizer.sanitizeMaidenhead('fn@20#xr'), 'FN20XR');
    });

    test('trims whitespace', () {
      expect(InputSanitizer.sanitizeMaidenhead('  fn20xr  '), 'FN20XR');
    });

    test('handles empty strings', () {
      expect(InputSanitizer.sanitizeMaidenhead(''), '');
    });

    test('removes unicode characters', () {
      // Maidenhead is ASCII-only format (ham radio standard)
      expect(InputSanitizer.sanitizeMaidenhead('fn20😀xr'), 'FN20XR');
      expect(InputSanitizer.sanitizeMaidenhead('用户fn20'), 'FN20');
    });
  });

  group('InputSanitizer edge cases', () {
    test('handles very long strings', () {
      final longString = 'a' * 10000;
      final sanitized = InputSanitizer.sanitizeUsername(longString);
      expect(sanitized.length, 10000);
      expect(sanitized, longString);
    });

    test('handles strings with only dangerous characters', () {
      expect(InputSanitizer.sanitizeUsername('\u200B\u200C\u200D'), '');
      expect(InputSanitizer.sanitizeText('\x00\x01\x02'), '');
    });

    test('handles mixed valid and invalid characters', () {
      expect(
        InputSanitizer.sanitizeUsername('user\u200B123'),
        'user123',
      );
      expect(
        InputSanitizer.sanitizeText('Hello\x00123'),
        'Hello123',
      );
    });
  });

  group('InputSanitizer security scenarios', () {
    test('prevents homograph attacks (visual spoofing)', () {
      // While we don't normalize Unicode, we remove dangerous characters
      // that could be used for attacks. Homograph detection would require
      // the unorm_dart package or similar.

      // Remove zero-width that could hide spoofed characters
      expect(
        InputSanitizer.sanitizeUsername('admin\u200Bx'),
        'adminx',
      );
    });

    test('prevents RTL text injection attacks', () {
      // RTL override could display "admintruestrue" as "eurttsure"
      final malicious = 'admin\u202Etrue';
      expect(InputSanitizer.sanitizeUsername(malicious), 'admintrue');
    });

    test('prevents invisible character injection', () {
      // Could be used to bypass length checks or display filters
      final malicious = 'user\u200B\u200C\u200D\uFEFFname';
      expect(InputSanitizer.sanitizeUsername(malicious), 'username');
    });

    test('prevents control character injection', () {
      // Could break terminal displays or logs
      // ESC character (0x1B) is removed, but [31m and [0m are regular ASCII
      final malicious = 'user\x1B[31mname\x1B[0m'; // ANSI color codes
      expect(
        InputSanitizer.sanitizeUsername(malicious),
        'user[31mname[0m', // ESC removed, but brackets/numbers remain
      );

      // Test with actual control characters only
      expect(
        InputSanitizer.sanitizeUsername('user\x1Bname'),
        'username', // ESC character removed
      );
    });
  });
}
