--pretranslated: do not change this file

-- Localization
gettext.textdomain('webui-voice')

local content_helper = require("web.content_helper")
local ui_helper = require("web.ui_helper")
local post_helper = require("web.post_helper")
local table, ipairs = table, ipairs
local proxy = require("datamodel")

-- Shortcuts to validation helpers to make lines shorter
local vNES = post_helper.validateNonEmptyString

-- In Transformer
-- rpc.mmbpx.phonebook_entry.@.FirstName
-- rpc.mmbpx.phonebook_entry.@.LastName
-- rpc.mmbpx.phonebook_entry.@.HomeNumber
-- rpc.mmbpx.phonebook_entry.@.WorkNumber
-- rpc.mmbpx.phonebook_entry.@.MobileNumber

-- Phonebook contacts
-- BEGIN
local contact_columns = {
  {
    header = T"Last Name",
    name = "LastName",
    param = "LastName",
    type = "text",
    attr = { input = { class="span2" } },
  },
  {
    header = T"First Name",
    name = "FirstName",
    param = "FirstName",
    type = "text",
    attr = { input = { class="span2" } },
  },
  {
    header = T"Number",
    name = "HomeNumber",
    param = "HomeNumber",
    type = "text",
    attr = { input = { class="span2" } },
  },
}
-- END

local function validate_phonenumber(value)
  if value == "" or value:match("^([%+%d]?[%d%s%-%#%*]+)$") then
    return true
  end
  return nil, "Invalid phone number"
end

local contact_valid = {
  -- To do: currently, mmpbxphone can't set the fields to empty
  -- so we have to make sure the fields are not empty otherwise it will be a bug
  FirstName = vNES,
  LastName = vNES,
  HomeNumber = validate_phonenumber,
  WorkNumber = validate_phonenumber,
  MobileNumber = validate_phonenumber,
}

local tolower = string.lower

-- BEGIN
local function sort_func(a, b)
if a["LastName"] == b["LastName"] then
 	return tolower(a["FirstName"]) < tolower(b["FirstName"])
   else
   	return tolower(a["LastName"]) < tolower(b["LastName"])
   end
end

local function refresh_blacklist()
  proxy.set("rpc.mmpbx.blacklist.refresh","1")
end
-- END

local contact_options = {
  tableid = "phonebook_entry",
  basepath = "rpc.mmpbx.phonebook_entry.@.",
  createMsg = T"Add new contact",
  sorted = sort_func,
  onModify = refresh_blacklist,
  onAdd = refresh_blacklist,
  onDelete = refresh_blacklist,
}

local contact_data, contact_helpmsg = post_helper.handleTableQuery(contact_columns, contact_options, nil, nil, contact_valid)

local uri = ngx.var.uri
if ngx.var.args and string.len(ngx.var.args) > 0 then
  uri = uri .. "?" .. ngx.var.args
end

ngx.print( ui_helper.createHeader(T"Telephony", false, true) ); ngx.print('\
\
<div class="modal-body update">\
  ')

  local lp = require("web.lp")
  lp.setpath("/www/snippets/")
  lp.include("tabs-voice.lp")
  
  ngx.print('\
  <form class="form-horizontal" method="post" action="'); ngx.print( uri ); ngx.print('">\
    <fieldset>\
\
      <legend>'); ngx.print( T"Blacklist v3.0.4" ); ngx.print('</legend>\
\
');
      ngx.print(ui_helper.createTable(contact_columns, contact_data, contact_options, nil, contact_helpmsg))
      ngx.print('\
    </fieldset>\
  </form>\
</div>\
');
ngx.print(ui_helper.createFooter())
