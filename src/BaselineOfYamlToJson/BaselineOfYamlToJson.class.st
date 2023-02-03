Class {
	#name : #BaselineOfYamlToJson,
	#superclass : #BaselineOf,
	#category : #BaselineOfYamlToJson
}

{ #category : #baselines }
BaselineOfYamlToJson >> baseline: spec [

	<baseline>
	spec for: #common do: [ 
		self defineDependencies: spec.
		self definePackages: spec.
		self defineGroups: spec ]
]

{ #category : #baselines }
BaselineOfYamlToJson >> defineDependencies: spec [

	
]

{ #category : #baselines }
BaselineOfYamlToJson >> defineGroups: spec [

	
]

{ #category : #baselines }
BaselineOfYamlToJson >> definePackages: spec [

	spec
		package: 'YamlToJson'.

]
