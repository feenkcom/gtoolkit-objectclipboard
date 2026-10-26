"
Stores live objects under generated UUIDs using GtStoredClipboardObject entries in an OrderedDictionary. Each entry holds its ID, live value, and one optional name. Name lookup scans entries; there is no secondary name dictionary. Names are case-sensitive nonempty strings. Use the clipboard naming interface to enforce uniqueness and announce changes. Assigning a new name replaces the entry's previous name; assigning another entry's name is rejected. Name changes and reads do not affect insertion order.

Every insertion creates a fresh entry. lastObject returns the last remaining entry's value. Removing it exposes the preceding entry. lastObject signals NotFound for empty clipboard; lastObjectIfAbsent: and hasLastObject distinguish empty clipboard from a stored nil. Removing an entry also removes it from name lookup. clearCache resets entries.

Announces changes using GtObjectClipboardContentChangeAnnouncement and its GtObjectClipboardObjectAddedAnnouncement subclass.
"
Class {
	#name : 'GtObjectClipboard',
	#superclass : 'Object',
	#instVars : [
		'objectsByUUID',
		'announcer'
	],
	#classInstVars : [
		'default'
	],
	#category : 'GToolkit-ObjectClipboard-Core',
	#package : 'GToolkit-ObjectClipboard',
	#tag : 'Core'
}

