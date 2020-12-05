if type(APP.model) ~= "table" then
    APP.model = {}
end

if type(APP.configuration) ~= "table" then
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

local _rpcPass = eliUtil.random_string(20, _charsetTable)
local _daemonConfiguration = type(APP.configuration.DAEMON_CONFIGURATION) == "table" and APP.configuration.DAEMON_CONFIGURATION or  {}
if not _daemonConfiguration.rpcuser then
    _daemonConfiguration.rpcuser = APP.user
end
if not _daemonConfiguration.rpcpassword then
    _daemonConfiguration.rpcpassword = _rpcPass
end

APP.model =
    eliUtil.merge_tables(
    APP.model,
    {
        DAEMON_CONFIGURATION = eliUtil.merge_tables(
            {
                server = APP.configuration.SERVER and 1 or nil,
                listen = APP.configuration.SERVER and 1 or nil,
            },
            _daemonConfiguration
        ),
        SERVICE_CONFIGURATION = eliUtil.merge_tables(
            {
                TimeoutStopSec = 300,
            },
            type(APP.configuration.SERVICE_CONFIGURATION) == "table" and APP.configuration.SERVICE_CONFIGURATION or {},
            true
        ),
        DAEMON_NAME = "bictoind",
        CLI_NAME = "bitcoin-cli",
        CONF_NAME = "bictoin.conf",
        CONF_SOURCE = "__btc/assets/daemon.conf",
        SERVICE_NAME = "bictoind",
        DATA_DIR = "data"
    },
    true
)
