// ----------------------------------------------------
// Method: Add Item Button (or your button's object method)
// Description: Opens add item form and sends data to Notion
// ----------------------------------------------------

// Open the addProduct form

If (FORM Event:C1606.code=On Clicked:K2:4)
	
	var $palette_window : Integer
	$palette_window:=Open form window:C675("addProduct"; Palette form window:K39:9)
	DIALOG:C40("addProduct"; *)
	
End if 
