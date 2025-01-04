if type(am.app.get_configuration()) ~= "table" then
    ami_error("Configuration not found...", EXIT_INVALID_CONFIGURATION)
end

local rpc_pass = util.random_string(20)
local daemon_conf = type(am.app.get_configuration("DAEMON_CONFIGURATION")) == "table" and
    am.app.get_configuration("DAEMON_CONFIGURATION") or {}
if not daemon_conf.rpcuser then
    daemon_conf.rpcuser = am.app.get("user")
end
if not daemon_conf.rpcpassword then
    daemon_conf.rpcpassword = rpc_pass
end

local external_ip = nil
if not am.app.get_configuration("externalip") then
    external_ip = am.app.get_configuration("bind", ""):match("(.*):.*")
end

local daemon_conf = util.merge_tables({
    server = am.app.get_configuration("SERVER") and 1 or nil,
    listen = am.app.get_configuration("SERVER") and 1 or nil,
    externalip = external_ip
}, am.app.get_configuration("DAEMON_CONFIGURATION", {}), true)

am.app.set_model(
    {
        DAEMON_CONFIGURATION = daemon_conf,
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
