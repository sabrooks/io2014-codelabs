library polymer_and_dart.web.models;

import 'package:polymer/polymer.dart';
import 'dart:html';
import 'dart:indexed_db';
import 'dart:async';


/*
 * The barebones model for a codelab. Defines constants used for validation.
 */
class Codelab extends Observable {
  static const List<String> LEVELS = const ['easy', 'intermediate', 'advanced'];
  static const MIN_TITLE_LENGTH = 10;
  static const MAX_TITLE_LENGTH = 30;
  static const MAX_DESCRIPTION_LENGTH = 140;

  @observable String title;
  @observable String description;
  @observable String level;
  @observable String selected;
  
  var dbKey;
  

  Codelab([this.title = "", this.description = "", this.level =""]);
  
  String toString() => '$title $description $level';
  
  Codelab.fromDb(key, Map value){
    dbKey = key;
    title = value['title'];
    description = value['description'];
    level = value['level'];
    }
  
  Map<String, Object> toDb(){
      var codelabMap = new Map<String, Object>();
      codelabMap['title'] = title;
      codelabMap['description'] = description;
      codelabMap['level']=level;
      return codelabMap;
    }
}

class CodelabStore {
  static const String CODELAB_STORE = 'codelabStore';
  static const String NAME_INDEX = 'name_index';
  
  final List<Codelab> codelabs = toObservable(new List());
     
   Database _db;

   Future open(){
     return window.indexedDB.open('codelabDB',
       version: 1,
       onUpgradeNeeded: _initializeDatabase)
       .then(_loadFromDB);
   }      
       
  //Initializes the object store if it is brand new,
  // or upgrades it if the version is older.
       
  void _initializeDatabase (VersionChangeEvent e){
  Database db = (e.target as Request).result;
         
   var objectStore = db.createObjectStore(CODELAB_STORE,
    autoIncrement: true);
         
   //Create an index to search by name,
   //unique is true: the index doesn't allow duplicate milestone names.
   objectStore.createIndex(NAME_INDEX, 'codelabName', unique: true);
   }
  
   // Loads all of the existing objects from the database.
   //The future completes when the loading is finished.
       
 Future _loadFromDB(Database db){
   _db = db;
         
   var trans = db.transaction(CODELAB_STORE, 'readonly');
   var store = trans.objectStore(CODELAB_STORE);
         
   //Get everything in the store.
   var cursors = store.openCursor(autoAdvance: true).asBroadcastStream();
   cursors.listen((cursor){
      //Add codelab to the internal list.
      var codelab = new Codelab.fromDb(cursor.key, cursor.value);
      codelabs.add(codelab);
   });
   return cursors.length.then((_){
     return codelabs.length;
   });
 }
       
 //Add a new codelab to the codelabs in the Database.
 // This returns a future with the new codelab when the codelab
 //has been added.
 Future<Codelab> add(Codelab codelab){
    var codelabAsMap = codelab.toDb();
         
    var transaction = _db.transaction(CODELAB_STORE, 'readwrite');
    var objectStore = transaction.objectStore(CODELAB_STORE);
         
    objectStore.add(codelabAsMap).then((addedKey){
      //NOTE! The key cannot be used until the transaction completes.
      codelab.dbKey = addedKey;
    });
         
    //Note that the codelabe cannot by queried until the transaction 
    //has completed!
    return transaction.completed.then((_){
       //Once the transaction completes, add it to our list of available items.
       codelabs.add(codelab);
           
        //Return the codelabs so this becomes the result of the future.
       return codelab;
    });
 }
       
 //Removes a codelab fromt he list of codelabs
 //
 //This returns a Future which completes when the codelabe has been removed
       
 Future removeCodelab(Codelab codelab){
  //Remove from the database.
  var transaction = _db.transaction(CODELAB_STORE, 'readwrite');
  transaction.objectStore(CODELAB_STORE).delete(codelab.dbKey);
         
  return transaction.completed.then((_){
    //Null out the key to indicate that the codelab is dead.
    codelab.dbKey = null;
    //Remove from internal list.
    codelabs.remove(codelab);
  });
 }
 
  Future clear(){
    //Clear database
    var transaction = _db.transaction(CODELAB_STORE, 'readwrite');
    transaction.objectStore(CODELAB_STORE).clear();
    
    return transaction.completed.then((_) {
      //clear internal list.
      codelabs.clear();
    });
  }
}