import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotrendy/screens/auth_screen.dart';

void main() {
  group('AuthScreen', () {
    Future<void> openScreen(WidgetTester tester) async {
      tester.view.physicalSize = const Size(900, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

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
      final values = [
        'Bekir Sazak',
        'bekir@example.com',
        password,
        confirmation,
      ];

      for (var index = 0; index < values.length; index++) {
        final field = fields.at(index);
        await tester.ensureVisible(field);
        await tester.enterText(field, values[index]);
      }
    }

    testWidgets('login form validates email and password', (tester) async {
      await openScreen(tester);

      await tester.tap(find.text('GİRİŞ YAP'));
      await tester.pumpAndSettle();

      expect(find.text('Geçerli bir e-posta adresi girin.'), findsOneWidget);
      expect(find.text('Şifre en az 6 karakter olmalı.'), findsOneWidget);
    });

    testWidgets('login submits when the keyboard Done action is pressed',
        (tester) async {
      await openScreen(tester);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'bekir@example.com');
      await tester.enterText(fields.at(1), '123456');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(
        find.text('Form hazır. Giriş servisi henüz bağlanmadı.'),
        findsOneWidget,
      );
    });

    testWidgets('login and registration fields support autofill', (tester) async {
      await openScreen(tester);

      var fields = find.byType(TextFormField);
      expect(
        tester.widget<TextFormField>(fields.at(0)).autofillHints,
        contains(AutofillHints.username),
      );
      expect(
        tester.widget<TextFormField>(fields.at(1)).autofillHints,
        contains(AutofillHints.password),
      );
      expect(find.byType(AutofillGroup), findsOneWidget);

      await tester.tap(find.text('Kayıt ol'));
      await tester.pumpAndSettle();

      fields = find.byType(TextFormField);
      expect(
        tester.widget<TextFormField>(fields.at(0)).autofillHints,
        contains(AutofillHints.name),
      );
      expect(
        tester.widget<TextFormField>(fields.at(1)).autofillHints,
        contains(AutofillHints.newUsername),
      );
      expect(
        tester.widget<TextFormField>(fields.at(2)).autofillHints,
        contains(AutofillHints.newPassword),
      );
      expect(
        tester.widget<TextFormField>(fields.at(3)).autofillHints,
        contains(AutofillHints.newPassword),
      );
      expect(
        tester.widget<TextFormField>(fields.at(0)).textCapitalization,
        TextCapitalization.words,
      );
      expect(
        tester.widget<TextFormField>(fields.at(1)).keyboardType,
        TextInputType.emailAddress,
      );
      expect(
        tester.widget<TextFormField>(fields.at(2)).enableSuggestions,
        isFalse,
      );
    });

    testWidgets('password visibility controls are independent', (tester) async {
      await openRegistration(tester);

      final fields = find.byType(TextFormField);
      expect(tester.widget<TextFormField>(fields.at(2)).obscureText, isTrue);
      expect(tester.widget<TextFormField>(fields.at(3)).obscureText, isTrue);

      await tester.tap(find.byTooltip('Şifreyi göster').first);
      await tester.pumpAndSettle();

      expect(tester.widget<TextFormField>(fields.at(2)).obscureText, isFalse);
      expect(tester.widget<TextFormField>(fields.at(3)).obscureText, isTrue);

      await tester.tap(find.byTooltip('Şifreyi göster'));
      await tester.pumpAndSettle();

      expect(tester.widget<TextFormField>(fields.at(2)).obscureText, isFalse);
      expect(tester.widget<TextFormField>(fields.at(3)).obscureText, isFalse);
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

      final checkbox = find.byType(Checkbox);
      await tester.ensureVisible(checkbox);
      await tester.tap(checkbox);
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
