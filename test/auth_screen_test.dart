import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotrendy/screens/auth_screen.dart';

void main() {
  group('AuthScreen', () {
    Future<void> openScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AuthScreen(brandName: 'GoPlay'),
        ),
      );
    }

    Future<void> openRegistration(WidgetTester tester) async {
      await openScreen(tester);
      await tester.tap(find.text('Kayıt ol'));
      await tester.pumpAndSettle();
    }

    Future<void> fillRegistration(
      WidgetTester tester, {
      String password = '123456',
      String confirmation = '123456',
    }) async {
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Bekir Sazak');
      await tester.enterText(fields.at(1), 'bekir@example.com');
      await tester.enterText(fields.at(2), password);
      await tester.enterText(fields.at(3), confirmation);
    }

    testWidgets('login form validates email and password', (tester) async {
      await openScreen(tester);

      await tester.tap(find.text('GİRİŞ YAP'));
      await tester.pumpAndSettle();

      expect(find.text('Geçerli bir e-posta adresi girin.'), findsOneWidget);
      expect(find.text('Şifre en az 6 karakter olmalı.'), findsOneWidget);
    });

    testWidgets('registration rejects mismatched passwords', (tester) async {
      await openRegistration(tester);
      await fillRegistration(
        tester,
        password: '123456',
        confirmation: '654321',
      );

      final submitButton = find.text('HESAP OLUŞTUR');
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('Şifreler eşleşmiyor.'), findsOneWidget);
    });

    testWidgets('registration requires terms acceptance', (tester) async {
      await openRegistration(tester);
      await fillRegistration(tester);

      final submitButton = find.text('HESAP OLUŞTUR');
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(
        find.text('Devam etmek için koşulları kabul edin.'),
        findsOneWidget,
      );

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(
        find.text('Form hazır. Kayıt servisi henüz bağlanmadı.'),
        findsOneWidget,
      );
    });
  });
}
