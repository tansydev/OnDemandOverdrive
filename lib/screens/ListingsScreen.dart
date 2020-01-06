import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ondemand_overdrive/models/Listing.dart';
import 'package:http/http.dart' as http;
import 'package:ondemand_overdrive/screens/ListingDetailScreen.dart';
import 'package:transparent_image/transparent_image.dart';

class ListingsScreen extends StatefulWidget {
  ListingsScreen({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _ListingPageState createState() => _ListingPageState();
}

class _ListingPageState extends State<ListingsScreen> {

  Future<List<Listing>> _listingsFuture;
  Future<List<Listing>> _filteredListings;
  List<String> _selectedListingTypes;

  @override
  void initState(){
    super.initState();
    _listingsFuture = _getListings();
    _selectedListingTypes = ['movie','series'];
    _filterListings();
  }

  void _filterListings(){
    setState(() {
      _filteredListings = _listingsFuture.then((listings) => listings.where((l) => _selectedListingTypes.contains(l.type)).toList());
    });
  }

  Future<List<Listing>> _getListings() async {
    final response = await http.get('http://test.1024design.co.uk/api/listings');

    if (response.statusCode == 200){
      var data = jsonDecode(response.body);
      var listings = data as List;
      return listings.map<Listing>((json) => Listing.fromJson(json)).toList();
    }
    else {
      throw Exception();
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: _buildListings(),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Apply Filters'),
            ),
            CheckboxListTile(
              title: const Text('Movies'),
              value: _selectedListingTypes.contains('movie'),
              onChanged: (bool checked){
                if (checked){
                  this._selectedListingTypes.add('movie');
                }
                else {
                  this._selectedListingTypes.remove('movie');
                }
                _filterListings();
              },
            ),
            CheckboxListTile(
              title: const Text('Series'),
              value: _selectedListingTypes.contains('series'),
              onChanged: (bool checked){
                if (checked){
                  this._selectedListingTypes.add('series');
                }
                else {
                  this._selectedListingTypes.remove('series');
                }
                _filterListings();
              },
            ),
          ]
        )
      ),
    );
  }

  Widget _buildListings(){

    return Container(
        padding: const EdgeInsets.only(left: 8, right: 8),
        child: FutureBuilder(
            future: _filteredListings,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return GridView.builder(
                  itemCount: snapshot.data.length,
                  padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
                  gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, i) {
                    return _buildListing(snapshot.data[i]);
                  }
                );
              }
              return Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
        )
    );
  }

  Widget _buildListing(Listing listing){
    return GestureDetector(
      child: Column(
          children: [
            Expanded(
              flex: 10,
              child: ClipRRect(
                borderRadius: new BorderRadius.circular(8.0),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Image(
                        image: AssetImage('assets/images/placeholder.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                    FadeInImage(
                      image: NetworkImage(listing.image),
                      fit: BoxFit.contain,
                      placeholder: AssetImage('assets/images/placeholder-trans.png'),
                    ),
                  ]
                )
              ),
            ),
            Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    listing.name,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                )
            ),
          ]
      ),
      onTap: () => _pushListingDetailPage(listing.id),
    );
  }

  void _pushListingDetailPage(BigInt id) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
            body: ListingDetailScreen(id: id),
          );
        },
      ),
    );
  }
}