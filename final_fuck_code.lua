--uitls
function log_type(item)
	print("Type of item is: ", type(item))
end

log_file = "lua_log.txt"

function file_log(content)
	--file = io.open(log_file, "a")
	--file:write(content)
    --file:write("\n")
    --io:flush()
    --file:close()
end

function traverse(table_item)
	for k, v in pairs(table_item) do
		print(k, "...................", v)
	end
end

function is_table(item)
	return type(item) == "table"
end

deep_traverse_str = ""
function deep_traverse(table_name)
	deep_traverse_str = deep_traverse_str .. ".."
	if type(table_name) == "table" then
		for k, v in pairs(table_name) do
			print(k, "------")
			deep_traverse(v)
		end
	else
		print("------", deep_traverse_str, table_name)
	end
end

function print_r ( t )  
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end


function value_flat(value)
	if type(value) == 'nil' then
		return '0'
	elseif type(value) == "boolean" then
		if value then
			return '1'
		else
			return '0'
		end
	elseif type(value) == 'table' then
		local str = ''
		if next(value) ~= nil then
			for k, v in pairs(value) do
				if type(v) == "boolean" then
					if v then
						str = str .. '1' .. ' '
					else
						str = str .. '0' .. ' '
					end
				else
					if (type(v) == "table") then
						for x, y in pairs(v) do
							if y == nil then
								str = str .. 0 .. ' '
							else
								str = str .. y .. ' '
							end
						end
					elseif v == nil then
						str = str .. 0 .. ' '
					else
						str = str .. v .. ' '
					end
				end
			end
		end
		return str
	else
		return value
	end
end
--/utils

function process_node_properties(node_properties)
    local str = '<node id=\'' .. node_properties["id"] .. '\' type=\'' .. node_properties["type"] .. '\' name=\'' .. node_properties["name"] .. '\' position=\'' .. node_properties["position"][1] .. ' ' .. node_properties["position"][2] .. '\'>'
    print("process_node_properties: ", str)
    return str
end

function process_node_attributes(node_attributes)
    if next(node_attributes) == nil then
        return ''
    else
        local node_attributes_str = ''
        for k, v in pairs(node_attributes) do
        	-- print_r(v)
        	if next(v) ~= nil then
            	node_attributes_str = node_attributes_str .. '<attr name=\'' .. v["name"] .. '\' type=\'' .. v["type"] .. '\'>' .. value_flat(v["value"]) .. '</attr>'
        	end
        end

        print("node_attributes_str: ", node_attributes_str)
        return node_attributes_str
    end
end

function pin_node2str(pin_node)
	local pin_node_str = ''
	print(pin_node["properties"])
	local pin_node_properties = pin_node["properties"]
	local pin_node_attributes = pin_node["attributes"]
	pin_node_str = pin_node_str .. '<node id=\'' .. pin_node_properties["id"] .. '\' type=\'' .. pin_node_properties["type"] .. '\' name=\'' .. pin_node_properties["name"] .. '\'>'
	for k, v in pairs(pin_node_attributes) do
		pin_node_str = pin_node_str .. '<attr name=\'' .. v["name"] .. '\' type=\'' .. v["type"] .. '\'>' .. value_flat(v["value"]) .. '</attr>'
	end
	if next(pin_node["pin"]) == nil then
		return pin_node_str .. '</node>'
	else
		for h, j in pairs(pin_node["pin"]) do
			print("h is: ", h	)
			local pin_pin_prop = j["properties"];
			local pin_pin_attr = j["attributes"];
			local pin_pin_node = j["pin_node"]
			local pin_pin_node_prop = pin_pin_node["properties"]
			local pin_pin_node_attr = pin_pin_node["attributes"]
			pin_node_str = pin_node_str .. '<pin name=\'' .. pin_pin_prop["name"] .. '\'>'
			-- for x, y in pairs(pin_pin_node_attr) do
			-- 	pin_node_str = pin_node_str .. '<attr name=\'' .. y["name"] .. '\' type=\'' .. y["type"] .. '\'>' .. value_flat(y["value"]) .. '</attr>'
			-- end
			pin_node_str = pin_node_str .. pin_node2str(pin_pin_node) .. '</pin>'
		end
	end
	return pin_node_str .. '</node>'
end	

