import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nexa_ai/features/chatbot/presentation/screens/chat_screen.dart';

final appRouter = GoRouter(
  initialLocation: ChatScreen.routeName,
  routes: <GoRoute>[
    GoRoute(
      path: ChatScreen.routeName,
      builder: (context, state) => const ChatScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text(state.error.toString()),
    ),
  ),
);
