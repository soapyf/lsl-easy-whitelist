# LSL Easy Whitelist

A simple and memory-efficient group whitelisting system for Second Life, designed for SLMC (Second Life Military Community) use.

## Features

- **Dialog-based interface** - Easy-to-use click menus for managing group whitelists
- **Region-wide scanning** - Automatically discovers groups worn by avatars in the region
- **Persistent storage** - Uses linkset data for reliable whitelist persistence
- **Cached whitelist** - Fast access for rezzing objects without linkset data read delays
- **Add/Remove individual groups** - Fine-grained control over whitelist entries
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

1. **Touch the object** - Opens the main menu with three options:
   - **Add** - Scan the region for new groups to add
   - **Remove** - View and remove individual groups from the whitelist
   - **Clear All** - Remove all whitelisted groups at once

2. **Adding Groups:**
   - Click "Add" to scan all avatars in the region
   - Groups are automatically detected from worn attachments
   - Select group numbers from the paginated menu to add them
   - Use `<` and `>` buttons to navigate through pages

3. **Removing Groups:**
   - Click "Remove" to view all whitelisted groups
   - Select group numbers to remove individual groups
   - Menu automatically refreshes after removal

### Deploying to Child Objects

The whitelist can be passed to rezzed objects using:

```lsl
string whitelistJson = llList2Json(JSON_OBJECT, whitelistCache);

llRezObjectWithParams("ObjectName", [
    REZ_PARAM_STRING, whitelistJson,
    REZ_POS, llGetPos() + <0,0,1>,
    REZ_ROT, llGetRot()
]);
```

Child objects will receive the whitelist in their `on_rez` event via `llGetStartString()`.

## Data Storage

The script uses a hybrid storage approach:

- **Linkset Data** - Persistent storage with the following prefixes:
  - `wl_<groupkey>` - Whitelisted groups (permanent)
  - `scan_<index>` - Temporary scan results (cleaned up after use)

- **Script Variable** - `whitelistCache` list for instant access when rezzing objects

The cache is automatically refreshed on script start and updated whenever groups are added or removed.

## Changelog

- **12/11/2025** - Migrated from hover text storage to linkset data. Added individual group removal. Implemented whitelist caching for faster object rezzing.
- **8/31/2024** - Updated to support as many groups as script memory can handle. Previously could only display 12 groups.

## Requirements

- Second Life viewer with LSL support
- Object must be owned by the user operating the menus
- Sufficient linkset data available (each group uses one key)

## License

This project is provided as-is
