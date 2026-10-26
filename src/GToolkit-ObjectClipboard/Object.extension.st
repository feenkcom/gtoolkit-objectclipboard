Extension { #name : 'Object' }

{ #category : '*GToolkit-ObjectClipboard' }
Object >> gtActionCopyObjectInspectFor: anAction [
	<gtAction>
	^ anAction button
		priority: 81;
		target: GtPhlowObjectContextMenuTarget;
		icon: BrGlamorousVectorIcons clipboard;
		tooltip: 'Copy object reference';
		menuItemGroup: BrMenuItemGroupConfiguration editing;
		action: [ :aButton |
			Clipboard clipboardText: (GtObjectClipboard default addNewObject: self) ]
]
