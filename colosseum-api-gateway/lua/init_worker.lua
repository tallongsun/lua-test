local config = require("config")

if config.get("use_consul") then
  if ngx.worker.id() and ngx.worker.id() == 0 then
    local apiManager = require("api_manager")
    ngx.timer.at(0, apiManager.watchApiManager)
  end
end
