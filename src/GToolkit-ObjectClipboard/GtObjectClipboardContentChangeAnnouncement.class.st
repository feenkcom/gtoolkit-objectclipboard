"
Announces changes to a GtObjectClipboard. Carries the storage whose contents changed.
"
Class {
	#name : 'GtObjectClipboardContentChangeAnnouncement',
	#superclass : 'Announcement',
	#instVars : [
		'objectClipboard'
	],
	#category : 'GToolkit-ObjectClipboard-Core',
	#package : 'GToolkit-ObjectClipboard',
	#tag : 'Core'
}

{ #category : 'accessing' }
GtObjectClipboardContentChangeAnnouncement >> objectClipboard [
	^ objectClipboard
]

{ #category : 'accessing' }
GtObjectClipboardContentChangeAnnouncement >> objectClipboard: anObject [
	objectClipboard := anObject
]
