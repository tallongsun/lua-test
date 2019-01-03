local session = require "resty.session".open()

ngx.say(session.data.name)
ngx.say(session.data.key1)