function pin2str(pin)
    local pin_properties = pin["properties"];
    local pin_attributes = pin["attributes"];

    local pin_str = ''
    if pin_properties["connect"] ~= nil then
        pin_str = pin_str .. '<pin name=\'' .. pin_properties["name"] .. '\' connect=\'' .. pin_properties["connect"] .. '\'/>'
        return pin_str
    else
    	if pin_properties["dynamic"] then
	    	return pin_str .. '<pin name=\'' .. pin_properties["name"] .. '\' dynamicType=\'' .. pin_properties["type"] .. '\'>' .. pin_node2str(pin["pin_node"]) .. '</pin>'
	    else
    		return pin_str .. '<pin name=\'' .. pin_properties["name"] .. '\'>' .. pin_node2str(pin["pin_node"]) .. '</pin>'
    	end
    end
end

function process_node_pins(pins)
    local pins_str = ''
    for k, v in pairs(pins) do
        -- local pin_properties = v["properties"]
        -- if pin_properties["connect"] ~= nil then
        --     pins_str = pins_str .. '<pin name=\'' .. pin_properties['name'] .. '\' connect=\'' .. pin_properties['connect'] ..'\'/>'
        -- else
        --     local pin_node_properties = v["pin_node"]["properties"]
        --     local pin_node_attributes = v["pin_node"]["attributes"]
      		-- pins_str = pins_str .. '<pin name=\'' .. pin_properties['name'] .. '\'>' .. '<node id=\'' .. pin_node_properties["id"] .. '\' type=\'' .. value_flat(pin_node_properties["type"]) ..'\'>' .. '<attr name=\'' .. pin_node_attributes["name"] .. ' type=\'' .. value_flat(pin_node_attributes["type"]) .. '\'>' .. value_flat(pin_node_attributes["value"]) .. '</attr></node></pin>'
        -- end
        pins_str = pins_str .. pin2str(v)
    end
    return pins_str
end

function process_node(v)
    local properties = v["properties"]
    local properties_str = process_node_properties(properties)
    local attributes = v["attributes"]
    local attributes_str = process_node_attributes(attributes)
    local pins = v["pins"]
    local pins_str = process_node_pins(pins)

    return properties_str .. attributes_str .. pins_str .. '</node>'
end

function luatab2ocs(table_name)
    local nodes = table_name["graph"]["nodes"]
    local node_all_str = ''
    for k, v in pairs(nodes) do
        node_str = process_node(v)
        node_all_str = node_all_str .. node_str
    end
    local timestmap = os.date("%Y-%m-%d %H:%M:%S")
    return '<OCS2 version=\'2250000\'' .. ' timestmap= \'' .. timestmap .. '\'>' .. '<graph id=\'' .. table_name["graph"]["properties"]["id"] .. '\' type=\'' .. table_name["graph"]["properties"]["type"] .. '\' name=\'' .. table_name["graph"]["properties"]["name"] .. '\'>' .. node_all_str .. '</graph>' .. '</OCS2>'
end

function register_node_info(node_prop_id, 
							node_prop_name, 
							node_prop_type, 
							node_prop_position,
							node_attr_table)
	local node_info = {
		properties = {
			id 		= node_prop_id,
			name 		= node_prop_name,
			type 		= node_prop_type,
			position 	= node_prop_position
		},
		attributes = {},
		pins = {}
	}
	for k, v in pairs(node_attr_table) do
		node_info["attributes"][k] = v
	end

	return node_info
end

initial_node_id = 1000
initial_node_counter = 0

--构建内部表示的数据结构
inner_data_structure = {
	graph = {
		properties = {
			id = initial_node_id,
            type = '1',
            name = "scene",
		},
		attributes = {},
		nodes = {
		},
	}
}

function get_node_id_by_name(node_name)
	for k, v in pairs(inner_data_structure["graph"]["nodes"]) do
		if v["properties"]["name"] == node_name then
			return v["properties"]["id"]
		end
	end
	return -1
end

function insert_pin(node, z, pin)
	local node_info = node:getProperties()
	local node_name = node_info["name"]
	for k, v in pairs(inner_data_structure["graph"]["nodes"]) do
		if (v["properties"]["name"] == node_name) then
			v["pins"]["pin" .. z] = pin
		end
	end
end

