Class ISC.SE.Tools.JSON [ Abstract ]
{

Parameter DeleteRootClassAndPckg As %Boolean = 1;

/// method to generate a class schema fro a JSON input file
ClassMethod GenerateClasses(pJSONFilename As %String, pRootPackage As %String, pRootClass As %String, pIRISMessageClass As %Boolean = 0, pCompile As %Boolean = 0, pCompileFlags As %String = "crk", pVerbose As %Boolean = 1) As %Status
{
	#dim tJSON as %DynamicObject
	#dim tInput as %Stream.FileCharacter
	#dim tSc as %Status = $$$OK
	
	try {
		set tInput = ##class(%Stream.FileCharacter).%New()
		$$$ThrowOnError(tInput.LinkToFile(pJSONFilename))
		write:pVerbose !,"file opened, file length: ",tInput.Size
		set tJSON = ##class(%DynamicObject).%FromJSON(tInput)
		write:pVerbose !,"dynamic Object successfully created!",!
		$$$ThrowOnError(..BuildTree(tJSON,.tTree))
		zwrite:pVerbose tTree
		$$$ThrowOnError(..GenerateClassesFromTree(.tTree, pRootPackage, pRootClass, pRootClass, pIRISMessageClass, pVerbose))
		write:pVerbose !,"classes generated!"
		if pCompile {
			set:'pVerbose pCompileFlags = pCompileFlags_"-d" 
			do $system.OBJ.CompilePackage(pRootPackage, pCompileFlags)
		}
		}
	catch tEx {
		set tSc = tEx.AsStatus()	
	}	
	
	return tSc
}

/// same as GenerateClasses, but takes a stream as input object
ClassMethod GenerateClassesFromStream(pJSONStream As %Stream.Object, pRootPackage As %String, pRootClass As %String, pIRISMessageClass As %Boolean = 0, pCompile As %Boolean = 0, pCompileFlags As %String = "crk", pVerbose As %Boolean = 1) As %Status
{
	#dim tJSON as %DynamicObject
	#dim tSc as %Status = $$$OK
	
	try {
		set tJSON = ##class(%DynamicObject).%FromJSON(pJSONStream)
		$$$ThrowOnError(..BuildTree(tJSON,.tTree))
		$$$ThrowOnError(..GenerateClassesFromTree(.tTree, pRootPackage, pRootClass, pRootClass, pIRISMessageClass, pVerbose))
		if pCompile {
			do $system.OBJ.CompilePackage(pRootPackage, pCompileFlags)
		}
		}
	catch tEx {
		set tSc = tEx.AsStatus()	
	}	
	
	return tSc
}

ClassMethod BuildTree(pJSON As %DynamicObject, Output pTree) As %Status [ Private ]
{
	#dim tKeyIndex as %Integer = 0
	#dim tIterator as %Iterator.Object
	#dim tSc as %Status = $$$OK
	
	try {
		set tIterator = pJSON.%GetIterator() 
		while tIterator.%GetNext(.tKey,.tValue) {
			set tType = pJSON.%GetTypeOf(tKey)
			set pTree($increment(tKeyIndex),tKey) = $lb(tType,tValue)
			if tType = "object" {
				kill tSubTree
				set tSubJSON = pJSON.%Get(tKey)
				set tSc = ..BuildTree(tSubJSON,.tSubTree)
				merge pTree(tKeyIndex,tKey) = tSubTree 
			}
			if tType = "array" {
				set tFirstMember = tValue.%Get(0)
				if $isobject(tFirstMember) {
					set pTree(tKeyIndex,tKey) = pTree(tKeyIndex,tKey)_$lb(tFirstMember)
					kill tSubTree
					set tSubJSON = pJSON.%Get(tKey).%Get(0)
					set tSc = ..BuildTree(tSubJSON,.tSubTree)
					merge pTree(tKeyIndex,tKey) = tSubTree
					}
				else {
					set pTree(tKeyIndex,tKey) = pTree(tKeyIndex,tKey)_$lb("tFirstmember") 
					}	
				}
		}
	}
	catch tEx {
		set tSc = tEx.AsStatus()
	}
	
	kill ^mbDebug
	merge ^mbDebug = pTree
	return tSc
}

ClassMethod GenerateClassesFromTree(pTree, pPackage As %String, pClassname As %String, pRootClass As %String, pIRISMessageClass As %Boolean, pVerbose As %Boolean) As %Status [ Private ]
{
	#dim tIdx as %Integer = 0
	#dim tCd as %Dictionary.ClassDefinition
	#dim tSc as %Status = $$$OK
	
	
	try {
	
		set pClassRef = ##class(%Dictionary.ClassDefinition).%OpenId(pPackage_"."_pClassname)
		if $ISOBJECT(pClassRef) {
			if (..#DeleteRootClassAndPckg = 0) { throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"Class name, '"_pPackage_"."_pClassname_"' already exists")) }
			else {
				$$$ThrowOnError($system.OBJ.Delete(pPackage_"."_pClassname,"-D"))
				$$$ThrowOnError($system.OBJ.DeletePackage(pPackage_"."_pClassname,"-D"))
				}
		}
		
		$$$ThrowOnError(..MakeClassDefinition(pRootClass,pPackage_"."_pClassname,pIRISMessageClass,.tCd))
		write:pVerbose !,"building class: "_pPackage_"."_pClassname
		set tIdx = $order(pTree(tIdx))
		while tIdx '= "" {
		    set tProperty = $order(pTree(tIdx,""))
			set tType = $li(pTree(tIdx,tProperty),1)
			set tValue = $li(pTree(tIdx,tProperty),2)
			if (tType = "object") {
				kill tSubTree
				write:pVerbose !,"adding object-reference for property: ",tProperty
				merge tSubTree = pTree(tIdx,tProperty)
				set tType = pPackage_"."_pClassname_"."_$tr(tProperty,"-_.: ")
				$$$ThrowOnError(..GenerateClassesFromTree(.tSubTree,pPackage_"."_pClassname, $tr(tProperty,"-_.: "), pRootClass, pIRISMessageClass, pVerbose))
				$$$ThrowOnError(..MakePropertyDefinition(tProperty,tType,tValue,.tPd))
				do tCd.Properties.Insert(tPd)
				}
			elseif (tType = "array") {
				if $li(pTree(tIdx,tProperty),3) [ "DynamicObject" {
					kill tSubTree
					merge tSubTree = pTree(tIdx,tProperty)
					set tType = pPackage_"."_pClassname_"."_$tr(tProperty,"-_.: ")
					write:pVerbose !,"adding relationship for type: ",tType				
					$$$ThrowOnError(..GenerateClassesFromTree(.tSubTree,pPackage_"."_pClassname, $tr(tProperty,"-_.: "), pRootClass, pIRISMessageClass,pVerbose))
					$$$ThrowOnError(..MakePropertyDefinition(tProperty,tType,tValue,.tPd))
					$$$ThrowOnError(..MakeRelationship(tPd, pPackage_"."_pClassname, tType))
				}
				else {
					$$$ThrowOnError(..MakePropertyDefinition(tProperty,"string",tValue,.tPd))
					set tPd.Collection = "list"
				}
				
				do tCd.Properties.Insert(tPd)
				
			}
			else {
				write:pVerbose !,"adding property : "_tProperty_" with type: "_tType
				$$$ThrowOnError(..MakePropertyDefinition(tProperty,tType,tValue,.tPd))
				do tCd.Properties.Insert(tPd)
			}
			set tIdx = $order(pTree(tIdx))
		}
		set tSc = tCd.%Save()
	}
	catch tEx {
		set tSc = tEx.AsStatus()
	}
		
	return tSc
}

ClassMethod MakeClassDefinition(pRootClass As %String, pClassname As %String, pIRISMessageClass As %Boolean, Output pClassDefinition As %Dictionary.ClassDefinition) As %Status [ Private ]
{
		#dim tSc as %Status = $$$OK
		
		try {
			set pClassDefinition = ##class(%Dictionary.ClassDefinition).%New()
			set pClassDefinition.Name = pClassname
			if pIRISMessageClass && (pRootClass = $piece(pClassname,".",$length(pClassname,"."))) {
				set pClassDefinition.Super = "Ens.Request,%JSON.Adaptor"
				}
			else {
				set pClassDefinition.Super = "%Persistent,%XML.Adaptor,%JSON.Adaptor"
			}
			set pClassDefinition.Inheritance = "left"
			set pClassDefinition.ProcedureBlock = 1
			}
		catch tEx {
			set tSc = tEx.AsStatus()
		}
		
		return tSc
}

ClassMethod MakePropertyDefinition(pPropname As %String, pPropType As %String, pPropValue As %String, Output pPropertyDefinition As %Dictionary.PropertyDefinition) As %Status [ Private ]
{
	#dim tSc as %Status = $$$OK
	
	try {
		set pPropertyDefinition = ##class(%Dictionary.PropertyDefinition).%New()
		set pPropertyDefinition.Name = $translate(pPropname,"-_: ")
		set pPropertyDefinition.Type = $case(pPropType,
												"string"	:	"%String",
												"number"	:	"%Numeric",
												"boolean"	:	"%Boolean",
												"null"		:	"%String",
															:	pPropType
															)
		do pPropertyDefinition.Parameters.SetAt(pPropname,"%JSONFIELDNAME")
		if pPropType = "string" {
			do pPropertyDefinition.Parameters.SetAt("","MAXLEN")
		}
		if pPropType = "number" {
			set tScale = ..GetScale(pPropValue)
			do pPropertyDefinition.Parameters.SetAt(tScale,"SCALE")
		}													
	}
	catch tEx {
		set tSc = tEx.AsStatus()
	}
	
	return tSc
}

ClassMethod GetScale(pValue As %String) As %Integer [ Private ]
{
	return $length($piece(pValue,".",2))
}

ClassMethod MakeRelationship(ByRef pPropDefinition As %Dictionary.PropertyDefinition, pType As %String, pInverseType As %String) As %Status [ Private ]
{
	#dim tSc as %Status = $$$OK
	
	try {
		set tInverseProp = $piece(pType,".",$length(pType,"."))
		set pPropDefinition.Relationship = 1
		set pPropDefinition.Cardinality = "children"
		set pPropDefinition.Inverse = tInverseProp
	
		// now modify the inverse property-class
		set tCd = $classmethod("%Dictionary.ClassDefinition","%OpenId", pInverseType)
		set tPropDef = ##class(%Dictionary.PropertyDefinition).%New()
		set tPropDef.Name = tInverseProp
		set tPropDef.Type = pType
		set tPropDef.Relationship = 1
		set tPropDef.Cardinality = "parent"
		set tPropDef.Inverse = pPropDefinition.Name
		do tCd.Properties.Insert(tPropDef)
		set tSc = tCd.%Save()
		}
	catch tEx {
		set tSc = tEx.AsStatus()
	}	
	
	return tSc
}

/// Sample method which feeds the generator with a sample JSON file. It creates a InterSystems IRIS message class.
ClassMethod runGenerator() As %Status
{
	// This call generates a InterSystems IRIS message class in the package Sample.Import. The message classname is ExampleImport
	set tSc = ..GenerateClasses("example.json","Sample.Import","ExampleImport",0,1)
	return tSc
}

/// Sample method which shows how to load data into a previously generated schema
ClassMethod loadData() As %Status
{
#dim tSc as %Status = $$$OK

	set tFile = ##class(%Stream.FileCharacter).%New()
	write !,"Status öfffnen: ",tFile.LinkToFile("example.json")
	set tSourceObj = ##class(%DynamicObject).%FromJSON(tFile)
	write !,"object created!"
	write !,"creating target object..."
	set tDestObj = ##class(Sample.Import.ExampleImport).%New()
	if $isobject(tDestObj) {
		write !,"target object created!"
	}
	else {
		write !,"could not create target object!"
	} 
	write !,"load data..."
	set tSc = tDestObj.%JSONImport(tSourceObj)
	if tSc {
		write !,"data successfully loaded!"
	}
	else {
		do $system.Status.DisplayError(tSc)
	}
	write !,"saving data..."
	set tSc = tDestObj.%Save()
	if tSc {
		write !,"data successfully saved!"
	}
	else {
		do $system.Status.DisplayError(tSc)
	}
	
	return tSc
}

/// Test the generator and loads data
ClassMethod TestImport(FileName As %String = "example.json") As %Status
{
    SET sc = $$$OK
    
    SET tFile = ##class(%Stream.FileCharacter).%New()
	write !,"Load Status: ",tFile.LinkToFile(FileName)
	set tSourceObj = ##class(%DynamicObject).%FromJSON(tFile)

    // Generate Class Here

    SET packagename = "Sample.Import"
    SET iClassname = "ExampleImport"
    
    SET sc = ..GenerateClasses(FileName, packagename, iClassname, 1, 1)
    IF $$$ISERR(sc) {
        Write !, "ERROR: Generating Classes", !, !
        do $system.Status.DisplayError(sc)
        QUIT $$$OK
    }

    SET obj = $ClassMethod(packagename _ "." _ iClassname, "%New")
    IF $IsObject(obj) {
        Write !, "Made New Class", !
    } else {
        do $system.Status.DisplayError(sc)
    }

    SET sc = obj.%JSONImport(tSourceObj)
    if $$$ISOK(sc){
        Write !, "Parsing Tested and complete", !
    } else {
        do $system.Status.DisplayError(sc)
    }

    QUIT sc
}

}
