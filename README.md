# JSON2Persistent
Little tool to create persistent or message classes for InterSystems IRIS and InterSystems IRIS For Health from JSON input

This little tool can be leveraged to create peristent classes or InterSystems IRIS and InterSystems IRIS For Health message classes from JSON files or JSON streams.
This can be helpful if you receive JSON input and you have to further process it in InterSystems IRIS or InterSystems IRIS For Health.

The generated classes extend %JSON.Adaptor and once you have created the persistent schema, it is easy to wokr with the JSON input or just save it in INterSystems IRIS.

The generator currently supports the following features.

-	a persistent class definition will be created from a *JSON* object {…}
-	embededd objects will be mapped to a object reference and a persistent class definition will be recursively created from the embedded object
-	an *array of objects* will be mapped recursively tp parent/child relationships
-	an *array of literal values* will be mapped to a *list* of %String
-	JSON datatype *string* -> *%String*
-	JSON datatype *number* -> *%Numeric*. The scale will be calculated from a sample record
-	JSON datatype *boolean* -> *%Boolean*

The generator provides a couple of sample methods:
- *runGenerator()*. This method demonstrates how to create a persistent schema from a sample JSON file
- *loadData()* demonstrates how to load data from a JSON file into a previously created schema
- *TestImport()* combines runGenerator() and loadData()

There are two generateor methods *GenerateClasses* and *GenerateClassesFromStream*. The basically do the same. The first one takes a file as input source, the second one takes a stream as source

- classmethod *GenerateClasses*(pJSONFilename as %String, 
							pRootPackage as %String, 
							pRootClass as %String, 
							pIRISMessageClass as %Boolean = 0, 
							pCompile as %Boolean = 0, 
							pCompileFlags as %String = "crk", 
							pVerbose as %Boolean = 1)

The flag *pIRISMessageClass* controls whether IRIS message classes are created. You can directly use these classes in a interoperability production.
The flag *pCompile* controls whether the newly generated classes are automatically compiled.
							
To use this tool, just load and compile the class *ISC.SE.Tools.JSON.cls* into your namespace.							
