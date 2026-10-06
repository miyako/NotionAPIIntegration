
// ----------------------------------------------------
// User name (OS): Admin
// Date and time: 08/11/25, 12:01:47
// ----------------------------------------------------
// Method: On Startup
// Description
// Prompts the user to input database id and bearer token, then stores them in Storage
//
// Parameters
// ----------------------------------------------------



var $databaseId; $bearerToken : Text

Use (Storage:C1525)
	If (Storage:C1525.notionConfig=Null:C1517)
		ALERT:C41("Please enter your Notion API credentials.")
		$bearerToken:=Request:C163("Enter Notion Bearer Token:")
		$databaseId:=Request:C163("Enter Notion Database ID:")
		Storage:C1525.notionConfig:=New shared object:C1526
	End if 
End use 

Use (Storage:C1525.notionConfig)
	Storage:C1525.notionConfig.bearerToken:="Bearer "+$bearerToken
	Storage:C1525.notionConfig.databaseId:=$databaseId
End use 

$document_window:=Open form window:C675("Main"; Plain form window:K39:10)
DIALOG:C40("Main")