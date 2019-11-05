import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart';
import 'package:smrobotics/config.dart';
import 'package:smrobotics/constants.dart';
import 'package:smrobotics/eventPage.dart';
import 'package:smrobotics/timer.dart';


class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin{
  Widget body;
  List<Event> events;
  
  Widget titleWidget;
  bool isSearching;
  AnimationController searchIconController;
  TextEditingController searchController;

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    titleWidget = new Text("Analysis");
    isSearching = false;
    searchIconController = new AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500)
    );
    searchController = new TextEditingController();
    this.body = Center(child: CircularProgressIndicator());
    getEvents();
  }
    
      @override
      Widget build(BuildContext context) {
        return Scaffold(
          key: _scaffoldKey,
          drawer: Drawer(
            child: ListView(
              children: <Widget>[
                ListTile(
                  title: Text("Timer"),
                  subtitle: Text("FTC Game timer"),
                  trailing: Icon(Icons.timer, color: Colors.black,),
                  onTap: ()=>Navigator.of(context).push(
                    MaterialPageRoute(
                      fullscreenDialog:true,
                      maintainState:true,
                      builder:(c)=>GameTimer()
                    )
                  ),
                )
              ],
            ),
          ),
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.menu),
              onPressed: ()=>_scaffoldKey.currentState.openDrawer(),
            ),
            title: AnimatedSwitcher(child:titleWidget, duration: Duration(milliseconds: 300), transitionBuilder: (w,a)=>ScaleTransition(scale: a,child: w)),
          ),
          floatingActionButton: FloatingActionButton(
            child: AnimatedIcon(
              icon: AnimatedIcons.search_ellipsis,
              progress: searchIconController,
            ),
            onPressed: (){
              setState(() {
                if(this.isSearching){
                  this.isSearching = false;
                  //CLOSE SEARCH
                  searchIconController.reverse();

                  setState(() {
                    titleWidget = Text("Analysis");
                  });
                }else{
                  this.isSearching = true;
                  //OPEN SEARCH
                  searchIconController.forward();

                  setState(() {
                    titleWidget = Container(
                      padding: EdgeInsets.symmetric(vertical: 3),
                      child: TextField(
                        autofocus: true,
                        autocorrect: false,
                        keyboardAppearance: Brightness.light,
                        controller: searchController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.white)
                          ),
                          focusColor: Colors.white,
                          labelText: "Search Competitions",
                          labelStyle: TextStyle(color:Colors.white)
                        ),

                        onChanged: (v){
                          List<Event> searchedEvents = [];
                          for (Event event in this.events) {
                            if(event.name().toLowerCase().contains(v.toLowerCase())||event.venue().toLowerCase().contains(v.toLowerCase())){
                              searchedEvents.add(event);
                            }
                          }
                          if(searchedEvents.isEmpty){
                            _scaffoldKey.currentState.removeCurrentSnackBar();
                            _scaffoldKey.currentState.showSnackBar(
                              SnackBar(
                                backgroundColor: secondaryColor,
                                content: Text("No events with that name found"),
                                action: SnackBarAction(
                                  label: "Ok",
                                  onPressed: ()=>_scaffoldKey.currentState.hideCurrentSnackBar(),
                                ),
                              )
                            );
                          }else{
                            _scaffoldKey.currentState.hideCurrentSnackBar();
                          }
                          setState(() {
                            body = buildEventsGridview(events:searchedEvents);
                          });
                        },
                      ),
                    );
                  });
                  
                }
              });
            },
          ),
          body: body,
          // body: FutureBuilder(
          //   future: get(baseURL+"event/", headers: requiredHeadersWithSeason),
          //   builder: (c,s){
          //     if(s.connectionState!=ConnectionState.done){
          //       return Center(child: CircularProgressIndicator());
          //     }else if(s.hasError){
          //       return Center(child: Text("Sorry, we are having trouble connecting to The Orange Alliance Servers", textAlign: TextAlign.center,));
          //     }else{
          //       Response response = s.data;
          //       String responseBody = response.body;
          //       List events = jsonDecode(responseBody);
          //       List<Event> formattedEvents = formatEvents(events: events);
          //       return buildEventsGridview(events: formattedEvents);
          //     }
          //   },
          // ),
        );
        
      }

      GridView buildEventsGridview({List<Event> events}) {
        return GridView.builder(
          
          padding: EdgeInsets.all(15),
          itemCount: events.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 25,
            mainAxisSpacing: 25  
          ),
          itemBuilder: (c,i){
            Event event = events[i];
            return RaisedButton(
              splashColor: i%2==0?primaryColor:secondaryColor,
              elevation: 15,
              focusElevation: 0,
              onPressed: ()=>Navigator.of(context).push(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  maintainState: true,
                  builder: (c)=>CompetitionView(event)
                )
              ),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(35)
              ),
              child: Text(event.name(), textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            );
          },
        );
      }
      List formatEvents({@required List events}){
        List<Event> formattedEvents = [];
        for(Map event in events){
          try {
            Event formattedEvent = new Event(event: event);
            formattedEvents.add(formattedEvent);
          } catch (e) {
          }
        }
        return formattedEvents;
      }
    void getEvents() async{
        Future<Response> events = get(baseURL+"event/", headers: requiredHeadersWithSeason);
        events.catchError((onError){
          setState(() {
            body = Center(child: Text("Sorry, we are having trouble connecting to The Orange Alliance servers", textAlign: TextAlign.center));
          });
        });

        Response response = await events;
        String responseBody = response.body;
        List eventsUnF = jsonDecode(responseBody);
        List<Event> formattedEvents = formatEvents(events: eventsUnF);
        this.events = formattedEvents;
        setState(() {
            body = buildEventsGridview(events: this.events);
          });
      }
      
}

class Event{
  Map event;
  Event(
    {
      @required this.event
    }
  );

  String name(){
    if(event['event_name']!=null){
      return event['event_name'];
    }else{
      return "Unnamed Event";
    }
  }
  String eventKey()=>event['event_key'];

  String city(){
    if(event['city']!=null){
      return event['city'];
    }else{
      return "";
    }
  }

  String country(){
    if(event['country']!=null){
      return event['country'];
    }else{
      return "";
    }
  }

  String venue(){
    if(event['venue']!=null){
      return event['venue'];
    }else{
      return "";
    }
  }

  bool hasFieldCount(){
    if(event['field_count']!=null){
      return true;
    }else{
      return false;
    }
  }
  String fieldCount(){
    if(event['field_count']==null){
      return "Unknown Field Count";
    }else{
      return event['field_count'].toString()+" Fields";
    }
  }

  String website()=>event['website'];

  bool hasWebsite()=>event['website']!=null;

  bool isActive()=>event['is_active']==true;

}