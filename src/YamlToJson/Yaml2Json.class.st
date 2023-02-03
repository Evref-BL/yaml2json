Class {
	#name : #Yaml2Json,
	#superclass : #Object,
	#category : #YamlToJson
}

{ #category : #'flutter specific' }
Yaml2Json >> convertPubSpecLockToJson: aString [

	"convert the Yaml of a pubspec.lock file to a json file"
	

	| lines parsed parts spaces opening openCounter json finalTable yamlString originalLines |
	
	"Split the YAML string into lines"
	"remove comment lines (strating with #"
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
				 | temp |
				 temp := each asString trim.
				 (temp at: 1) isLetter ifTrue: [ temp := '"' , temp , '"' ].
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
	
	yamlString := aString.
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
				 c := temp at: 1.

				 c = $' ifTrue: [ temp := '"' , temp allButFirst allButLast , '"' ].
				 c isLetter | (c = $^) | c isDecimalDigit ifTrue: [ 
					 temp := '"' , temp , '"' ].

				 "c isLetter
					 ifTrue: [ temp := '""' , temp , '""' ]
					 ifFalse: [ 
						 c = '^'
							 ifTrue: [ temp := '""' , temp , '""' ]
							 ifFalse: [ c = '''' ifTrue: [ temp := '""' , temp , '""' ] ] ]."
				 temp ]) ].

	"create the json string"
	json := '{'.
	finalTable do: [ :line | line do: [ :each | json := json , each ] ].
	openCounter timesRepeat: [ json := json , '}' ].
	json := json , '}'.

	json := json replaceAllRegex: ',}' with: '}'.

	^ json
]

{ #category : #'as yet unclassified' }
Yaml2Json >> convertToJson: aString [

	"Split the YAML string into lines"

	| lines parsed parts spaces opening openCounter json finalTable yamlString originalLines |
	"remove comment lines (strating with #"
	yamlString := aString.

	originalLines := yamlString lines collect: [:line | self removeComment: line].
	


	"Initialize a dictionary to store the parsed content"
	parsed := OrderedCollection new.
	
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
				 | temp |
				 temp := each asString trim.
				 (temp at: 1) isLetter ifTrue: [ temp := '"' , temp , '"' ].
				 temp ]) ].

	"create the json string"
	json := '{'.
	finalTable do: [ :line | line do: [ :each | json := json , each ] ].
	openCounter timesRepeat: [ json := json , '}' ].
	json := json , '}'.

	json := json replaceAllRegex: ',}' with: '}'.

	

	^ json
]

{ #category : #removing }
Yaml2Json >> removeComment: aString [

	"take one line of yaml and remove its eventual comments"


	^ aString replaceAllRegex: '#.*' with: ''.

	
]

{ #category : #removing }
Yaml2Json >> removeComments: aString [

	"take the yaml as a string and remove its comments"

	^ aString lines collect: [ :line | 
		  self removeComment: line , Character cr asString ]
]
