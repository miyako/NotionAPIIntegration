//%attributes = {"invisible":true}

// ----------------------------------------------------
// User name (OS): Admin
// Date and time: 08/11/25, 12:02:32
// ----------------------------------------------------
// Method: addNotionItem
// Description
// Takes input data from the form and send API request to notion
//
// Parameters
// ----------------------------------------------------


If (Form:C1466.productName="") | (Form:C1466.productName=Null:C1517)
	ALERT:C41(Localized string("Alert_ProductNameRequired"))
	return 
Else 
	// Convert array selection to Form.status
	If (statusArray>0) & (statusArray<=Size of array:C274(statusArray))
		Form:C1466.status:=statusArray{statusArray}
	Else 
		Form:C1466.status:="In Stock"
	End if 
	
	// Convert array selection to Form.status
	If (categoryArray>0) & (categoryArray<=Size of array:C274(categoryArray))
		Form:C1466.category:=categoryArray{categoryArray}
	Else 
		Form:C1466.category:="In Stock"
	End if 
	
	// Get the form data and send to Notion
	var $itemData : Object
	$itemData:=New object:C1471
	
	// Map form fields to item data
	$itemData.productName:=Form:C1466.productName
	$itemData.category:=Form:C1466.category
	$itemData.price:=Form:C1466.price
	$itemData.stockLevel:=Form:C1466.stockLevel
	$itemData.sku:=Form:C1466.sku
	$itemData.supplier:=Form:C1466.supplier
	$itemData.status:=Form:C1466.status
	$itemData.dateAdded:=Form:C1466.dateAdded
	$itemData.restockDate:=Form:C1466.restockDate
	$itemData.soldUnits:=Form:C1466.soldUnits
	$itemData.tags:=Form:C1466.tags
	
	var $dbRequest : 4D:C1709.HTTPRequest
	var $dbResponse : Object
	var $databaseId : Text
	var $headers : Object
	var $requestBody : Object
	var $properties : Object
	
	
	$headers:=New object:C1471
	$headers.Accept:="application/json"
	$headers["Content-Type"]:="application/json"
	$headers["Notion-Version"]:="2022-06-28"
	
	Use (Storage:C1525)
		$databaseId:=Storage:C1525.notionConfig.databaseId
		$headers.Authorization:=Storage:C1525.notionConfig.bearerToken
	End use 
	
	$properties:=New object:C1471
	
	If ($itemData.productName#Null:C1517) & ($itemData.productName#"")
		$properties["Product Name"]:=New object:C1471("title"; New collection:C1472(New object:C1471("type"; "text"; "text"; New object:C1471("content"; $itemData.productName))))
	End if 
	
	If ($itemData.category#Null:C1517) & ($itemData.category#"")
		$properties.Category:=New object:C1471("select"; New object:C1471("name"; $itemData.category))
	End if 
	
	If ($itemData.price#Null:C1517) & ($itemData.price#"")
		var $priceNum : Real
		$priceNum:=Num:C11($itemData.price)
		If ($priceNum>=0)
			$properties.Price:=New object:C1471("number"; $priceNum)
		End if 
	End if 
	
	If ($itemData.stockLevel#Null:C1517) & ($itemData.stockLevel#"")
		var $stockNum : Integer
		$stockNum:=Num:C11($itemData.stockLevel)
		If ($stockNum>=0)
			$properties.StockLevel:=New object:C1471("number"; $stockNum)
		End if 
	End if 
	
	If ($itemData.sku#Null:C1517) & ($itemData.sku#"")
		$properties.SKU:=New object:C1471("rich_text"; New collection:C1472(New object:C1471("type"; "text"; "text"; New object:C1471("content"; $itemData.sku))))
	End if 
	
	If ($itemData.supplier#Null:C1517) & ($itemData.supplier#"")
		$properties.Supplier:=New object:C1471("select"; New object:C1471("name"; $itemData.supplier))
	End if 
	
	If ($itemData.status#Null:C1517) & ($itemData.status#"")
		$properties.Status:=New object:C1471("status"; New object:C1471("name"; $itemData.status))
	Else 
		$properties.Status:=New object:C1471("status"; New object:C1471("name"; "In Stock"))
	End if 
	
	If ($itemData.dateAdded#Null:C1517)
		$properties["Date Added"]:=New object:C1471("date"; New object:C1471("start"; String:C10($itemData.dateAdded; ISO date GMT:K1:10)))
	Else 
		$properties["Date Added"]:=New object:C1471("date"; New object:C1471("start"; String:C10(Current date:C33; ISO date GMT:K1:10)))
	End if 
	
	If ($itemData.restockDate#Null:C1517)
		$properties["Restock Date"]:=New object:C1471("date"; New object:C1471("start"; String:C10($itemData.restockDate; ISO date GMT:K1:10)))
	End if 
	
	If ($itemData.soldUnits#Null:C1517) & ($itemData.soldUnits#"")
		var $soldNum : Integer
		$soldNum:=Num:C11($itemData.soldUnits)  // Convert text to number
		$properties["Sold (Units)"]:=New object:C1471("number"; $soldNum)
	Else 
		$properties["Sold (Units)"]:=New object:C1471("number"; 0)
	End if 
	
	$requestBody:=New object:C1471
	$requestBody.parent:=New object:C1471("database_id"; $databaseId)
	$requestBody.properties:=$properties
	
	$dbRequest:=4D:C1709.HTTPRequest.new("https://api.notion.com/v1/pages"; {method: "POST"; headers: $headers; body: $requestBody})
	$dbRequest.wait(30)
	
	If (($dbRequest.response.status>=200) & ($dbRequest.response.status<300))
		ALERT:C41(Replace string(Localized string("Alert_ItemAdded"); "{name}"; $itemData.productName))
		OK:=1
		CANCEL:C270
		getNotionDatabase
	Else 
		var $errorBody : Text
		
		If (Value type:C1509($dbRequest.response.body)=Is text:K8:3)
			$errorBody:=$dbRequest.response.body
		Else 
			$errorBody:=JSON Stringify:C1217($dbRequest.response.body)
		End if 
		
		Try
			$dbResponse:=JSON Parse:C1218($errorBody)
			ALERT:C41(Replace string(Replace string(Localized string("Alert_ErrorAddingItem"); "{status}"; String:C10($dbRequest.response.status)); "{message}"; String:C10($dbResponse.message)))
		Catch
			ALERT:C41(Replace string(Replace string(Localized string("Alert_ErrorAddingItem"); "{status}"; String:C10($dbRequest.response.status)); "{message}"; $errorBody))
		End try
	End if 
	
End if 