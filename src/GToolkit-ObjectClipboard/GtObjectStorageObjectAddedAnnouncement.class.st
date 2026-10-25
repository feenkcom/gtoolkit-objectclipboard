"
Announces a newly inserted GtObjectStorage entry. Carries the storage and the stored entry.
"
Class {
	#name : 'GtObjectStorageObjectAddedAnnouncement',
	#superclass : 'GtObjectStorageContentChangeAnnouncement',
	#instVars : [
		'storedObject'
	],
	#category : 'GToolkit-ObjectClipboard-Core',
	#package : 'GToolkit-ObjectClipboard',
	#tag : 'Core'
}

{ #category : 'accessing' }
GtObjectStorageObjectAddedAnnouncement >> storedObject [
	^ storedObject
]

{ #category : 'accessing' }
GtObjectStorageObjectAddedAnnouncement >> storedObject: anObject [
	storedObject := anObject
]
