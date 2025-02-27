usageSyntax = "#D19D6B[Use]: #FFFFFF"
errorSyntax = "#E48F8F[Error]: #FFFFFF"
successSyntax = "#9BE48F[Success]: #FFFFFF"
infoSyntax = "#8FC3E4[Info]: #FFFFFF"

info2HexColor = "#9BE48F"
info3HexColor = "#8FC3E4"
whiteHexColor = "#FFFFFF"

function outputAdminMessage(text)
    for k,v in ipairs(getElementsByType("player")) do
        if getElementData(v, "adminLevel") >= 1 then
            outputChatBox("#8CA4FF[Admin]: " .. whiteHexColor .. "".. text, v, 255, 255, 255, true)
            exports.a_logs:createDCLog(removeHex(text, 6), 1)
        end
    end
end

function removeHex (text, digits)
    assert (type (text) == "string", "Bad argument 1 @ removeHex [String expected, got "..tostring(text).."]")
    assert (digits == nil or (type (digits) == "number" and digits > 0), "Bad argument 2 @ removeHex [Number greater than zero expected, got "..tostring (digits).."]")
    return string.gsub (text, "#"..(digits and string.rep("%x", digits) or "%x+"), "")
end

adminSyntaxes = {
    [0] = {"#FFFFFF(Játékos) "},
    [1] = {"#dfacde(P. Moderátor) "},
    [2] = {"#cfad80(Moderátor) "},
    [3] = {"#62a7e1(Adminisztrátor) "},
    [4] = {"#89DC3C(FőAdmin) "},
    [5] = {"#dce188(Fejlesztő) "},
    [6] = {"#e18c88(Tulajdonos) "},
}

function getAdminSyntax(adminLevel)
    if tonumber(adminLevel) then
        return adminSyntaxes[tonumber(adminLevel)][1]   
    else
        return false
    end
end

devSerials = {}