--返回一个pin的信息的表
function get_pin_info(node, pin_name)
	file_log(node:getProperties()["name"] .. "........" .. pin_name)
	local connected_node = node:getConnectedNode(pin_name)
	local pin_info = node:getPinInfo(pin_name)
	local pin_type = 0
	local pin_dynamic = false
	if pin_info["isDynamic"] then
		pin_dynamic = true
		pin_type = pin_info["type"]
	end

	if connected_node then
		file_log("get connected_node")
		if not connected_node:getProperties().pinOwned then
			file_log("get an linker node")
			local linked_node_info = connected_node:getProperties()
			local pin = {properties = {name = pin_name, connect = tostring(get_node_id_by_name(linked_node_info["name"]))},
				attributes = {},
				pin_node = {},
			}
			return pin
		else
			file_log("get an owned node")
			local pin_node = {properties = {}, attributes = {}}
			local owned_node_properties = connected_node:getProperties()
			pin_node["properties"]["id"] = initial_node_id + 1
			pin_node["properties"]["name"] = owned_node_properties["name"]
			file_log("pin_node name is: " .. pin_node["properties"]["name"])
			pin_node["properties"]["type"] = owned_node_properties["type"]
			file_log("pin_node type is: " .. pin_node["properties"]["type"])
			initial_node_id = pin_node["properties"]["id"]
			local owned_node_attribute_counter = connected_node:getAttributeCount()
			file_log("pin node's attr count is: " .. owned_node_attribute_counter)
			if pin_node["properties"]["type"] == 34 then
				--表示当前结点是一个图片
				local pic_node_attr_name = "filename"
				local pic_node_attr_type = "11"
				local pic_node_attr_value = ""	
				local_pin_node = {}
				for l = 1, owned_node_attribute_counter, 1 do
					local attribute_info = connected_node:getAttributeInfoIx(l);
					print("value is: ", attribute_value)
					print("###################################################################")
					print("###################################################################")
					-- print_r(attribute_value)
					local pin_node_attributes_name = octane.apiinfo.getAttributeName(attribute_info["id"])
					print(pin_node_attributes_name)
					local pin_node_attribute_type = attribute_info["type"]
					if pin_node_attributes_name == "filename" then
						pic_node_attr_value = connected_node:getAttributeIx(l)
						break
					end
				end
				local_pin_node["type"] = "11"
				local_pin_node["name"] = "filename"
				local_pin_node["value"] = pic_node_attr_value
				pin_node["attributes"][1] = local_pin_node
			else
				for l = 1, owned_node_attribute_counter, 1 do
					local_pin_node = {}
					local attribute_info = connected_node:getAttributeInfoIx(l);
					print("value is: ", attribute_value)
					-- print_r(attribute_value)
					local pin_node_attributes_name = octane.apiinfo.getAttributeName(attribute_info["id"])
					print(pin_node_attributes_name)
					local pin_node_attributes_type = attribute_info["type"]
					pin_node_attributes_value = connected_node:getAttributeIx(l)
					local_pin_node["type"] = pin_node_attributes_type
					local_pin_node["name"] = pin_node_attributes_name
					local_pin_node["value"] = pin_node_attributes_value
					pin_node["attributes"][l] = local_pin_node
				end
			end
			--到这里当前被pi拥有的结点的prop和attr都已经得到了
			--下面开始处理它的pin
			local pin_count = connected_node:getPinCount()
			-- print(pin_count)
			local pin_pin_nodes = {}
			if pin_pin_count == 0 then
				-- pin连接的值结点没有pin，那么就终止
				local pin = {properties = {name = pin_name, dynamic = pin_dynamic, type = pin_type},
					attributes = {},
					pin_node = pin_node
				}
				return pin
			else
				-- pin连接的值结点有pin，那么就接着调用
				local pin = {}
				local pin_pin_nodes = {}
				for u = 1, pin_count, 1 do
					print("The pin_pin_count is: ", pin_count)
					local pin_pin_name = connected_node:getPinInfoIx(u)["name"]
					print("pin_pin_name is: ", pin_pin_name)
					print("pin_pin_name is: ", pin_pin_name)
					print("connect_node name is: ", connected_node:getProperties()["name"])
					pin_pin_nodes[u] = get_pin_info(connected_node, pin_pin_name)
				end
				-- pin = {properties = {name = pin_name},
				-- 	attributes = {},
				-- 	pin_node = pin_pin_nodes
				-- }

				return {properties = {name = pin_name, dynamic = pin_dynamic, type = pin_type},
					attributes = {},
					pin_node = {
						properties = pin_node["properties"],
						attributes = pin_node["attributes"],
						pin = pin_pin_nodes
					}
				}
				-- return pin
			end
		end
	-- else
	-- 	return {properties = {name = pin_name},
	-- 		attributes = {},
	-- 		pin_node = {}
	-- 	}
	end
