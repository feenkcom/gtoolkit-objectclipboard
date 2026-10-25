"
An entry in GtObjectStorage, pairing a generated UUID with the original live value and an optional name (nil when unnamed). Use the storage naming interface to coordinate uniqueness and announce changes. Name strings are copied on assignment and access.
"
Class {
	#name : 'GtStoredObject',
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
GtStoredObject class >> id: anId value: anObject [
	^ self new initializeWithId: anId value: anObject
]

{ #category : 'accessing' }
GtStoredObject >> id [
	^ id
]

{ #category : 'accessing' }
GtStoredObject >> idString36 [
	^ id asString36
]

{ #category : 'initialization' }
GtStoredObject >> initializeWithId: anId value: anObject [
	id := anId.
	value := anObject.
]

{ #category : 'accessing' }
GtStoredObject >> name [
	^ name ifNotNil: [ name copy ]
]

{ #category : 'accessing' }
GtStoredObject >> name: aName [
	"Storage coordinates uniqueness; nil removes the optional name."
	(aName isNil or: [ aName isString and: [ aName isNotEmpty ] ])
		ifFalse: [ self error: 'An object name must be a nonempty string or nil' ].
	name := aName ifNotNil: [ aName copy ].
]

{ #category : 'printing' }
GtStoredObject >> printOn: aStream [
	super printOn: aStream.
	aStream << ' ['; << self idString36; << '] '; print: value.
]

{ #category : 'accessing' }
GtStoredObject >> value [
	^ value
]
