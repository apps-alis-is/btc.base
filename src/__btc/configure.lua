local user = am.app.get("user")
ami_assert(type(user) == "string", "User not specified...")

local ok, user_plugin = am.plugin.safe_get("user")
ami_assert(ok, "Failed to load user plugin - " .. tostring(user_plugin), EXIT_PLUGIN_LOAD_ERROR)

log_info("Checking user '" .. user .. "' availability...")
local ok = user_plugin.add(user, { disable_login = true, disable_password = true, gecos = "" })
ami_assert(ok, "Failed to create user - " .. user)

local data_path = am.app.get_model("DATA_DIR")
fs.safe_mkdirp(data_path)

local conf_dest = path.combine(data_path, am.app.get_model("CONF_NAME"))
local ok, err = fs.safe_copy_file(am.app.get_model("CONF_SOURCE"), conf_dest)
ami_assert(ok, "Failed to deploy " .. am.app.get_model("CONF_NAME") .. ": " .. (err or ""))

local ok, uid = fs.safe_getuid(user)
ami_assert(ok, "Failed to get " .. user .. "uid - " .. (uid or ""))

local ok, err = fs.safe_chown(data_path, uid, uid, { recurse = true })
if not ok then
    ami_error("Failed to chown " .. data_path .. " - " .. (err or ""))
end

log_info("Configuring " .. am.app.get("id") .. " services...")

local ok, systemctl = am.plugin.safe_get("systemctl")
ami_assert(ok, "Failed to load systemctl plugin - " .. tostring(systemctl))
local ok, err = systemctl.safe_install_service("__btc/assets/daemon.service",
    am.app.get("id") .. "-" .. am.app.get_model("SERVICE_NAME", "bitcoind"))
ami_assert(ok,
    "Failed to install " ..
    am.app.get("id") .. "-" .. am.app.get_model("SERVICE_NAME", "") .. ".service " .. (err or ""))

log_success(am.app.get("id") .. " services configured")
