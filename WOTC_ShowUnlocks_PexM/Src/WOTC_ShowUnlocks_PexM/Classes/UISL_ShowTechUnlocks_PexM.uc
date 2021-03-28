//*******************************************************************************************
//  FILE:   Show Unlocks PexM by RustyDios (from code by TeslaRage && Oni)                               
//  
//	File CREATED	06/01/21    08:00
//	LAST UPDATED    26/01/21	04:14
//
//	ADDS A NEW PANEL TO THE PEXM PROJECTS SCREEN THAT SHOWS ALL THE UNLOCK REWARDS
//
// HIDDEN CONFIG OPTIONS
// ;Show my UI in proving grounds and research, does not support PGOv2 (Tesla's does)
// bShowInPG = true     bShowInRS = true
//
//*******************************************************************************************
class UISL_ShowTechUnlocks_PexM extends UIScreenListener config(Game);

//custom struct used for this 
struct UnlockedItems_PexM
{
	var name ItemType;
	var string Unlock;
    var bool isPartial;
    var bool isRewardDeck;
    var bool bHide;
};

//Grab local strings
var localized string Title, m_strPartial, m_strPossible, m_strObfuscate, m_strEmptyUnlocks;

//grab config values
var config bool bEnableLog, bObfuscateIfNotFound, bShowInPG, bShowInRS;
var config int UI_FONT_SIZE;
var config int PANEL_ANCHOR_X_PX, PANEL_ANCHOR_Y_PX, PANEL_WIDTH_PX, PANEL_HEIGHT_PX;     // 1300, 200, 380, 640
var config int PANEL_ANCHOR_X_PG, PANEL_ANCHOR_Y_PG, PANEL_WIDTH_PG, PANEL_HEIGHT_PG;     // 1300, 200, 380, 640
var config int PANEL_ANCHOR_X_RS, PANEL_ANCHOR_Y_RS, PANEL_WIDTH_RS, PANEL_HEIGHT_RS;     // 1250, 475, 450, 330
var config array<name> arrTechToObfuscate, arrTechToHide, arrItemToObfuscate;

//var config array<UnlockedItems_PexM> arrOverride;     //this would be used to add config editable overrides, somehow... 

//panels and things used just for this UI
var UIBGBox RewardBG;
var UIPanel Reward;
var UIX2PanelHeader TitleHeader;
var UITextContainer Description;
var UISimpleCommodityScreen CurrentScreen;  //technically as UIChoose-x- is a child of so we can cast to this

//easy strings for the icons
var string ItemIcon, FacilityIcon, FacilityUpgradeIcon, ResearchIcon, ProvingGroundIcon, ShadowIcon, PsiIcon, ErrorIcon;

///////////////////////////////////////////////////////////////////////////////
//  SCREEN MANIPULATION
///////////////////////////////////////////////////////////////////////////////

//  Check we have the right screen on init
event OnInit(UIScreen Screen)
{
	CurrentScreen = UISimpleCommodityScreen(`SCREENSTACK.GetCurrentScreen());

    if (CurrentScreen != none)
    {
		switch( CurrentScreen.Class.Name )
        {
            case 'UIChoosePexMProject':			        //===== PSIONICS EX MACHINA BUILD MENU =====//
                `LOG("Screen was one we wanted on init :: " @CurrentScreen.Class.Name ,default.bEnableLog,'RustyShowTech_PexM');
                AddPanel(default.PANEL_ANCHOR_X_PX, default.PANEL_ANCHOR_Y_PX, default.PANEL_WIDTH_PX, default.PANEL_HEIGHT_PX);
                UpdateRewardText();
                break;
            case 'UIChooseProject':			        //===== PROVING GROUND BUILD MENU =====//
                if (default.bShowInPG)
                {
                    `LOG("Screen was one we wanted on init :: " @CurrentScreen.Class.Name ,default.bEnableLog,'RustyShowTech_PexM');
                    AddPanel(default.PANEL_ANCHOR_X_PG, default.PANEL_ANCHOR_Y_PG, default.PANEL_WIDTH_PG, default.PANEL_HEIGHT_PG);
                    UpdateRewardText();
                }
                break;
            case 'UIChooseResearch':				    //===== RESEARCH 'BUILD' MENU =====//
                if (default.bShowInRS)
                {
                    `LOG("Screen was one we wanted on init :: " @CurrentScreen.Class.Name ,default.bEnableLog,'RustyShowTech_PexM');
                    AddPanel(default.PANEL_ANCHOR_X_RS, default.PANEL_ANCHOR_Y_RS, default.PANEL_WIDTH_RS, default.PANEL_HEIGHT_RS, true);
                    UpdateRewardText();
                }
                break;
            default:
                //DO NOTHING FOR SCREENS WE DON'T WANT TO CHANGE
                break;
        }
    }
}

