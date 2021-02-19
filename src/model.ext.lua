if type(am.app.get_config()) ~= "table" then
    ami_error("Configuration not found...", EXIT_INVALID_CONFIGURATION)
end

local _charsetTable = {}
_charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
_charset:gsub(
    ".",
    function(c)
        table.insert(_charsetTable, c)
    end
)

local _rpcPass = util.random_string(20, _charsetTable)
local _daemonConfiguration = type(am.app.get_config("DAEMON_CONFIGURATION")) == "table" and am.app.get_config("DAEMON_CONFIGURATION") or  {}
if not _daemonConfiguration.rpcuser then
    _daemonConfiguration.rpcuser = am.app.get("user")
end
if not _daemonConfiguration.rpcpassword then
    _daemonConfiguration.rpcpassword = _rpcPass
end

am.app.set_model(
    {
        DAEMON_CONFIGURATION = {
            server = am.app.get_config("SERVER") and 1 or nil,
            listen = am.app.get_config("SERVER") and 1 or nil,
        },
        SERVICE_CONFIGURATION = util.merge_tables(
            {
                TimeoutStopSec = 300,
            },
            type(am.app.get_config("SERVICE_CONFIGURATION")) == "table" and am.app.get_config("SERVICE_CONFIGURATION") or {},
            true
        ),
        DAEMON_NAME = "bictoind",
        CLI_NAME = "bitcoin-cli",
        CONF_NAME = "bictoin.conf",
        CONF_SOURCE = "__btc/assets/daemon.conf",
        SERVICE_NAME = "bictoind",
        DATA_DIR = "data"
    },
    { merge = true, overwrite = true }
)
