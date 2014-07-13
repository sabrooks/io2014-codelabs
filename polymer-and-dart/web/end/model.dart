library polymer_and_dart.web.models;

import 'package:polymer/polymer.dart';

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

  Codelab([this.title = "", this.description = ""]);
  
  bool validateCodelabTitle() {
    if (title.length < MIN_TITLE_LENGTH ||
        title.length > MAX_TITLE_LENGTH) {
      throw new StateError("Title must be between $MIN_TITLE_LENGTH  and "
          "$MAX_TITLE_LENGTH characters.");
      return false;
    }
    return true;
  }
  
  Codelab.fromJson(Map<String, Object> codelabMap){
    title = codelabMap['title'];
    description = codelabMap['description'];
    level = codelabMap['level'];
  }
  Map<String, Object> toJson(){
      var codelabMap = new Map<String, Object>();
      codelabMap['title'] = title;
      codelabMap['description'] = description;
      codelabMap['level']=level;
      return codelabMap;
    }
}