//%attributes = {}
var $dbRequest : 4D:C1709.HTTPRequest
var $dbResponse : Object
var $headers : Object
var $pageId : Text
var $requestBody : Object

If (Form:C1466.curItem#Null:C1517)
	$pageId:=Form:C1466.curItem.id
Else 
	ALERT:C41("Please select a product from the list to delete.")
	return 
End if 

// Confirm deletion
var $userInput : Text
$userInput:=Request:C163("Type 'DELETE' to confirm deletion of "+Form:C1466.curItem.productName+":")
If (OK=0) | ($userInput#"DELETE")
	ALERT:C41("Deletion cancelled.")
	return 
End if 

$headers:=New object:C1471
$headers.Accept:="application/json"
$headers["Content-Type"]:="application/json"
$headers["Notion-Version"]:="2022-06-28"

Use (Storage:C1525)
	$headers.Authorization:=Storage:C1525.notionConfig.bearerToken
End use 
$requestBody:=New object:C1471
$requestBody.archived:=True:C214

$dbRequest:=4D:C1709.HTTPRequest.new("https://api.notion.com/v1/pages/"+$pageId; {method: "PATCH"; headers: $headers; body: $requestBody})
$dbRequest.wait(30)

If (($dbRequest.response.status>=200) & ($dbRequest.response.status<300))
	ALERT:C41("Product "+Form:C1466.curItem.productName+" deleted successfully!")
	getNotionDatabase  // Refresh the list
Else 
	var $errorBody : Text
	$errorBody:=String:C10($dbRequest.response.body)
	
	Try
		$dbResponse:=JSON Parse:C1218($errorBody)
		ALERT:C41("Error deleting product: "+String:C10($dbRequest.response.status)+" - "+$dbResponse.message)
	Catch
		ALERT:C41("Error deleting product: "+String:C10($dbRequest.response.status)+" - "+$errorBody)
	End try
End if 