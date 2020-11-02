
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
