"
Announces a newly inserted GtObjectClipboard entry. Carries the storage and the stored entry.
"
Class {
	#name : 'GtObjectClipboardObjectAddedAnnouncement',
	#superclass : 'GtObjectClipboardContentChangeAnnouncement',
	#instVars : [
		'storedObject'
	],
	#category : 'GToolkit-ObjectClipboard-Core',
	#package : 'GToolkit-ObjectClipboard',
	#tag : 'Core'
}

{ #category : 'accessing' }
GtObjectClipboardObjectAddedAnnouncement >> storedObject [
	^ storedObject
]

{ #category : 'accessing' }
GtObjectClipboardObjectAddedAnnouncement >> storedObject: anObject [
	storedObject := anObject
]
