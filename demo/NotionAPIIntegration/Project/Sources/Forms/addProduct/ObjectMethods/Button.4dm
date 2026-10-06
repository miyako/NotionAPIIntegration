// OK Button object method for addProduct form

// Validate required fields
If (Form:C1466.productName="") | (Form:C1466.productName=Null:C1517)
	ALERT:C41("Product Name is required!")
	return 
Else 
	addNotionItem
	
End if 