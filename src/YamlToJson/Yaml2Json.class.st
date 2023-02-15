Class {
	#name : #Yaml2Json,
	#superclass : #Object,
	#category : #YamlToJson
}

{ #category : #'flutter specific' }
Yaml2Json >> convertPubSpecLockToJson: aString [

	"convert the Yaml of a pubspec.lock file to a json file"

	| lines parsed parts spaces opening openCounter json finalTable yamlString originalLines |
	"Split the YAML string into lines""remove comment lines (strating with #"
	yamlString := aString.

	"Initialize a dictionary to store the parsed content"
	parsed := OrderedCollection new.

	originalLines := yamlString lines collect: [ :line | 
		                 self removeComment: line ].


	"removing comment line"
	lines := originalLines select: [ :each | 
		         (each matchesRegex: '^#.*') not & each isNotEmpty ].

	"Iterate over each line"
	lines do: [ :line | "split over : and check if there is more than one element"
		parts := ':' split: line.
		parts size > 1 ifTrue: [ 
			parsed add: (OrderedCollection
					 with: parts first
					 with: ':'
					 with: (line allButFirst: parts first size + 1)) ] ].

	spaces := 0.
	opening := 0.

	openCounter := 0.

	finalTable := OrderedCollection new.

	parsed do: [ :line | 
		| closing |
		closing := false.

		"check if the spaces are diminishing, indicating a the end of a block"
		spaces := (line first select: [ :char | char isSpaceSeparator ])
			          size.
		[ opening > spaces ] whileTrue: [ 
			line addFirst: '},'.
			openCounter := openCounter - 1.
			opening := opening - 2 ].


		"if the last element is empty, it means the a block is opening"
		line last = ''
			ifTrue: [ "if not, then we add a coma"
				line at: line size put: '{'.
				openCounter := openCounter + 1.
				opening := opening + 2 ]
			ifFalse: [ line add: ',' ].

		finalTable add: (line collect: [ :each | 
				 | temp c |
				 temp := each asString trim.
				 c := temp first. 
				 c = $' ifTrue: [ 
					 temp := '"' , temp allButFirst allButLast , '"'.
					 c := temp first ].
				 c = $, | (c = $:) | (c = ${) | (c = $}) | (c = $") ifFalse: [ 
					 temp := '"' , temp , '"' ].
				
				 "(temp at: 1) isLetter ifTrue: [ temp := '""' , temp , '""' ]."
				 temp ]) ].

	"create the json string"
	json := '{'.
	finalTable do: [ :line | line do: [ :each | json := json , each ] ].
	openCounter timesRepeat: [ json := json , '}' ].
	json := json , '}'.

	json := json replaceAllRegex: ',}' with: '}'.


	^ json
]

