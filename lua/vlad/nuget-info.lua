local curl = require('plenary.curl')
local uv   = vim.loop

local M    = {}

-- helper to do a GET and parse JSON
local function http_get_json(url)
  local res = curl.get {
    url    = url,
    accept = 'application/json',
  }
  if res and res.body then
    local ok, data = pcall(vim.fn.json_decode, res.body)
    if ok then return data end
    error("Failed to parse JSON from " .. url)
  end
  error("HTTP request failed for " .. url)
end

--- Get the latest version string for a package
-- @param pkg string e.g. "Newtonsoft.Json"
-- @return string latest semver
function M.get_latest_version(pkg, stable)
  -- Default to stable versions only
  stable     = stable ~= false

  local name = pkg:lower()
  local url  = ("https://api.nuget.org/v3-flatcontainer/%s/index.json"):format(name)
  local data = http_get_json(url)
  local vers = data.versions

  if stable then
    -- Filter out prerelease versions (containing hyphen per SemVer)
    local stable_versions = {}
    for _, v in ipairs(vers) do
      if not v:match("%-") then
        table.insert(stable_versions, v)
      end
    end
    vers = stable_versions
  end

  return vers[#vers]
end

function M.get_all_versions(pkg)
  local name = pkg:lower()
  local url  = ("https://api.nuget.org/v3-flatcontainer/%s/index.json"):format(name)
  local data = http_get_json(url)
  return data.versions or {}
end

--- Get metadata for the latest version
-- @param pkg string
-- @return table catalogEntry (id, version, description, authors, licenseUrl, etc.)
function M.get_latest_metadata(pkg)
  local name    = pkg:lower()
  local latest  = M.get_latest_version(pkg)
  local reg_url = ("https://api.nuget.org/v3/registration5-semver1/%s/index.json"):format(name)
  local data    = http_get_json(reg_url)

  -- Check pages from last to first (latest versions are usually at the end)
  for i = #data.items, 1, -1 do
    local page = data.items[i]
    local page_items = page.items
    if not page_items and page["@id"] then
      local page_data = http_get_json(page["@id"])
      page_items = page_data.items
    end
    
    if page_items then
      for _, item in ipairs(page_items) do
        local ce = item.catalogEntry
        if ce.version == latest then
          return ce
        end
      end
    end
  end
  vim.notify(("Could not find metadata for %s@%s"):format(pkg, latest), vim.log.levels.ERROR)
  return nil
end

--- Fetch metadata for a specific version
-- @param pkg string
-- @param version string
-- @return table catalogEntry
function M.get_metadata(pkg, version)
  local name = pkg:lower()
  local url  = ("https://api.nuget.org/v3/registration5-semver1/%s/index.json"):format(name)
  local data = http_get_json(url)
  
  -- Check pages from last to first (newer versions are usually at the end)
  for i = #(data.items or {}), 1, -1 do
    local page = data.items[i]
    local page_items = page.items
    if not page_items and page["@id"] then
      local page_data = http_get_json(page["@id"])
      page_items = page_data.items
    end
    
    if page_items then
      for _, item in ipairs(page_items) do
        local ce = item.catalogEntry
        if ce.version:lower() == version:lower() then
          return ce
        end
      end
    end
  end
  vim.notify(("Metadata for %s@%s not found"):format(pkg, version), vim.log.levels.ERROR)
  return nil
end

--- Extract supported frameworks from catalog entry
-- @param entry table catalogEntry
-- @return table list of normalized frameworks
function M.get_supported_frameworks(entry)
  if entry == nil then
    error("No catalog entry provided")
    return {}
  end
  local groups = entry.dependencyGroups or {}
  local set = {}
  for _, grp in ipairs(groups) do
    local tf = grp.targetFramework or ""
    -- normalize e.g. net8.0 -> .net8
    local norm = tf:lower():gsub("^net(%d+)%.?%d*$(%d*)", ".net%1")
    if norm == "" or norm == tf:lower() then
      norm = "." .. tf
    end
    set[norm] = true
  end
  local list = {}
  for f in pairs(set) do table.insert(list, f) end
  table.sort(list)
  return list
end

-- Expose a user command: :NugetInfo <PackageName>
vim.api.nvim_create_user_command('NugetInfo', function()
  -- read current line
  local line = vim.api.nvim_get_current_line()
  -- extract first word inside double quotes
  local input = line:match('"([^"]+)"')
  -- if word is nil, print "no word found" and return
  if input == nil then
    print("no word found")
    return
  end
  if not input or input == "" then return end
  vim.notify("Fetching NuGet info for " .. input .. " …", vim.log.levels.INFO)

  -- Run the HTTP calls off the main thread to avoid blocking
  vim.defer_fn(function()
    local ok, meta = pcall(M.get_latest_metadata, input)
    if not meta then
      vim.notify("Failed to fetch metadata for " .. input, vim.log.levels.ERROR)
      return
    end
    if not ok then
      vim.schedule(function()
        vim.notify(meta, vim.log.levels.ERROR)
      end)
      return
    end

    vim.schedule(function()
      local msg = table.concat({
        ("Package: %s"):format(meta.id),
        ("Version: %s"):format(meta.version),
        ("Authors: %s"):format(meta.authors or "n/a"),
        ("License: %s"):format(meta.licenseUrl or "n/a"),
        ("Description: %s"):format(meta.description or "n/a"),
      }, "\n")
      vim.notify(msg, vim.log.levels.INFO, { title = "NuGet Info" })
    end)
  end, 0)
end, { nargs = "?", desc = "Show latest NuGet package info" })

vim.api.nvim_create_user_command('NugetVersions', function()
  -- read current line
  local line = vim.api.nvim_get_current_line()
  -- get all words inside double quotes
  local words = {}
  for word in line:gmatch('"([^"]+)"') do
    table.insert(words, word)
  end

  local pkg = words[1]
  local base = words[2]

  if not pkg or pkg == "" then
    vim.notify("No package name found", vim.log.levels.WARN)
    return
  end

  if not base or base == "" then
    vim.notify("No base version found", vim.log.levels.WARN)
    return
  end

  vim.defer_fn(function()
    local ok, vers = pcall(M.get_all_versions, pkg)
    if not ok then
      vim.schedule(function() vim.notify(vers, vim.log.levels.ERROR) end)
      return
    end

    if #vers == 0 then
      vim.schedule(function()
        vim.notify("No versions found for " .. pkg, vim.log.levels.WARN)
      end)
      return
    end

    -- Overall latest
    local latest = M.get_latest_version(pkg, true)
    -- Parse base version
    local maj_b, min_b, pat_b = base:match('^(%d+)%.(%d+)%.(%d+)$')
    maj_b, min_b, pat_b = tonumber(maj_b), tonumber(min_b), tonumber(pat_b)

    -- Find safe update within same major.minor
    local safe, safe_ver = base, { maj = maj_b, min = min_b, pat = pat_b }
    for _, v in ipairs(vers) do
      local maj, min, pat = v:match('^(%d+)%.(%d+)%.(%d+)$')
      maj, min, pat = tonumber(maj), tonumber(min), tonumber(pat)
      if maj == maj_b and maj and min and pat then
        -- Same major version, check if it's newer but still "safe"
        if (min > safe_ver.min) or (min == safe_ver.min and pat > safe_ver.pat) then
          safe = v
          safe_ver = { maj = maj, min = min, pat = pat }
        end
      end
    end
    -- fetch frameworks
    local latest_meta = M.get_metadata(pkg, latest)
    local safe_meta   = M.get_metadata(pkg, safe)
    local latest_fws  = {}
    if latest_meta then
      latest_fws = M.get_supported_frameworks(latest_meta)
    end
    local safe_fws = {}
    if safe_meta then
      safe_fws = M.get_supported_frameworks(safe_meta)
    end

    -- Display results
    vim.schedule(function()
      local lines = {}
      if latest ~= safe then
        table.insert(lines, ("Latest: %s - [%s]"):format(latest, table.concat(latest_fws, ", ")))
        table.insert(lines, ("Safe: %s - [%s]"):format(safe, table.concat(safe_fws, ", ")))
      else
        table.insert(lines, ("Latest/Safe: %s - [%s]"):format(latest, table.concat(latest_fws, ", ")))
      end
      local msg = table.concat(lines, "\n")
      vim.notify(msg, vim.log.levels.INFO, { title = "NuGet Versions" })
    end)
  end, 0)
end, { nargs = '*', desc = 'Show latest and safe patch versions for a NuGet package' })


return M
