--Will poll for new events and handle them all (call the registered callbacks).
--The implementation is efficient, it will only check a single shared memory value and return immediately if no new events are available
local ev = require("resty.worker.events")
--success,err = ev.poll()
--print(success,err)

local events = ev.event_list("my-module-event-source",
        "started",  "event2" )
ev.post(events._source,events.started,nil)
ev.post(events._source,events.event2,nil)
ev.post("xx-events","xx-event",nil)
