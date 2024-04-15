list groups;

default
{
    on_rez(integer param)
    {
        if(param)
        {
            parent = (string)llGetObjectDetails(llGetKey(),[OBJECT_REZZER_KEY]);
            list text = llCSV2List((string)llGetObjectDetails(parent,[OBJECT_TEXT]));
            groups += text;
        }
    }
}
