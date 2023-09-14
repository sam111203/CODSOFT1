import 'package:flutter/material.dart';

class FQuotes extends StatelessWidget {
  final List<String> fQuotes;

  FQuotes({Key? key, required this.fQuotes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fav Quotes'),
      ),
      body: ListView.builder(
        itemCount: fQuotes.length,
        itemBuilder: (BuildContext context, int index) {
          String i = fQuotes[index];
          return ListTile(
            title: Text('$index ) $i'),
          );
        },
      ),
    );
  }
}
