import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nexa_ai/features/chatbot/presentation/screens/onboarding_screen.dart';
import 'package:nexa_ai/features/chatbot/presentation/screens/home_screen.dart';
import 'package:nexa_ai/features/chatbot/presentation/screens/chat_screen.dart';
import 'package:nexa_ai/features/maps/presentation/screens/maps_screen.dart';

final appRouter = GoRouter(
  initialLocation: OnboardingScreen.routeName,
  routes: <GoRoute>[
    GoRoute(
      path: OnboardingScreen.routeName,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: HomeScreen.routeName,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: ChatScreen.routeName,
      builder: (context, state) => const ChatScreen(),
    ),
    GoRoute(
      path: MapsScreen.routeName,
      builder: (context, state) => const MapsScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text(state.error.toString()),
    ),
  ),
);