// clear the extra boxes on loose focus or when screen is closed
event OnLoseFocus(UIScreen Screen)
{
    switch(Screen.Class.Name)
    {
        case 'UIChoosePexMProject':			        //===== PSIONICS EX MACHINA BUILD MENU =====//
            Clear();
            break;
        case 'UIChooseProject':				        //===== PROVING GROUND BUILD MENU =====//
            if (default.bShowInPG)
            {
                Clear();
            }
            break;
        case 'UIChooseResearch':				    //===== RESEARCH 'BUILD' MENU =====//
            if (default.bShowInRS)
            {
                Clear();
            }
            break;
        default:
            //DO NOTHING FOR SCREENS WE DON'T WANT TO CHANGE
            break;
    }
}

event OnRemoved(UIScreen Screen)
{
    switch(Screen.Class.Name)
    {
        case 'UIChoosePexMProject':			        //===== PSIONICS EX MACHINA BUILD MENU =====//
            Clear();
            break;
        case 'UIChooseProject':				        //===== PROVING GROUND BUILD MENU =====//
            if (default.bShowInPG)
            {
                Clear();
            }
            break;
        case 'UIChooseResearch':				    //===== RESEARCH 'BUILD' MENU =====//
            if (default.bShowInRS)
            {
                Clear();
            }
            break;
        default:
            //DO NOTHING FOR SCREENS WE DON'T WANT TO CHANGE
            break;
    }
}

simulated function Clear()
{
    if (RewardBG != none)   { RewardBG.Remove();        `LOG("RewardBG Cleared",default.bEnableLog,'RustyShowTech_PexM');   }
    if (Reward != none)     { Reward.Remove();          `LOG("Reward   Cleared",default.bEnableLog,'RustyShowTech_PexM');   }   
}

