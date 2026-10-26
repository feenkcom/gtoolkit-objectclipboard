"
An entry in GtObjectClipboard, pairing a generated UUID with the original live value and an optional name (nil when unnamed). Use the clipboard naming interface to coordinate uniqueness and announce changes. Name strings are copied on assignment and access.
"
Class {
	#name : 'GtStoredClipboardObject',
	#superclass : 'Object',
	#instVars : [
		'id',
		'value',
		'name'
	],
	#category : 'GToolkit-ObjectClipboard-Core',
	#package : 'GToolkit-ObjectClipboard',
	#tag : 'Core'
}

{ #category : 'instance creation' }
GtStoredClipboardObject class >> id: anId value: anObject [
	^ self new initializeWithId: anId value: anObject
]

{ #category : 'accessing' }
GtStoredClipboardObject >> id [
	^ id
]

{ #category : 'accessing' }
GtStoredClipboardObject >> idString36 [
	^ id asString36
]

{ #category : 'initialization' }
GtStoredClipboardObject >> initializeWithId: anId value: anObject [
	id := anId.
	value := anObject.
]

{ #category : 'accessing' }
GtStoredClipboardObject >> name [
	^ name ifNotNil: [ name copy ]
]

{ #category : 'accessing' }
GtStoredClipboardObject >> name: aName [
	"The clipboard coordinates uniqueness; nil removes the optional name."
	(aName isNil or: [ aName isString and: [ aName isNotEmpty ] ])
		ifFalse: [ self error: 'An object name must be a nonempty string or nil' ].
	name := aName ifNotNil: [ aName copy ].
]

{ #category : 'printing' }
GtStoredClipboardObject >> printOn: aStream [
	super printOn: aStream.
	aStream << ' ['; << self idString36; << '] '; print: value.
]

{ #category : 'accessing' }
GtStoredClipboardObject >> value [
	^ value
]
