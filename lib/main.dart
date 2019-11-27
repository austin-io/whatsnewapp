import 'package:flutter/cupertino.dart';
import "package:url_launcher/url_launcher.dart"; 
import "package:http/http.dart" as http;
import "dart:convert" as convert;
import 'package:flutter/material.dart';
import "./components/sort_button.dart";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "What's New?",
      home: MyHomePage(title: Text("What's New?", style: TextStyle(
            fontWeight: FontWeight.w100,
            color: Colors.black
          )
        )
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final Text title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  Map<String, dynamic> _data;
  String _searchQuery = "";
  String _sort = "";
  String _baseUrl = "";
  int _pageNumber;
  bool _isLoading = false;
  String apiKey = "df3ca0eaf750486582cad74f24406454";

  Future<dynamic> getData() async {
    _isLoading = true;
    http.Response response = await http.get(
      _baseUrl + "apiKey=$apiKey" + _searchQuery + _sort + "&page=$_pageNumber"
    );

    this.setState(() {
      _data = convert.json.decode(response.body);
      _isLoading = false;
    });
  }

  _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<Null> _onRefresh() async {
    await new Future.delayed(new Duration(seconds: 1));
    this.getData();
    return null;
  }

  @override
  void initState() {
    super.initState();
    _pageNumber = 1;
    _baseUrl = "https://newsapi.org/v2/top-headlines?language=en&country=us&";
    this.getData();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: (){
            setState(() {
              _pageNumber = 1;
              _baseUrl = "https://newsapi.org/v2/top-headlines?language=en&country=us&";
              _searchQuery = "";
              this.getData();
            });
          },
          child: widget.title,
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: (){
            setState(() {
              _pageNumber = 1;
              _baseUrl = "https://newsapi.org/v2/top-headlines?language=en&country=us&";
              _searchQuery = "";
              this.getData();
            });
          },
          child: Icon(
            Icons.home,
            color: Colors.green[300],
          ),
        ),
      ), 
      body: Center (
        child: RefreshIndicator(
          child: Column(
            children: <Widget>[
              Container(
                height: 50,
                padding: EdgeInsets.all(8),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        onChanged: (String s){
                          setState(() {
                            if(s.isEmpty){
                              _pageNumber = 1;
                              _baseUrl = "https://newsapi.org/v2/top-headlines?language=en&country=us&";
                              _searchQuery = "";
                            } else {
                              _pageNumber = 1;
                              _baseUrl = "https://newsapi.org/v2/everything?language=en&";
                              String _search = Uri.encodeComponent(s);
                              _searchQuery = "&q=$_search";
                            }
                          });
                        },
                        decoration: InputDecoration(
                          fillColor: Colors.black.withOpacity(0.05),
                          filled: true,
                          prefixIcon: Icon(Icons.search, color: Colors.green[300],),
                          hintText: 'Looking for something?',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                          contentPadding: EdgeInsets.zero
                        )
                      ),
                    ),
                    Container(
                      child: RaisedButton(
                        child: Text("Search", style: TextStyle(color: Colors.white)),
                        color: Colors.green[300],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                        onPressed: () => getData(),
                      ),
                      padding: EdgeInsets.only(left: 5)
                    ),
                  ],
                )
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SortButton("Popular", () {
                        _sort = "&sortBy=popularity";
                        _pageNumber = 1;
                        getData();
                      }
                    ),
                    SortButton("Relevant", () {
                        _sort = "&sortBy=relevancy";
                        _pageNumber = 1;
                        getData();
                      }
                    ),
                    SortButton("New", () {
                        _sort = "&sortBy=publishedAt";
                        _pageNumber = 1;
                        getData();
                      }
                    ),
                  ],
                ),
              ),
              _data != null ? _data["articles"].length == 0 ? Padding(
                padding: EdgeInsets.all(20),
                child: Text("Oh no! We couldn't find any more articles!", style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[500]
                  )
                )
              )
              : SizedBox.shrink()
              : SizedBox.shrink(),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: _data == null ? 0 : _data["articles"].length,
                  itemBuilder: (BuildContext context, int index) {
                    return new GestureDetector(
                      onTap: () {
                        _launchUrl(_data["articles"][index]["url"]);
                      },
                      child: new Card(
                        child: Column(
                          children: <Widget>[
                            // SizedBox.shrink() will return nothing
                            _data["articles"][index]["urlToImage"] == null ? SizedBox.shrink() : new Image.network(_data["articles"][index]["urlToImage"]),
                            new Container(
                              child: new Text(
                                _data["articles"][index]["title"],
                              ),
                              padding: EdgeInsets.all(20),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CupertinoButton(
                    child: Icon(Icons.arrow_back, color: Colors.green[300]),
                    onPressed: () {
                      _pageNumber < 2 ? _pageNumber = 1 : setState((){
                        _pageNumber--;
                        getData();
                      });
                    },
                  ),
                  Text("$_pageNumber", style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[500]
                  )),
                  CupertinoButton(
                    child: Icon(Icons.arrow_forward, color: Colors.green[300]),
                    onPressed: () {
                      if(!_isLoading && _data["articles"].length != 0){
                        setState(() {
                          _pageNumber++;
                          getData();
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          onRefresh: _onRefresh,
        )
      )
    );
  }
}
