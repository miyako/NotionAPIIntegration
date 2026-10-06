
// ----------------------------------------------------
// User name (OS): Admin
// Date and time: 08/11/25, 12:07:18
// ----------------------------------------------------
// Method: DataStore
// Description
// DataStore used to expose function to Qodly studio
//
// Parameters
// ----------------------------------------------------

Class extends DataStoreImplementation


exposed Function updateStock($selectedInventory : Object)
	var $dbRequest : 4D:C1709.HTTPRequest
	var $dbResponse : Object
	var $headers : Object
	var $pageId : Text
	var $newStockValue : Real
	var $requestBody : Object
	
	If ($selectedInventory.id#Null:C1517)
		$pageId:=$selectedInventory.id
	Else 
		Web Form:C1735.setWarning("Please select a product from the list to update its stock.")
		return 
	End if 
	
	$newStockValue:=100
	
	
	$headers:=New object:C1471
	$headers.Accept:="application/json"
	$headers["Content-Type"]:="application/json"
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
		
		Web Form:C1735.setMessage("Stock level for "+$selectedInventory.productName+" updated successfully!")
		
	Else 
		var $errorBody : Text
		$errorBody:=String:C10($dbRequest.response.body)
		
		Try
			$dbResponse:=JSON Parse:C1218($errorBody)
			Web Form:C1735.setError("Error updating stock: "+String:C10($dbRequest.response.status)+" - "+$dbResponse.message)
		Catch
			Web Form:C1735.setError("Error updating stock: "+String:C10($dbRequest.response.status)+" - "+$errorBody)
		End try
	End if 
	
exposed Function getNotionDatabase() : Collection
	var $dbRequest : 4D:C1709.HTTPRequest
	var $dbResponse : Object
	var $databaseId : Text
	var mappedInventory : Collection
	var $headers : Object
	
	var totalItems : Integer
	var totalRevenue : Real
	var itemsSold : Integer
	var lowStockAlert : Integer
	
	
	mappedInventory:=New collection:C1472
	
	$headers:=New object:C1471
	$headers.Accept:="application/json"
	$headers["Content-Type"]:="application/json"
	$headers["Notion-Version"]:="2022-06-28"
	Use (Storage:C1525)
		$databaseId:=Storage:C1525.notionConfig.databaseId
		$headers.Authorization:=Storage:C1525.notionConfig.bearerToken
	End use 
	$dbRequest:=4D:C1709.HTTPRequest.new("https://api.notion.com/v1/databases/"+$databaseId+"/query"; {method: "POST"; headers: $headers})
	$dbRequest.wait(30)
	
	If (($dbRequest.response.status>=200) & ($dbRequest.response.status<300))
		If (Value type:C1509($dbRequest.response.body)=Is object:K8:27)
			$dbResponse:=$dbRequest.response.body
		Else 
			$dbResponse:=JSON Parse:C1218(String:C10($dbRequest.response.body))
		End if 
		
		var $dbPages : Collection
		$dbPages:=$dbResponse.results
		
		totalItems:=0
		totalRevenue:=0
		itemsSold:=0
		lowStockAlert:=0
		
		For ($j; 0; $dbPages.length-1)
			var $page : Object
			var $item : Object
			$page:=$dbPages[$j]
			
			$item:=New object:C1471
			$item.id:=$page.id
			
			$item.category:=$page.properties.Category.select.name
			$item.dateAdded:=$page.properties["Date Added"].date.start
			$item.price:=$page.properties.Price.number
			$item.productName:=$page.properties["Product Name"].title[0].plain_text
			$item.restockDate:=$page.properties["Restock Date"].date.start
			$item.revenueEstimate:=$page.properties["Revenue Estimate"].formula.number
			$item.sku:=$page.properties.SKU.rich_text[0].plain_text
			$item.soldUnits:=$page.properties["Sold (Units)"].number
			$item.status:=$page.properties.Status.status.name
			$item.stockLevel:=$page.properties["StockLevel"].number
			$item.supplier:=$page.properties.Supplier.select.name
			$item.notes:=""
			$item.tags:=""
			
			var $tagNames : Collection
			$tagNames:=New collection:C1472
			For each ($tag; $page.properties.Tags.multi_select)
				$tagNames.push($tag.name)
			End for each 
			$item.tags:=$tagNames
			
			mappedInventory.push($item)
			
			totalItems:=totalItems+1
			
			If ($item.revenueEstimate#Null:C1517)
				totalRevenue:=totalRevenue+$item.revenueEstimate
			End if 
			
			If ($item.soldUnits#Null:C1517)
				itemsSold:=itemsSold+$item.soldUnits
			End if 
			
			Case of 
				: ($item.status="Out of Stock")
					lowStockAlert:=lowStockAlert+1
				: ($item.status="Low Stock")
					lowStockAlert:=lowStockAlert+1
				: (($item.stockLevel#Null:C1517) & ($item.stockLevel<10))
					lowStockAlert:=lowStockAlert+1
			End case 
			
		End for 
		
		var $kpis : Object
		$kpis:=New object:C1471
		$kpis.totalItems:=totalItems
		$kpis.totalRevenue:=totalRevenue
		$kpis.itemsSold:=itemsSold
		$kpis.lowStockAlert:=lowStockAlert
		
		mappedInventory.push($kpis)
		
	Else 
	End if 
	return mappedInventory
	
exposed Function createStock($newStock : Object)
	
	If ($newStock.productName="") | ($newStock.productName=Null:C1517)
		Web Form:C1735.setWarning("Product Name is required!")
		return 
	Else 
		
		If ($newStock.status=Null:C1517) | ($newStock.status="")
			$newStock.status:="In Stock"
		End if 
		
		If ($newStock.category=Null:C1517) | ($newStock.category="")
			$newStock.category:="General"
		End if 
		
		var $itemData : Object
		$itemData:=New object:C1471
		
		$itemData.productName:=$newStock.productName
		$itemData.category:=$newStock.category
		$itemData.price:=$newStock.price
		$itemData.stockLevel:=$newStock.stockLevel
		$itemData.sku:=$newStock.sku
		$itemData.supplier:=$newStock.supplier
		$itemData.status:=$newStock.status
		$itemData.dateAdded:=$newStock.dateAdded
		$itemData.restockDate:=$newStock.restockDate
		$itemData.soldUnits:=$newStock.soldUnits
		$itemData.tags:=$newStock.tags
		
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
			$soldNum:=Num:C11($itemData.soldUnits)
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
			Web Form:C1735.setMessage("Item '"+$itemData.productName+"' added successfully!")
			Web Form:C1735["newStock"].hide()
		Else 
			var $errorBody : Text
			
			If (Value type:C1509($dbRequest.response.body)=Is text:K8:3)
				$errorBody:=$dbRequest.response.body
			Else 
				$errorBody:=JSON Stringify:C1217($dbRequest.response.body)
			End if 
			
			Try
				$dbResponse:=JSON Parse:C1218($errorBody)
				Web Form:C1735.setError("Error adding item: "+String:C10($dbRequest.response.status)+" - "+$dbResponse.message)
			Catch
				Web Form:C1735.setError("Error adding item: "+String:C10($dbRequest.response.status)+" - "+$errorBody)
			End try
		End if 
		
	End if 
	Web Form:C1735.setMessage("Stock created!")
	
exposed Function deleteStock($selectedStock : Object)
	var $dbRequest : 4D:C1709.HTTPRequest
	var $dbResponse : Object
	var $headers : Object
	var $pageId : Text
	var $requestBody : Object
	
	If ($selectedStock.id#Null:C1517)
		$pageId:=$selectedStock.id
	Else 
		Web Form:C1735.setWarning("Please select a product from the list to delete.")
		return 
	End if 
	
	var $userInput : Text
	
	
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
		Web Form:C1735.setMessage("Product "+$selectedStock.productName+" deleted successfully!")
	Else 
		var $errorBody : Text
		$errorBody:=String:C10($dbRequest.response.body)
		
		Try
			$dbResponse:=JSON Parse:C1218($errorBody)
			Web Form:C1735.setError("Error deleting product: "+String:C10($dbRequest.response.status)+" - "+$dbResponse.message)
		Catch
			Web Form:C1735.setError("Error deleting product: "+String:C10($dbRequest.response.status)+" - "+$errorBody)
		End try
	End if 
	
exposed Function loadKPIs() : Object
	var $inventoryData : Collection
	$inventoryData:=This:C1470.getNotionDatabase()
	
	var kpis : Object
	If ($inventoryData.length>0)
		kpis:=$inventoryData[$inventoryData.length-1]
	Else 
		kpis:=New object:C1471
		kpis.totalItems:=0
		kpis.totalRevenue:=0
		kpis.itemsSold:=0
		kpis.lowStockAlert:=0
		kpis.formattedRevenue:="$0"
	End if 
	
	return kpis