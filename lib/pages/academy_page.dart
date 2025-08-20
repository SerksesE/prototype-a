import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AcademyPage extends ConsumerWidget {
  const AcademyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text("Welcome on the Academy Page")),
      body: Container(),
    );
  }
}
