"
Announces changes to a GtObjectStorage. Carries the storage whose contents changed.
"
Class {
	#name : 'GtObjectStorageContentChangeAnnouncement',
	#superclass : 'Announcement',
	#instVars : [
		'objectStorage'
	],
	#category : 'GToolkit-ObjectClipboard-Core',
	#package : 'GToolkit-ObjectClipboard',
	#tag : 'Core'
}

{ #category : 'accessing' }
GtObjectStorageContentChangeAnnouncement >> objectStorage [
	^ objectStorage
]

{ #category : 'accessing' }
GtObjectStorageContentChangeAnnouncement >> objectStorage: anObject [
	objectStorage := anObject
]
