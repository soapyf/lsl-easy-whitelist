// This script provides an easy to use and navigate group whitelisting feature using simple click dialog menus for SLMC use
// The whitelist is stored in linkset data with the "wl_" prefix and can be passed to rezzed objects via llRezObjectWithParams and REZ_PARAM_STRING
/////////////
// 8/31/2024 - Updated to support as many groups as script memory can handle. Previously could only display 12 groups
// 12/11/2025 - Migrated from hover text storage to linkset data. Eliminated list-based storage

integer channel = -1246;
integer index;
integer MODE_ADD = 0;      // Adding groups to whitelist
integer MODE_REMOVE = 1;   // Removing groups from whitelist
integer mode;

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

showWhitelist()
{
    index = 0;
    
    // Clear temporary scan results and populate with current whitelist
    llLinksetDataDeleteFound("scan_", "");
    
    list allKeys = llLinksetDataListKeys(0, -1);
    integer scanCount = 0;
    integer i; 
    integer count = llGetListLength(allKeys);
    
    for(i = 0; i < count; i++)
    {
        string fullKey = llList2String(allKeys, i);
        // Only process keys that start with "wl_"
        if(llGetSubString(fullKey, 0, 2) == "wl_")
        {
            string groupKey = llGetSubString(fullKey, 3, -1); // Remove "wl_" prefix
            llLinksetDataWrite("scan_" + (string)scanCount, groupKey);
            scanCount++;
        }
    }
    
    if(scanCount == 0)
    {
        llOwnerSay("Whitelist is empty");
        return;
    }
    
    menu();
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
        
        string prompt = llDumpList2String(URLs, "\n");
        if(mode == MODE_ADD)
            prompt = "Select groups to ADD:\n" + prompt;
        else
            prompt = "Select groups to REMOVE:\n" + prompt;
            
        llDialog(llGetOwner(), prompt, buttons, channel);
    }
}

default
{
    touch_start(integer total_number)
    {
        if(llDetectedKey(0) == llGetOwner())
        {
           llDialog(llGetOwner(), " ", ["Add Groups", "Remove Groups", "Clear All"], channel);
           llListen(channel, "", llGetOwner(), "");
        }
    }
    
    listen(integer chan, string name, key id, string msg)
    {
        if(msg == "Add Groups")
        {
            mode = MODE_ADD;
            findGroups();
        }
        else if(msg == "Remove Groups")
        {
            mode = MODE_REMOVE;
            showWhitelist();
        }
        else if(msg == "Clear All")
        {
            // Delete all whitelisted groups
            llLinksetDataDeleteFound("wl_", "");
            llLinksetDataDeleteFound("scan_", "");
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
            string group = llLinksetDataRead("scan_" + msg);
            if(group != "")
            {
                if(mode == MODE_ADD)
                {
                    llLinksetDataWrite("wl_" + group, "1");
                    llOwnerSay("Added secondlife:///app/group/" + group + "/inspect to the whitelist");
                }
                else if(mode == MODE_REMOVE)
                {
                    llLinksetDataDelete("wl_" + group);
                    llOwnerSay("Removed secondlife:///app/group/" + group + "/inspect from the whitelist");
                    // Refresh the removal menu
                    showWhitelist();
                }
            }
        }
    }
    
    // When you want to rez with the whitelist:
    // list allKeys = llLinksetDataListKeys(0, -1);
    // list whitelistGroups = [];
    // integer i; for(i = 0; i < llGetListLength(allKeys); i++) {
    //     string key = llList2String(allKeys, i);
    //     if(llGetSubString(key, 0, 2) == "wl_") {
    //         whitelistGroups += llGetSubString(key, 3, -1);
    //     }
    // }
    // string whitelistJson = llList2Json(JSON_ARRAY, whitelistGroups);
}