// set to refresh text on item selection changed
simulated function OnItemSelectedCallback(UIList ContainerList, int ItemIndex)
{
    CurrentScreen.SelectedItemChanged(ContainerList, ItemIndex);

    switch( CurrentScreen.Class.Name )
    {
        case 'UIChoosePexMProject':			        //===== PSIONICS EX MACHINA BUILD MENU =====//
            `LOG("Screen was one we wanted on change item :: " @CurrentScreen.Class.Name,default.bEnableLog,'RustyShowTech_PexM');
            UpdateRewardText();
            break;
        case 'UIChooseProject':			        //===== PROVING GROUND BUILD MENU =====//
            if (default.bShowInPG)
            {
                `LOG("Screen was one we wanted on change item :: " @CurrentScreen.Class.Name ,default.bEnableLog,'RustyShowTech_PexM');
                UpdateRewardText();
            }
            break;
        case 'UIChooseResearch':				//===== RESEARCH 'BUILD' MENU =====//
            if (default.bShowInRS)
            {
                `LOG("Screen was one we wanted on change item :: " @CurrentScreen.Class.Name ,default.bEnableLog,'RustyShowTech_PexM');
                UpdateRewardText();
            }
            break;
        default:
            //DO NOTHING FOR SCREENS WE DON'T WANT TO CHANGE
            break;
    }
}

///////////////////////////////////////////////////////////////////////////////
//  NEW PANELS
///////////////////////////////////////////////////////////////////////////////

//here we init the BG boxes
simulated function AddPanel(int X, int Y, int W, int H, optional bool bGrandparent = false)
{
    local UIScreen AttachToScreen;

    //setup the new panel and common icons as strings, inject image, (image path, width, hieght, vertical offset)
    ItemIcon =              class'UIUtilities_Text'.static.InjectImage("img:///UILibrary_XPACK_StrategyImages.MissionIcon_SupplyDrop",  20, 20, -5); //the only one NOT referrenced in UIUtilities_Image
    ResearchIcon =          class'UIUtilities_Text'.static.InjectImage(class'UIUtilities_Image'.const.AlertIcon_Science,                20, 20, -5); //techs
    ProvingGroundIcon =     class'UIUtilities_Text'.static.InjectImage(class'UIUtilities_Image'.const.AlertIcon_Construction,           20, 20, -5);
    ShadowIcon =            class'UIUtilities_Text'.static.InjectImage(class'UIUtilities_Image'.const.HTML_AttentionIcon,               20, 20, -5);
    FacilityIcon =          class'UIUtilities_Text'.static.InjectImage(class'UIUtilities_Image'.const.AlertIcon_Engineering,            20, 20, -5);
    FacilityUpgradeIcon =   class'UIUtilities_Text'.static.InjectImage(class'UIUtilities_Image'.const.FacilityStatus_Power,             20, 20, -5);
    PsiIcon =               class'UIUtilities_Text'.static.InjectImage(class'UIUtilities_Image'.const.EventQueue_Psi,                   20, 20, -5);
    ErrorIcon =             class'UIUtilities_Text'.static.InjectImage(class'UIUtilities_Image'.const.EventQueue_Alien,                 20, 20, -5); //used for quick identifiction of errors

    //adjust the list selection change to refresh the panel
    if (`ISCONTROLLERACTIVE)
    {
        CurrentScreen.List.OnItemClicked = OnItemSelectedCallback;
        //CurrentScreen.List.OnSelectionChanged = OnItemSelectedCallback; < does this fix controller issues ?
    }
    else
    {
        CurrentScreen.List.OnSelectionChanged = OnItemSelectedCallback;
    }

    //research screen needs to actually go on the powercore to be in front of tygan, ugh... 
    if (bGrandparent)
    {
        AttachToScreen = `SCREENSTACK.GetScreen(class'UIFacility_Powercore');
    }
    else
    {
        AttachToScreen = CurrentScreen;
    }

    //setup the background panel
    RewardBG = CurrentScreen.Spawn(class'UIBGBox', AttachToScreen);
    RewardBG.LibID = class'UIUtilities_Controls'.const.MC_X2Background;
    RewardBG.InitBG('ShowResearchUnlocks_Reward_BG', X, Y, W, H); // pos x, pos y , width, height

    //setup the text panel to the same size and position
    Reward = CurrentScreen.Spawn(class'UIPanel', AttachToScreen);
    Reward.InitPanel('ShowResearchUnlocks_Reward');
    Reward.SetSize(RewardBG.Width, RewardBG.Height);
    Reward.SetPosition(RewardBG.X, RewardBG.Y);

    //setup the text panel title
    TitleHeader = CurrentScreen.Spawn(class'UIX2PanelHeader', Reward);
    TitleHeader.InitPanelHeader('', class'UIUtilities_Text'.static.GetColoredText(Title, eUIState_Cash, 32), "");
    TitleHeader.SetPosition(TitleHeader.X + 10, TitleHeader.Y + 10);
    TitleHeader.SetHeaderWidth(Reward.Width - 20);

    //setup the main body description text, size and position
    Description = CurrentScreen.Spawn(class'UITextContainer', Reward);
    Description.InitTextContainer();            
    Description.bAutoScroll = true;
    Description.SetSize(RewardBG.Width - 20, RewardBG.Height - 55);
    Description.SetPosition(Description.X + 10, Description.Y + 50);

    Description.Text.SetHeight(Description.Text.Height * 3.0f);                   

    `LOG("===== PANEL ADDED =====",default.bEnableLog,'RustyShowTech_PexM');
}

///////////////////////////////////////////////////////////////////////////////
//  UPDATING TEXT
///////////////////////////////////////////////////////////////////////////////

//update and change the text based on current selected item
simulated function UpdateRewardText()
{
  	local XComGameState_Tech TechState;
    local X2TechTemplate TechTemplate;
    local array<UnlockedItems_PexM> UnlockedItems;
	local string Unlocks;
    local int i;

    if ( CurrentScreen.List.GetSelectedItem() != none )
    {
        //get the selected item index
        i = CurrentScreen.List.GetItemIndex(CurrentScreen.List.GetSelectedItem());
        TechState = XComGameState_Tech(`XCOMHISTORY.GetGameStateForObjectID(CurrentScreen.m_arrRefs[i].ObjectID));
        TechTemplate = TechState.GetMyTemplate();

        //work out what it unlocks
        CustomGetUnlocks(TechTemplate, UnlockedItems);

        //create the message array string  
        MessageArray(Unlocks, UnlockedItems);

        //change the description in the reward list        
        Description.SetText(class'UIUtilities_Text'.static.AddFontInfo(Unlocks, false, false, false, default.UI_FONT_SIZE) );
    }

    `LOG("===== TEXT UPDATE DONE =====",default.bEnableLog,'RustyShowTech_PexM');

}

///////////////////////////////////////////////////////////////////////////////
//  INFORMATION GATHERING
///////////////////////////////////////////////////////////////////////////////

// work out what the selected item unlocks
static function CustomGetUnlocks(X2TechTemplate TemplateToUpdate, out array<UnlockedItems_PexM> UnlockedItems)
{
    local X2ItemTemplateManager             ItemTemplateManager;
    local X2StrategyElementTemplateManager  TemplateManager;

    local X2DataTemplate                    DataTemplate;
    local X2ItemTemplate                    ItemTemplate, Tier2Template, Tier3Template;	
    local X2TechTemplate                    TechTemplate;
    local X2FacilityTemplate                FacilityTemplate;
    local X2FacilityUpgradeTemplate         FacilityUpgTemplate;     
    local X2SchematicTemplate               SchematicTemplate;    

	local array<name> TemplateNames;
    local name TemplateName;
    local int i;

    local UnlockedItems_PexM UnlockedItem;
    
    ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
    TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	TemplateManager.GetTemplateNames(TemplateNames);       

    //if its on the config list of tech rewards to hide results ... none by default for pexm ... 
    if ( default.arrTechToObfuscate.find(TemplateToUpdate.DataName) != INDEX_NONE )
    {
        UnlockedItem.bHide = true;
    }
    else
    {
        UnlockedItem.bHide = false;
    }

    `LOG("===== BEGIN CONSTRUCTING UNLOCKS LIST =====",default.bEnableLog,'RustyShowTech_PexM_List');

    //for techs, research, proving ground, facility schematics
    foreach TemplateNames(TemplateName)
	{
        //Research Techs and Proving Grounds are covered here
        TechTemplate = X2TechTemplate(TemplateManager.FindStrategyElementTemplate(TemplateName));
        if ( TechTemplate != None )             
        {   
            if (TechTemplate.Requirements.RequiredTechs.find(TemplateToUpdate.DataName) != INDEX_NONE)
            {
                // skip over breakthroughs and remove techs that have already been completed or techs to hide
                if (TechTemplate.bBreakthrough || `XCOMHQ.IsTechResearched(TechTemplate.DataName) || default.arrTechToHide.find(TechTemplate.DataName) != INDEX_NONE)
                {
                    continue; //move on to the next item
                }
                else
                {
                    if ( TechTemplate.bProvingGround )      {   UnlockedItem.ItemType = 'PG';       }
                    else if (TechTemplate.bShadowProject)   {   UnlockedItem.ItemType = 'Shadow';   }
                    else                                    {   UnlockedItem.ItemType = 'Tech';     }

                    UnlockedItem.Unlock = TechTemplate.DisplayName;
                    UnlockedItem.isRewardDeck = false;                        

                    //found out if the item requires more stuff than this tech
                    UnlockedItem.isPartial = IsPartialUnlock(TemplateToUpdate.DataName, TechTemplate.Requirements.RequiredTechs);

                    //add it to the OUT array
                    UnlockedItems.AddItem(UnlockedItem);
                    `LOG(" TECH ADDED TO UNLOCK ARRAY :: NAME ::" @UnlockedItem.Unlock @":: TYPE ::" @UnlockedItem.ItemType @":: REWARD DECK ::" @UnlockedItem.isRewardDeck 
                            @":: PARTIAL ::" @UnlockedItem.isPartial @":: HIDDEN ::" @UnlockedItem.bHide @":: TEMPLATE ::" @TechTemplate.DataName, default.bEnableLog,'WOTC_ShowTechRewards');

                    continue; //move on to the next item
                }
            }
        }//end tech != none

        // it wasn't a 'tech' (research/shadow/PG/breakthrough) ... not already done ... so must be a facility
        //check for a facility
        FacilityTemplate = X2FacilityTemplate(TemplateManager.FindStrategyElementTemplate(TemplateName));
        if ( FacilityTemplate != none )
        {
            if(FacilityTemplate.Requirements.RequiredTechs.Find(TemplateToUpdate.DataName) != INDEX_NONE )
            {
                UnlockedItem.ItemType = 'Facility';
                UnlockedItem.Unlock = FacilityTemplate.DisplayName;
                UnlockedItem.isRewardDeck = false;                    

                //found out if the item requires more stuff than this tech
                UnlockedItem.isPartial = IsPartialUnlock(TemplateToUpdate.DataName, FacilityTemplate.Requirements.RequiredTechs);
                
                //add it to the OUT array
                UnlockedItems.AddItem(UnlockedItem);
                `LOG(" FACT ADDED TO UNLOCK ARRAY :: NAME ::" @UnlockedItem.Unlock @":: TYPE ::" @UnlockedItem.ItemType @":: REWARD DECK ::" @UnlockedItem.isRewardDeck 
                        @":: PARTIAL ::" @UnlockedItem.isPartial @":: HIDDEN ::" @UnlockedItem.bHide @":: TEMPLATE ::" @FacilityTemplate.DataName, default.bEnableLog,'RustyShowTech_PexM');

                continue; //move on to the next item
            }
        }//end facility !=none

        //wasn't a facility, must be a facility upgrade
        FacilityUpgTemplate = X2FacilityUpgradeTemplate(TemplateManager.FindStrategyElementTemplate(TemplateName));
        if ( FacilityUpgTemplate != none )
        {
            if(FacilityUpgTemplate.Requirements.RequiredTechs.Find(TemplateToUpdate.DataName) != INDEX_NONE )
            {
                UnlockedItem.ItemType = 'FacilityUpgrade';
                UnlockedItem.Unlock = FacilityUpgTemplate.DisplayName;
                UnlockedItem.isRewardDeck = false;                        

                //found out if the item requires more stuff than this tech
                UnlockedItem.isPartial = IsPartialUnlock(TemplateToUpdate.DataName, FacilityUpgTemplate.Requirements.RequiredTechs);
                
                //add it to the OUT array
                UnlockedItems.AddItem(UnlockedItem);
                `LOG(" FACU ADDED TO UNLOCK ARRAY :: NAME ::" @UnlockedItem.Unlock @":: TYPE ::" @UnlockedItem.ItemType @":: REWARD DECK ::" @UnlockedItem.isRewardDeck 
                        @":: PARTIAL ::" @UnlockedItem.isPartial @":: HIDDEN ::" @UnlockedItem.bHide @":: TEMPLATE ::" @FacilityUpgTemplate.DataName, default.bEnableLog,'RustyShowTech_PexM');

                continue; //move on to the next item
            }
        }//end fac upgrade !=none
    }//end strategy templates check

    `LOG("===== SWITCH CONSTRUCTING UNLOCKS LIST =====",default.bEnableLog,'RustyShowTech_PexM_List');

    // For items and schematics
    foreach ItemTemplateManager.IterateTemplates(DataTemplate, none)
    {
        ItemTemplate = X2ItemTemplate(DataTemplate);

        if (ItemTemplate != none)
        {
            UnlockedItem.ItemType = 'Item';
            
            /////////////////////////////  PEXM UNIQUE CODE FOR ITEM OBFUSCATION /////////////////////////////////////////////////
            if (InStr (ItemTemplate.DataName, "GEM_") != -1 || InStr (ItemTemplate.DataName, "PCSPsi_") != -1 )     // It's PexM so obfuscate
            {
                UnlockedItem.ItemType = 'Psi';

                UnlockedItem.bHide = IsObfuscationModeOn(ItemTemplate);
            }
            else if ( default.arrItemToObfuscate.Find(ItemTemplate.DataName) != -1)                                 // It's on the hidden list
            {
                UnlockedItem.bHide = IsObfuscationModeOn(ItemTemplate);
            }
            else
            {
                UnlockedItem.bHide = false;
            }
            /////////////////////////////  PEXM UNIQUE CODE FOR ITEM OBSFUSCATION /////////////////////////////////////////////////

            if (ItemTemplate.Requirements.RequiredTechs.Find(TemplateToUpdate.DataName) != INDEX_NONE
                || ItemTemplate.ArmoryDisplayRequirements.RequiredTechs.Find(TemplateToUpdate.DataName) != INDEX_NONE
                || ItemTemplate.CreatorTemplateName == TemplateToUpdate.DataName
               )
            {
                //for item schematic templates
                SchematicTemplate = X2SchematicTemplate(DataTemplate);
                if (SchematicTemplate != none)
                {   
                    // I think this block of code does't use ItemTemplate anymore, so let's use it
                    ItemTemplate = ItemTemplateManager.FindItemTemplate(SchematicTemplate.ReferenceItemTemplate);                                
                    
                    UnlockedItem.Unlock = SchematicTemplate.FriendlyName;
                    UnlockedItem.isRewardDeck = false;

                    //found out if the item requires more stuff than this tech
                    UnlockedItem.isPartial = IsPartialUnlock(TemplateToUpdate.DataName, ItemTemplate.Requirements.RequiredTechs);

					//this should stop any 'empty' schematics from being added ... thanks Iridar!
                    // This should do it - refer to PATemplateMods::KillItem from "Prototype Armoury Beta"
                    // if (SchematicTemplate.ItemsToUpgrade.Length != 0 && SchematicTemplate.ItemRewards.Length != 0) // This one skipped COTK2.0 schematics
                    if (SchematicTemplate.CanBeBuilt != false && SchematicTemplate.PointsToComplete < 999999)
                    {
                        //add it to the OUT array
                        UnlockedItems.AddItem(UnlockedItem);
                        `LOG(" SCHM ADDED TO UNLOCK ARRAY :: NAME ::" @UnlockedItem.Unlock @":: TYPE ::" @UnlockedItem.ItemType @":: REWARD DECK ::" @UnlockedItem.isRewardDeck 
                            @":: PARTIAL ::" @UnlockedItem.isPartial @":: HIDDEN ::" @UnlockedItem.bHide @":: TEMPLATE ::" @ItemTemplate.DataName, default.bEnableLog,'WOTC_ShowTechRewards');
                    
                        continue; //move on to the next item in the list
                    }
                }
                //normal item directly unlocked
                else
                {
                    UnlockedItem.Unlock = ItemTemplate.GetItemFriendlyNameNoStats();
                    UnlockedItem.isRewardDeck = false;

                    //found out if the item requires more stuff than this tech
                    UnlockedItem.isPartial = IsPartialUnlock(TemplateToUpdate.DataName, ItemTemplate.Requirements.RequiredTechs);

                    //add it to the OUT array
                    UnlockedItems.AddItem(UnlockedItem);
                    `LOG(" ITEM ADDED TO UNLOCK ARRAY :: NAME ::" @UnlockedItem.Unlock @":: TYPE ::" @UnlockedItem.ItemType @":: REWARD DECK ::" @UnlockedItem.isRewardDeck 
                            @":: PARTIAL ::" @UnlockedItem.isPartial @":: HIDDEN ::" @UnlockedItem.bHide @":: TEMPLATE ::" @ItemTemplate.DataName, default.bEnableLog,'RustyShowTech_PexM');

                    continue; //move on to the next item in the list
                }            
            }
            //item is part of a reward deck
            else if (ItemTemplate.RewardDecks.Find(TemplateToUpdate.RewardDeck) != INDEX_NONE )
            {
                //original mod code here for PGOv2 Unlocks ... commented out as I don't plan to support/build against PGOv2 for PexM's UISL but here in case anyone wants continuity
                /*
                    //if ( class'UIScreenListener_ShowTechUnlocks'.default.bPGOInstalled && default.bEnablePGOIntegration )
                    if (IsModLoaded('WOTC_PGOverhaul') && default.bEnablePGOIntegration )
                    {                
                        j = class'WOTC_PGOverhaul.X2Helpers_PGOverhaulExperimentalItems'.default.arrUnlockExperimentalItem.Find('ItemName', ItemTemplate.DataName);  

                        if ( j != INDEX_NONE )
                        {                   
                            if ( XComHQ.IsTechResearched(class'WOTC_PGOverhaul.X2Helpers_PGOverhaulExperimentalItems'.default.arrUnlockExperimentalItem[j].TechName) )
                            {
                                continue;
                            }
                        }
                    }
                */

                // Check if the item list should be shown as the upgraded version of the items
                // Example: Experimental Grenade projects that should show Acid Bomb instead of Acid Grenade if AdvancedGrenade Tech has been researched
                Tier2Template = ItemTemplateManager.GetUpgradedItemTemplateFromBase(ItemTemplate.DataName);            
                Tier3Template = ItemTemplateManager.GetUpgradedItemTemplateFromBase(Tier2Template.DataName);

                if (Tier2Template != none && `XCOMHQ.IsTechResearched(Tier2Template.CreatorTemplateName))
                {
                    ItemTemplate = Tier2Template;   //eg showing Acid Bomb instead of Grenade if Advanced Explosives is done
                }

                if (Tier3Template != none && `XCOMHQ.IsTechResearched(Tier3Template.CreatorTemplateName)) // && IsModLoaded('WOTC_SuperiorExplosives')
                {
                    ItemTemplate = Tier3Template;   //eg showing Acid Warhead instead of Bomb/Grenade if Superior Explosives is done
                }

                UnlockedItem.Unlock = ItemTemplate.GetItemFriendlyNameNoStats();
                UnlockedItem.isRewardDeck = true; // Will always show as a possible item reward, finally

                UnlockedItem.isPartial = false; // For experimental items, we pretend that it will never be partial and we will always get one of the items
            
                //add it to the OUT array
                UnlockedItems.AddItem(UnlockedItem);
                `LOG(" DECK ADDED TO UNLOCK ARRAY :: NAME ::" @UnlockedItem.Unlock @":: TYPE ::" @UnlockedItem.ItemType @":: REWARD DECK ::" @UnlockedItem.isRewardDeck 
                        @":: PARTIAL ::" @UnlockedItem.isPartial @":: HIDDEN ::" @UnlockedItem.bHide @":: TEMPLATE ::" @ItemTemplate.DataName, default.bEnableLog,'RustyShowTech_PexM');

                continue; //move on to the next item in the list
            }
        } //end item template !=none
    } // end item templates check

    // Tech Templates that give items directly e.g. IcarusArmor tech template gives MediumAlienArmor
    if (TemplateToUpdate.ItemRewards.Length > 0)
    {
        for ( i = 0; i < TemplateToUpdate.ItemRewards.Length; i++)
        {
            ItemTemplate = ItemTemplateManager.FindItemTemplate(TemplateToUpdate.ItemRewards[i]);

            if (ItemTemplate != none)
            {
                //check its not already on the list
                if (UnlockedItems.Find('Unlock', ItemTemplate.GetItemFriendlyNameNoStats()) == INDEX_NONE)
                {
                    UnlockedItem.ItemType = 'Item';
                    UnlockedItem.isRewardDeck = false;  //a bit of special case, this one should always be false
                    UnlockedItem.isPartial = false;     //a bit of special case, this one should always be false

                    // Need to cater for scenario where the tech gives schematic instead of item
                    SchematicTemplate = X2SchematicTemplate(ItemTemplate);
                    if (SchematicTemplate != none) //example: Bolt Caster Tech gives Bolt Caster Schematic
                    {
                        UnlockedItem.Unlock = SchematicTemplate.FriendlyName;
                    }
                    else //example: IcarusArmor tech template gives MediumAlienArmor
                    {
                        UnlockedItem.Unlock = ItemTemplate.GetItemFriendlyNameNoStats();
                    }
    
                    //add it to the OUT array as it's not part of it already
                    UnlockedItems.AddItem(UnlockedItem);
                    `LOG(" LOOT ADDED TO UNLOCK ARRAY :: NAME ::" @UnlockedItem.Unlock @":: TYPE ::" @UnlockedItem.ItemType @":: REWARD DECK ::" @UnlockedItem.isRewardDeck 
                            @":: PARTIAL ::" @UnlockedItem.isPartial @":: HIDDEN ::" @UnlockedItem.bHide @":: TEMPLATE ::" @ItemTemplate.DataName, default.bEnableLog,'RustyShowTech_PexM');
                    continue; //move on to the next item
                }
            } //end != none
        } //end for loop
    }//end direct item check

    //THIS would be where MORE SPECIAL LOGIC goes for the case-by-case basis, not required for my PexM listener though
    //Maybe a new config struct for (i ; i < default.arrOverride ; i++)
    //  { // check and do stuff }
    //  add to the OUT array
    //  log

    `LOG("===== FINISH CONSTRUCTING UNLOCKS LIST =====",default.bEnableLog,'RustyShowTech_PexM_List');
}

//find out if this item requires more than the current tech
static function bool IsPartialUnlock(name ExcludedTech, array<name> RequiredTechs)
{
    local X2StrategyElementTemplateManager StratMgr;
	local X2TechTemplate TechTemplate;
	local int i;
	
	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	for(i = 0; i < RequiredTechs.Length; i++)
	{
		TechTemplate = X2TechTemplate(StratMgr.FindStrategyElementTemplate(RequiredTechs[i]));

		if(TechTemplate != none && TechTemplate.DataName != ExcludedTech )
		{
			if(!`XCOMHQ.TechTemplateIsResearched(TechTemplate))
			{
                //xcom still needs more techs to unlock this
                return true;
			}
		}
	}
    //xcom does not need more techs to unlock this
	return false;
}

