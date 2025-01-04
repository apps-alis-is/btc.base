local ok, systemctl = am.plugin.safe_get("systemctl")
ami_assert(ok, "Failed to load systemctl plugin")

local ok, err = systemctl.safe_stop_service(am.app.get("id") .. "-" .. am.app.get_model("SERVICE_NAME"))
ami_assert(ok,
    "Failed to stop " .. am.app.get("id") .. "-" .. am.app.get_model("SERVICE_NAME") .. ".service " .. (err or ""))

log_success("Node services succesfully stopped.")
