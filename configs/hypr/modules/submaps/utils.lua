local M = {}

function M.switch(name)
  return function()
    hl.dispatch(hl.dsp.submap(name))
  end
end

function M.current_dir(level)
    local source = debug.getinfo(level or 2, "S").source
    local path = source:sub(1, 1) == "@" and source:sub(2) or source

    return assert(
        path:match("(.*/)"),
        "Failed to determine current file directory"
    )
end

return M
