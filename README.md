# LSL Easy Whitelist

A simple and memory-efficient group whitelisting system for Second Life, designed for SLMC (Second Life Military Community) use.

## Features

- **Dialog-based interface** - Easy-to-use click menus for managing group whitelists
- **Region-wide scanning** - Automatically discovers groups worn by avatars in the region
- **Persistent storage** - Uses linkset data for reliable whitelist persistence
- **Memory efficient** - No list-based storage, scales with available linkset data space
- **Paginated menus** - Display up to 6 groups per page with navigation
- **Deployable support** - Pass whitelist to rezzed objects via `llRezObjectWithParams`

## Files

- **`whitelist.lsl`** - Main controller script for managing the whitelist
- **`deployable.lsl`** - Child object script that receives whitelist data on rez

## Installation

1. Create a new object in Second Life
2. Add the `whitelist.lsl` script to the object
3. (Optional) Create child objects with `deployable.lsl` for distributed whitelist enforcement

## Usage

### Managing the Whitelist

1. **Touch the object** - Opens the main menu
2. **Click "Whitelist"** - Scans the region for groups and displays a paginated menu
3. **Select group numbers** - Click the number buttons to add groups to the whitelist
4. **Navigate pages** - Use `<` and `>` buttons to browse through discovered groups
5. **Clear whitelist** - Click "Clear" to remove all whitelisted groups

### Deploying to Child Objects

The whitelist can be passed to rezzed objects using:

```lsl
list allKeys = llLinksetDataListKeys(0, -1);
list whitelistGroups = [];
integer i; for(i = 0; i < llGetListLength(allKeys); i++) {
    string key = llList2String(allKeys, i);
    if(llGetSubString(key, 0, 2) == "wl_") {
        whitelistGroups += llGetSubString(key, 3, -1);
    }
}
string whitelistJson = llList2Json(JSON_ARRAY, whitelistGroups);

llRezObjectWithParams("ObjectName", [
    REZ_PARAM_STRING, whitelistJson,
    REZ_POS, llGetPos() + <0,0,1>,
    REZ_ROT, llGetRot()
]);
```

Child objects will receive the whitelist in their `on_rez` event via `llGetStartString();`.

## Data Storage

The script uses LSL linkset data with the following prefixes:

- **`wl_<groupkey>`** - Whitelisted groups (persistent)
- **`scan_<index>`** - Temporary scan results (cleaned up after use)

## Changelog

- **12/11/2025** - Migrated from hover text storage to linkset data. Eliminated list-based storage
- **8/31/2024** - Updated to support as many groups as script memory can handle. Previously could only display 12 groups

## Requirements

- Second Life viewer with LSL support
- Object must be owned by the user operating the menus
- Sufficient linkset data available (each group uses one key)

## License

This project is provided as-is