{ #category : #'flutter specific' }
Yaml2Json >> convertPubSpecYamlToJson: aString [

	"convert the Yaml of a pubspec.yaml file to a json file"

	| lines parsed parts spaces opening openCounter json finalTable yamlString originalLines |
	yamlString := self refactoreTab: (self refactoreMultiline: aString).
	"Split the YAML string into lines"
	"remove comment lines (strating with #"
	originalLines := yamlString lines collect: [ :line | 
		                 self removeComment: line ].



	"Initialize a dictionary to store the parsed content"
	parsed := OrderedCollection new.

	"removing comment line"
	lines := originalLines select: [ :each | 
		         (each matchesRegex: '^#.*') not & each isNotEmpty ].

	"Iterate over each line"
	lines do: [ :line | 
		| data |
		"split over : and check if there is more than one element"
		parts := ':' split: line.

		parts size > 1
			ifTrue: [ 
				data := (line allButFirst: parts first size + 1) trim.
				(data isNotEmpty and: [ data first = $" ]) ifFalse: [ 
					data := data replaceAllRegex: '\"' with: '\"' ].
				parsed add:
					(OrderedCollection with: parts first with: ':' with: data) ]
			ifFalse: [ 
				(line matchesRegex: '^\W*-.*') ifTrue: [ 
					parsed last last = ''
						ifTrue: [ parsed last at: parsed last size put: line trim ]
						ifFalse: [ parsed last addLast: line trim ] ] ] ].

	spaces := 0.
	opening := 0.

	openCounter := 0.

	finalTable := OrderedCollection new.

	parsed do: [ :line | 
		| closing startArray tline |
		closing := false.
		startArray := false.

		"check if the spaces are diminishing, indicating a the end of a block"
		spaces := (line first select: [ :char | char isSpaceSeparator ])
			          size.
		[ opening > spaces ] whileTrue: [ 
			line addFirst: '},'.
			openCounter := openCounter - 1.
			opening := opening - 2 ].

		"if the line start with a - then start an array"
		tline := OrderedCollection new.
		line do: [ :each | 
			tline add: each.
			(each isNotEmpty and: [ each first = $- ]) ifTrue: [ 
				startArray ifFalse: [ 
					tline add: '[' before: each.
					startArray := true ].
				tline add: ',' ] ].
		startArray ifTrue: [ 
			tline addLast: ']'.
			startArray := false ].


		"if the last element is empty, it means the a block is opening"
		tline last = ''
			ifTrue: [ "if not, then we add a coma"
				tline at: tline size put: '{'.
				openCounter := openCounter + 1.
				opening := opening + 2 ]
			ifFalse: [ tline add: ',' ].

		finalTable add: (tline collect: [ :each | 
				 | temp c |
				 temp := each asString trim.
				 c := temp first.
				 c = $' ifTrue: [ 
					 temp := '"' , temp allButFirst allButLast , '"'.
					 c := temp first ].
				 "converti yaml value to json values except when observing a key symbol"
				 ({ $:. $,. $[. $]. ${. $}. $" } anySatisfy: [ :char | char = c ]) 
					 ifFalse: [ temp := '"' , temp , '"' ].
				 temp ]) ].





	"create the json string"
	json := '{'.
	finalTable do: [ :line | line do: [ :each | json := json , each ] ].
	openCounter timesRepeat: [ json := json , '}' ].
	json := json , '}'.

	json := json replaceAllRegex: ',}' with: '}'.
	json := json replaceAllRegex: ',]' with: ']'.

	^ json
]

{ #category : #removing }
Yaml2Json >> hasComment: aString [

	"take one line of yaml and remove its eventual comments"

	^ (('.*#.*' asRegex matches: aString) and: [ ('.*".*#.*".*' asRegex matches: aString) not ] )
]

{ #category : #removing }
Yaml2Json >> refactoreMultiline: aString [

	"in yaml, transform a : >- \n b to :: a : b"

	| reg res substitute |
	reg := '\:\s*>-\s*' asMyRegex.
	"the substitute that will be apply in case of a match"
	substitute := String streamContents: [ :str | str << ': ' ].

	res := String streamContents: [ :out | 
		       aString readStreamDo: [ :stream | 
			       reg
				       copyStream: stream
				       to: out
				       replacingMatchesWith: substitute ] ].
	^ res
]

{ #category : #removing }
Yaml2Json >> refactoreTab: aString [

	"in yaml, transform a : [b] ::> a : ""[b]"" "

	| reg res l |
	l := ''.
	aString lines do: [ :line | "the substitute that will be apply in case of a match"
		reg := '\[(.*)\]' asMyRegex.

		res := String streamContents: [ :out | 
			       line readStreamDo: [ :stream | 
				       reg
					       copyStream: stream
					       to: out
					       replacingMatchesWith: '"[{1}]"' ] ].
		l := l , res , OSPlatform current lineEnding ].
	^ l
]

{ #category : #removing }
Yaml2Json >> removeComment: aString [

	"take one line of yaml and remove its eventual comments"
	(self hasComment: aString )
	ifTrue: [ ^ aString replaceAllRegex: '#.*' with: '' ]
	ifFalse: [ ^ aString ].
	
]

{ #category : #removing }
Yaml2Json >> removeComments: aString [

	"take the yaml as a string and remove its comments"

	^ aString lines collect: [ :line | 
		  self removeComment: line , Character cr asString ]
]
