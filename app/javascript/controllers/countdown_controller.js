import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ['time'];
  static values = { endTime: String };

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
    
    let text = "";
    switch (true) {
      case years > 0:
        text = `${years}y : ${days}d : ${hours}h : ${minutes}m : ${seconds}s`;
        break;
      case days > 0:
        text = `${days}d : ${hours}h : ${minutes}m : ${seconds}s`;
        break;
      case hours > 0:
        text = `${hours}h : ${minutes}m : ${seconds}s`;
        break;
      case minutes > 0:
        text = `${minutes}m : ${seconds}s`;
        break;
      case seconds > 0:
        text = `${seconds}s`;
        break;
      default:
        text = "0";
    }
    this.timeTarget.innerText = text;

    if (distance < 0) {
      clearInterval(this.interval);
      this.timeTarget.innerText = "0";
    }
  }

  disconnect() {
    clearInterval(this.interval);
  }
}
