#include	<multicolors>
#include	<geoip>

#pragma		semicolon	1
#pragma		newdecls	required

char	TF2_GetTeamColor[][96]	=	{
	"{black}",
	"{grey}",
	"{red}",
	"{blue}",
	"{lightgreen}",
	"{orange}"
};

char	CSS_GetTeamColor[][96]	=	{
	"{black}",
	"{grey}",
	"{red}",
	"{blue}"
};

char	CSGO_GetTeamColor[][96] =	{
	"{black}",
	"{grey}",
	"{orange}",
	"{bluegrey}"
};

char	flag_owner[16],
		flag_admin[16],
		flag_moderator[16],
		flag_vip[16];
		

ConVar		manager_connect,
			manager_disconnect,
			manager_flag_owner,
			manager_flag_admin,
			manager_flag_moderator,
			manager_flag_vip;

public	Plugin	myinfo	=	{
	name		=	"[ANY] Connect/Disconnect Manager",
	author		=	"Tk /id/Teamkiller324",
	description	=	"Manages the connect & disconnect messages with full translation support",
	version		=	"1.0.0",
	url			=	"https://steamcommunity.com/id/Teamkiller324"
}

public	void	OnPluginStart()	{
	LoadTranslations("connect_disconnect_manager.phrases");
	switch(GetEngineVersion())	{
		case	Engine_TF2:			HookEvent("player_connect_client",	Event_PlayerConnect,	EventHookMode_Pre);
		case	Engine_CSS:			HookEvent("player_connect_client",	Event_PlayerConnect,	EventHookMode_Pre);
		case	Engine_CSGO:		HookEvent("player_connect",			Event_PlayerConnect,	EventHookMode_Pre);
		case	Engine_Left4Dead2:	HookEvent("player_connect",			Event_PlayerConnect,	EventHookMode_Pre);
	}
	HookEvent("player_disconnect",	Event_PlayerDisconnect,	EventHookMode_Pre);
	
	//ConVars
	manager_connect		=	CreateConVar("sm_connect_manager_connect",		"1",	"Determine if connect messages are enabled and wich method to use. \n0 = Disabled \n1 = Enabled - Use OnClientAuthorized \n2 = Enabled - Use OnClientPostAdminCheck",	_,	true,	0.0,	true,	2.0);
	manager_disconnect	=	CreateConVar("sm_connect_manager_disconnect",	"1",	"Determine if disconnect messages should be enabled.");
	
	//Flags
	manager_flag_owner		=	CreateConVar("sm_connect_manager_flag_owner",		"z",	"Owner flag for Connect Disconnect Manager");
	manager_flag_admin		=	CreateConVar("sm_connect_manager_flag_admin",		"b",	"Admin flag for Connect Disconnect Manager");
	manager_flag_moderator	=	CreateConVar("sm_connect_manager_flag_moderator",	"o",	"Moderator flag for Connect Disconnect Manager");
	manager_flag_vip		=	CreateConVar("sm_connect_manager_flag_vip",			"a",	"Vip flag for Connect Disconnect Manager");
	
	manager_flag_owner.GetString(flag_owner,			sizeof(flag_owner));
	manager_flag_admin.GetString(flag_admin,			sizeof(flag_admin));
	manager_flag_moderator.GetString(flag_moderator,	sizeof(flag_moderator));
	manager_flag_vip.GetString(flag_vip,				sizeof(flag_vip));
}

Action	Event_PlayerConnect(Event event,	const char[] name,	bool dontBroadcast)	{
	SetEventBroadcast(event,	true);
}

public	void	OnClientAuthorized(int client)	{
	if(manager_connect.IntValue == 1 && IsValidClient(client))	{
		char	auth[64],
				ip[16],
				country[256],
				adminflag[128];
		GetClientAuthId(client,	AuthId_Steam2,	auth,	sizeof(auth));
		GetClientIP(client,	ip,	sizeof(ip));
		if(!GeoipCountry(ip,	country,	sizeof(country)))
			FormatEx(country,	sizeof(country),	"%t",	"manager_country_unknown");
		
		if(IsClientOwner(client))
			FormatEx(adminflag,	sizeof(adminflag),	"%t",	"manager_name_owner");
		else if(IsClientAdmin(client))
			FormatEx(adminflag,	sizeof(adminflag),	"%t",	"manager_name_admin");
		else if(IsClientModerator(client))
			FormatEx(adminflag,	sizeof(adminflag),	"%t",	"manager_name_moderator");
		else if(IsClientVip(client))
			FormatEx(adminflag,	sizeof(adminflag),	"%t",	"manager_name_vip");
		else if(IsFakeClient(client))
			FormatEx(adminflag,	sizeof(adminflag),	"%t",	"manager_name_bot");
		else
			FormatEx(adminflag,	sizeof(adminflag),	"%t",	"manager_name_default");
		
		switch(IsFakeClient(client))	{
			case	true:	CPrintToChatAll("%t",	"manager_connect_bot",	adminflag,	client);
			case	false:	CPrintToChatAll("%t",	"manager_connect",		adminflag,	client,	auth,	country);
		}
	}
}

