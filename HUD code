list groups  =  []; // Groups you always want to be whitelisted
list whitelist;
list groupList;
list groupKeys;
list buttons;

integer channel = -1246;

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
    listen(integer chan, string name, key id, string msg){
        if(msg=="Whitelist"){
            list t = llGetAgentList(AGENT_LIST_REGION,[]);
            integer i = llGetListLength(t)-1;
            groupList = [];
            groupKeys = [];
            buttons = [" ",">"];
            integer x; for(; x<i; x++)
            {
                string gKey = (string)llGetObjectDetails(llList2Key(llGetAttachedList(llList2Key(t,x)),0),[OBJECT_GROUP]);
                if(gKey)
                {
                    string groupURL = "secondlife:///app/group/"+gKey+"/inspect";
                    if(llListFindList(whitelist,[(key)gKey]) == -1 && llListFindList(groupKeys,[gKey]) == -1 && llListFindList(groups,[gKey]) == -1)
                    {
                        integer L = llGetListLength(groupList);
                        groupList+=[(string)L+". "+groupURL];
                        groupKeys+=[gKey];
                        buttons+=[(string)L];
                    }
                }
            }
            if(groupList)
            {
                if(llGetListLength(groupList) >7){
                    llDialog(llGetOwner(),llDumpList2String(llList2List(groupList,0,6),"\n"),llList2List(buttons,0,8),channel);
                }
                else{ llDialog(llGetOwner(),llDumpList2String(groupList,"\n"),llListReplaceList(buttons,[" "," "],0,1),channel); }
            }
            else{
                llOwnerSay("All groups in region already whitelisted");
            }
        }    
        else if(msg=="Clear"){
            whitelist = [];
            llSetText("",<1,1,1>,0);
            llOwnerSay("Cleared whitelist");
        }
        else if(msg==">"){
            list pg2b = ["<"," "]+llList2List(buttons,9,16);
            llDialog(llGetOwner(),llDumpList2String(llList2List(groupList,7,13),"\n"),pg2b,-343);
        }
        else if(msg=="<"){
            llDialog(llGetOwner(),llDumpList2String(llList2List(groupList,0,6),"\n"),llList2List(buttons,0,8),-343);
        } 
        else if(msg==" "){
            
        }
        else{
            key group = llList2String(groupKeys,(integer)msg);
            string name = llList2String(groupList,(integer)msg);
            whitelist+=group;
            llSetText(llList2CSV(whitelist),<1,1,1>,0);
            llOwnerSay("Added " + name + "("+(string)group+")"+" to the whitelist");
        }
    }
}
