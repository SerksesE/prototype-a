import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrackerPage extends ConsumerWidget {
  const TrackerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text("Welcome on the Tracker Page")),
      body: Container(),
    );
  }
}
