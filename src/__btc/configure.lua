local _user = APP.user
ami_assert(type(_user) == "string", "User not specified...")
local _ok, _uid = eliFs.safe_getuid(_user)
if not _ok or not _uid then
    log_info("Creating user - " .. _user .. "...")
    local _ok = os.execute('adduser --disabled-login --disabled-password --gecos "" ' .. _user)
    ami_assert(_ok, "Failed to create user - " .. _user)
    log_info("User " .. _user .. " created.")
else
    log_info("User " .. _user .. " found.")
end

local DATA_PATH = APP.model.DATA_DIR
local _ok, _error = eliFs.safe_mkdirp(DATA_PATH)

local _confDest = eliPath.combine(DATA_PATH, APP.model.CONF_NAME)
local _ok, _error = eliFs.safe_copy_file(APP.model.CONF_SOURCE, _confDest)
ami_assert(_ok, "Failed to deploy " .. APP.model.CONF_NAME .. ": " .. (_error or ""))

local _ok, _uid = eliFs.safe_getuid(_user)
ami_assert(_ok, "Failed to get " .. _user .. "uid - " .. (_uid or ""), EXIT_APP_CONFIGURE_ERROR)

local _ok, _error = eliFs.chown(DATA_PATH, _uid, _uid)
ami_assert(_ok, "Failed to chown " .. DATA_PATH .. " - " .. (_error or ""), EXIT_APP_CONFIGURE_ERROR)

log_info("Configuring " .. APP.id .. " services...")

local _ok, _systemctl = safe_load_plugin("systemctl")
ami_assert(_ok, "Failed to load systemctl plugin - " ..  tostring(_systemctl), EXIT_APP_CONFIGURE_ERROR)
local _ok, _error = _systemctl.safe_install_service("__btc/assets/daemon.service", APP.id .. "-" .. APP.model.SERVICE_NAME)
ami_assert(_ok, "Failed to install " .. APP.id .. "-" .. APP.model.SERVICE_NAME .. ".service " .. (_error or ""), EXIT_APP_CONFIGURE_ERROR)

log_success(APP.id .. " services configured")