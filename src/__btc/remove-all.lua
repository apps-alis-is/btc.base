local ok, systemctl = am.plugin.safe_get("systemctl")
ami_assert(ok, "Failed to load systemctl plugin")

local ok, err = systemctl.safe_remove_service(am.app.get("id") .. "-" .. am.app.get_model("SERVICE_NAME"))
if not ok then
    ami_error("Failed to remove " ..
        am.app.get("id") .. "-" .. am.app.get_model("SERVICE_NAME") .. ".service " .. (err or ""))
end

log_success("Node services succesfully removed.")
