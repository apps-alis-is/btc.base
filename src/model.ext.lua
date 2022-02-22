if type(am.app.get_configuration()) ~= "table" then
    ami_error("Configuration not found...", EXIT_INVALID_CONFIGURATION)
end

local _rpcPass = util.random_string(20)
local _daemonConfiguration = type(am.app.get_configuration("DAEMON_CONFIGURATION")) == "table" and am.app.get_configuration("DAEMON_CONFIGURATION") or  {}
if not _daemonConfiguration.rpcuser then
    _daemonConfiguration.rpcuser = am.app.get("user")
end
if not _daemonConfiguration.rpcpassword then
    _daemonConfiguration.rpcpassword = _rpcPass
end

local _externalIp = nil
if not am.app.get_configuration("externalip") then
    _externalIp = am.app.get_configuration("bind", ""):match("(.*):.*")
end

local _daemonConfiguration = util.merge_tables({
    server = am.app.get_configuration("SERVER") and 1 or nil,
    listen = am.app.get_configuration("SERVER") and 1 or nil,
    externalip = _externalIp
}, am.app.get_configuration("DAEMON_CONFIGURATION", {}), true)

am.app.set_model(
    {
        DAEMON_CONFIGURATION = _daemonConfiguration,
        SERVICE_CONFIGURATION = util.merge_tables(
            {
                TimeoutStopSec = 300,
            },
            type(am.app.get_configuration("SERVICE_CONFIGURATION")) == "table" and am.app.get_configuration("SERVICE_CONFIGURATION") or {},
            true
        ),
        DAEMON_NAME = "bictoind",
        CLI_NAME = "bitcoin-cli",
        CONF_NAME = "bictoin.conf",
        CONF_SOURCE = "__btc/assets/daemon.conf",
        SERVICE_NAME = "bictoind",
        STARTUP_ARGS = am.app.get_configuration("STARTUP_ARGS", {}),
        DATA_DIR = path.combine(os.cwd(), "data"),
        ABOUT_SOURCE = "__btc/about.hjson"
    },
    { merge = true, overwrite = true }
)
