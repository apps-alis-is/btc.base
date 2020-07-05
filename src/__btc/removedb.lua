local _user = APP.user
ami_assert(type(_user) == "string", "User not specified...")

eliFs.remove("data/blocks", { recurse = true })
eliFs.remove("data/chainstate", { recurse = true })