const POLLING_INTERVAL = 5 * 1000;
let currentTimeout = null;
const triggerPolling = () => {
  if (document.hidden || document.visibilityState === "hidden" || window.pausePolling){
    // noop
  } else {
    const event = new Event("poll");
    document.dispatchEvent(event);
    clearTimeout(currentTimeout)
    currentTimeout = setTimeout(triggerPolling, POLLING_INTERVAL);
    // console.log("polling");
  }
};
triggerPolling();
document.addEventListener("visibilitychange", triggerPolling);
