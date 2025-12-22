// Group Whitelist resets on attach
// 8/31/2024 - Updated to support as many groups as script memory can handle. Previously could only display 12 groups

// When you want to rez with the whitelist:
/*
llRezObjectWithParams("ObjectName", [
    REZ_PARAM_STRING, llList2Json(JSON_OBJECT,["whitelist",whitelist]),
    REZ_POS, llGetPos() + <0,0,1>,
    REZ_ROT, llGetRot()
]);
*/

list whitelist;
list groupList;

integer WLHandle = -1;
integer WLchannel = -1246;
integer index;

findGroups()
{
    index = 0;
    groupList = [];
    list URLs;
    list avatars = llGetAgentList(AGENT_LIST_REGION, []);
    integer numAvatars = llGetListLength(avatars);
    
    integer x;
    for(x = 0; x < numAvatars; ++x)
    {
        key avatar = llList2Key(avatars, x);
        list attachments = llGetAttachedList(avatar);
        key gKey = llList2Key(llGetObjectDetails(llList2Key(attachments, 0), [OBJECT_GROUP]), 0);
            
        if(gKey != "" && gKey != NULL_KEY && !~llListFindList(groupList, [gKey]) && !~llListFindList(whitelist, [gKey]))
        {
            groupList += [gKey];
        }
    }
    
    if(groupList)
    {
        wlmenu();
    }
    else 
    {
        llOwnerSay("All groups in region already whitelisted");
        if(~WLHandle) llListenRemove(WLHandle);
    }
}

wlmenu()
{
    list URLs;
    list buttons = [" ", "Close", " "];
    
    if(index > 0) buttons = llListReplaceList(buttons, ["<"], 0, 0);

    integer maxIndex = index + 6;
    integer groupListLen = llGetListLength(groupList);
    if(maxIndex > groupListLen) maxIndex = groupListLen;

    integer x;
    for(x = index; x < maxIndex; ++x)
    {
        key uuid = llList2Key(groupList, x);
        URLs += (string)x + ". secondlife:///app/group/" + (string)uuid + "/inspect";
        buttons += (string)x;
    }
    
    if(maxIndex < groupListLen)
    {
        buttons = llListReplaceList(buttons, [">"], 2, 2);
    }
    
    llDialog(llGetOwner(), llDumpList2String(URLs, "\n"), buttons, WLchannel);
    if(~WLHandle) llListenRemove(WLHandle);
    WLHandle = llListen(WLchannel, "", llGetOwner(), "");
}

default
{
    state_entry()
    {
        whitelist = [];
    }
    
    attach(key id)
    {
        if(id) llResetScript();
    }
    
    touch_start(integer num_detected)
    {
        if(llDetectedKey(0) == llGetOwner())
        {
            if(~WLHandle) llListenRemove(WLHandle);
            WLHandle = llListen(WLchannel, "", llGetOwner(), "");
            llDialog(llGetOwner(), " ", ["ADD","CLEAR","Close"], WLchannel);
        }
    }
    
    listen(integer channel, string name, key id, string message)
    {
        if(channel != WLchannel || id != llGetOwner()) return;
        
        if(message == "ADD")
        {
            findGroups();
        }
        else if(message == "Close")
        {
            if(~WLHandle) llListenRemove(WLHandle);
        }
        else if(message == "<")
        {
            index -= 6;
            wlmenu();
        }
        else if(message == ">")
        {
            index += 6;
            wlmenu();
        }
        else if(message == "CLEAR")
        {
            whitelist = [];
            llOwnerSay("Cleared whitelist");
        }
        else
        {
            integer num = (integer)message;
            if(num >= 0 && num < llGetListLength(groupList) && message != " ")
            {
                key groupKey = llList2Key(groupList, num);
                whitelist += [groupKey];
                llOwnerSay("Added secondlife:///app/group/" + (string)groupKey + "/inspect to the whitelist");
            }
        }
    }
}
