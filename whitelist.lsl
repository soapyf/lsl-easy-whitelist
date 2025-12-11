// This script provides an easy to use and navigate group whitelisting feature using simple click dialog menus for SLMC use
// The whitelist is stored in linkset data with the "wl_" prefix and can be passed to rezzed objects via llRezObjectWithParams and REZ_PARAM_STRING
/////////////
// 8/31/2024 - Updated to support as many groups as script memory can handle. Previously could only display 12 groups
// 12/11/2025 - Migrated from hover text storage to linkset data. Eliminated list-based storage

integer channel = -1246;
integer index;

findGroups()
{
    index = 0;
    
    // Clear temporary scan results
    llLinksetDataDeleteFound("scan_", "");
    
    list agents = llGetAgentList(AGENT_LIST_REGION, []);
    integer i = llGetListLength(agents);
    integer scanCount = 0;
    list foundGroups = []; // Track groups we've already found this scan
    
    integer x; for(x = 0; x < i; x++)
    {
        key agent = llList2Key(agents, x);
        list attachments = llGetAttachedList(agent);
        integer attCount = llGetListLength(attachments);
        
        integer a; for(a = 0; a < attCount; a++)
        {
            string gKey = (string)llGetObjectDetails(llList2Key(attachments, a), [OBJECT_GROUP]);
            if(gKey != "" && gKey != NULL_KEY)
            {
                // Check if already whitelisted OR already found in this scan
                if(llLinksetDataRead("wl_" + gKey) == "" && 
                   llListFindList(foundGroups, [gKey]) == -1)
                {
                    // Store temporarily with scan_ prefix
                    llLinksetDataWrite("scan_" + (string)scanCount, gKey);
                    foundGroups += gKey; // Mark as found
                    scanCount++;
                }
            }
        }
    }
    
    if(scanCount > 0)
    {
        menu();
    }
    else 
    {
        llOwnerSay("All groups in region already whitelisted");
    }
}

menu()
{
    list URLs;
    list buttons;
    
    if(index > 0) buttons = ["<", "Close", " "];
    else buttons = [" ", "Close", " "];
    
    integer displayCount = 0;
    integer x; for(x = index; x < index + 6; x++)
    {
        string uuid = llLinksetDataRead("scan_" + (string)x);
        if(uuid != "")
        {
            URLs += (string)x + ". secondlife:///app/group/" + uuid + "/inspect";
            buttons += (string)x;
            displayCount++;
        }
    }
    
    if(displayCount > 0)
    {
        // Check if there are more items
        if(llLinksetDataRead("scan_" + (string)(index + 6)) != "")
        {
            buttons = llListReplaceList(buttons, [">"], 2, 2);
        }
        
        llDialog(llGetOwner(), llDumpList2String(URLs, "\n"), buttons, channel);
    }
}

default
{
    touch_start(integer total_number)
    {
        if(llDetectedKey(0) == llGetOwner())
        {
           llDialog(llGetOwner(), " ", ["Whitelist", "Clear"], channel);
           llListen(channel, "", llGetOwner(), "");
        }
    }
    
    listen(integer chan, string name, key id, string msg)
    {
        if(msg == "Whitelist")
        {
            findGroups();
        }
        else if(msg == "Clear")
        {
            // Delete all whitelisted groups
            llLinksetDataDeleteFound("wl_", "");
            llOwnerSay("Cleared whitelist");
        }
        else if(msg == ">")
        {
            index += 6;
            menu();
        }
        else if(msg == "<")
        {
            index -= 6;
            menu();
        }
        else if(msg != " " && msg != "Close")
        {
            // Add to permanent whitelist
            string group = llLinksetDataRead("scan_" + msg);
            if(group != "")
            {
                llLinksetDataWrite("wl_" + group, "1");
                llOwnerSay("Added secondlife:///app/group/" + group + "/inspect to the whitelist");
            }
        }
    }
    
    // When you want to rez with the whitelist:
    // string whitelistJson = llList2Json(JSON_ARRAY, llLinksetDataListKeys("wl_", 0, -1));
}