{ #category : 'accessing' }
GtObjectClipboard class >> default [
	"The image-wide object clipboard used by the inspector's Copy object action."
	^ default ifNil: [ default := self new ]
]

{ #category : 'adding' }
GtObjectClipboard >> addNewObject: anObject [
	"Always create a new entry and return its external ID."
	| newUUID storedObject |
	newUUID := self generateNewUUID.
	storedObject := GtStoredClipboardObject id: newUUID value: anObject.
	objectsByUUID at: newUUID put: storedObject.
	self notifyObjectAdded: storedObject.
	^ newUUID asString36
]

{ #category : 'adding' }
GtObjectClipboard >> addNewObject: anObject named: aName [
	| newUUID storedObject |
	self validateName: aName.
	(self includesName: aName) ifTrue: [ self error: 'Object name already exists' ].
	newUUID := self generateNewUUID.
	storedObject := GtStoredClipboardObject id: newUUID value: anObject.
	storedObject name: aName.
	objectsByUUID at: newUUID put: storedObject.
	self notifyObjectAdded: storedObject.
	^ newUUID asString36
]

{ #category : 'accessing' }
GtObjectClipboard >> announcer [
	^announcer
]

{ #category : 'initialization' }
GtObjectClipboard >> clearCache [
	objectsByUUID := OrderedDictionary new.
	self notifyClipboardContentChanges.
]

{ #category : 'utils' }
GtObjectClipboard >> convertToInternalId: anObjectId [
	^ UUID fromString36: anObjectId
]

{ #category : 'utils' }
GtObjectClipboard >> generateNewUUID [
	"TODO: extend to check that the UUID does not exist"
	^ UUID new
]

{ #category : 'gt - actions' }
GtObjectClipboard >> gtActionClearFor: anAction [
	<gtAction>
	^ anAction button
		priority: 10;
		icon: BrGlamorousVectorIcons bin;
		tooltip: 'Clear object clipboard';
		action: [ :aButton | self clearCache ]
]

{ #category : 'gt - views' }
GtObjectClipboard >> gtObjectsByUUIDFor: aView [
	<gtView>
	objectsByUUID ifNil: [ ^ aView empty ].
	^ aView columnedList
		title: 'Objects by UUID';
		items: [ objectsByUUID values ];
		column: 'ID' text: [ :each | each id asString36 ] width: 200;
		column: 'Value' text: [ :each | each value ];
		updateWhen: GtObjectClipboardContentChangeAnnouncement in: self announcer;
		send: [ :each | each value ];
		contextItemLabel: 'Copy ID'
			action: [ :anElement :each | Clipboard clipboardText: each id asString36 ];
		contextItemLabel: 'Inspect ID'
			action: [ :anElement :each | anElement phlow spawnObject: each id ];
		contextItemLabel: 'Inspect value'
			action: [ :anElement :each | anElement phlow spawnObject: each value ];
		contextItemLabel: 'Remove item'
			action: [ :anElement :each | self privateRemoveObjectAt: each id ifAbsent: [ ] ]
]

{ #category : 'accessing - last' }
GtObjectClipboard >> hasLastObject [
	^ objectsByUUID isNotEmpty
]

{ #category : 'accessing - names' }
GtObjectClipboard >> includesName: aName [
	self storedObjectNamed: aName ifAbsent: [ ^ false ].
	^ true
]

{ #category : 'api - testing' }
GtObjectClipboard >> includesObjectWithId: anObjectId [
	| internalId |
	internalId := self convertToInternalId: anObjectId.
	^ objectsByUUID includesKey: internalId
]

{ #category : 'initialization' }
GtObjectClipboard >> initialize [
	super initialize.
	
	announcer := Announcer new.
	self clearCache.
]

{ #category : 'accessing - last' }
GtObjectClipboard >> lastObject [
	^ self lastObjectIfAbsent: [ NotFound signal: 'No last object' ]
]

{ #category : 'accessing - last' }
GtObjectClipboard >> lastObjectIfAbsent: aBlock [
	objectsByUUID ifEmpty: [ ^ aBlock value ].
	^ (objectsByUUID at: (objectsByUUID keyAtIndex: objectsByUUID size)) value
]

{ #category : 'accessing' }
GtObjectClipboard >> locateIdByIdentityForObject: anObject [
	objectsByUUID valuesDo: [ :aStoredObject |
		aStoredObject value == anObject ifTrue: [ ^ aStoredObject id asString36 ] ].
	
	NotFound signal: 'Could not find object'  
]

{ #category : 'accessing - names' }
GtObjectClipboard >> nameObjectAt: anObjectId as: aName [
	"Each entry has one optional name. Assigning a name replaces its previous name."
	| entry existing |
	self validateName: aName.
	entry := self storedObjectAt: anObjectId.
	existing := self storedObjectNamed: aName ifAbsent: [ nil ].
	(existing notNil and: [ existing ~~ entry ])
		ifTrue: [ self error: 'Object name already exists' ].
	entry name: aName.
	self notifyClipboardContentChanges.
	^ anObjectId
]

{ #category : 'accessing - names' }
GtObjectClipboard >> names [
	| result |
	result := OrderedCollection new.
	objectsByUUID valuesDo: [ :each |
		each name ifNotNil: [ :aName | result add: aName ] ].
	^ result
]

{ #category : 'as yet unclassified' }
GtObjectClipboard >> notifyClipboardContentChanges [
	announcer announce: (GtObjectClipboardContentChangeAnnouncement new
		objectClipboard: self).
]

{ #category : 'announcing' }
GtObjectClipboard >> notifyObjectAdded: aStoredObject [
	announcer announce: (GtObjectClipboardObjectAddedAnnouncement new
		objectClipboard: self;
		storedObject: aStoredObject).
]

{ #category : 'accessing' }
GtObjectClipboard >> objectAt: anObjectId [ 
	^ (self storedObjectAt: anObjectId) value
]

{ #category : 'accessing' }
GtObjectClipboard >> objectAt: anObjectId ifPresent: aPresentBlock ifAbsent: anAbsentBlock [
	^ self
		storedObjectAt: anObjectId
		ifPresent: [ :aStoredObject | aPresentBlock value: aStoredObject value ]
		ifAbsent: anAbsentBlock
]

{ #category : 'api - accessing' }
GtObjectClipboard >> objectCount [
	^ objectsByUUID size
]

{ #category : 'accessing - names' }
GtObjectClipboard >> objectIdNamed: aName [
	^ (self storedObjectNamed: aName) idString36
]

{ #category : 'utils - accessing' }
GtObjectClipboard >> objectIds [
	^ objectsByUUID keys collect: [ :each |
			each asString36 ]
]

{ #category : 'accessing - names' }
GtObjectClipboard >> objectNamed: aName [
	^ self objectNamed: aName ifAbsent: [ NotFound signal: 'No object named ', aName asString ]
]

{ #category : 'accessing - names' }
GtObjectClipboard >> objectNamed: aName ifAbsent: aBlock [
	^ (self storedObjectNamed: aName ifAbsent: [ ^ aBlock value ]) value
]

{ #category : 'printing' }
GtObjectClipboard >> printOn: aStream [
	super printOn: aStream.

	aStream 
		<< ' [';
		print: self objectCount;
		<< ' ';
		<< ('object' asPluralBasedOn: self objectCount);
		<< ']'
]

{ #category : 'private' }
GtObjectClipboard >> privateRemoveObjectAt: aKey ifAbsent: anAbsentBlock [
	| removedObject |
	removedObject := objectsByUUID removeKey: aKey ifAbsent: [ ^ anAbsentBlock value ].
	self notifyClipboardContentChanges.
	^ removedObject
]

{ #category : 'accessing - names' }
GtObjectClipboard >> removeName: aName [
	| entry |
	entry := self storedObjectNamed: aName.
	entry name: nil.
	self notifyClipboardContentChanges.
	^ entry idString36
]

{ #category : 'removing' }
GtObjectClipboard >> removeObjectAt: anObjectId [
	^ self removeObjectAt: anObjectId ifAbsent: [ NotFound signal: 'No object with this ID' ]
]

{ #category : 'removing' }
GtObjectClipboard >> removeObjectAt: anObjectId ifAbsent: aBlock [
	^ self privateRemoveObjectAt: (self convertToInternalId: anObjectId) ifAbsent: aBlock
]

{ #category : 'accessing - names' }
GtObjectClipboard >> rename: aName to: aNewName [
	self validateName: aNewName.
	^ self nameObjectAt: (self objectIdNamed: aName) as: aNewName
]

{ #category : 'api - accessing' }
GtObjectClipboard >> size [
	^ objectsByUUID size
]

{ #category : 'accessing' }
GtObjectClipboard >> storedObjectAt: anObjectId [
	| internalId |
	
	internalId := self convertToInternalId: anObjectId.
	^ objectsByUUID at: internalId
]

{ #category : 'accessing' }
GtObjectClipboard >> storedObjectAt: anObjectId ifPresent: aPresentBlock ifAbsent: anAbsentBlock [
	| internalId |
	
	internalId := self convertToInternalId: anObjectId.
	^ objectsByUUID 
		at: internalId
		ifPresent: aPresentBlock
		ifAbsent: anAbsentBlock
]

{ #category : 'accessing - names' }
GtObjectClipboard >> storedObjectNamed: aName [
	^ self storedObjectNamed: aName ifAbsent: [ KeyNotFound signal: aName asString ]
]

{ #category : 'accessing - names' }
GtObjectClipboard >> storedObjectNamed: aName ifAbsent: aBlock [
	"Look up the name on entries, without maintaining a secondary index."
	aName ifNil: [ ^ aBlock value ].
	objectsByUUID valuesDo: [ :each |
		each name = aName ifTrue: [ ^ each ] ].
	^ aBlock value
]

{ #category : 'private' }
GtObjectClipboard >> validateName: aName [
	(aName isString and: [ aName isNotEmpty ])
		ifFalse: [ self error: 'An object name must be a nonempty string' ].
]
