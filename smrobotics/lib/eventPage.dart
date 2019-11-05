import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:smrobotics/constants.dart';
import 'homePage.dart';

class CompetitionView extends StatefulWidget {
  Event theEvent;
  CompetitionView(this.theEvent);
  @override
  _CompetitionViewState createState() => new _CompetitionViewState(theEvent);
}

class _CompetitionViewState extends State<CompetitionView> {
  String toaEVENTURL;
  Event theEvent;
  _CompetitionViewState(this.theEvent);  //constructor

  Widget eventWebsite;
  Widget fieldCount;
  
  @override
  void initState() {

    if(theEvent.hasWebsite()){
      eventWebsite = CupertinoActionSheetAction(
        child: Text("View Event Website"),
        onPressed: ()=>launchWebview(context, title: theEvent.name(), url: theEvent.website()),
      );
    }else{
      eventWebsite = Container(height: 0);
    }
    if(theEvent.hasFieldCount()){
      fieldCount = CupertinoActionSheetAction(
        child: Text("Field Count"),
        onPressed: ()=>showCupertinoModalPopup(
          context: context,
          builder: (c)=>CupertinoAlertDialog(
            title: Text("Field Count"),
            content: Text(theEvent.name()+" has "+theEvent.fieldCount()+" field"+(theEvent.fieldCount()=="1"?"":"s")),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text("Ok"),
                onPressed: ()=>Navigator.of(context).pop(),
              )
            ],
          )
        ),
      );
    }else{
      fieldCount = Container(height: 0);
    }
  
    super.initState();
    toaEVENTURL = "https://theorangealliance.org/events/"+theEvent.eventKey();
  }
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text(theEvent.name()),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: (){
              showCupertinoModalPopup(
                context: context,
                builder: (c)=>CupertinoActionSheet(
                  cancelButton: CupertinoActionSheetAction(
                    child: Text("Cancel"),
                    onPressed: ()=>Navigator.of(context).pop(),
                  ),
                  actions: <Widget>[
                    CupertinoActionSheetAction(
                      child: Text("View on theorangealliance.org"),
                      onPressed: ()=>launchWebview(context, url: toaEVENTURL, title: theEvent.name())
                    ),
                    eventWebsite,
                    fieldCount,
                    
                  ],
                )
              );
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: get(
          makeEventURL("teams"),
          headers: requiredHeadersWithSeason,
        ),
        builder: (c,s){
          if(s.connectionState!=ConnectionState.done){
            return Center(child: CircularProgressIndicator());
          }else if(s.hasError){
            return Container(height: 0);
          }else{

            dynamic unFParticipants = jsonDecode(s.data.body);
            return SingleChildScrollView(
              child: Text(unFParticipants.toString()),
            );
          }
        },
      ),
    );
  }
  String makeEventURL(String ext)=>baseURL+"event/"+theEvent.eventKey()+"/"+ext;
}