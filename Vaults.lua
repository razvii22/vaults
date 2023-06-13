local vaults = {}
vaults.__index = vaults

local wrap = peripheral.wrap
local setmetatable = setmetatable
local getName = peripheral.getName
local find = peripheral.find

setmetatable(vaults, {
    __call = function (cls, ...)
      return cls.new(...)
    end,
})


-- constructor function
function vaults.new(list)
    local self = setmetatable({},vaults)
    self.list = list
    self:wrap()
    self:indexAll()
    self.new = function() error("Instances may not create other instances!",2) end
    return self
end


--wrap method, adds a vaults field to the object and fills it with the returned objecs of every vault on the list...
function vaults:wrap()
    self.vaults = {}
    for k,v in pairs(self.list) do
        self.vaults[k] = wrap(self.list[k])
        self.vaults[k].index = k
        self.vaults[k].name = self.list[k]
    end
end


--find arbitraty items in the master index!
function vaults:findItem(item)
    local list = {}
    for k,v in pairs(self.index) do --iterate through vaults
        local vault = k
        for k,v in pairs(v) do  --iterate through vault contents
            local slot = k
            if v.name == item then
                local count = v.count
                list[#list+1] = {["vault"] = vault,["slot"] = slot,["count"] = count}
            end
        end
    end
    return list
end


--idk why but i wanted to know how big the network is
function vaults:size()
    local count = 0
    for k,v in pairs(self.vaults) do --iterates through the vaults
        count = count + v.size()
    end
    return count 
end



function vaults:pullItems(source,target,list,count)
    if type(target) ~= "table" then error("Target not specified correctly.",2) end

    local oldcount = count

    for k,v in pairs(list) do

        if not (self.vaults[v.vault].name == target) then


            
            count = count - ccount

            if ccount == v.count then
                self.index[v.vault][v.slot] = nil
            end
        end
    end


end



function vaults:pushItems(target,list,count)
    local oldcount = count
    for k,v in pairs(list) do
        if not (self.vaults[v.vault].name == target) then
            local ccount = self.vaults[v.vault].pushItems(target,v.slot,count)
            count = count - ccount
            if count == 0 then return count end
        end
    end
    local hash = {}
    for k,v in pairs(list) do
        if not hash[v] then 
            self:indexVault(v.vault)
        else
            hash[v] = true
        end
    end
    return oldcount - count
end


--helper function, returns all peripheral names of certain type on network
function vaults.findInv(type,count)
    local count = count or 0
    local vaultsS = {find(type)}
    local names = {}
    local hash = {}
    for k,v in pairs(vaultsS) do
        local name = getName(vaultsS[k])

        if not hash[name] then
            names[#names+1] = name
            hash[name] = true
        end
        if #names == count then return names end
    end
    return names
end


--index vaults and returns said index
function vaults:indexAll()
    self.index = {}
    for k,v in pairs(self.vaults) do
        self.index[k] = v.list()
    end
    --return self.index
end


--indexes specific vault in the vaults index
function vaults:indexVault(vaultIndex)
    if not vaultIndex then return 1 end
    local list = self.vaults[vaultIndex].list()
    self.index[vaultIndex] = list
    return list
end


--god help me
function vaults:genList()
    local modnames = {}
    local modhash = {}

    local names = {}
    local namehash = {}

    for k,v in pairs(self.index) do
        for _,v in pairs(v) do
            local _,colon = v.name:find(":")
            local modname = v.name:sub(1,colon)
            local name = v.name:sub(colon+1,v.name:len())

            if not modhash[modname] then
                modnames[#modnames+1] = modname
                modhash[modname] = true
            elseif not namehash[name] then
                names[#names+1] = name
                namehash[name] = true
            end
        end
    end
    return {["names"] = names,["modnames"] = modnames}
end

return vaults