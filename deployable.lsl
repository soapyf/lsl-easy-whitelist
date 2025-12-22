list groups;

default
{
    on_rez(integer param)
    {
        string startString = llGetStartString();
        string whitelist = llJsonGetValue(startString,["whitelist"]);
        if(whitelist != JSON_NULL && whitelist != JSON_INVALID)
        {
            groups += llCSV2List(whitelist);
            llOwnerSay("Loaded " + (string)llGetListLength(groups) + " whitelisted groups");
        }
    }
}
