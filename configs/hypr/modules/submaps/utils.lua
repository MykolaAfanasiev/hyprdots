local M = {}

function M.switch(name)
  return function()
    hl.dispatch(hl.dsp.submap(name))
  end
end

return M
