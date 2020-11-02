minetest.register_chatcommand("mail",{
	description = "Open the mail interface",
	func = function(name)
		mail.show_inbox(name)
	end
})

minetest.register_chatcommand("contacts",{
	description = "Open the contacts book",
	func = function(name)
		mail.show_contacts(name)
	end
})

minetest.register_chatcommand("compose",{
	description = "Compose a mail",
	func = function(name)
		mail.show_compose(name, nil, nil, nil, nil, name)
	end
})
