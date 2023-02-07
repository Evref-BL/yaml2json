# yaml2json
Convert yaml (found in flutter project) to json
## Installation

```st
Metacello new
  githubUser: 'Evref-BL' project: 'yaml2json' commitish: 'main' path: 'src';
  baseline: 'YamlToJson';
  load
```

## API 

   Note that this API is a work in progress and will evolve over time. 

```st
y2j := Yaml2Json new. 

"aString is the entire Yaml content of a file"
aString := 'path/to/pubspec.yaml' asFileLocator contents. 

"specfic method to handle the yaml tipically found in pubspec.yaml of a flutter project"
y2j convertPubSpecYamlToJson: aString.

"specfic method to handle the yaml tipically found in pubspec.lock of a flutter project (no syntax differences with yaml, but the file content is easier to parser). "
y2j convertPubSpecLockToJson: aString.
```

