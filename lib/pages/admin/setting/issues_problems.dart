import 'package:flutter/material.dart';

class IssuesProblems extends StatefulWidget {
  const IssuesProblems({super.key});

  @override
  State<IssuesProblems> createState() => _IssuesProblemsState();
}

class _IssuesProblemsState extends State<IssuesProblems> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feedback"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                            'https://via.placeholder.com/150'), // Replace with actual image URL
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jerome Bell',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '2 week ago',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet sint. '
                    'Velit officia consequat duis enim velit mollit. Exercitation veniam '
                    'consequat sunt nostrud amet.',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
