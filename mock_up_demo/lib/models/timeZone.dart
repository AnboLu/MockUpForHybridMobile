import 'package:mock_up_demo/databaseHelper.dart';

class TimeZone{

  int id;
  int zone;
  int time;



  TimeZone(this.id,this.zone,this.time);


  TimeZone.fromMap(Map<String, dynamic> map){
    id=map['id'];
    zone=map['zone'];
    time=map['time'];
    
  }



  Map<String,dynamic> toMap(){
      return{
        DataBaseHelper.colId:id,
        DataBaseHelper.colZone:zone,
        DataBaseHelper.colTime:time
        
      };
    }
}