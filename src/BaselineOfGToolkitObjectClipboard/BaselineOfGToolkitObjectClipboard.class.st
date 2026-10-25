"
Loads GToolkit-ObjectClipboard into a Glamorous Toolkit image.
"
Class {
	#name : 'BaselineOfGToolkitObjectClipboard',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfGToolkitObjectClipboard',
	#package : 'BaselineOfGToolkitObjectClipboard'
}

{ #category : 'baseline' }
BaselineOfGToolkitObjectClipboard >> baseline: spec [
	<baseline>
	spec for: #common do: [
		spec package: 'GToolkit-ObjectClipboard' ]
]