public	void	OnClientPostAdminCheck(int client)	{
	if(manager_connect.IntValue == 2 && IsValidClient(client))	{
		char	auth[64],
				ip[16],
				country[256],
				adminflag[128];
		GetClientAuthId(client,	AuthId_Steam2,	auth,	sizeof(auth));
		GetClientIP(client,	ip,	sizeof(ip));
		if(!GeoipCountry(ip,	country,	sizeof(country)))
			FormatEx(country,	sizeof(country),	"%t",	"manager_country_unknown");
		
		if(IsClientOwner(client))
			FormatEx(adminflag,	sizeof(adminflag),	"%t",	"manager_name_owner");
		else if(IsClientAdmin(client))
			FormatEx(adminflag,	sizeof(adminflag),	"%t",	"manager_name_admin");
		else if(IsClientModerator(client))
			FormatEx(adminflag,	sizeof(adminflag),	"%t",	"manager_name_moderator");
		else if(IsClientVip(client))
			FormatEx(adminflag,	sizeof(adminflag),	"%t",	"manager_name_vip");
		else if(IsFakeClient(client))
			FormatEx(adminflag,	sizeof(adminflag),	"%t",	"manager_name_bot");
		else
			FormatEx(adminflag,	sizeof(adminflag),	"%t",	"manager_name_default");
			
		switch(IsFakeClient(client))	{
			case	true:	CPrintToChatAll("%t",	"manager_connect_bot",	adminflag,	client);
			case	false:	CPrintToChatAll("%t",	"manager_connect",		adminflag,	client,	auth,	country);
		}
	}
}

Action	Event_PlayerDisconnect(Event event,	const char[] name,	bool dontBroadcast)	{
	int	client	=	GetClientOfUserId(event.GetInt("userid"));
	if(manager_disconnect.BoolValue && IsValidClient(client))	{
		char	reason[256],
				auth[64],
				ip[16],
				country[256],
				adminflag[128],
				teamcolor[96];
		event.GetString("reason",	reason,	sizeof(reason));
		GetClientAuthId(client,	AuthId_Steam2,	auth,	sizeof(auth));
		GetClientIP(client,	ip,	sizeof(ip));
		if(!GeoipCountry(ip,	country,	sizeof(country)))
			FormatEx(country,	sizeof(country),	"%t",	"manager_country_unknown");
			
		if(StrContains(reason,	"Disconnect by user.",	false)	!=	-1)
			FormatEx(reason,	sizeof(reason),	"%t",	"manager_reason_disconnect");
		else if(StrContains(reason,	"Connect Closing",	false)	!=	-1)
			FormatEx(reason,	sizeof(reason),	"%t",	"manager_reason_connection_closing");
		else if(StrContains(reason,	"timed out",		false)	!=	-1)
			FormatEx(reason,	sizeof(reason),	"%t",	"manager_reason_timed_out");
		else if(StrContains(reason,	"kicked",			false)	!=	-1)
			FormatEx(reason,	sizeof(reason),	"%t",	"manager_reason_kicked");
		else if(StrContains(reason,	"Steam auth ticket has been canceled",	false)	!=	-1)
			FormatEx(reason,	sizeof(reason),	"%t",	"manager_reason_steam_auth_ticket_canceled");
		else if(StrContains(reason,	"#GameUI_Disconnect_TooManyCommands",	false)	!=	-1)
			FormatEx(reason,	sizeof(reason),	"%t",	"manager_too_many_commands");
			
		switch(GetEngineVersion())	{
			case	Engine_TF2:			teamcolor	=	TF2_GetTeamColor[GetClientTeam(client)];
			case	Engine_CSS:			teamcolor	=	CSS_GetTeamColor[GetClientTeam(client)];
			case	Engine_CSGO:		teamcolor	=	CSGO_GetTeamColor[GetClientTeam(client)];
			//case	Engine_Left4Dead2:	teamcolor	=	L4D2_GetTeamColor[client]; planned soon
		}
		
		if(IsClientOwner(client))
			FormatEx(adminflag,	sizeof(adminflag),	"%t",	"manager_name_owner");
		else if(IsClientAdmin(client))
			FormatEx(adminflag,	sizeof(adminflag),	"%t",	"manager_name_admin");
		else if(IsClientModerator(client))
			FormatEx(adminflag,	sizeof(adminflag),	"%t",	"manager_name_moderator");
		else if(IsClientVip(client))
			FormatEx(adminflag,	sizeof(adminflag),	"%t",	"manager_name_vip");
		else if(IsFakeClient(client))
			FormatEx(adminflag,	sizeof(adminflag),	"%t",	"manager_name_bot");
		else
			FormatEx(adminflag,	sizeof(adminflag),	"%t",	"manager_name_default");
		
		switch(IsFakeClient(client))	{
			case	true:	CPrintToChatAll("%t",	"manager_disconnect_bot",	adminflag,	teamcolor,	client);
			case	false:	CPrintToChatAll("%t",	"manager_disconnect",		adminflag,	teamcolor,	client,	auth,	country,	reason);
		}
	}
}

bool	IsValidClient(int client)	{
	if(client != 0)
		return	true;
	return	false;
}

bool	IsClientOwner(int client)	{
	if(CheckCommandAccess(client,	"manager_flag_owner",	ReadFlagString(flag_owner),	false))
		return	true;
	return	false;
}

bool	IsClientAdmin(int client)	{
	if(CheckCommandAccess(client,	"manager_flag_admin",	ReadFlagString(flag_admin),	false))
		return	true;
	return	false;
}

bool	IsClientModerator(int client)	{
	if(CheckCommandAccess(client,	"manager_flag_moderator",	ReadFlagString(flag_moderator),	false))
		return	true;
	return	false;
}

bool	IsClientVip(int client)	{
	if(CheckCommandAccess(client,	"manager_flag_vip",	ReadFlagString(flag_vip),	false))
		return	true;
	return	false;
}