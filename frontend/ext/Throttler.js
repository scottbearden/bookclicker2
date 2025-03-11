export default class Throttler { 
  
 constructor(throttleInMs) {
   this.started_at = Date.now();
   this.throttleInMs = throttleInMs;
 } 
 
 restart() {
   if (Date.now() - this.started_at >= this.throttleInMs) {
     this.started_at = Date.now();
     return true;
    } else {
      return false;
    }
 }
  
}