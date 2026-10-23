//%attributes = {}
// Opens the Main form without blocking: called by On Startup and by the File menu.
// Without parameters: brings the window to the front if it is already open, otherwise
// runs again in the application process (worker 1) with a parameter.
#DECLARE($params : Object)

var $title : Text
var $window : Integer
$title:=Localized string("Main_WindowTitle")

If (Count parameters=0)
	
	ARRAY LONGINT($windows; 0)
	WINDOW LIST($windows)
	
	var $i : Integer
	For ($i; 1; Size of array:C274($windows))
		$window:=$windows{$i}
		If (Window process($window)=1) && (Get window title($window)=$title)
			var $left; $top; $right; $bottom : Integer
			GET WINDOW RECT($left; $top; $right; $bottom; $window)
			CALL FORM($window; Formula(SET WINDOW RECT($left; $top; $right; $bottom; $window)))
			return 
		End if 
	End for 
	
	CALL WORKER(1; Current method name; {})
	
Else 
	
	If (Storage:C1525.notionConfig=Null:C1517)
		var $databaseId; $bearerToken : Text
		ALERT:C41(Localized string("Startup_AlertCredentials"))
		$bearerToken:=Request:C163(Localized string("Startup_RequestBearerToken"))
		$databaseId:=Request:C163(Localized string("Startup_RequestDatabaseId"))
		Use (Storage:C1525)
			Storage:C1525.notionConfig:=New shared object:C1526("bearerToken"; "Bearer "+$bearerToken; "databaseId"; $databaseId)
		End use 
	End if 
	
	SET MENU BAR(1)
	
	$window:=Open form window:C675("Main"; Plain form window:K39:10; Horizontally centered; Vertically centered)
	SET WINDOW TITLE($title; $window)
	DIALOG:C40("Main"; *)
	
End if 
