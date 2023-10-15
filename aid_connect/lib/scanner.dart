import 'dart:typed_data';
import 'package:flutter/material.dart';

int getphone(Uint8List data){
  String t="";
  for(int i=3;i<data.length;i++){
    t+=data[i].toString();
  }
  return int.parse(t);
}
int gettype(Uint8List data){
  return data[2];
}
double getlat(Uint8List data){
  int flag=data[1];
  String lat=data[3].toString();
  lat+='.';
  int i=4;
  while(i!=7){
    if(data[i]==0)lat+='00';
    else if(data[i]<10)lat+='0'+data[i].toString();
    else lat+=data[i].toString();
  }
  if(flag==1)lat='-'+lat;
  return double.parse(lat);
}
double getlon(Uint8List data){
  int flag=data[2];
  String lon=data[7].toString();
  lon+='.';
  int i=8;
  while(i!=11){
    if(data[i]==0)lon+='00';
    else if(data[i]<10)lon+='0'+data[i].toString();
    else lon+=data[i].toString();
  }
  if(flag==1)lon='-'+lon;
  return double.parse(lon);
}