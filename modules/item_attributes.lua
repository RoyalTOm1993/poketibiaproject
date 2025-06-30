function stringToTable(inputString)
    local tableFunction = load("return " .. inputString)
    local dataTable = tableFunction()
    return dataTable
end

function getBallSpecialAttribute(key, tableString)
    local dataTable = stringToTable(tableString)
    return dataTable[key]
end