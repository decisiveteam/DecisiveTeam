import { Controller } from "@hotwired/stimulus";

const formatUnit = (unit, value) => {
  return unit[0];
  // if (value === 1) {
  //   // assuming that the unit is plural
  //   return " " + unit.slice(0, -1) + " ";
  // } else {
  //   return " " + unit;
  // }
};

export default class extends Controller {
  static targets = ['time'];
  static values = { endTime: String, baseUnit: String };

  connect() {
    this.startCountdown();
  }

  startCountdown() {
    this.updateCountdown();

    this.interval = setInterval(() => {
      this.updateCountdown();
    }, 1000);
  }

  updateCountdown() {
    const now = new Date();
    const distance = Date.parse(this.endTimeValue) - now;

    const oneSecond = 1000;
    const oneMinute = oneSecond * 60;
    const oneHour = oneMinute * 60;
    const oneDay = oneHour * 24;
    const oneYear = oneDay * 365;
    
    const years = Math.floor(distance / oneYear);
    const days = Math.floor((distance % oneYear) / oneDay);
    const hours = Math.floor((distance % oneDay) / oneHour);
    const minutes = Math.floor((distance % oneHour) / oneMinute);
    let seconds = Math.floor((distance % oneMinute) / oneSecond);
    if (seconds < 10) seconds = `0${seconds}`;

    let values = [years, days, hours, minutes, seconds];
    let keys = ["years", "days", "hours", "minutes", "seconds"];
    const nonZeroIndex = values.findIndex((value) => value > 0);
    const unitIndex = keys.indexOf(this.baseUnitValue || 'seconds');
    keys = keys.slice(nonZeroIndex, unitIndex + 1);
    values = values.slice(nonZeroIndex, unitIndex + 1);

    const textChunks = keys.map((key, index) => `${values[index]}${formatUnit(key, values[index])}`);
    
    // textChunks[textChunks.length - 1] = "and " + textChunks[textChunks.length - 1]; 

    this.timeTarget.innerHTML = textChunks.join(" : ");

    if (distance < 0) {
      clearInterval(this.interval);
      this.timeTarget.innerText = "0";
    }
  }

  disconnect() {
    clearInterval(this.interval);
  }
}
