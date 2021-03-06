local M = {}
local vim = vim
local loop = vim.loop
local api = vim.api

M.items = {}
M.callback = false

-- onDirScanned handler for vim.loop
local function onDirScanned(err, data)
  if err then
    -- print('ERROR: ', err)
    -- TODO handle err
  end
  if data then
    local function iter()
      return vim.loop.fs_scandir_next(data)
    end
    for name, type in iter do
        table.insert(M.items, {type = type, name=name})
    end
  end
  M.callback = true
end

local fileTypesMap = setmetatable({
    ['file'] = "(file)",
    ['directory'] = "(dir)",
    ['char'] = "(char)",
    ['link'] = "(link)",
    ['block'] = "(block)",
    ['fifo'] = "(pipe)",
    ['socket'] = "(socket)"
}, {__index = function() 
    return '(unknown)'
  end
})

M.getCompletionItems = function(prefix, score_func)
  local complete_items = {}
  for _, val in ipairs(M.items) do
    local score = score_func(prefix, val.name)
    if score < #prefix/3 or #prefix == 0 then
      table.insert(complete_items, {
        word = val.name,
        kind = 'Path ' .. fileTypesMap[val.type],
        score = score,
        icase = 1,
        dup = 1,
        empty = 1,
      })
    end
  end
  -- print(vim.inspect(complete_items))
  return complete_items
end

M.getCallback = function()
  return M.callback
end

M.triggerFunction = function(_, _, _, manager)
  local pos = api.nvim_win_get_cursor(0)
  local line = api.nvim_get_current_line()
  local line_to_cursor = line:sub(1, pos[2])
  local textMatch = vim.fn.match(line_to_cursor, '\\f*$')
  local keyword = line_to_cursor:sub(textMatch+1)
  if keyword ~= '/' then
    keyword = keyword:match("%s*(%S+)%w*/.*$")
  end
  local path = vim.fn.expand('%:p:h')
  if keyword ~= nil then
    -- dealing with special case in matching
    if keyword == "/" and line:sub(pos[2], pos[2]) then
      path = keyword
      goto continue
    elseif string.sub(keyword, 1, 1) == "\"" or string.sub(keyword, 1, 1) == "'" then
      keyword = string.sub(keyword, 2, #keyword)
    end

    local expanded_keyword = vim.fn.glob(keyword)
    local home = vim.fn.expand("$HOME")
    if expanded_keyword == '/' then
      goto continue
    elseif expanded_keyword ~= nil and expanded_keyword ~= '/' then
      path = expanded_keyword
    else
      path = vim.fn.expand('%:p:h')
      path = path..'/'..keyword
    end
  end

  ::continue::
  path = path..'/'
  M.items = {}
  vim.loop.fs_scandir(path, onDirScanned)
end

return M
