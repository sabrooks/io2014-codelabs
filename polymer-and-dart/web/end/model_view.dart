import 'dart:async';
import 'dart:indexed_db';
import 'model.dart';
import 'package:polymer/polymer.dart';

/*
 * The VIEW-MODEL for the app.
 * 
 * Implements the business logic 
 * and manages the information exchanges
 * between the MODEL (Milestone & MilestoneStore)
 * and the VIEW (CountDownComponent & MilestoneComponent).
 * 
 * Manages a Timer to update the milestones.
 */

CodelabApp codelabApp = new CodelabApp();

class CodelabApp extends Observable {
  //Is IndexedDB supported in this browser?
  bool idbAvailable = IdbFactory.supported;
  
  CodelabStore _store = new CodelabStore();
  
  @observable bool hasCodelabs;
  
  List<Codelab> get codelabs =>_store.codelabs;
  
  
  
  //Life-cycle methods..
  
  //called from the VIEW when the element is inserted into the DOM
  Future start(){
    if(!idbAvailable){
      return new Future.error('IndexedDB not supported.');
    }
    
    return _store.open().then((_){
      hasCodelabs = notifyPropertyChange(const Symbol('hasCodelabs'),
          hasCodelabs, (codelabs.length == 0) ? false: true);
    });
  }
  
  void addCodelab(Codelab codelab){
    //validate codelab
    _store.add(codelab).then((_){
      hasCodelabs = notifyPropertyChange(const Symbol('hasCodelabs'),
          hasCodelabs, (codelabs.length == 0) ? false: true);
    },
    onError: (e) {print('duplicate key'); });
  }
  
  Future removeCodelab(Codelab codelab){
    return _store.removeCodelab(codelab).then((_){
      hasCodelabs = notifyPropertyChange(const Symbol('hasCodelabs'),
          hasCodelabs, (codelabs.length == 0) ? false: true);
    });
  }
  
  Future clear(){
    return _store.clear().then((_){
      hasCodelabs = notifyPropertyChange(const Symbol('hasCodelabs'),
          hasCodelabs, (codelabs.length == 0) ? false: true);     
    });
  }
}