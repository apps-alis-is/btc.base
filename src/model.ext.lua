if type(am.app.get_configuration()) ~= "table" then
    ami_error("Configuration not found...", EXIT_INVALID_CONFIGURATION)
end

local _rpc_pass = util.random_string(20)
local _daemon_configuration = type(am.app.get_configuration("DAEMON_CONFIGURATION")) == "table" and
    am.app.get_configuration("DAEMON_CONFIGURATION") or {}
if not _daemon_configuration.rpcuser then
    _daemon_configuration.rpcuser = am.app.get("user")
end
if not _daemon_configuration.rpcpassword then
    _daemon_configuration.rpcpassword = _rpc_pass
end

local _external_ip = nil
if not am.app.get_configuration("externalip") then
    _external_ip = am.app.get_configuration("bind", ""):match("(.*):.*")
end

local _daemon_configuration = util.merge_tables({
    server = am.app.get_configuration("SERVER") and 1 or nil,
    listen = am.app.get_configuration("SERVER") and 1 or nil,
    externalip = _external_ip
}, am.app.get_configuration("DAEMON_CONFIGURATION", {}), true)

am.app.set_model(
    {
        DAEMON_CONFIGURATION = _daemon_configuration,
        SERVICE_CONFIGURATION = util.merge_tables(
            {
                TimeoutStopSec = 300,
            },
            type(am.app.get_configuration("SERVICE_CONFIGURATION")) == "table" and
            am.app.get_configuration("SERVICE_CONFIGURATION") or {},
            true
        ),
        DAEMON_NAME = "bitcoind",
        CLI_NAME = "bitcoin-cli",
        CONF_NAME = "bitcoin.conf",
        CONF_SOURCE = "__btc/assets/daemon.conf",
        SERVICE_NAME = "bitcoind",
        STARTUP_ARGS = am.app.get_configuration("STARTUP_ARGS", {}),
        DATA_DIR = path.combine(os.cwd(), "data"),
        ABOUT_SOURCE = "__btc/about.hjson"
    },
    { merge = true, overwrite = true }
)
