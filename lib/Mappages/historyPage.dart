import 'package:flutter/material.dart';
import 'package:google_maps_webservice/src/places.dart';

class SearchHistories extends StatefulWidget {
  final String Searchhint;
  SearchHistories({required this.Searchhint}) : super();

  @override
  State<SearchHistories> createState() => _SearchHistories();
}

class _SearchHistories extends State<SearchHistories> {
  final TextEditingController _searchController = TextEditingController();

  String apiKey = 'AIzaSyAwcZL9g3S3OPmvxn1MKW6Mz5WIGITGf9E';
  GoogleMapsPlaces googleMapsPlaces =
      GoogleMapsPlaces(apiKey: 'AIzaSyAwcZL9g3S3OPmvxn1MKW6Mz5WIGITGf9E');
  List<Prediction> _predictions = [];

  void _onSearchtextChanged(String value) async {
    if (value.isNotEmpty) {
      try {
        final predictions = await placeApiprovider.searchplaces(value);
        setState(() {
          _predictions = predictions;
        });
      } catch (e) {
        print("error:$e");
      }
    } else {
      setState(() {
        _predictions = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Card(
                  elevation: 6,
                  color: Colors.blueGrey[50],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          )),
                      Container(
                        height: 50,
                        width: 300,
                        child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              _onSearchtextChanged(value);
                            },
                            decoration: InputDecoration(
                              hintText: '${widget.Searchhint}',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                              contentPadding:
                                  EdgeInsets.fromLTRB(10, 12, 12, 12),
                              fillColor: Colors.blueGrey[50],
                              filled: true,
                              enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.white, width: 0),
                                  borderRadius: BorderRadius.circular(20)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.white, width: 0),
                                  borderRadius: BorderRadius.circular(20)),
                            )),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                thickness: 1,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 10),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "History",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.76,
                child: ListView.builder(
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 6,
                      child: Container(
                        height: 59,
                        child: ListTile(
                          leading: IconButton(
                              onPressed: () {},
                              icon: Container(
                                height: 30,
                                width: 50,
                                child: Image.asset(
                                    "android/assets/location_icon.png"),
                              )),
                          title: Text(
                            "thinQ24",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            "Guindy",
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          trailing: Icon(Icons.favorite_outline),
                          onTap: () async {
                            final placeDetails = await placeApiprovider
                                .getplacesDetails(_predictions[index].placeId!);
                            print("place:${placeDetails.result.name}");
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 150,
                  ),
                  Icon(Icons.gps_fixed),
                  Text("Select from Map")
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

final googleMapsPlaces =
    GoogleMapsPlaces(apiKey: 'AIzaSyAwcZL9g3S3OPmvxn1MKW6Mz5WIGITGf9E');

class placeApiprovider {
  static Future<List<Prediction>> searchplaces(String searchTerm) async {
    final response = await googleMapsPlaces.autocomplete(searchTerm,
        types: ['(cities)'], language: 'en');
    if (response.isOkay) {
      return response.predictions;
    } else {
      throw response.errorMessage!;
    }
  }

  static Future<PlacesDetailsResponse> getplacesDetails(String placeId) async {
    final response = await googleMapsPlaces.getDetailsByPlaceId(placeId);
    if (response.isOkay) {
      return response;
    } else {
      throw response.errorMessage!;
    }
  }
}
