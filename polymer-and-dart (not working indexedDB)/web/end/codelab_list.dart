import 'package:polymer/polymer.dart';
import 'dart:convert';
import 'codelab_list_view.dart';


/*
 * Class to represent a collection of Codelab objects.
 */

@CustomTag('codelab-list')
class CodelabList extends PolymerElement {
  static const ALL = "all";
  
  @observable CodelabListApp codelabList = codelabListObject;
  
  /*
   * Field for a new Codelab object.
   */
  @observable Codelab newCodelab = new Codelab();

  /*
   * Collection of codelabs. The source of truth for all codelabs in this app.
   */
  @observable List<Codelab> codelabs = toObservable([]);

  /*
   * Sets the new codelab form to default to the intermediate level.
   */
  String get defaultLevel => Codelab.LEVELS[1];

  /*
   * List of filter values. Includes the levels defined in the model, as well
   * as a filter to return all codelabs.
   */
  final List<String> filters = [ALL]..addAll(Codelab.LEVELS);

  /*
   * String that stores the value used to filter codelabs.
   */
  @observable String filterValue = ALL;

  /*
   * The list of filtered codelabs.
   */
  @observable List<Codelab> filteredCodelabs = toObservable([]);

  /*
   * Named constructor. Sets initial value of filtered codelabs and sets
   * the new codelab's level to the default.
   */
  CodelabList.created() : super.created() {
    filteredCodelabs = codelabs;
    newCodelab.level = defaultLevel;
    load();
  }
  

  /*
   * Replaces the existing new Codelab, causing the new codelab form to reset.
   */
  resetForm() {
    newCodelab = new Codelab();
    newCodelab.level = defaultLevel;
  }

  /*
   * Adds a codelab to the codelabs list and resets the new codelab form. This
   * triggers codelabsChanged().
   */
  addCodelab(Event e, var detail, Node sender) {
    e.preventDefault();
    codelabs.add(detail['codelab']);
    resetForm();
  }

  /*
   * Removes a codelab from the codelabs list. This triggers codelabsChanged().
   */
  deleteCodelab(Event e, var detail, Node sender) {
    var codelab = detail['codelab'];
    codelabs.remove(codelab);
  }
  
  saveCodelab(Event e, var detail, Node sender){
    window.localStorage['polymer_codelabs'] = JSON.encode(codelabs);
  }

  /*
   * Calculates the codelabs to display when using a filter.
   */
  filter() {
    if (filterValue == ALL) {
      filteredCodelabs = codelabs;
      return;
    }
    filteredCodelabs = codelabs.where((codelab) {
      return codelab.level == filterValue;
    }).toList();
  } 

  /*
   * Refreshes the filtered codelabs list every time the codelabs list changes.
   */
  codelabsChanged() {
    filter();
  }
  
  load(){
    String json = window.localStorage['polymer_codelabs'];
    var codelabList = new List<Map<String, Object>>();
    codelabList = JSON.decode(json);
    for(Map<String, Object> codelabMap in codelabList){
      Codelab codelab = new Codelab.fromJson(codelabMap);
      codelabs.add(codelab);
    }
  }
  
}
