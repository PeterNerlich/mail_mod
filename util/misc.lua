
function mail.calculate_frequent_contacts(name, only_show_contacts)
	local max_lookback_in_s = 60*60*24 * 30 * 4	-- don't bother with messages older than 4 months

	local contacts = mail.getContacts(name)
	local messages = mail.getMessages(name)

	local scores = {}
	local msgs = {}
	local now = os.time()

	-- find the last message
	-- assume the new messages are always appended to the end and the table is chronological
	for i = #messages, 1, -1 do
		if messages[i] then
			if now - messages[i].time > max_lookback_in_s then
				break
			end

			local k = string.lower(messages[i].sender)
			if not (only_show_contacts and contacts[k] == nil) then
				if msgs[k] == nil then
					msgs[k] = 0
				end
				if scores[k] == nil then
					scores[k] = 0
				end

				local timeago = now - messages[i].time
				msgs[k] = msgs[k] + 1
				scores[k] = scores[k] + (10000 / timeago / msgs[k])
			end
		end
	end

	-- prepare sorting the table
	local out = {}
	for k, score in pairs(scores) do
		table.insert(out, {
			key = k,
			score = score,
			incontacts = contacts[k] ~= nil
		})
	end

	-- sort descending (highest score = most frequent contact)
	table.sort(out, function(a, b)
		if not a then
			a = {key="a", score=0}
		end
		if not b then
			a = {key="b", score=0}
		end
		if a.score == b.score then
			-- well, just sort alphabetically...
			return a.key < b.key
		end
		return a.score > b.score
	end)
	return out
end

function mail.pretty_date(timestamp, trim_if_recent)
	-- convert timestamp to table in local time
	local ts_tab = os.date("*t", timestamp)

	if trim_if_recent then
		local ago = os.time() - timestamp
		timestamp = os.time(ts_tab)	-- make display local time for os.date()

		if ago >= 0 then
			local now_tab = os.date("*t")
			now_tab.sec = 0
			now_tab.min = 0
			now_tab.hour = 0
			if timestamp >= os.time(now_tab) then
				return os.date("%H:%M", timestamp)
			else
				now_tab.day = 1
				now_tab.month = 1
				if timestamp >= os.time(now_tab) then
					return os.date("%d.%m. %H:%M", timestamp)
				end
			end
		end
	end

	return os.date("%d.%m.%Y %H:%M:%S", timestamp)
end

function mail.pretty_duration(seconds)
	if seconds < 60 then
		return seconds .. " sec"
	elseif seconds < 60*60 then
		return math.floor(0.5 + seconds/60) .. " min"

	elseif seconds < 60*60*2 then
		return math.floor(0.5 + seconds/60/60) .. " hour"
	elseif seconds < 60*60*24 then
		return math.floor(0.5 + seconds/60/60) .. " hrs"

	elseif seconds < 60*60*24 * 2 then
		return math.floor(0.5 + seconds/60/60/24) .. " day"
	elseif seconds < 60*60*24 * 30 then
		return math.floor(0.5 + seconds/60/60/24) .. " days"

	elseif seconds < 60*60*24 *30 *2 then
		return math.floor(0.5 + seconds/60/60/24 /30) .. " month"
	elseif seconds < 60*60*24 *30 *12 then
		return math.floor(0.5 + seconds/60/60/24 /30) .. " months"

	elseif seconds < 60*60*24 *30 *12 *2 then
		return math.floor(0.5 + seconds/60/60/24 /30 /12) .. " year"
	else
		return math.floor(0.5 + seconds/60/60/24 /30 /12) .. " yrs"
	end
end

function pairsByKeys(t, f)
	-- http://www.lua.org/pil/19.3.html
	local a = {}
	for n in pairs(t) do table.insert(a, n) end
	table.sort(a, f)
	local i = 0		-- iterator variable
	local iter = function()		-- iterator function
		i = i + 1
		if a[i] == nil then
			return nil
		else
			--return a[i], t[a[i]]
			-- add the current position and the length for convenience
			return a[i], t[a[i]], i, #a
		end
	end
	return iter
end
