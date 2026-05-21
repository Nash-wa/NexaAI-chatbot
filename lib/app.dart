import 'package:flutter/material.dart';

import 'features/chatbot/presentation/screens/chat_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NexaAI',
      theme: ThemeData.dark(),
      home: const ChatScreen(),
    );
  }
}
