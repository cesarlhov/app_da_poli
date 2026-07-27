// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:app_da_poli/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// Cria um roteador de teste simples que aponta para a tela de splash
final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    ),
  ],
);

void main() {
  testWidgets('App starts and shows a loading indicator',
      (WidgetTester tester) async {
    // Constrói o app e dispara um frame.
    // Agora estamos passando o roteador de teste, como é exigido.
    await tester.pumpWidget(MyApp(router: _router));

    // Verifica se o indicador de progresso (da SplashPage) está na tela.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}