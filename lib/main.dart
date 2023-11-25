import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'square_tile.dart';

Future<Map> fetchMarvelComics() async {
  const publicKey = 'da059c01832ea7c2678b00041d90cc48';
  const privateKey = '47787cc5eeafb7dd1b301e74bb816cf8ef6a50bc';
  final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  final hash = md5.convert(utf8.encode(timestamp + privateKey + publicKey)).toString();

  final response = await http.get(
    Uri.parse(
        'https://gateway.marvel.com/v1/public/comics?ts=$timestamp&apikey=$publicKey&hash=$hash'),
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load Comics');
  }
}

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
        primarySwatch: Colors.red,),
      home: Scaffold(
        appBar: AppBar(title: const Text('Marvel Comics')),
        body: FutureBuilder<Map>(
          future: fetchMarvelComics(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data?['data']['results'].length,
                itemBuilder: (context, index) {
                  var comics = snapshot.data?['data']['results'][index];
                  return SquareTile(
                    name: comics['title'] ?? 'No title available',
                    description: comics['description'] ?? 'No description available',
                    imagePath: '${comics['thumbnail']['path']}.${comics['thumbnail']['extension']}',
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
