import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Mood> fetchMood(String input) async {
  final response = await http
      .post(Uri.parse('http://localhost:5001/analyzeSentiment'), 
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "text": input,
    }));

  if (response.statusCode >= 200 && response.statusCode < 300) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Mood.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Mood');
  }
}

class Mood {
  final double moodScale;

  const Mood({
    required this.moodScale
  });

  factory Mood.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'sent_score': double moodScale,
      } =>
        Mood(
          moodScale: moodScale,
        ),
      _ => throw const FormatException('Failed to load Mood.'),
    };
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<Mood> futureMood;
  String _inputText = "Hello World!";

  @override
  void initState() {
    super.initState();
    futureMood = fetchMood(_inputText);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Detector Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Mood Detector Example'),
        ),
        body: ListView(
          children: <Widget>[
            Center(child: 
              Padding(
                padding: const EdgeInsets.all(20.0), 
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _inputText = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Enter Text',
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    border: OutlineInputBorder(),
                  ),
                ),
              )
            ),
            Center(
              child:
                SizedBox(
                  height: 120,
                  child: FutureBuilder<Mood>(
                    future: futureMood,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if(snapshot.data!.moodScale <= 0.2 && snapshot.data!.moodScale >= -0.2) {
                          return const Icon(
                            Icons.sentiment_neutral, // Neutral face icon
                            size: 100,
                            color: Colors.yellow,
                          );
                        }
                        if(snapshot.data!.moodScale >= 0) {
                          return const Icon(
                            Icons.sentiment_satisfied, // Happy face icon
                            size: 100,
                            color: Colors.green,
                          );
                        } else {
                          return const Icon(
                            Icons.sentiment_dissatisfied, // Sad face icon
                            size: 100,
                            color: Colors.red,
                          );
                        }
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      }
                      // By default, show a loading spinner.
                      return const Center(child: SizedBox(
                        height: 70,
                        width: 70,
                        child: CircularProgressIndicator(),
                      ));
                    },
                  )
                )
              ),
              TextButton(
                onPressed: () {
                  // Add your button action here
                  setState(() {
                    futureMood = fetchMood(_inputText);
                  });
                },
                child: const Text('Assess Mood'),
              )
          ]
        ),
      ),
    );
  }
}