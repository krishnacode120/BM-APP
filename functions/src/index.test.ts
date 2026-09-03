import {testHooks} from "./index";

function assert(value: boolean, message: string) {
  if (!value) throw new Error(message);
}

assert(testHooks.canTransition("pending", "confirmed"), "pending can confirm");
assert(testHooks.canTransition("confirmed", "processing"), "confirmed can process");
assert(testHooks.canTransition("processing", "ready"), "processing can ready");
assert(testHooks.canTransition("ready", "outForDelivery"), "ready can dispatch");
assert(testHooks.canTransition("outForDelivery", "delivered"), "dispatch can deliver");
assert(!testHooks.canTransition("delivered", "pending"), "delivered cannot revert");
assert(!testHooks.canTransition("pending", "unknown"), "unknown status rejected");
