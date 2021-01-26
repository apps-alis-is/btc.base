local _ok, _systemctl = am.plugin.safe_get("systemctl")
ami_assert(_ok, "Failed to load systemctl plugin")

local _ok, _error = _systemctl.safe_remove_service(am.app.get("id") .. "-" .. am.app.get_model("SERVICE_NAME"))
if not _ok then
    ami_error("Failed to remove " .. am.app.get("id") .. "-" .. am.app.get_model("SERVICE_NAME") .. ".service " .. (_error or ""))
end

log_success("Node services succesfully removed.")