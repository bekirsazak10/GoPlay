import 'dart:ui' show Tristate;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotrendy/screens/auth_screen.dart';

TextField textFieldFor(WidgetTester tester, Finder formField) {
  final textField = find.descendant(
    of: formField,
    matching: find.byType(TextField),
  );
  return tester.widget<TextField>(textField);
}

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
        textFieldFor(tester, fields.at(0)).autofillHints,
        contains(AutofillHints.username),
      );
      expect(
        textFieldFor(tester, fields.at(1)).autofillHints,
        contains(AutofillHints.password),
      );
      expect(find.byType(AutofillGroup), findsOneWidget);

      await tester.tap(find.text('Kayıt ol'));
      await tester.pumpAndSettle();

      fields = find.byType(TextFormField);
      expect(
        textFieldFor(tester, fields.at(0)).autofillHints,
        contains(AutofillHints.name),
      );
      expect(
        textFieldFor(tester, fields.at(1)).autofillHints,
        contains(AutofillHints.newUsername),
      );
      expect(
        textFieldFor(tester, fields.at(2)).autofillHints,
        contains(AutofillHints.newPassword),
      );
      expect(
        textFieldFor(tester, fields.at(3)).autofillHints,
        contains(AutofillHints.newPassword),
      );
      expect(
        textFieldFor(tester, fields.at(0)).textCapitalization,
        TextCapitalization.words,
      );
      expect(
        textFieldFor(tester, fields.at(1)).keyboardType,
        TextInputType.emailAddress,
      );
      expect(
        textFieldFor(tester, fields.at(2)).enableSuggestions,
        isFalse,
      );
    });

    testWidgets('login and registration mode expose selected semantics',
        (tester) async {
      await openScreen(tester);

      var loginMode = tester.getSemantics(
        find.bySemanticsLabel('Giriş yap'),
      );
      var registrationMode = tester.getSemantics(
        find.bySemanticsLabel('Kayıt ol'),
      );

      expect(loginMode.getSemanticsData().flagsCollection.isButton, isTrue);
      expect(
        loginMode.getSemanticsData().flagsCollection.isSelected,
        Tristate.isTrue,
      );
      expect(
        registrationMode.getSemanticsData().flagsCollection.isButton,
        isTrue,
      );
      expect(
        registrationMode.getSemanticsData().flagsCollection.isSelected,
        Tristate.isFalse,
      );

      await tester.tap(find.text('Kayıt ol'));
      await tester.pumpAndSettle();

      loginMode = tester.getSemantics(
        find.bySemanticsLabel('Giriş yap'),
      );
      registrationMode = tester.getSemantics(
        find.bySemanticsLabel('Kayıt ol'),
      );

      expect(
        loginMode.getSemanticsData().flagsCollection.isSelected,
        Tristate.isFalse,
      );
      expect(
        registrationMode.getSemanticsData().flagsCollection.isSelected,
        Tristate.isTrue,
      );
    });

    testWidgets('password visibility controls are independent', (tester) async {
      await openRegistration(tester);

      final fields = find.byType(TextFormField);
      expect(textFieldFor(tester, fields.at(2)).obscureText, isTrue);
      expect(textFieldFor(tester, fields.at(3)).obscureText, isTrue);

      await tester.tap(find.byTooltip('Şifreyi göster').first);
      await tester.pumpAndSettle();

      expect(textFieldFor(tester, fields.at(2)).obscureText, isFalse);
      expect(textFieldFor(tester, fields.at(3)).obscureText, isTrue);

      await tester.tap(find.byTooltip('Şifreyi göster'));
      await tester.pumpAndSettle();

      expect(textFieldFor(tester, fields.at(2)).obscureText, isFalse);
      expect(textFieldFor(tester, fields.at(3)).obscureText, isFalse);
    });

    testWidgets('registration shows live password strength feedback',
        (tester) async {
      await openRegistration(tester);

      final fields = find.byType(TextFormField);
      expect(find.textContaining('Şifre gücü:'), findsNothing);

      await tester.enterText(fields.at(2), '123456');
      await tester.pump();
      expect(find.text('Şifre gücü: Zayıf'), findsOneWidget);

      await tester.enterText(fields.at(2), '12345678');
      await tester.pump();
      expect(find.text('Şifre gücü: Orta'), findsOneWidget);

      await tester.enterText(fields.at(2), 'Sifre123!');
      await tester.pump();
      expect(find.text('Şifre gücü: Güçlü'), findsOneWidget);
    });

    testWidgets('registration explains each password requirement',
        (tester) async {
      await openRegistration(tester);

      final passwordField = find.byType(TextFormField).at(2);
      await tester.enterText(passwordField, '123456');
      await tester.pump();

      expect(find.text('En az 8 karakter'), findsOneWidget);
      expect(find.text('Büyük ve küçük harf'), findsOneWidget);
      expect(find.text('En az bir rakam'), findsOneWidget);
      expect(find.text('Özel karakter'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(3));
      expect(
        find.bySemanticsLabel('En az 8 karakter: eksik'),
        findsOneWidget,
      );

      await tester.enterText(passwordField, 'Sifre123!');
      await tester.pump();

      expect(find.byIcon(Icons.check_circle), findsNWidgets(4));
      expect(find.byIcon(Icons.radio_button_unchecked), findsNothing);
      expect(
        find.bySemanticsLabel('En az 8 karakter: tamamlandı'),
        findsOneWidget,
      );
    });

    testWidgets('switching auth modes clears passwords and hides them again',
        (tester) async {
      await openRegistration(tester);

      var fields = find.byType(TextFormField);
      await tester.enterText(fields.at(1), 'bekir@example.com');
      await tester.enterText(fields.at(2), 'secret123');
      await tester.enterText(fields.at(3), 'secret123');

      await tester.tap(find.byTooltip('Şifreyi göster').first);
      await tester.pumpAndSettle();
      expect(textFieldFor(tester, fields.at(2)).obscureText, isFalse);

      await tester.tap(find.text('Giriş yap'));
      await tester.pumpAndSettle();

      fields = find.byType(TextFormField);
      expect(
        textFieldFor(tester, fields.at(0)).controller!.text,
        isEmpty,
      );
      expect(textFieldFor(tester, fields.at(1)).controller!.text, isEmpty);

      await tester.tap(find.text('Kayıt ol'));
      await tester.pumpAndSettle();

      fields = find.byType(TextFormField);
      expect(textFieldFor(tester, fields.at(2)).controller!.text, isEmpty);
      expect(textFieldFor(tester, fields.at(3)).controller!.text, isEmpty);
      expect(textFieldFor(tester, fields.at(2)).obscureText, isTrue);
      expect(textFieldFor(tester, fields.at(3)).obscureText, isTrue);
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

    testWidgets('registration form supports compact screens and drag dismissal',
        (tester) async {
      tester.view.physicalSize = const Size(390, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: AuthScreen(brandName: 'GoPlay'),
        ),
      );
      await tester.tap(find.text('Kayıt ol'));
      await tester.pumpAndSettle();

      final scrollView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(
        scrollView.keyboardDismissBehavior,
        ScrollViewKeyboardDismissBehavior.onDrag,
      );

      final submitButton = find.text('HESAP OLUŞTUR');
      await tester.ensureVisible(submitButton);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
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
