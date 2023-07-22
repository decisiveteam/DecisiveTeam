const POLLING_INTERVAL = 5 * 1000;
const triggerPolling = () => {
  if (document.hidden){
    // noop
  } else {
    const event = new Event("poll");
    document.dispatchEvent(event);
    setTimeout(triggerPolling, POLLING_INTERVAL);
    console.log("polling");
  }
};
triggerPolling();
document.addEventListener("visibilitychange", triggerPolling);
