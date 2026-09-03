"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const index_1 = require("./index");
function assert(value, message) {
    if (!value)
        throw new Error(message);
}
assert(index_1.testHooks.canTransition("pending", "confirmed"), "pending can confirm");
assert(index_1.testHooks.canTransition("confirmed", "processing"), "confirmed can process");
assert(index_1.testHooks.canTransition("processing", "ready"), "processing can ready");
assert(index_1.testHooks.canTransition("ready", "outForDelivery"), "ready can dispatch");
assert(index_1.testHooks.canTransition("outForDelivery", "delivered"), "dispatch can deliver");
assert(!index_1.testHooks.canTransition("delivered", "pending"), "delivered cannot revert");
assert(!index_1.testHooks.canTransition("pending", "unknown"), "unknown status rejected");
//# sourceMappingURL=index.test.js.map