//find out if this item is obfuscated
static function bool IsObfuscationModeOn(X2ItemTemplate ItemTemplate)
{
    local bool bToHideOrNotToHide;

    if ( default.bObfuscateIfNotFound )
    {
        //try to find if xcom has ever had or has the item in question
        //by type, unlocked, current inventory, by state/quantity recorded at least once (even if current is 0)
        if  (   `XCOMHQ.EverAcquiredInventoryTypes.Find(ItemTemplate.DataName) != INDEX_NONE
            ||  `XCOMHQ.UnlockedItems.Find(ItemTemplate.DataName) != INDEX_NONE
            ||  `XCOMHQ.HasItem(ItemTemplate)
            ||  `XCOMHQ.GetNumItemInInventory(ItemTemplate.DataName) > 0
            ||  `XCOMHQ.GetItemByName(ItemTemplate.DataName) != none
            )
        {
            bToHideOrNotToHide = false;     //xcom has found this at least once
        }
        else
        {
            bToHideOrNotToHide = true;      //xcom has never had this
        }
    }
    else    
    {
        bToHideOrNotToHide = false;         //obfuscate not turned on
    }

  return bToHideOrNotToHide;
}

///////////////////////////////////////////////////////////////////////////////
//  STRING FORMATION FOR DISPLAY
///////////////////////////////////////////////////////////////////////////////

//construct the entire unlocks description string ... line by line ...
simulated function MessageArray(out string Unlocks, array<UnlockedItems_PexM> UnlockedItems)
{
    local int i; 

    if (UnlockedItems.Length <= 0 )
    {
        Unlocks $= ShadowIcon $": " $m_strEmptyUnlocks;
    }

    for( i = 0; i < UnlockedItems.Length; i++)
    {
        //add the correct Icon
        switch ( UnlockedItems[i].ItemType )
        {
            case 'Item':            Unlocks $= (ItemIcon $ ": ");               break;
            case 'Tech':            Unlocks $= (ResearchIcon $ ": ");           break;
            case 'PG':              Unlocks $= (ProvingGroundIcon $ ": ");      break;
            case 'Shadow':          Unlocks $= (ShadowIcon $ ": ");             break;
            case 'Facility':        Unlocks $= (FacilityIcon $ ": ");           break;
            case 'FacilityUpgrade': Unlocks $= (FacilityUpgradeIcon $ ": ");    break;
            case 'Psi':             Unlocks $= (PsiIcon $ ": ");                break;
            default:                Unlocks $= (ErrorIcon $ ": ");              break;
        }       

        //show or hide the unlock name ... pexm has some special handling for its items, see above
        if ( UnlockedItems[i].bHide )   { Unlocks $= m_strObfuscate;            }
        else                            { Unlocks $= UnlockedItems[i].Unlock;   }

        //append the partial tag if it needs more techs/stuff
        if ( UnlockedItems[i].isPartial )   { Unlocks $= " " $m_strPartial;     }

        //append the deck tag if it is part of a deck 
        if ( UnlockedItems[i].isRewardDeck ){ Unlocks $= " " $m_strPossible;    }

        //if we have more lines add a line break
        if(i < UnlockedItems.Length - 1)    { Unlocks $= "\n";                  }
    }
}

///////////////////////////////////////////////////////////////////////////////
//  MOD CHECK - NOT REQUIRED FOR PEXM UISL BUT KEPT FOR REFFERENCE
//  Note that the DLCName in this case is the base name of the .XComMod file
///////////////////////////////////////////////////////////////////////////////
/*
static function bool IsModLoaded(name DLCName)
{
    local XComOnlineEventMgr    EventManager;
    local int                   Index;

    EventManager = `ONLINEEVENTMGR;

    for(Index = EventManager.GetNumDLC() - 1; Index >= 0; Index--)  
    {
        if(EventManager.GetDLCNames(Index) == DLCName)  
        {
            return true;
        }
    }
    return false;
}
*/

//////////////////////////////////////////////////////////
//defaultproperties
//{	
//	ScreenClass = 'UIChoosePexMProject';
//}
