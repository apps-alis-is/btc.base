local _ok, _systemctl = safe_load_plugin("systemctl")
ami_assert(_ok, "Failed to load systemctl plugin", EXIT_APP_STOP_ERROR)

local _ok, _error = _systemctl.safe_stop_service(APP.id .. "-" .. APP.model.SERVICE_NAME)
ami_assert(_ok, "Failed to stop " .. APP.id .. "-" .. APP.model.SERVICE_NAME .. ".service " .. (_error or ""), EXIT_APP_STOP_ERROR)

log_success("Node services succesfully stopped.")