vaults = {}
vaults.__index = vaults


setmetatable(vaults, {
    __call = function (cls, ...)
      return cls.new(...)
    end,
})

--constructor function
function vaults.new(list)
    local self = setmetatable({},vaults)
    self.list = list
    self:wrap()
    self:doIndex()
    self.new = function() error("Instances may not create other instances!",2) end
    return self
end

--wrap method, adds a vaults field to the object and fills it with the returned objecs of every vault on the list...

function vaults:wrap()
    self.vaults = {}
    for k,v in pairs(self.list) do
        self.vaults[k] = peripheral.wrap(self.list[k])
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

--helper function, returns all peripheral names of certain type on network

function vaults.find(type)
    local vaultsS = {peripheral.find(type)}
    local names = {}
    for k,v in pairs(vaultsS) do
        names[k] = peripheral.getName(vaultsS[k])
    end
    return names
end

--index vaults and returns said index

function vaults:doIndex()
    self.index = {}
    for k,v in pairs(self.vaults) do
        self.index[k] = v.list()
    end
    --return self.index
end

--god help me

function vaults:genList()
    local modnames = {}
    local modhash = {}

    local names = {}
    local namehash = {}

    for k,v in pairs(self.index) do
        for k,v in pairs(v) do
            local _,colon = v.name:find(":")
            local modname = v.name:sub(1,colon)
            local name = v.name:sub(colon+1,v.name:len())

            if not modhash[modname] then
                modnames[#modnames+1] = modname
                modhash[modname] = true
            elseif not namehash[name] then
                names[#names+1] = name
                namehash[name] = name
            end
        end
    end
    return {["names"] = names,["modnames"] = modnames}
end

return vaults