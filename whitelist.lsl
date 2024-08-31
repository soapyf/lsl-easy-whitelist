// This script is meant to provide an easy to use and navigate group whitelisting feature using simple click dialog menus for SLMC use
// The whitelist will be stored as a CSV with invisible hovertext but you could also use llRezObjectWithParams and REZ_PARAM_STRING to pass the list 
/////////////
// 8/31/2024 - Updated to support as many groups as script memory can handle. Previously could only display 12 groups

list groups  =  []; // Groups you always want to be whitelisted
list whitelist;
list groupList;

integer channel = -1246;
integer index;

findGroups()
{
    index=0;
    groupList = [];
    list URLs;
    list t = llGetAgentList(AGENT_LIST_REGION,[]);
    integer i = llGetListLength(t);

    integer x; for(; x<i; x++)
    {
        string gKey = (string)llGetObjectDetails(llList2Key(llGetAttachedList(llList2Key(t,x)),0),[OBJECT_GROUP]);
        if(gKey)
        {
            if(llListFindList(groupList,[gKey]) == -1 && llListFindList(whitelist,[gKey]) == -1 && llListFindList(groups,[gKey]) == -1 && gKey!=NULL_KEY)
            {
                string groupURL = "secondlife:///app/group/"+gKey+"/inspect";
                integer num = llGetListLength(groupList);
                groupList+=[gKey];
                URLs+=[(string)num+". "+groupURL];
            }
        }
    }
    if(groupList)
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
    if(index > 0){ buttons = ["<","Close"," "];}
    else{ buttons = [" ","Close"," "];}

    integer x; for(x=index; x<index+6; x++)
    {
        string uuid = llList2String(groupList,x);
        if(uuid){
            URLs+=(string)x+". secondlife:///app/group/"+uuid+"/inspect";
            buttons+=(string)x;
        }
    }
    if(buttons){
        if(index+6 > llGetListLength(groupList)-1)
        { 
            llDialog(llGetOwner(),llDumpList2String(URLs,"\n"),buttons,channel);
        }
        else 
        {
            llDialog(llGetOwner(),llDumpList2String(URLs,"\n"),llListReplaceList(buttons,[">"],2,2),channel);
        }
        
    }
}
default
{
    touch_start(integer total_number)
    {
        if(llDetectedKey(0) == llGetOwner())
        {
           llDialog(llGetOwner()," ",["Whitelist","Clear"],channel);
           llListen(channel,"",llGetOwner(),"");
        }
    }
    listen(integer chan, string name, key id, string msg)
    {
        if(msg=="Whitelist")
        {
            findGroups();
        }
        else if(msg=="Clear")
        {
            whitelist = [];
            llSetText("",<1,1,1>,0);
            llOwnerSay("Cleared whitelist");
        }
        // Menu Navigation
        else if(msg==">")
        {
            index+=7;
            menu();
            
        }
        else if(msg=="<")
        {
            index-=7;
            menu();
        }
        else
        {
            if(msg!=" " && msg!="Close")
            {
                string group = llList2String(groupList,(integer)msg);
                whitelist+=group;
                llSetText(llList2CSV(whitelist)+","+llList2CSV(groups),<1,1,1>,0);
                llOwnerSay("Added secondlife:///app/group/"+(string)group+"/inspect to the whitelist");
            }
        }
    }
}
