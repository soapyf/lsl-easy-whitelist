# LSL Easy Whitelist

# Second Life Group Whitelist Script

A Second Life (LSL) script that allows you to build and manage a whitelist of group keys from avatars in the current region.

## Features

- Detects all groups worn by avatars in the region
- Paginated dialog system to browse and select groups
- Add detected groups to your whitelist
- Remove all groups from the whitelist at once
- Whitelist resets when the object is attached

## Usage

1. **Attach or Rez** the object containing this script
2. **Touch** the object to open the main menu
3. **Select "ADD"** to scan for groups in the region
4. **Choose groups** from the paginated list to add them to your whitelist
5. **Use navigation buttons** (`<` and `>`) to browse through multiple pages
6. **Select "CLEAR"** to empty the entire whitelist
7. **Click "Close"** to dismiss any menu

## Rezzing with Whitelist Data

You can pass the whitelist to rezzed objects using:

```lsl
llRezObjectWithParams("ObjectName", [
    REZ_PARAM_STRING, llList2Json(JSON_OBJECT,["whitelist",whitelist]),
    REZ_POS, llGetPos() + <0,0,1>,
    REZ_ROT, llGetRot()
]);
```
