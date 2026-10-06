//%attributes = {}

var $dbRequest : 4D:C1709.HTTPRequest
var $dbResponse : Object
var $headers : Object
var $pageId : Text
var $newStockValue : Real
var $requestBody : Object

If (Form:C1466.curItem#Null:C1517)
	$pageId:=Form:C1466.curItem.id
Else 
	ALERT:C41("Please select a product from the list to update its stock.")
	return 
End if 

$newStockValue:=100

$headers:=New object:C1471
$headers.Accept:="application/json"
$headers["Content-Type"]:="application/json"
//$headers.Authorization:="Bearer "+"<your Notion integration secret>"
$headers["Notion-Version"]:="2022-06-28"

Use (Storage:C1525)
	$headers.Authorization:=Storage:C1525.notionConfig.bearerToken
End use 

$requestBody:=New object:C1471
$requestBody.properties:=New object:C1471
$requestBody.properties.StockLevel:=New object:C1471("number"; $newStockValue)
$requestBody.properties.Status:=New object:C1471("status"; New object:C1471("name"; "In Stock"))
$dbRequest:=4D:C1709.HTTPRequest.new("https://api.notion.com/v1/pages/"+$pageId; {method: "PATCH"; headers: $headers; body: $requestBody})
$dbRequest.wait(30)


If (($dbRequest.response.status>=200) & ($dbRequest.response.status<300))
	ALERT:C41("Stock level for "+Form:C1466.curItem.productName+" updated successfully!")
	getNotionDatabase
Else 
	var $errorBody : Text
	$errorBody:=String:C10($dbRequest.response.body)
	
	Try
		$dbResponse:=JSON Parse:C1218($errorBody)
		ALERT:C41("Error updating stock: "+String:C10($dbRequest.response.status)+" - "+$dbResponse.message)
	Catch
		ALERT:C41("Error updating stock: "+String:C10($dbRequest.response.status)+" - "+$errorBody)
	End try
End if 
