export default class SortToggleManager { 
   
  constructor(initialQueryString, toggleFields) {
    this.toggleFields = toggleFields;
    if (initialQueryString) {
      if (initialQueryString[0] == "-") {
        this.currentDirection = "-";
        this.currentField = initialQueryString.slice(1);
      } else {
        this.currentDirection = "";
        this.currentField = initialQueryString;
      }
    }

    this.time = new Date()
  }
  
  toggle(field) {
    if (this.currentField == field) {
      if (this.currentDirection === "-") {
        this.currentDirection = ""
      } else {
        this.currentDirection = "-"
      }
    } else {
      this.currentDirection = this.toggleFields[field];
    }
    this.currentField = field;
  }
  
  asQueryString() {
    if (this.currentField) {
      return this.currentDirection + this.currentField;
    } else {
      return "";
    }
  }
  
  caratCssClass(field) {
    let sortCarat = "";
    if (this.currentField === field) {
      if (this.currentDirection == "-") {
        sortCarat = "sort-carat glyphicon glyphicon-chevron-down";
      } else {
        sortCarat = "sort-carat glyphicon glyphicon-chevron-up";
      }
    }
    return sortCarat;
  }
  
}