end

--获取场景图
function get_all(root_node_name)
	file_log("entering ................")
	scene_graph = octane.project.getSceneGraph()
	--从场景图中获取总的外部结点
	----拿到这些结点的名称(因为目前没有找到拿到结点的ID方法, 所以ID要自己生成)
	----生成这些结点的表示数据, 存入数据结构
	all_single_nodes = octane.nodegraph.getOwnedItems(scene_graph)
	for k, v in pairs(all_single_nodes) do
		local single_node_properties = v:getProperties()
		local node_prop_id = initial_node_id + 1;
		initial_node_id = node_prop_id
		local node_prop_name = single_node_properties["name"]
		if node_prop_name ~= root_node_name then
			node_prop_name  = single_node_properties["name"] .. '-' .. k
			v:updateProperties({name = node_prop_name})
		end
		local node_prop_type = single_node_properties["type"]
		local node_prop_position = single_node_properties["position"]
		local single_node_attribte_counter = v:getAttributeCount()
		local node_attr_table = {}
		local node_type_name = octane.apiinfo.getNodeTypeName(single_node_properties["type"])
		file_log("zzzzzzzzzzzzzzzzz" .. octane.apiinfo.getNodeTypeName(34))
		if single_node_attribte_counter ~= 0 then
			if (node_type_name == 'NT_TEX_IMAGE') then
				file_log("Found rgb image>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
				local attribute_count = v:getAttributeCount()
				for z = 1, attribute_count, 1 do
					local attribute_info = v:getAttributeInfoIx(z)
					if octane.apiinfo.getAttributeName(attribute_info['id']) == 'filename' then
						local file_name = v:getAttributeIx(z)
						node_attr_table[z] = {
							name = "filename",
							type = attribute_info["type"],
							value = file_name
						}
					end
				end
			else
				for i = 1, single_node_attribte_counter, 1 do
					local node_attribute_info = v:getAttributeInfoIx(i)
					local node_attribute_value = v:getAttributeIx(i)
					if type(node_attribute_value) ~= "table" then
						node_attr_table[i] = {
							name = octane.apiinfo.getAttributeName(node_attribute_info["id"]),
							type = node_attribute_info["type"],
							value = node_attribute_value
						}
					end
				end
			end
		else
			--这里表示node没有attribute的情况, 什么也不做
		end
		local single_node = register_node_info(node_prop_id, node_prop_name, node_prop_type, node_prop_position, node_attr_table)
		local node_index = initial_node_counter + 1
		initial_node_counter = node_index
		inner_data_structure["graph"]["nodes"][node_index] = single_node;
	end
	-- print_r(inner_data_structure)
	for k, v in pairs(all_single_nodes) do
		local single_node_pin_counter = v:getPinCount()
		for k = 1, single_node_pin_counter, 1 do
			local single_node_pin_info = v:getPinInfoIx(k)
			local single_node_pin_name = single_node_pin_info["name"]
			file_log("=====================" .. single_node_pin_name .. "============================")
			local pin_deep_info = get_pin_info(v, single_node_pin_name)
			print("@@@@@@@@@@@@@@@@@@@@@@@@")
			-- print_r(pin_deep_info)
			-- print_r(pin_deep_info)
			-- print(pin_deep_info["pin_node"]["pin"][1]["pin_node"]["pin"][1]["pin_node"]["pin"])
			print("@@@@@@@@@@@@@@@@@@@@@@@@")
			insert_pin(v, k, pin_deep_info)
		end
	end
end

--print_r(inner_data_structure)
get_all('0003f432cc7311e49ec700163e021ee1')
print(luatab2ocs(inner_data_structure))
-- print(type((inner_data_structure["graph"]["node"])))
-- print_r(inner_data_structure)