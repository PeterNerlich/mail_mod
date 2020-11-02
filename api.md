
# Mail format
The mail format in the api hooks

```lua
mail = {
	from = "sender name",
	to = "players, which, are, addressed",
	cc = "carbon copy",
	bcc = "players, which, get, a, copy, but, are, not, visible, to, others",
	subject = "subject line",
	body = "mail body",
	-- 8 attachments max
	attachments = {"default:stone 99", "default:gold_ingot 99"}
}
```

The fields `to`, `cc` and `bcc` can contain a player, multiple player names separated by commas, or be empty. Players in `to` are the recipiants, who are addressed directly. `cc` specifies players that get the mail to get notified, but are not immediate part of the conversation. There is no technical difference between `to` and `cc`, it just implies meaning for the players. Players can see all fields making up the mail except `bcc`, which is the only difference to `cc`.

Usernames in Minetest can only be [alphanumerical and contain hyphens and underscores](https://github.com/minetest/minetest/blob/ae83edd16581b2b5426b565e703a8766e88dbbf6/src/player.h#L32). On this basis, we define a naming schema for mailinglists that are immediately distinguishable from playernames as follows: Server global mailing lists consist of an **at sign** and a **list name** (e.g. `@maintenance`), user created mailing lists additionally have a **colon** and the **username** they belong to (e.g. `@cave-exploration:test` by the user test). Mailing lists may be actively or passively moderated, meaning that their owners (or in case of global lists users with the `mailinglist-mod` privelege) can blacklist or whitelist a set of users from writing to a mailinglist (passive moderation) or manually greenlight messages from a backlog to be distributed to the subscribed users (active moderation). In case of rejection the sender may or may not be notified by another message.

Attachments need to be provided for each player getting the mail. Until this is implemented, trying to send a mail to multiple players will fail.

The `from` and `to` fields were renamed from the previous format:

```lua
mail = {
	src = "source name",
	dst = "destination name",
	subject = "subject line",
	body = "mail body",
	-- 8 attachments max
	attachments = {"default:stone 99", "default:gold_ingot 99"}
}
```

## Sending mail
Old variant (pre-1.1)
```lua
mail.send("source name", "destination name", "subject line", "mail body")
```

New variant (1.1+)
```lua
mail.send({
	from = "sender name",
	to = "destination name",
	cc = "carbon copy",
	bcc = "blind carbon copy",
	subject = "subject line",
	body = "mail body"
})
```

# Hooks
On-receive mail hook:

```lua
mail.register_on_receive(function(m)
	-- "m" is an object in the form: "Mail format"
end)
```

# internal mail format (on-disk)
The mail format on-disk

> (worldfolder)/mails/(playername).json

```json
[{
	"unread": true,
	"sender": "sender name",
	"subject": "subject name",
	"body": "main\nmultiline\nbody",
	"time": 1551258349,
	"attachments": [
		"default:stone 99",
		"default:gold_ingot 99"
	]
}]

```
