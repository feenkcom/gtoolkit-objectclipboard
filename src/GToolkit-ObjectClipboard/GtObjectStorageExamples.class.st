Class {
	#name : 'GtObjectStorageExamples',
	#superclass : 'Object',
	#traits : 'TAssertable',
	#classTraits : 'TAssertable classTrait',
	#category : 'GToolkit-ObjectClipboard-Examples',
	#package : 'GToolkit-ObjectClipboard',
	#tag : 'Examples'
}

{ #category : 'examples' }
GtObjectStorageExamples >> accessingObjectReturnsStoredObject [
	<gtExample>
	<return: #GtStoredObject>
	| storage object id presentObject entry |
	storage := self newObjectStorage.
	object := Object new.
	id := storage addNewObject: object.
	self assert: (storage objectAt: id) identicalTo: object.
	presentObject := storage objectAt: id ifPresent: [ :found | found ] ifAbsent: [ self fail ].
	self assert: presentObject identicalTo: object.
	entry := storage storedObjectAt: id.
	self assert: entry value identicalTo: object.
	self assert: entry id equals: (UUID fromString36: id).
	^ entry
]

{ #category : 'examples' }
GtObjectStorageExamples >> accessingObjectThatIsMissingReturnsMissing [
	<gtExample>
	<return: #String>
	| objectStorage absentResult |
	
	objectStorage := self newObjectStorage.
	absentResult := objectStorage
		objectAt: UUID new asString36
		ifPresent: [ 'present' ]
		ifAbsent: [ 'missing' ].
	self assert: absentResult equals: 'missing'.
	
	^ absentResult
]

{ #category : 'examples - names' }
GtObjectStorageExamples >> addNewNilObjectNamed [
	<gtExample>
	<return: #GtObjectStorage>
	| storage id |
	storage := self newObjectStorage.
	id := storage addNewObject: nil named: 'nothing'.
	self assert: (storage objectNamed: 'nothing' ifAbsent: [ self fail ]) isNil.
	self assert: (storage objectIdNamed: 'nothing') equals: id.
	self assert: storage hasLastObject.
	self assert: storage lastObject isNil.
	^ storage
]

{ #category : 'examples - names' }
GtObjectStorageExamples >> addNewObjectNamed [
	<gtExample>
	<return: #GtObjectStorage>
	| storage value id announcements |
	storage := self newObjectStorage.
	value := Object new.
	announcements := OrderedCollection new.
	storage announcer when: GtObjectStorageContentChangeAnnouncement
		do: [ :each |
			self assert: each storedObject name equals: 'sample'.
			self assert: (storage objectNamed: 'sample') identicalTo: value.
			announcements add: each ] for: announcements.
	id := storage addNewObject: value named: 'sample'.
	self assert: id isString.
	self assert: (storage objectIdNamed: 'sample') equals: id.
	self assert: (storage objectAt: id) identicalTo: value.
	self assert: (storage storedObjectAt: id) name equals: 'sample'.
	self assert: storage lastObject identicalTo: value.
	self assert: storage objectCount equals: 1.
	self assert: announcements size equals: 1.
	self assert: announcements first class equals: GtObjectStorageObjectAddedAnnouncement.
	^ storage
]

{ #category : 'examples - names' }
GtObjectStorageExamples >> addNewObjectNamedRejectsInvalidNamesWithoutInsertion [
	<gtExample>
	<return: #GtObjectStorage>
	| storage id value announcements |
	storage := self namedObject.
	id := storage objectIdNamed: 'sample'.
	value := storage lastObject.
	announcements := OrderedCollection new.
	storage announcer when: GtObjectStorageContentChangeAnnouncement
		do: [ :each | announcements add: each ] for: announcements.
	self should: [ storage addNewObject: Object new named: 'sample' ] raise: Error.
	self should: [ storage addNewObject: Object new named: '' ] raise: Error.
	self should: [ storage addNewObject: Object new named: nil ] raise: Error.
	self should: [ storage addNewObject: Object new named: 42 ] raise: Error.
	self assert: storage objectCount equals: 1.
	self assert: (storage objectIdNamed: 'sample') equals: id.
	self assert: storage lastObject identicalTo: value.
	self assert: announcements isEmpty.
	^ storage
]

{ #category : 'examples' }
GtObjectStorageExamples >> addObjectAnswersId [
	<gtExample>
	<return: #GtObjectStorage>
	| storage id value entry |
	storage := self newObjectStorage.
	value := Object new.
	id := storage addNewObject: value.
	entry := storage storedObjectAt: id.
	self assert: id isString.
	self assert: (storage includesObjectWithId: id).
	self assert: entry class equals: GtStoredObject.
	self assert: entry id equals: (UUID fromString36: id).
	self assert: entry value identicalTo: value.
	self assert: storage lastObject identicalTo: value.
	^ storage
]

{ #category : 'examples - announcements' }
GtObjectStorageExamples >> addingObjectAnnouncesEntry [
	<gtExample>
	<return: #GtObjectStorage>
	| storage announcements id |
	storage := self newObjectStorage.
	announcements := OrderedCollection new.
	storage announcer when: GtObjectStorageContentChangeAnnouncement
		do: [ :announcement | announcements add: announcement ] for: announcements.
	id := storage addNewObject: Object new.
	self assert: announcements size equals: 1.
	self assert: announcements first class equals: GtObjectStorageObjectAddedAnnouncement.
	self assert: announcements first objectStorage identicalTo: storage.
	self assert: announcements first storedObject identicalTo: (storage storedObjectAt: id).
	self assert: storage lastObject identicalTo: announcements first storedObject value.
	^ storage
]

{ #category : 'examples' }
GtObjectStorageExamples >> addingSameObjectTwiceAddsTwoObjects [
	<gtExample>
	<return: #GtObjectStorage>
	| storage value firstId secondId |
	storage := self newObjectStorage.
	value := Object new.
	firstId := storage addNewObject: value.
	secondId := storage addNewObject: value.
	self deny: firstId equals: secondId.
	self assert: storage objectCount equals: 2.
	self assert: (storage objectAt: firstId) identicalTo: value.
	self assert: (storage objectAt: secondId) identicalTo: value.
	self assert: storage objectIds asArray equals: { firstId. secondId }.
	self assert: storage lastObject identicalTo: value.
	^ storage
]

{ #category : 'examples - names' }
GtObjectStorageExamples >> assigningNameReplacesPreviousName [
	<gtExample>
	<return: #GtObjectStorage>
	| storage id value |
	storage := self namedObject.
	id := storage objectIdNamed: 'sample'.
	value := storage objectNamed: 'sample'.
	storage nameObjectAt: id as: 'replacement'.
	self deny: (storage includesName: 'sample').
	self assert: (storage objectNamed: 'replacement') identicalTo: value.
	self assert: (storage storedObjectAt: id) name equals: 'replacement'.
	self assert: storage names asArray equals: #('replacement').
	self assert: storage objectCount equals: 1.
	self assert: storage lastObject identicalTo: value.
	^ storage
]

{ #category : 'examples - baseline' }
GtObjectStorageExamples >> baselineIncludesObjectClipboard [
	<gtExample>
	| project |
	project := BaselineOfGToolkitObjectClipboard project.
	self assert: (project version: 'baseline') notNil.
	self assert: ((project version: 'baseline') packages
		anySatisfy: [ :each | each name = 'GToolkit-ObjectClipboard' ]).
	^ project
]

{ #category : 'examples' }
GtObjectStorageExamples >> clearStorageRemovesObjects [
	<gtExample>
	<return: #GtObjectStorage>
	| storage id |
	storage := self namedObject.
	id := storage objectIdNamed: 'sample'.
	storage clearCache.
	self assert: storage objectCount equals: 0.
	self deny: (storage includesObjectWithId: id).
	self assert: storage names isEmpty.
	self deny: storage hasLastObject.
	self should: [ storage lastObject ] raise: NotFound.
	^ storage
]

{ #category : 'examples - announcements' }
GtObjectStorageExamples >> contentChangesAnnounceStorage [
	<gtExample>
	<return: #GtObjectStorage>
	| storage announcements id |
	storage := self newObjectStorage.
	id := storage addNewObject: Object new.
	announcements := OrderedCollection new.
	storage announcer when: GtObjectStorageContentChangeAnnouncement
		do: [ :announcement | announcements add: announcement ] for: announcements.
	storage nameObjectAt: id as: 'sample'.
	storage rename: 'sample' to: 'renamed'.
	storage removeName: 'renamed'.
	storage removeObjectAt: id.
	storage clearCache.
	self assert: announcements size equals: 5.
	announcements do: [ :each |
		self assert: each class equals: GtObjectStorageContentChangeAnnouncement.
		self assert: each objectStorage identicalTo: storage ].
	^ storage
]

{ #category : 'examples - last' }
GtObjectStorageExamples >> lookupAndNamingPreserveLastObject [
	<gtExample>
	<return: #GtObjectStorage>
	| storage firstId lastId lastValue |
	storage := self namedObject.
	firstId := storage objectIdNamed: 'sample'.
	lastValue := Object new.
	lastId := storage addNewObject: lastValue.
	storage objectAt: firstId.
	storage objectNamed: 'sample'.
	storage nameObjectAt: firstId as: 'older'.
	storage rename: 'older' to: 'oldest'.
	self assert: storage lastObject identicalTo: lastValue.
	self assert: storage objectIds asArray equals: { firstId. lastId }.
	^ storage
]

{ #category : 'examples - names' }
GtObjectStorageExamples >> missingAndInvalidNames [
	<gtExample>
	<return: #GtObjectStorage>
	| storage id |
	storage := self newObjectStorage.
	id := storage addNewObject: Object new.
	self should: [ storage nameObjectAt: id as: '' ] raise: Error.
	self should: [ storage nameObjectAt: id as: nil ] raise: Error.
	self should: [ storage nameObjectAt: UUID new asString36 as: 'missing' ] raise: KeyNotFound.
	self assert: storage names isEmpty.
	self assert: (storage objectNamed: 'missing' ifAbsent: [ #absent ]) equals: #absent.
	self should: [ storage objectNamed: 'missing' ] raise: NotFound.
	self should: [ storage rename: 'missing' to: 'new' ] raise: KeyNotFound.
	self should: [ storage removeName: 'missing' ] raise: KeyNotFound.
	storage nameObjectAt: id as: 'Name'.
	self deny: (storage includesName: 'name').
	^ storage
]

{ #category : 'examples - names' }
GtObjectStorageExamples >> nameCollisionsDoNotOverwrite [
	<gtExample>
	<return: #GtObjectStorage>
	| storage firstId secondId |
	storage := self namedObject.
	firstId := storage objectIdNamed: 'sample'.
	secondId := storage addNewObject: Object new.
	self should: [ storage nameObjectAt: secondId as: 'sample' ] raise: Error.
	self assert: (storage objectIdNamed: 'sample') equals: firstId.
	storage nameObjectAt: secondId as: 'other'.
	self should: [ storage rename: 'other' to: 'sample' ] raise: Error.
	self assert: (storage objectIdNamed: 'other') equals: secondId.
	self assert: (storage objectIdNamed: 'sample') equals: firstId.
	^ storage
]

{ #category : 'examples - names' }
GtObjectStorageExamples >> namedObject [
	<gtExample>
	<return: #GtObjectStorage>
	| storage value id entry |
	storage := self newObjectStorage.
	value := Object new.
	id := storage addNewObject: value.
	entry := storage storedObjectAt: id.
	self assert: entry name isNil.
	storage nameObjectAt: id as: 'sample'.
	self assert: entry name equals: 'sample'.
	self assert: (storage objectNamed: 'sample') identicalTo: value.
	self assert: (storage objectIdNamed: 'sample') equals: id.
	self assert: (storage includesName: 'sample').
	self assert: storage names asSet equals: #('sample') asSet.
	storage nameObjectAt: id as: 'sample'.
	self assert: storage objectCount equals: 1.
	^ storage
]

{ #category : 'examples - names' }
GtObjectStorageExamples >> namesAreCopied [
	<gtExample>
	<return: #GtObjectStorage>
	| storage id input returned |
	storage := self newObjectStorage.
	id := storage addNewObject: Object new.
	input := 'sample' copy.
	storage nameObjectAt: id as: input.
	input at: 1 put: $X.
	returned := (storage storedObjectAt: id) name.
	returned at: 1 put: $Y.
	self assert: (storage includesName: 'sample').
	self assert: (storage storedObjectAt: id) name equals: 'sample'.
	^ storage
]

{ #category : 'examples' }
GtObjectStorageExamples >> newObjectStorage [
	<gtExample>
	<return: #GtObjectStorage>
	| storage |
	storage := GtObjectStorage new.
	self assert: storage class equals: GtObjectStorage.
	self assert: storage objectCount equals: 0.
	self assert: storage names isEmpty.
	self deny: storage hasLastObject.
	self assert: (storage lastObjectIfAbsent: [ #missing ]) equals: #missing.
	self should: [ storage lastObject ] raise: NotFound.
	^ storage
]

{ #category : 'examples - last' }
GtObjectStorageExamples >> nilIsAStoredLastObject [
	<gtExample>
	<return: #GtObjectStorage>
	| storage id |
	storage := self newObjectStorage.
	storage addNewObject: Object new.
	id := storage addNewObject: nil.
	storage nameObjectAt: id as: 'nil'.
	self assert: storage hasLastObject.
	self assert: storage lastObject isNil.
	self assert: (storage lastObjectIfAbsent: [ self fail ]) isNil.
	self assert: (storage objectNamed: 'nil' ifAbsent: [ self fail ]) isNil.
	^ storage
]

{ #category : 'examples' }
GtObjectStorageExamples >> objectCountTracksAddedObjects [
	<gtExample>
	<return: #GtObjectStorage>
	| storage first second |
	storage := self newObjectStorage.
	first := Object new.
	second := Object new.
	storage addNewObject: first.
	self assert: storage lastObject identicalTo: first.
	storage addNewObject: second.
	self assert: storage objectCount equals: 2.
	self assert: storage lastObject identicalTo: second.
	^ storage
]

{ #category : 'examples - removal' }
GtObjectStorageExamples >> removingLastSelectsPreviousObject [
	<gtExample>
	<return: #GtObjectStorage>
	| storage firstId secondId thirdId first second third |
	storage := self newObjectStorage.
	first := Object new.
	second := Object new.
	third := Object new.
	firstId := storage addNewObject: first.
	secondId := storage addNewObject: second.
	thirdId := storage addNewObject: third.
	self assert: storage objectIds asArray equals: { firstId. secondId. thirdId }.
	self assert: storage lastObject identicalTo: third.
	storage removeObjectAt: thirdId.
	self assert: storage lastObject identicalTo: second.
	storage removeObjectAt: secondId.
	self assert: storage lastObject identicalTo: first.
	storage removeObjectAt: firstId.
	self deny: storage hasLastObject.
	self should: [ storage lastObject ] raise: NotFound.
	^ storage
]

{ #category : 'examples - removal' }
GtObjectStorageExamples >> removingObjectsCleansNamesAndLast [
	<gtExample>
	<return: #GtObjectStorage>
	| storage oldId lastId lastValue |
	storage := self namedObject.
	oldId := storage objectIdNamed: 'sample'.
	lastValue := Object new.
	lastId := storage addNewObject: lastValue.
	storage nameObjectAt: lastId as: 'last'.
	storage removeObjectAt: oldId.
	self assert: storage names asSet equals: #('last') asSet.
	self assert: storage lastObject identicalTo: lastValue.
	storage removeObjectAt: lastId.
	self assert: storage names isEmpty.
	self deny: storage hasLastObject.
	self assert: (storage removeObjectAt: lastId ifAbsent: [ #absent ]) equals: #absent.
	self should: [ storage removeObjectAt: lastId ] raise: NotFound.
	^ storage
]

{ #category : 'examples - names' }
GtObjectStorageExamples >> renameAndRemoveName [
	<gtExample>
	<return: #GtObjectStorage>
	| storage id value entry |
	storage := self namedObject.
	id := storage objectIdNamed: 'sample'.
	value := storage objectNamed: 'sample'.
	entry := storage storedObjectAt: id.
	storage rename: 'sample' to: 'renamed'.
	self deny: (storage includesName: 'sample').
	self assert: entry name equals: 'renamed'.
	self assert: (storage objectIdNamed: 'renamed') equals: id.
	self assert: (storage objectNamed: 'renamed') identicalTo: value.
	storage rename: 'renamed' to: 'renamed'.
	storage removeName: 'renamed'.
	self assert: entry name isNil.
	self deny: (storage includesName: 'renamed').
	self deny: (storage includesName: nil).
	self assert: storage names isEmpty.
	self assert: (storage objectAt: id) identicalTo: value.
	self assert: storage lastObject identicalTo: value.
	^ storage
]

{ #category : 'examples' }
GtObjectStorageExamples >> storedObjectIncludesIdAndValue [
	<gtExample>
	<return: #GtStoredObject>
	| storage value id entry |
	storage := self newObjectStorage.
	value := Object new.
	id := storage addNewObject: value.
	entry := storage storedObjectAt: id.
	self assert: entry class equals: GtStoredObject.
	self assert: entry id equals: (UUID fromString36: id).
	self assert: entry idString36 equals: id.
	self assert: entry value identicalTo: value.
	^ entry
]
