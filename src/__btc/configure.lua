local user = am.app.get("user")
ami_assert(type(user) == "string", "User not specified...")

local user_plugin, err = am.plugin.get("user")
ami_assert(user_plugin, "Failed to load user plugin - " .. tostring(err), EXIT_PLUGIN_LOAD_ERROR)

log_info("Checking user '" .. user .. "' availability...")
local ok = user_plugin.add(user, { disable_login = true, disable_password = true, gecos = "" })
ami_assert(ok, "Failed to create user - " .. user)

local data_path = am.app.get_model("DATA_DIR")
fs.mkdirp(data_path)

local conf_dest = path.combine(data_path, am.app.get_model("CONF_NAME"))
local ok, err = fs.copy_file(am.app.get_model("CONF_SOURCE"), conf_dest)
ami_assert(ok, "Failed to deploy " .. am.app.get_model("CONF_NAME") .. ": " .. (err or ""))

local uid, err = fs.getuid(user)
ami_assert(uid, "Failed to get " .. user .. "uid - " .. tostring(err))

local ok, err = fs.chown(data_path, uid, uid, { recurse = true })
if not ok then
    ami_error("Failed to chown " .. data_path .. " - " .. (err or ""))
end

log_info("Configuring " .. am.app.get("id") .. " services...")

local systemctl, err = am.plugin.get("systemctl")
ami_assert(systemctl, "Failed to load systemctl plugin - " .. tostring(err))
local ok, err = systemctl.safe_install_service("__btc/assets/daemon.service",
    am.app.get("id") .. "-" .. am.app.get_model("SERVICE_NAME", "bitcoind"))
ami_assert(ok,
    "Failed to install " ..
    am.app.get("id") .. "-" .. am.app.get_model("SERVICE_NAME", "") .. ".service " .. (err or ""))

log_success(am.app.get("id") .. " services configured")
