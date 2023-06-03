local function msg(obj)
  reaper.ShowConsoleMsg(tostring(obj) .. "\n")
end

local function parse_tc(input_str)
  local invalid_tc = false

  local ttbl = { [","] = ":", ["."] = ":", [";"] = ":" }
  local tc = input_str:gsub("[,.;]", ttbl):gsub("[^%d:]", ""):gsub(":%.?$", ""):gsub("^:", ""):gsub(":$","")

  if tc:len() == 0 then
    msg("Please enter a valid timecode!")
    invalid_tc = true
  else
    if input_str:sub(1,1) == "+" or input_str:sub(1,1) == "-" then
      -- relative timecode
      local multiplier = (input_str:sub(1,1) == "-") and -1 or 1
      local seconds = tonumber(tc:match("(%d+)$"))
      local minutes = tonumber(tc:match("(%d+):(%d+)$"))
      local hours = tonumber(tc:match("(%d+):(%d+):(%d+)$"))
      if seconds == nil and minutes == nil and hours == nil then
        msg(input_str .. " is not a valid timecode!")
        invalid_tc = true
      else
        seconds = seconds or 0
        minutes = minutes or 0
        hours = hours or 0
        local offset = (hours * 3600 + minutes * 60 + seconds) * multiplier
        local new_pos = reaper.GetCursorPosition() + offset
        reaper.SetEditCurPos(new_pos, true, true)
      end
    else
      -- absolute timecode
      local parts = {}
      for part in tc:gmatch("%d+") do
        table.insert(parts, tonumber(part))
      end
      if #parts == 1 then
        -- seconds
        local new_pos = reaper.parse_timestr_pos("00:00:" .. tc, 0)
        if new_pos == -1 then
          msg(input_str .. " is not a valid timecode!")
          invalid_tc = true
        else
          reaper.SetEditCurPos(new_pos, true, true)
        end
      elseif #parts == 2 then
        -- minutes and seconds
        local new_pos = reaper.parse_timestr_pos("00:" .. tc, 0)
        if new_pos == -1 then
          msg(input_str .. " is not a valid timecode!")
          invalid_tc = true
        else
          reaper.SetEditCurPos(new_pos, true, true)
        end
      elseif #parts == 3 then
        -- hours, minutes and seconds
        local new_pos = reaper.parse_timestr_pos(tc, 0)
        if new_pos == -1 then
          msg(input_str .. " is not a valid timecode!")
          invalid_tc = true
        else
          reaper.SetEditCurPos(new_pos, true, true)
        end
      else
        msg(input_str .. " is not a valid timecode!")
        invalid_tc = true
      end
    end
  end

  if invalid_tc then
    return false
  else
    return true
  end
end

local retval, user_input = reaper.GetUserInputs("Jump to timecode", 1, "Timecode", "", 20)

if retval then
  local input_tc = user_input
  parse_tc(input_tc)
end
