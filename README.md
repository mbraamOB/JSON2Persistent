# JSON2Persistent
Little tool to create persistent or message classes for InterSystems IRIS and InterSystems IRIS For Health from JSON input

This little tool can be leveraged to create peristent classes or InterSystems IRIS and InterSystems IRIS For Health message classes from JSON files or JSON streams.
This can be helpful if you receive JSON input and you have to further process it in InterSystems IRIS or InterSystems IRIS For Health.

The generated classes extend %JSON.Adaptor and once you have created the persistent schema, it is easy to wokr with the JSON input or just save it in InterSystems IRIS.

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

## Docker support
### Prerequisites
Make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.
### Installation 
Clone/git pull the repo into any local directory      
```
 git clone https://github.com/mbraamOB/JSON2Persistent.git     
```
Open the terminal in this directory and run:     
```
 docker-compose up -d    
```
## How to Test it   
Open IRIS terminal:   
```
 docker-compose exec iris iris session iris ##class(ISC.SE.Tools.JSON).TestImport()
````
And observe the execution of the example
~~~
Load Status: 1
file opened, file length: 230
dynamic Object successfully created!
tTree(1,"sring_property_1")=$lb("string","This is a string")
tTree(2,"numeric_property_2")=$lb("number",3.1)
tTree(3,"boolean_property_3")=$lb("boolean","1")
tTree(4,"obj_property_4")=$lb("object","7@%Library.DynamicObject")
tTree(4,"obj_property_4",1,"property_1")=$lb("string","value_1")
tTree(4,"obj_property_4",2,"property_2")=$lb("array","6@%Library.DynamicArray","tFirstmember")

building class: Sample.Import.ExampleImport
adding property : sring_property_1 with type: string
adding property : numeric_property_2 with type: number
adding property : boolean_property_3 with type: boolean
adding object-reference for property: obj_property_4
building class: Sample.Import.ExampleImport.objproperty4
adding property : property_1 with type: string
classes generated!
Compilation started on 07/14/2021 18:50:30 with qualifiers 'crk'
Compiling 2 classes
Compiling class Sample.Import.ExampleImport.objproperty4
Compiling class Sample.Import.ExampleImport
Compiling table Sample_Import_ExampleImport.objproperty4
Compiling table Sample_Import.ExampleImport
Compiling routine Sample.Import.ExampleImport.objproperty4.1
Compiling routine Sample.Import.ExampleImport.1
Compilation finished successfully in 0.195s.

Made New Class

Parsing Tested and complete
~~~

To REST API Enable:
1.	Goto to management portal Home
2.	Change to namespace with JSON tool
3.	Create Web Application
4.	Choose a name for your REST-Application
5.  Set the Dispatch Class to "REST.SE.REST.JSON"

