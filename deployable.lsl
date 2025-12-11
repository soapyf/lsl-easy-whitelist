list groups;

default
{
    on_rez(integer param)
    {
        string whitelistJson = llGetStartString();
        if(whitelistJson != "")
        {
            groups = llJson2List(whitelistJson);
            llOwnerSay("Loaded " + (string)llGetListLength(groups) + " whitelisted groups");
        }
    }
}
