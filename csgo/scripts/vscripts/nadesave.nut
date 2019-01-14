/* nadesave.nut
 * Nade Saving Script
 * by Foltik
 * based on a script by S0lll0s, Bidj and Rurre
 * 
 * goes into /csgo/scripts/vscripts/nadesave.nut
 *
 * USAGE, in console:
 *  script_execute nadesave
 *	script ns_setup()
 * 	bind "anykey" "script ns_save()"
 *	bind "anykey" "script ns_pause()"
 * Press the ns_save() key before every nade you want to save, all following nades will fly the same path.
 * regardless of how you throw them. To pause the script and throw nades freely use the other bind ns_pause().
 */

this.saved		<- {};
this.thrown		<- [];
this.pos		<- null;
this.vel		<- null;
this.saving		<- "";
this.throwing	<- "";

printl( @"nadesave executed" );
printl( @"type to start: script ns_setup()" );

ns_think <- function() {
	local flash = null;
	while ((flash = Entities.FindByClassname(flash, "flashbang_projectile")) != null)
		ns_exec(flash);
	
	local he = null;
	while ((he = Entities.FindByClassname(he, "hegrenade_projectile")) != null)
		ns_exec(he);
	
	local smoke = null;
	while ((smoke = Entities.FindByClassname(smoke, "smokegrenade_projectile")) != null)
		ns_exec(smoke);
		
	local molly = null;
	while ((molly = Entities.FindByClassname(molly, "molotov_projectile")) != null)
		ns_exec(molly);
}

function ns_setup() {
	printl(@"[NS] nadesave.nut");
	printl(@"[NS] Nade Saving Script");
	printl(@"[NS] CONSOLE USAGE:");
	printl(@"[NS] 	 script ns_save(""slotname"" = ""quicksave"")  - Saves the next nade thrown to slot ""slotname"".");
	printl(@"[NS] 	 script ns_throw(""slotname"" = ""quicksave"") - The next nade thrown will throw the nade saved in slot ""slotname"".");
	printl(@"[NS] 	 script ns_clear() - Clear all save slots.");

	printl(@"[NS] Setting up...");
	
	// Create timer entity
	local timer = Entities.CreateByClassname("logic_timer");
	timer.ValidateScriptScope();
	local timerScope = timer.GetScriptScope();
	
	// Attach think function
	timerScope.Think <- ns_think;
	EntFireByHandle(timer, "AddOutput", "OnTimer !self:RunScriptCode:Think():0:-1", 0, null, null);
	
	// Set attributes
	timer.__KeyValueFromFloat("RefireTime", 0.05);
	timer.__KeyValueFromFloat("UseRandomTime", 0);
	timer.__KeyValueFromString("TargetName", "nade_timer");
	
	// Enable timer
	EntFireByHandle(timer, "Enable", "", 0, null, null);
	
	printl(@"[NS] Done.");
}

function ns_exec(nade) {
	foreach (index, item in thrown)
		if (nade == item)
		    return;

	if (saving.len()) {
		local info = {
			pos = nade.GetCenter(),
			vel = nade.GetVelocity(),
			type = nade.GetClassname()
		};
		saved[saving] <- info;
		ScriptPrintMessageCenterAll("Saved " + saving);
		saving = "";
	} else if (throwing.len()) {
		local info = saved[throwing];
		nade.SetAbsOrigin(info.pos);
		nade.SetVelocity(info.vel);
		ScriptPrintMessageCenterAll("Threw " + throwing);
		throwing = "";
	}
	
	thrown.push(nade);
}

function ns_save(key = "quicksave") {
	saving = key;
}

function ns_throw(key = "quicksave") {
    if (key in saved)
		throwing = key;
	else
	    ScriptPrintMessageCenterAll("Not found.");
}

function ns_clear() {
	saved = [];
}