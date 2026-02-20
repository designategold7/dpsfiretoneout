### ASRP Fire Tone Out System
1. CONFIGURATION (server.lua)
   - Set SONORAN_COMM_ID and SONORAN_API_KEY.
   - API Key requires "NEW_DISPATCH" permission.
   - SENDER_JOB is set to 'police'.
   - AFD_JOBS is set to 'ambulance'.
2. USAGE
   - Command: /tonefd [Optional Message]
   - Example: /tonefd 10-50 Major with entrapment
   - Requires 'police' job.
   - Tones 'ambulance' job players.
