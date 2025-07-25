import 'package:flutter/material.dart';

class ActionPlanScreen extends StatelessWidget {
  final String goal;
  final Map<String, String> plan;

  const ActionPlanScreen({required this.goal, required this.plan, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Action Plan for $goal")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Recommended Allocation:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ...plan.entries.map((entry) => ListTile(
              title: Text(entry.key),
              trailing: Text(entry.value, style: TextStyle(fontWeight: FontWeight.bold)),
            )),
          ],
        ),
      ),
    );
  }
}
