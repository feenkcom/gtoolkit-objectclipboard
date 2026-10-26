Class {
	#name : 'GtObjectClipboardExamples',
	#superclass : 'Object',
	#traits : 'TAssertable',
	#classTraits : 'TAssertable classTrait',
	#category : 'GToolkit-ObjectClipboard-Examples',
	#package : 'GToolkit-ObjectClipboard',
	#tag : 'Examples'
}

{ #category : 'examples' }
GtObjectClipboardExamples >> accessingObjectReturnsStoredObject [
	<gtExample>
	<return: #GtStoredClipboardObject>
	| clipboard object id presentObject entry |
	clipboard := self newObjectClipboard.
	object := Object new.
	id := clipboard addNewObject: object.
	self assert: (clipboard objectAt: id) identicalTo: object.
	presentObject := clipboard objectAt: id ifPresent: [ :found | found ] ifAbsent: [ self fail ].
	self assert: presentObject identicalTo: object.
	entry := clipboard storedObjectAt: id.
	self assert: entry value identicalTo: object.
	self assert: entry id equals: (UUID fromString36: id).
	^ entry
]

{ #category : 'examples' }
GtObjectClipboardExamples >> accessingObjectThatIsMissingReturnsMissing [
	<gtExample>
	<return: #String>
	| objectClipboard absentResult |
	
	objectClipboard := self newObjectClipboard.
	absentResult := objectClipboard
		objectAt: UUID new asString36
		ifPresent: [ 'present' ]
		ifAbsent: [ 'missing' ].
	self assert: absentResult equals: 'missing'.
	
	^ absentResult
]

{ #category : 'examples - names' }
GtObjectClipboardExamples >> addNewNilObjectNamed [
	<gtExample>
	<return: #GtObjectClipboard>
	| clipboard id |
	clipboard := self newObjectClipboard.
	id := clipboard addNewObject: nil named: 'nothing'.
	self assert: (clipboard objectNamed: 'nothing' ifAbsent: [ self fail ]) isNil.
	self assert: (clipboard objectIdNamed: 'nothing') equals: id.
	self assert: clipboard hasLastObject.
	self assert: clipboard lastObject isNil.
	^ clipboard
]

{ #category : 'examples - names' }
GtObjectClipboardExamples >> addNewObjectNamed [
	<gtExample>
	<return: #GtObjectClipboard>
	| clipboard value id announcements |
	clipboard := self newObjectClipboard.
	value := Object new.
	announcements := OrderedCollection new.
	clipboard announcer when: GtObjectClipboardContentChangeAnnouncement
		do: [ :each |
			self assert: each storedObject name equals: 'sample'.
			self assert: (clipboard objectNamed: 'sample') identicalTo: value.
			announcements add: each ] for: announcements.
	id := clipboard addNewObject: value named: 'sample'.
	self assert: id isString.
	self assert: (clipboard objectIdNamed: 'sample') equals: id.
	self assert: (clipboard objectAt: id) identicalTo: value.
	self assert: (clipboard storedObjectAt: id) name equals: 'sample'.
	self assert: clipboard lastObject identicalTo: value.
	self assert: clipboard objectCount equals: 1.
	self assert: announcements size equals: 1.
	self assert: announcements first class equals: GtObjectClipboardObjectAddedAnnouncement.
	^ clipboard
]

{ #category : 'examples - names' }
GtObjectClipboardExamples >> addNewObjectNamedRejectsInvalidNamesWithoutInsertion [
	<gtExample>
	<return: #GtObjectClipboard>
	| clipboard id value announcements |
	clipboard := self namedObject.
	id := clipboard objectIdNamed: 'sample'.
	value := clipboard lastObject.
	announcements := OrderedCollection new.
	clipboard announcer when: GtObjectClipboardContentChangeAnnouncement
		do: [ :each | announcements add: each ] for: announcements.
	self should: [ clipboard addNewObject: Object new named: 'sample' ] raise: Error.
	self should: [ clipboard addNewObject: Object new named: '' ] raise: Error.
	self should: [ clipboard addNewObject: Object new named: nil ] raise: Error.
	self should: [ clipboard addNewObject: Object new named: 42 ] raise: Error.
	self assert: clipboard objectCount equals: 1.
	self assert: (clipboard objectIdNamed: 'sample') equals: id.
	self assert: clipboard lastObject identicalTo: value.
	self assert: announcements isEmpty.
	^ clipboard
]

{ #category : 'examples' }
GtObjectClipboardExamples >> addObjectAnswersId [
	<gtExample>
	<return: #GtObjectClipboard>
	| clipboard id value entry |
	clipboard := self newObjectClipboard.
	value := Object new.
	id := clipboard addNewObject: value.
	entry := clipboard storedObjectAt: id.
	self assert: id isString.
	self assert: (clipboard includesObjectWithId: id).
	self assert: entry class equals: GtStoredClipboardObject.
	self assert: entry id equals: (UUID fromString36: id).
	self assert: entry value identicalTo: value.
	self assert: clipboard lastObject identicalTo: value.
	^ clipboard
]

{ #category : 'examples - announcements' }
GtObjectClipboardExamples >> addingObjectAnnouncesEntry [
	<gtExample>
	<return: #GtObjectClipboard>
	| clipboard announcements id |
	clipboard := self newObjectClipboard.
	announcements := OrderedCollection new.
	clipboard announcer when: GtObjectClipboardContentChangeAnnouncement
		do: [ :announcement | announcements add: announcement ] for: announcements.
	id := clipboard addNewObject: Object new.
	self assert: announcements size equals: 1.
	self assert: announcements first class equals: GtObjectClipboardObjectAddedAnnouncement.
	self assert: announcements first objectClipboard identicalTo: clipboard.
	self assert: announcements first storedObject identicalTo: (clipboard storedObjectAt: id).
	self assert: clipboard lastObject identicalTo: announcements first storedObject value.
	^ clipboard
]

{ #category : 'examples' }
GtObjectClipboardExamples >> addingSameObjectTwiceAddsTwoObjects [
	<gtExample>
	<return: #GtObjectClipboard>
	| clipboard value firstId secondId |
	clipboard := self newObjectClipboard.
	value := Object new.
	firstId := clipboard addNewObject: value.
	secondId := clipboard addNewObject: value.
	self deny: firstId equals: secondId.
	self assert: clipboard objectCount equals: 2.
	self assert: (clipboard objectAt: firstId) identicalTo: value.
	self assert: (clipboard objectAt: secondId) identicalTo: value.
	self assert: clipboard objectIds asArray equals: { firstId. secondId }.
	self assert: clipboard lastObject identicalTo: value.
	^ clipboard
]

{ #category : 'examples - names' }
GtObjectClipboardExamples >> assigningNameReplacesPreviousName [
	<gtExample>
	<return: #GtObjectClipboard>
	| clipboard id value |
	clipboard := self namedObject.
	id := clipboard objectIdNamed: 'sample'.
	value := clipboard objectNamed: 'sample'.
	clipboard nameObjectAt: id as: 'replacement'.
	self deny: (clipboard includesName: 'sample').
	self assert: (clipboard objectNamed: 'replacement') identicalTo: value.
	self assert: (clipboard storedObjectAt: id) name equals: 'replacement'.
	self assert: clipboard names asArray equals: #('replacement').
	self assert: clipboard objectCount equals: 1.
	self assert: clipboard lastObject identicalTo: value.
	^ clipboard
]

{ #category : 'examples - baseline' }
GtObjectClipboardExamples >> baselineIncludesObjectClipboard [
	<gtExample>
	| project |
	project := BaselineOfGToolkitObjectClipboard project.
	self assert: (project version: 'baseline') notNil.
	self assert: ((project version: 'baseline') packages
		anySatisfy: [ :each | each name = 'GToolkit-ObjectClipboard' ]).
	^ project
]

{ #category : 'as yet unclassified' }
GtObjectClipboardExamples >> clearClipboardAction [
	<gtExample>
	<return: #GtObjectClipboard>
	| clipboard action announcements |
	clipboard := self namedObject.
	clipboard addNewObject: Object new.
	announcements := OrderedCollection new.
	clipboard announcer when: GtObjectClipboardContentChangeAnnouncement
		do: [ :each | announcements add: each ] for: announcements.
	action := clipboard gtActionClearFor: GtPhlowAction new.
	self assert: clipboard objectCount equals: 2.
	self assert: announcements isEmpty.
	action performActionOn: nil.
	self assert: clipboard objectCount equals: 0.
	self assert: clipboard names isEmpty.
	self deny: clipboard hasLastObject.
	self assert: announcements size equals: 1.
	self assert: announcements first objectClipboard identicalTo: clipboard.
	action performActionOn: nil.
	self assert: clipboard objectCount equals: 0.
	^ clipboard
]

{ #category : 'as yet unclassified' }
GtObjectClipboardExamples >> clearClipboardRemovesObjects [
	<gtExample>
	<return: #GtObjectClipboard>
	| clipboard id |
	clipboard := self namedObject.
	id := clipboard objectIdNamed: 'sample'.
	clipboard clearCache.
	self assert: clipboard objectCount equals: 0.
	self deny: (clipboard includesObjectWithId: id).
	self assert: clipboard names isEmpty.
	self deny: clipboard hasLastObject.
	self should: [ clipboard lastObject ] raise: NotFound.
	^ clipboard
]

{ #category : 'as yet unclassified' }
GtObjectClipboardExamples >> contentChangesAnnounceClipboard [
	<gtExample>
	<return: #GtObjectClipboard>
	| clipboard announcements id |
	clipboard := self newObjectClipboard.
	id := clipboard addNewObject: Object new.
	announcements := OrderedCollection new.
	clipboard announcer when: GtObjectClipboardContentChangeAnnouncement
		do: [ :announcement | announcements add: announcement ] for: announcements.
	clipboard nameObjectAt: id as: 'sample'.
	clipboard rename: 'sample' to: 'renamed'.
	clipboard removeName: 'renamed'.
	clipboard removeObjectAt: id.
	clipboard clearCache.
	self assert: announcements size equals: 5.
	announcements do: [ :each |
		self assert: each class equals: GtObjectClipboardContentChangeAnnouncement.
		self assert: each objectClipboard identicalTo: clipboard ].
	^ clipboard
]

{ #category : 'examples - last' }
GtObjectClipboardExamples >> lookupAndNamingPreserveLastObject [
	<gtExample>
	<return: #GtObjectClipboard>
	| clipboard firstId lastId lastValue |
	clipboard := self namedObject.
	firstId := clipboard objectIdNamed: 'sample'.
	lastValue := Object new.
	lastId := clipboard addNewObject: lastValue.
	clipboard objectAt: firstId.
	clipboard objectNamed: 'sample'.
	clipboard nameObjectAt: firstId as: 'older'.
	clipboard rename: 'older' to: 'oldest'.
	self assert: clipboard lastObject identicalTo: lastValue.
	self assert: clipboard objectIds asArray equals: { firstId. lastId }.
	^ clipboard
]

{ #category : 'examples - names' }
GtObjectClipboardExamples >> missingAndInvalidNames [
	<gtExample>
	<return: #GtObjectClipboard>
	| clipboard id |
	clipboard := self newObjectClipboard.
	id := clipboard addNewObject: Object new.
	self should: [ clipboard nameObjectAt: id as: '' ] raise: Error.
	self should: [ clipboard nameObjectAt: id as: nil ] raise: Error.
	self should: [ clipboard nameObjectAt: UUID new asString36 as: 'missing' ] raise: KeyNotFound.
	self assert: clipboard names isEmpty.
	self assert: (clipboard objectNamed: 'missing' ifAbsent: [ #absent ]) equals: #absent.
	self should: [ clipboard objectNamed: 'missing' ] raise: NotFound.
	self should: [ clipboard rename: 'missing' to: 'new' ] raise: KeyNotFound.
	self should: [ clipboard removeName: 'missing' ] raise: KeyNotFound.
	clipboard nameObjectAt: id as: 'Name'.
	self deny: (clipboard includesName: 'name').
	^ clipboard
]

{ #category : 'examples - names' }
GtObjectClipboardExamples >> nameCollisionsDoNotOverwrite [
	<gtExample>
	<return: #GtObjectClipboard>
	| clipboard firstId secondId |
	clipboard := self namedObject.
	firstId := clipboard objectIdNamed: 'sample'.
	secondId := clipboard addNewObject: Object new.
	self should: [ clipboard nameObjectAt: secondId as: 'sample' ] raise: Error.
	self assert: (clipboard objectIdNamed: 'sample') equals: firstId.
	clipboard nameObjectAt: secondId as: 'other'.
	self should: [ clipboard rename: 'other' to: 'sample' ] raise: Error.
	self assert: (clipboard objectIdNamed: 'other') equals: secondId.
	self assert: (clipboard objectIdNamed: 'sample') equals: firstId.
	^ clipboard
]

{ #category : 'examples - names' }
GtObjectClipboardExamples >> namedObject [
	<gtExample>
	<return: #GtObjectClipboard>
	| clipboard value id entry |
	clipboard := self newObjectClipboard.
	value := Object new.
	id := clipboard addNewObject: value.
	entry := clipboard storedObjectAt: id.
	self assert: entry name isNil.
	clipboard nameObjectAt: id as: 'sample'.
	self assert: entry name equals: 'sample'.
	self assert: (clipboard objectNamed: 'sample') identicalTo: value.
	self assert: (clipboard objectIdNamed: 'sample') equals: id.
	self assert: (clipboard includesName: 'sample').
	self assert: clipboard names asSet equals: #('sample') asSet.
	clipboard nameObjectAt: id as: 'sample'.
	self assert: clipboard objectCount equals: 1.
	^ clipboard
]

{ #category : 'examples - names' }
GtObjectClipboardExamples >> namesAreCopied [
	<gtExample>
	<return: #GtObjectClipboard>
	| clipboard id input returned |
	clipboard := self newObjectClipboard.
	id := clipboard addNewObject: Object new.
	input := 'sample' copy.
	clipboard nameObjectAt: id as: input.
	input at: 1 put: $X.
	returned := (clipboard storedObjectAt: id) name.
	returned at: 1 put: $Y.
	self assert: (clipboard includesName: 'sample').
	self assert: (clipboard storedObjectAt: id) name equals: 'sample'.
	^ clipboard
]

{ #category : 'as yet unclassified' }
GtObjectClipboardExamples >> newObjectClipboard [
	<gtExample>
	<return: #GtObjectClipboard>
	| clipboard |
	clipboard := GtObjectClipboard new.
	self assert: clipboard class equals: GtObjectClipboard.
	self assert: clipboard objectCount equals: 0.
	self assert: clipboard names isEmpty.
	self deny: clipboard hasLastObject.
	self assert: (clipboard lastObjectIfAbsent: [ #missing ]) equals: #missing.
	self should: [ clipboard lastObject ] raise: NotFound.
	^ clipboard
]

{ #category : 'examples - last' }
GtObjectClipboardExamples >> nilIsAStoredLastObject [
	<gtExample>
	<return: #GtObjectClipboard>
	| clipboard id |
	clipboard := self newObjectClipboard.
	clipboard addNewObject: Object new.
	id := clipboard addNewObject: nil.
	clipboard nameObjectAt: id as: 'nil'.
	self assert: clipboard hasLastObject.
	self assert: clipboard lastObject isNil.
	self assert: (clipboard lastObjectIfAbsent: [ self fail ]) isNil.
	self assert: (clipboard objectNamed: 'nil' ifAbsent: [ self fail ]) isNil.
	^ clipboard
]

{ #category : 'examples' }
GtObjectClipboardExamples >> objectCountTracksAddedObjects [
	<gtExample>
	<return: #GtObjectClipboard>
	| clipboard first second |
	clipboard := self newObjectClipboard.
	first := Object new.
	second := Object new.
	clipboard addNewObject: first.
	self assert: clipboard lastObject identicalTo: first.
	clipboard addNewObject: second.
	self assert: clipboard objectCount equals: 2.
	self assert: clipboard lastObject identicalTo: second.
	^ clipboard
]

{ #category : 'examples - removal' }
GtObjectClipboardExamples >> removingLastSelectsPreviousObject [
	<gtExample>
	<return: #GtObjectClipboard>
	| clipboard firstId secondId thirdId first second third |
	clipboard := self newObjectClipboard.
	first := Object new.
	second := Object new.
	third := Object new.
	firstId := clipboard addNewObject: first.
	secondId := clipboard addNewObject: second.
	thirdId := clipboard addNewObject: third.
	self assert: clipboard objectIds asArray equals: { firstId. secondId. thirdId }.
	self assert: clipboard lastObject identicalTo: third.
	clipboard removeObjectAt: thirdId.
	self assert: clipboard lastObject identicalTo: second.
	clipboard removeObjectAt: secondId.
	self assert: clipboard lastObject identicalTo: first.
	clipboard removeObjectAt: firstId.
	self deny: clipboard hasLastObject.
	self should: [ clipboard lastObject ] raise: NotFound.
	^ clipboard
]

{ #category : 'examples - removal' }
GtObjectClipboardExamples >> removingObjectsCleansNamesAndLast [
	<gtExample>
	<return: #GtObjectClipboard>
	| clipboard oldId lastId lastValue |
	clipboard := self namedObject.
	oldId := clipboard objectIdNamed: 'sample'.
	lastValue := Object new.
	lastId := clipboard addNewObject: lastValue.
	clipboard nameObjectAt: lastId as: 'last'.
	clipboard removeObjectAt: oldId.
	self assert: clipboard names asSet equals: #('last') asSet.
	self assert: clipboard lastObject identicalTo: lastValue.
	clipboard removeObjectAt: lastId.
	self assert: clipboard names isEmpty.
	self deny: clipboard hasLastObject.
	self assert: (clipboard removeObjectAt: lastId ifAbsent: [ #absent ]) equals: #absent.
	self should: [ clipboard removeObjectAt: lastId ] raise: NotFound.
	^ clipboard
]

{ #category : 'examples - names' }
GtObjectClipboardExamples >> renameAndRemoveName [
	<gtExample>
	<return: #GtObjectClipboard>
	| clipboard id value entry |
	clipboard := self namedObject.
	id := clipboard objectIdNamed: 'sample'.
	value := clipboard objectNamed: 'sample'.
	entry := clipboard storedObjectAt: id.
	clipboard rename: 'sample' to: 'renamed'.
	self deny: (clipboard includesName: 'sample').
	self assert: entry name equals: 'renamed'.
	self assert: (clipboard objectIdNamed: 'renamed') equals: id.
	self assert: (clipboard objectNamed: 'renamed') identicalTo: value.
	clipboard rename: 'renamed' to: 'renamed'.
	clipboard removeName: 'renamed'.
	self assert: entry name isNil.
	self deny: (clipboard includesName: 'renamed').
	self deny: (clipboard includesName: nil).
	self assert: clipboard names isEmpty.
	self assert: (clipboard objectAt: id) identicalTo: value.
	self assert: clipboard lastObject identicalTo: value.
	^ clipboard
]

{ #category : 'examples' }
GtObjectClipboardExamples >> storedObjectIncludesIdAndValue [
	<gtExample>
	<return: #GtStoredClipboardObject>
	| clipboard value id entry |
	clipboard := self newObjectClipboard.
	value := Object new.
	id := clipboard addNewObject: value.
	entry := clipboard storedObjectAt: id.
	self assert: entry class equals: GtStoredClipboardObject.
	self assert: entry id equals: (UUID fromString36: id).
	self assert: entry idString36 equals: id.
	self assert: entry value identicalTo: value.
	^ entry
]
