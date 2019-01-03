local session = require "resty.session".start()
session.data.name="fan"
session.data.key1="value1"
session:save()
