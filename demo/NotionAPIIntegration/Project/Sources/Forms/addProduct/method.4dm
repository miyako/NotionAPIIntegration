// addProduct form On Load method

Case of 
	: (Form event code:C388=On Load:K2:1)
		// Create status array for dropdown
		ARRAY TEXT:C222(statusArray; 4)
		statusArray{1}:="In Stock"
		statusArray{2}:="Out of Stock"
		statusArray{3}:="Low Stock"
		statusArray{4}:="Ordered"
		
		// Set default selection (index 1 = "In Stock")
		statusArray:=1
		
		ARRAY TEXT:C222(categoryArray; 5)
		categoryArray{1}:="Apparel"
		categoryArray{2}:="Home Goods"
		categoryArray{3}:="Electronics"
		categoryArray{4}:="Accessories"
		categoryArray{5}:="Other"
		
		categoryArray:=1
		// Set default selection (index 1 = "In Stock")
		
		// Set other default values
		Form:C1466.dateAdded:=Current date:C33
		Form:C1466.restockDate:=Current date:C33
		
		
		
End case 