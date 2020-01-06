import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ondemand_overdrive/models/ListingDetail.dart';
import 'package:transparent_image/transparent_image.dart';

class ListingDetailScreen extends StatelessWidget{
  final BigInt id;

  ListingDetailScreen({Key key, this.id}) : super(key: key);

  Future<ListingDetail> _getDetail() async {
    final response = await http.get('http://test.1024design.co.uk/api/listingdetail/get/' + this.id.toString());

    if (response.statusCode == 200){
      var data = jsonDecode(response.body);
      return ListingDetail.fromJson(data);
    }
    else {
      throw Exception();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ListingDetail>(
        future: _getDetail(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _buildStack(snapshot.data);
          }
          else if (snapshot.hasError) {
            throw new Exception();
          }
          return Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
    );
  }

  Widget _buildStack(ListingDetail listing) {
    return Stack(
      children: <Widget>[
        _buildBackgroundStack(listing),
        _buildForegroundStack(listing),
      ],
    );
  }

  Widget _buildForegroundStack(ListingDetail listing){
    var appBar = AppBar(
      backgroundColor: Colors.transparent,
      title: Text(
        listing.name,
        overflow: TextOverflow.ellipsis,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: appBar,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Padding(
            padding: EdgeInsets.only(top: constraints.maxHeight/5 - appBar.preferredSize.height, bottom: 8.0, left: 8.0, right: 8.0),
            child: Column(
              children: <Widget>[
                Container(
                  height: constraints.maxHeight/4,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 5,
                                  blurRadius: 5,
                                )
                              ]
                          ),
                          child: ClipRRect(
                              borderRadius: new BorderRadius.circular(8.0),
                              child: FadeInImage.assetNetwork(
                                image: listing.image,
                                width: constraints.maxWidth/3,
                                fit: BoxFit.contain,
                                placeholder: 'assets/images/placeholder.png',
                              )
                          ),
                        )
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.max,
                              textBaseline: TextBaseline.alphabetic,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Text(
                                    listing.name,
                                    style: TextStyle(fontSize: 18.0),
                                  ),
                                ),
                                Text(
                                  listing.releaseDate.toString() + " - " + listing.runtime,
                                ),
                              ],
                            ),
                        )
                      )
                    ],
                  ),
                ),
                _buildTextInfo('', listing.description),
                _buildTextInfo('Actors', listing.actors),
                _buildTextInfo('Directed By', listing.director),
                _buildTextInfo('Production', listing.production),
                _buildTextInfo('Genre', listing.genre),
              ],
            )

          );
        },
      ),
    );
  }

  Widget _buildTextInfo(String title, String detail){
    return Visibility(
      visible: detail != null && detail.length > 0,
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Column(
          children: <Widget>[
            Visibility(
              visible: title != null && title.length > 0,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                detail,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundStack(ListingDetail listing) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Stack(
            children: <Widget>[
              FadeInImage(
                image: NetworkImage(listing.image),
                height: constraints.maxHeight / 3,
                width: constraints.maxWidth,
                fit: BoxFit.cover,
                placeholder: MemoryImage(kTransparentImage),
              ),
              BackdropFilter(
                filter: new ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: new Container(
                  decoration: new BoxDecoration(color: Colors.grey[200].withOpacity(0.1)),
                ),
              ),
              FadeInImage(
                image: NetworkImage(listing.background),
                height: constraints.maxHeight / 3,
                width: constraints.maxWidth,
                fit: BoxFit.cover,
                placeholder: MemoryImage(kTransparentImage),
              ),
            ]
          );
        }
    );
  }
}