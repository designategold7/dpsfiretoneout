### FD Fire Tone Out System (Sonoran CAD + Knight Duty Integration)
### Author: Designategold7

========================================================================
1. WHAT IS THIS?
========================================================================
This is a custom ESX script designed for Arkansas State RP 2.0. 
It allows on-duty DPS units to instantly "tone out" Fire & EMS to their location.

Key Features:
- COMMAND: /tonefd
- SENDER CHECK: Verifies user has 'dps' job AND is clocked in via Knight Duty (/duty DPS).
- RECIPIENT CHECK: Scans for 'ambulance/fire' jobs who are clocked in via Knight Duty (/duty AFD).
- ACTION: Plays a loud pager tone for FD units, sets their GPS to the scene, and shows a notification.
- INTEGRATION: Automatically sends a "NEW_DISPATCH" API request to Sonoran CAD to create a call.
- SAFETY: Includes a 30-second cooldown per officer to prevent spam.

========================================================================
2. INSTALLATION
========================================================================
1. Place the folder (e.g., `dps_tone`) into your server's [resources] directory.
2. Add `ensure dps_tone` to your `server.cfg`.
3. Ensure this resource starts AFTER `es_extended` and `knight_duty`.

========================================================================
3. CONFIGURATION (REQUIRED)
========================================================================
You must edit 'server.lua' to make this work with your specific environment.

A. SONORAN CAD API KEYS (Lines 15-16)
   Replace "CHANGE_ME" with your actual Community ID and API Key.
   * NOTE: The API Key must have "NEW_DISPATCH" permissions enabled in Sonoran Admin.

B. JOB NAMES (Lines 4-9)
   - SENDER_JOB = 'dps' 
     (Change this if the LEO database job name is different, e.g., 'police' or 'patrol')
   
   - AFD_JOBS
     (Ensure these match your database job names for Fire/EMS)

C. KNIGHT DUTY EXPORT (Line 24)
   This script uses: exports['knight_duty']:isOnDuty(source)
   * IF your resource is named 'knight-duty' (with a dash), you must rename 
     'knight_duty' to 'knight-duty' on Line 24 in server.lua.

========================================================================
4. USAGE
========================================================================
- Officer runs: /tonefd
- If Cooldown is active: Returns wait time.
- If Off Duty: Returns "Access Denied".
- If Successful: Tones units and logs call to CAD.
