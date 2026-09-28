-- hata bulmak icin kullanilan bir paket
local linter = require("lint")

linter.linters_by_ft = {
	markdown = { "vale" },
	lua = { "luacheck" },
	swift = { "swiftlint" },
	xml = { "xmllint" },
}

