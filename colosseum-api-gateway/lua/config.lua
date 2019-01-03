local config = {

    dev = {
      redis_host = "127.0.0.1",
      redis_port = "6379",
      redis_password = "",
      redis_timeout = 10000,
      redis_idle_time = 60000,
      redis_pool_size = 100,

      api_manager_host = "10.205.16.138",
      api_manager_port = "8090",
      api_manager_timeout = 10000,

      upstream_host = "10.205.16.138",
      upstream_port = "8080",

      use_consul = false,
      consul_host = "127.0.0.1",
      consul_port = 8500,
      consul_watch_timeout = 10,

      api_mapping_cache_timeout = 10,

      caas_host =  "10.205.17.202",
      caas_port = "8080",
      caas_app_key = "5c415b08268147eeb372cb349f5cba43"

    },

    sandbox = {
      redis_host = "127.0.0.1",
      redis_port = "6379",
      redis_password = "",
      redis_timeout = 10000,
      redis_idle_time = 60000,
      redis_pool_size = 100,

      api_manager_host = "10.205.16.138",
      api_manager_port = "8090",
      api_manager_timeout = 10000,

      upstream_host = "10.205.16.138",
      upstream_port = "8080",

      use_consul = false,
      consul_host = "127.0.0.1",
      consul_port = 8500,
      consul_watch_timeout = 10,

      api_mapping_cache_timeout = 10,

      caas_host =  "10.205.17.202",
      caas_port = "8080",
      caas_app_key = "5c415b08268147eeb372cb349f5cba43"

    },

    prod = {
      redis_host = "127.0.0.1",
      redis_port = "6379",
      redis_password = "",
      redis_timeout = 10000,
      redis_idle_time = 60000,
      redis_pool_size = 100,

      api_manager_host = "127.0.0.1",
      api_manager_port = "8090",
      api_manager_timeout = 10000,

      upstream_host = "10.200.0.6",
      upstream_port = "8080",

      use_consul = false,
      consul_host = "127.0.0.1",
      consul_port = 8500,
      consul_watch_timeout = 10,

      api_mapping_cache_timeout = 10,

      caas_host =  "10.205.17.202",
      caas_port = "8080",
      caas_app_key = "5c415b08268147eeb372cb349f5cba43"

    },

    poc = {
      redis_host = "127.0.0.1",
      redis_port = "6379",
      redis_password = "",
      redis_timeout = 10000,
      redis_idle_time = 60000,
      redis_pool_size = 100,

      api_manager_host = "10.205.16.138",
      api_manager_port = "8090",
      api_manager_timeout = 10000,

      upstream_host = "10.205.16.138",
      upstream_port = "8080",

      use_consul = false,
      consul_host = "127.0.0.1",
      consul_port = 8500,
      consul_watch_timeout = 10,

      api_mapping_cache_timeout = 10,

      caas_host =  "127.0.0.1",
      caas_port = "8010",
      caas_app_key = "5c415b08268147eeb372cb349f5cba43"
    }
}

local const env = os.getenv("ENV")
local function get(key)
    return config[env][key]
end

local _M = {
    env = env,
    get = get
}

return _M
