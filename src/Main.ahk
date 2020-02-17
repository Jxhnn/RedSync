 
; Crée par John Thomas, Décembre 2019.

#Include Functions.ahk
#Include Class_ImageButton.ahk
#SingleInstance, force 						; forcer a l'application a avoir qu'une seule instance
SyncServer = %A_Desktop%\John\Sync\Dev\AHK\vServer ;RéPERTOIRE DU SERVEUR DE SYNCHRONISATION
ImageButton.SetGuiColor("0xF9F9F9")			; Définit la couleur du fond des boutons (F9F9F9)

StartUp:
{
	FileRead, TempReload, %A_ScriptDir%\temp 	; Lis le fichier temp dans le dossier de l'application
	FileDelete, %A_ScriptDir%\temp 				; Supprime le fichier temp dans le dossier de l'application
	Gui, Color, F9F9F9 							; Définit la couleur du fond de l'interface (F9F9F9)
	if(TempReload = "") {						; Si la variable TempReload est vide, alors..
		Gui, -0x40000 +ToolWindow +OwnDialogs	 			; Permet de défiit des options de style (Close Button)
		Gui, Show, h350 w600, TeregaSync		; Montrer l'interface avec une hauteur de 350px et une largeur de 600px
		Gui, Add, Text, vLoadText x265 w500 y130, Chargement .
		Random, AnimationLoadTime, 100, 1500	; Génére un nombre aléatoire entre 100 et 1500 et le définir sur la variable 'AnimationLoadTime'
		Sleep, % AnimationLoadTime				; Attendre le temps définit dans la variable 'AnimationLoadTime' (en millisecondes)
		Gui, Add, Progress, w200 h20 c1ABC9C x200 y150 vLoadingProgress, 0		; Ajoute Une Progress Bar sur l'interface
		Loop, 100								; Répéter l'action en accolade 100 fois
		{
			GuiControl,, LoadingProgress, +1	; Ajoute 1 a la progress bar 'LoadingProgress'
			GuiControlGet, LoadingProgressNumber,, LoadingProgress
			if(LoadingProgressNumber > 30 and LoadingProgressNumber < 60) {
				GuiControl,,LoadText, Chargement . .
			}
			if(LoadingProgressNumber > 60) {
					GuiControl,,LoadText, Chargement . . .
			}
			Random, TimeToLoadSleep, 1, 20		; Génére un nombre aléatoire entre 1 et 20 et le définir sur la variable 'TimeToLoadSleep'
			Sleep, % TimeToLoadSleep			; Attendre le temps définit dans la variable 'TimeToLoadSleep' (en millisecondes)
		}
		GuiControl, Hide, LoadingProgress 		; Cacher la progress bar
		GuiControl, Hide, LoadText
	}
	VerifyConfig:
	{
		if !FileExist("files.conf") {
			FileAppend,, %A_ScriptDir%\files.conf
			; MsgBox, 16,, Fichier de configuration non trouvé. Veillez vérifier si ce fichier est bien présent dans le même répertoire que le logiciel.
			; ExitApp
		}
	}
	{
		if !FileExist("dest.conf") {
			FileAppend,, %A_ScriptDir%\dest.conf
			; MsgBox, 16,, Fichier de configuration non trouvé. Veillez vérifier si ce fichier est bien présent dans le même répertoire que le logiciel.
			; ExitApp
		}
	}
	{
		if !FileExist("server.conf") {
			FileAppend,, %A_ScriptDir%\server.conf
			; MsgBox, 16,, Fichier de configuration non trouvé. Veillez vérifier si ce fichier est bien présent dans le même répertoire que le logiciel.
			; ExitApp
		}
	}
	FileReadLine, DownloadPathSelect, %A_ScriptDir%\server.conf, 2
	if(DownloadPathSelect = "" or DownloadPathSelect =) {
		DownloadPathSelect = C:\Local
	}
	Gui, Show, h350 w600, TeregaSync
	LogoPath = %A_ScriptDir%\logo.png
	if FileExist(LogoPath) {
		Gui, Add, Picture,h75 w150 x450 y290 , %A_ScriptDir%\logo.png
	}
	; Fin des options d'Interface, ajouts de composants
	Gui, Add, DropDownList, vSyncType gSyncType Choose2 x230 y10 w150, Automatique|Manuelle
	GuiControl, Hide, SyncType
	Gui, Add, Button, gManualSync vManualSync w150 hwndManualSync, Synchroniser les fichiers`nvers le serveur
	Gui, Add, Button, gDeleteSyncFile y75 x310 w70 hwndDeleteSyncFile, Supprimer
	Gui, Add, Button, gAddFile y75 x230 w69 hwndAddFile, Ajouter
	Gui, Add, ListView, AltSubmit +Grid +NoSortHdr -theme -Multi gListSyncFiles x50 y100 w500, Fichier|Destination
	Gui, Add, Text, y240 x50, Sélectionner un fichier à télécharger :
	Gui, Add, DropDownList, AltSubmit vUpdateListFile w299 y237 x250 gUpdateListFile Choose1,
	Gui, Add, Text, x20 y320, User : %A_UserName%
	Gui, Add, Button, hwndDownloadFile x230 y270 w150 gStartDownloadFile, Télécharger un fichier`ndepuis le serveur
	Opt1 := [0, 0x1ABC9C, , "White", 8, , "0x16A085", 2]
	Opt2 := [ , "0x16A085"]
	Opt5 := [ , , ,"White"]
	Clock1 := [0, 0x2ECC71, , "White", "H", , "0x27AE60", 5]
	Clock2 := [ , "0x27AE60"]
	Clock5 := [ , , ,"White"]

	If !ImageButton.Create(ManualSync, Opt1, Opt2, , , Opt5)
		MsgBox, 32, ImageButton Error Btn1, % ImageButton.LastError
	If !ImageButton.Create(DeleteSyncFile, Opt1, Opt2, , , Opt5)
		MsgBox, 32, ImageButton Error Btn1, % ImageButton.LastError
	If !ImageButton.Create(AddFile, Opt1, Opt2, , , Opt5)
		MsgBox, 32, ImageButton Error Btn1, % ImageButton.LastError
	If !ImageButton.Create(DownloadFile, Opt1, Opt2, , , Opt5)
		MsgBox, 32, ImageButton Error Btn1, % ImageButton.LastError
	; If !ImageButton.Create(ClockHours, Clock1, Clock2, , , Clock5)
	; 	MsgBox, 32, ImageButton ErroClockHours Btn1, % ImageButton.LastError
	; If !ImageButton.Create(ClockMinutes, Clock1, Clock2, , , Clock5)
	; 	MsgBox, 32, ImageButton ErroClockHours Btn1, % ImageButton.LastError
	GetConfigServer:
	{
		FileReadLine, ConfigServer, %A_ScriptDir%\server.conf, 1
		if(ConfigServer = "") {
			MsgBox, 16, Erreur, aucun serveur n'as été inscrit.
			ExitApp
		}
		SyncServer = %ConfigServer%
	}
	DownloadFile:
	{
		Loop, %SyncServer%\*.*,, 1
		{
			; MsgBox, %A_LoopFileName%
			GuiControl,,UpdateListFile, %A_LoopFileName%
			if(AllPath = "" or AllNameFiles = "") {
				AllPath = % A_LoopFileFullPath
				AllNameFiles = % A_LoopFileName
			} else {
				AllNameFiles = %AllNameFiles%|%A_LoopFileName%
				AllPath = %AllPath%|%A_LoopFileFullPath%
			}
		}
	}
	DeleteOldSaves:
	{
		FormatTime, Today,, yyyyMMdd
		Loop, %SyncServer%\*.*, 1, 1
		{
			FileGetAttrib,CurAttrib, %A_LoopFileFullPath%
			IfInString, CurAttrib, D
			RegExMatch(A_LoopFileName, "([0-9][0-9])\.([0-9][0-9])\.([0-9][0-9][0-9][0-9])", OldSaveFolder)
			if not(OldSaveFolder1 = "") {
				DateOfOldSave = %OldSaveFolder3%%OldSaveFolder2%%OldSaveFolder1%
				distance := OldSaveFolder3 . OldSaveFolder2 . OldSaveFolder1
				distance -= Today, days
				if(distance < -365) {
					FileRemoveDir, %A_LoopFileFullPath%, 1
				}
			}
		}
	}
	MenuTrayInit:
	{
		Menu, Tray, NoStandard
		Menu, Tray, Add, Quitter, Quit
		Menu, Tray, Add, Ouvrir l'interface, OpenUI
		Menu, Tray, Add, Synchroniser, ManualSync
		; Menu, Tray, Add ; ADD SEPARATOR
	}
	SetListViewFiles:
	{
		LineNumber = 0
		Loop,
		{
			LineNumber := LineNumber + 1
			FileToAdd =
			currentDestination =
			FileReadLine, FileToAdd, %A_ScriptDir%\files.conf, %LineNumber%
			FileReadLine, currentDestination, %A_ScriptDir%\dest.conf, %LineNumber%
			if(FileToAdd = "") {
				LV_ModifyCol(1, "AutoHdr", "Fichiers")
				LV_ModifyCol(2, "AutoHdr Text", "Destination")
				Return
			}
			if(currentDestination = "" or currentDestination = ) {
				FileAppend, %SyncServer%`n, %A_ScriptDir%\dest.conf
				currentDestination = %SyncServer%
			}
			LV_Add("", FileToAdd, currentDestination)
		}
	}
	Return
}

GuiClose:
{
	Gui, Hide
	Return
}

Quit:
{
	MsgBox, 36,, Etes-vous sûr de vouloir quitter? Cela désactiveras la synchronisation automatique jusqu'au relancement de l'application.
	IfMsgBox, Yes
		Goto, RealExit
	Return
}

OpenUI:
{
	Gui, Show, , TeregaSync
	Return
}

StartDownloadFile:
{
	Gui, Submit, NoHide
	If(UpdateListFile = "") {
		MsgBox, 16,, Vous n'avez pas sélectionner de fichier à télécharger.
		Return
	}
	; FileSelectFile, FileToDownload, 3, %SyncServer%
	FileSelectFolder, FileToDownload, %DownloadPathSelect%, 3
	If(FileToDownload = "") {
		MsgBox, 16,, Vous n'avez pas sélectionner de répertoire.
		Return
	}
	SplittedNames := StrSplit(AllNameFiles, "|")
	SplittedPaths := StrSplit(AllPath, "|")
	PathToDownload := SplittedPaths[UpdateListFile]
	NameToDownload := SplittedNames[UpdateListFile]
	; MsgBox, % PathToDownload
	; MsgBox, %FileToDownload%
	FormatTime, DateHistory, , ShortDate
	FormatTime, TimeHistory, T12, Time
	StringReplace, DateHistory, DateHistory, / , _, A
	StringReplace, TimeHistory, TimeHistory, : , h_,
	StringReplace, TimeHistory, TimeHistory, : , m_,
	PathToVerifyS = %FileToDownload%\%NameToDownload%
	Debug := RegExMatch(PathToVerifyS, "\\(.+\\)*(.+(\..+))$", FileRegEx)
	StringReplace, NameWithoutExtensionS, FileRegEx2, %FileRegEx3% , , All
	if FileExist(PathToVerifyS) {
		if InStr(FileExist(PathToVerifyS), "D") {
			MsgBox, Un fichier a exactement le même nom que le programme! Veuillez supprimer ou renommer le fichier et recommencer l'opération.
			Return
		}
		NewDownloadName = %FileToDownload%\%NameWithoutExtensionS%_%DateHistory%_%TimeHistory%s%FileRegEx3%
		FileMove, %PathToVerifyS%, %NewDownloadName%,
		; MsgBox, % NewDownloadName
	}
	FileCopy, %PathToDownload%, %FileToDownload%
	Return
}

UpdateListFile:
{
	Gui, Submit, NoHide
	Return
}

SyncType:
{
	Gui, Submit, NoHide 						; Mise à jour des variables de l'interface
	if(SyncType == "Manuelle") {
		SetTimer, ManualSync, Off
	} else {
		SetTimer, ManualSync, 300000
	}
	Return
}

AddFile:
{
	FileSelectFile, SelectedFile, 3, %DownloadPathSelect%, Selectionner un fichier à sauvegarder
	if (SelectedFile = "") {
		MsgBox, 16,, Vous n'avez pas sélectionner de fichiers.
		Return
	}
	FileRead, AllFilesConf, %A_ScriptDir%\files.conf
	IfInString, AllFilesConf, %SelectedFile%
	{
		MsgBox, 16,, Le fichier est déjà présent dans les fichiers de synchronisation.
		Return
	}
	FileGetSize, FileSizeVerif, %A_ScriptDir%\files.conf
	if(FileSizeVerif <= 0) {
		FileAppend, %SelectedFile%, %A_ScriptDir%\files.conf
	} else {
		FileAppend, `n%SelectedFile%, %A_ScriptDir%\files.conf
	}
	LV_Add("",SelectedFile, SyncServer)
	LV_ModifyCol(1, "AutoHdr", "Fichiers")
	LV_ModifyCol(2, "AutoHdr", "Destination")
	FileAppend, 1, %A_ScriptDir%\temp
	Reload
	Return
}

ModifyDest:
{
	Gui, Submit, NoHide
	FileSelectFolder, NewDestination, %SyncServer%, 3
	if(ErrorLevel > 0) {
		MsgBox, 16,, Erreur code 7x.
		Return
	}
	if(NewDestination = "") {
		MsgBox, 16,, Erreur code 6x.
		Return
	}
	LV_modify(EventInfo, "Col2", NewDestination)
	LV_ModifyCol(1, "AutoHdr", "Fichiers")
	LV_ModifyCol(2, "AutoHdr", "Destination")
	
	FileReadLine, oldDest, %A_ScriptDir%\dest.conf, %EventInfo%
	FileReadLine, FilePath, %A_ScriptDir%\files.conf, %EventInfo%
	NameFolder := RegExMatch(FilePath, "\\(.+\\)*(.+\..+)$", OldFileName)
	FileDelete, %A_ScriptDir%\temp
	inputFile = %A_ScriptDir%\dest.conf ; change/set thePathToYourInputFile
	outputFile = %A_ScriptDir%\temp ; change/set thePathToYourOutputFile
	Loop, Read, %inputFile%, %outputFile% ; read from inputFile, and write to outputFile
	{
		If A_Index != %EventInfo% ; if we are NOT at line 20
		FileAppend, %A_LoopReadLine%`n ; write the same line to outputFile
		Else ; we are at line 20
		FileAppend, %NewDestination%`n ; write the replacement to outputFile
	}
	FileDelete, %A_ScriptDir%\dest.conf
	FileRead, DestData, %A_ScriptDir%\temp
	FileAppend, %DestData%, %A_ScriptDir%\dest.conf
	FileDelete, %A_ScriptDir%\temp
	MsgBox, 36,, Voulez vous déplacer ce fichier sur la nouvelle destination ?
	EventInfo =
	IfMsgBox, Yes
		Goto, MoveNewDestFile
	Return
}

MoveNewDestFile:
{
	FileMoveDir, %oldDest%\%OldFileName2%, %NewDestination%\%OldFileName2%
	Return
}

ManualSync:
{
	LineNumber = 0
	Loop,
	{
		LineNumber := LineNumber + 1
		FileToMove =
		FileReadLine, FileToMove, %A_ScriptDir%\files.conf, %LineNumber%
		if(FileToMove = "") {
			;NOTIFICATIONS DONE.
			if(LineNumber = 1) {
				MsgBox, 48,, Aucun fichier présent.
				Return
			}
			ToolTip, Synchronisation effectuée.
			Sleep, 2000
			ToolTip
			GuiControl,, UpdateListFile, |
			AllPath =
			AllNameFiles =
			Loop, %SyncServer%\*.*,, 1
			{
				GuiControl,,UpdateListFile, %A_LoopFileName%
				if(AllPath = "" or AllNameFiles = "") {
					AllPath = % A_LoopFileFullPath
					AllNameFiles = % A_LoopFileName
				} else {
					AllNameFiles = %AllNameFiles%|%A_LoopFileName%
					AllPath = %AllPath%|%A_LoopFileFullPath%
				}
			}
			Return
		}
		Debug := RegExMatch(FileToMove, "\\(.+\\)*(.+(\..+))$", RegExFile)
		if(RegExFile2 = "") {
			MsgBox, 16,, Erreur code 5x.
		}
		FileReadLine, DestPath, %A_ScriptDir%\dest.conf, %LineNumber%
		if(DestPath = "") {
			DestPath = %SyncServer%
		}
		PathToSync = %DestPath%\%RegExFile2%
		FormatTime, DateHistory, , ShortDate
		FormatTime, TimeHistory, T12, Time
		StringReplace, TimeHistory, TimeHistory, : , h_,
		StringReplace, TimeHistory, TimeHistory, : , m_,
		StringReplace, DateHistory, DateHistory, /, _, All
		if FileExist(PathToSync) {
			StringReplace, NameWithoutExtension, RegExFile2, %RegExFile3% , , All
			NewName = %NameWithoutExtension%_%DateHistory%_%TimeHistory%s%RegExFile3%
			FileMove, %PathToSync%, %DestPath%\%NewName%
		}
		FileCopy, %FileToMove%, %DestPath%
		RegExFile2 =
		RegExFile3 =
		If !( InStr( FileExist(SyncServer), "D") ) {
			MsgBox, 16,, Une erreur est survenue lors de la Synchronisation des fichiers. Erreur code 1x.
			FileDelete, % SyncServer
			Return
		}
		if !FileExist(FileToMove) {
			MsgBox, 21,, Une erreur est survenue lors de la Synchronisation des fichiers. Erreur code 0x.
			IfMsgBox, Retry
				Goto, ManualSync
			Return
		}
		if(ErrorLevel != 0) {
			MsgBox, 21,, Une erreur est survenue lors de la Synchronisation des fichiers. Erreur code %ErrorLevel%.
			IfMsgBox, Retry
				Goto, ManualSync
			Return
		}
	}
	Return
}

ListSyncFiles:
{
	Gui, Submit, NoHide
	EventInfo := LV_GetNext()
	if(EventInfo = 0) {
		Return
	}
	if (A_GuiEvent = "RightClick") {
		Goto, ModifyDest
	}
	Return
}


DeleteSyncFile:
{
	Gui, Submit, NoHide
	if(EventInfo = "") {
		return
	} Else {
		MsgBox, 36,, Etes-vous sûr de vouloir supprimer ce fichier de la synchronisation ? Une sauvegarde seras effectué.
		IfMsgBox Yes
			Goto, DeleteSyncFileEvent
	}
	Return
}

DeleteSyncFileEvent:
{
	LV_Delete(EventInfo)
	FileReadLine, FileToDelete, %A_ScriptDir%\files.conf, %EventInfo%
	sfile = %A_ScriptDir%\files.conf
	add_del(FileToDelete,sfile,"del")

	; NEW METHOD

	FileReadLine, oldDest, %A_ScriptDir%\dest.conf, %EventInfo%
	FileDelete, %A_ScriptDir%\temp
	inputFile = %A_ScriptDir%\dest.conf ; change/set thePathToYourInputFile
	outputFile = %A_ScriptDir%\temp ; change/set thePathToYourOutputFile
	if(EventInfo = 0) {
		EventInfo = 1
	}
	Loop, Read, %inputFile%, %outputFile% ; read from inputFile, and write to outputFile
	{
		If A_Index != %EventInfo% ; if we are NOT at line 20
		FileAppend, %A_LoopReadLine%`n ; write the same line to outputFile
	}
	FileDelete, %A_ScriptDir%\dest.conf
	FileRead, NewDestData, %A_ScriptDir%\temp
	FileAppend, %NewDestData%, %A_ScriptDir%\dest.conf
	FileDelete, %A_ScriptDir%\temp
	Return
}

RealExit:
{
	FileDelete, %A_ScriptDir%\temp
	ExitApp
}