// This script provides an easy to use and navigate group whitelisting feature using simple click dialog menus for SLMC use
// The whitelist is stored in linkset data with the "wl_" prefix and can be passed to rezzed objects via llRezObjectWithParams and REZ_PARAM_STRING
/////////////
// 8/31/2024 - Updated to support as many groups as script memory can handle. Previously could only display 12 groups
// 12/11/2025 - Migrated from hover text storage to linkset data. Eliminated list-based storage

integer channel = -1246;
integer index;
integer MODE_ADD = 0;
integer MODE_REMOVE = 1;
integer mode;
list whitelistCache = []; // Cache for quick access

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
        llDialog(llGetOwner(), " ", ["Add", "Remove", "Clear All"], channel);
        return;
        
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
        llDialog(llGetOwner(), " ", ["Add", "Remove", "Clear All"], channel);
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

// Add this helper function
refreshCache()
{
    whitelistCache = [];
    list allKeys = llLinksetDataListKeys(0, -1);
    integer i; 
    integer count = llGetListLength(allKeys);
    
    for(i = 0; i < count; i++)
    {
        string fullKey = llList2String(allKeys, i);
        if(llGetSubString(fullKey, 0, 2) == "wl_")
        {
            whitelistCache += llGetSubString(fullKey, 3, -1);
        }
    }
}

default
{
    state_entry()
    {
        refreshCache(); // Load on script start
    }
    
    touch_start(integer total_number)
    {
        if(llDetectedKey(0) == llGetOwner())
        {
           llDialog(llGetOwner(), " ", ["Add", "Remove", "Clear All"], channel);
           llListen(channel, "", llGetOwner(), "");
        }
    }
    
    listen(integer chan, string name, key id, string msg)
    {
        if(msg == "Add")
        {
            mode = MODE_ADD;
            findGroups();
        }
        else if(msg == "Remove")
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
            llDialog(llGetOwner(), " ", ["Add", "Remove", "Clear All"], channel);
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
                    whitelistCache += group; // Update cache
                    llOwnerSay("Added secondlife:///app/group/" + group + "/inspect to the whitelist");
                     // Refresh the add menu
                    findGroups();
                    
                }
                else if(mode == MODE_REMOVE)
                {
                    llLinksetDataDelete("wl_" + group);
                    integer idx = llListFindList(whitelistCache, [group]);
                    if(idx != -1) whitelistCache = llDeleteSubList(whitelistCache, idx, idx); // Update cache
                    llOwnerSay("Removed secondlife:///app/group/" + group + "/inspect from the whitelist");
                    // Refresh the removal menu
                    showWhitelist();
                }
            }
        }
    }
    
    // When you want to rez with the whitelist:
    // string whitelistJson = llList2Json(JSON_ARRAY, whitelistCache);
}
