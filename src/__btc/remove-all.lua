local _ok, _systemctl = safe_load_plugin("systemctl")
ami_assert(_ok, "Failed to load systemctl plugin", EXIT_APP_START_ERROR)

local _ok, _error = _systemctl.safe_remove_service(APP.id .. "-" .. APP.model.SERVICE_NAME)
if not _ok then
    ami_error("Failed to remove " .. APP.id  .. "-" .. APP.model.SERVICE_NAME .. ".service " .. (_error or ""), EXIT_APP_START_ERROR)
end

log_success("Node services succesfully removed.")