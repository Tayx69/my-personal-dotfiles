------------------
---- MONITORS ----
------------------

hl.monitor({
    output   = "",
    mode     = "1280x720@60.00Hz", --Resolution@RefreshRate
    position = "auto",
    scale    = "auto",
})

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})