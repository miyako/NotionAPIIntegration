//%attributes = {"invisible":true}
// ----------------------------------------------------
// User name (OS): Admin
// Date and time: 08/06/25, 17:39:21
// ----------------------------------------------------
// Method: getNotionDatabase
// Description: Gets Notion database and calculates KPIs
// 
//
// Parameters
// ----------------------------------------------------
var $dbRequest : 4D:C1709.HTTPRequest
var $dbResponse : Object
var $databaseId : Text
var mappedInventory : Collection
var $headers : Object

// KPI Variables
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
	
	var $j : Integer
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
		
		var $tagNames : Collection
		$tagNames:=New collection:C1472
		var $tag : Object
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
	$kpis.formattedRevenue:="$"+String:C10(totalRevenue; "###,##0")
	
	Form:C1466.inventoryKPIs:=$kpis
	Form:C1466.inventoryData:=mappedInventory
	
Else 
	ALERT:C41(Replace string:C233(Replace string:C233(Localized string:C991("Alert_ErrorQueryingDatabase"); "{status}"; String:C10($dbRequest.response.status)); "{message}"; String:C10($dbRequest.response.statusText)))
End if 