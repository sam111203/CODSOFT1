import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'favQuotes.dart';

void main() {
  runApp(QuotesApp());
}

class QuotesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.green),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String quote = '';
  List<String> fQuotes = [];

  @override
  void initState() {
    super.initState();
    fetchRandomQuote();
    loadSavedQuotes(); // Load saved quotes when the app starts
  }

  Future<void> fetchRandomQuote() async {
    try {
      final response = await http.get(Uri.parse('https://api.quotable.io/random'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final randomQuote = data['content'].toString();

        setState(() {
          quote = randomQuote;
        });
      } else {
        throw Exception('Failed to load quote');
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to load quote. Please try again later.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> loadSavedQuotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedQuotes = prefs.getStringList('savedQuotes');

    if (savedQuotes != null) {
      setState(() {
        fQuotes = savedQuotes;
      });
    }
  }

  void saveQuote() async {
    if (quote.isNotEmpty) {
      setState(() {
        fQuotes.add(quote);
      });
      Fluttertoast.showToast(
        msg: 'Quote saved!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      // Save the updated fQuotes list to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setStringList('savedQuotes', fQuotes);
    } else {
      Fluttertoast.showToast(
        msg: 'Quote is empty. Please fetch a quote first.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void navigateToFavQuotes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FQuotes(fQuotes: fQuotes),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quote of the day!!'),
        actions: [
          IconButton(
            onPressed: navigateToFavQuotes,
            icon: Icon(Icons.favorite),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(left: 10, right: 5),
              padding: EdgeInsets.only(left: 10, right: 10, top: 50, bottom: 50),
              decoration: BoxDecoration(
                color: Colors.lightGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                quote.isEmpty ? 'Loading quote...' : quote,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: saveQuote,
                  icon: Icon(Icons.save_alt),
                ),
                IconButton(
                  onPressed: () async {
                    if (quote.isNotEmpty) {
                      await Share.share(quote);
                    } else {
                      Fluttertoast.showToast(
                        msg: 'Quote is empty. Please fetch a quote first.',
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                      );
                    }
                  },
                  icon: Icon(Icons.share),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchRandomQuote,
        child: Icon(Icons.refresh),
      ),
    );
  }
}
