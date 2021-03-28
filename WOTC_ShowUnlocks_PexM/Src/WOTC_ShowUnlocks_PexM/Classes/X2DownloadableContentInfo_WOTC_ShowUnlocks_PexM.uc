//*******************************************************************************************
//  FILE:   XComDownloadableContentInfo_WOTC_ShowUnlocks_PexM.uc                                    
//  
//	File CREATED	06/01/21    08:00
//	LAST UPDATED    06/01/21    08:01
//
//	ADDS A NEW PANEL TO THE PEXM PROJECTS SCREEN THAT SHOWS ALL THE UNLOCK REWARDS
//
//*******************************************************************************************

class X2DownloadableContentInfo_WOTC_ShowUnlocks_PexM extends X2DownloadableContentInfo;

static event OnLoadedSavedGame(){}

static event InstallNewCampaign(XComGameState StartState){}
