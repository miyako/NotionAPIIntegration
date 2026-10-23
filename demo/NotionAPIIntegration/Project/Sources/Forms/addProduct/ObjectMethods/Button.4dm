// OK Button object method for addProduct form

// Validate required fields
If (Form:C1466.productName="") | (Form:C1466.productName=Null:C1517)
	ALERT:C41(Localized string("Alert_ProductNameRequired"))
	return 
Else 
	addNotionItem
	
End if 