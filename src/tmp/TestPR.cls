Class tmp.TestPR Extends %RegisteredObject
{

ClassMethod Test()
{
	set jsonresponse = {"resourceType":"Bundle","id":"94441e1c-7a6a-11ed-b253-0230819ed7ba","type":"searchset","timestamp":"2022-12-12T22:15:32Z","total":10,"link":[{"relation":"first","url":"https://fhir.chmkcc9xgiqu.workload-prod-fhiraas.isccloud.io/Observation?page=1&queryId=935db10c-7a6a-11ed-b253-0230819ed7ba"},{"relation":"self","url":"https://fhir.chmkcc9xgiqu.workload-prod-fhiraas.isccloud.io/Observation?_count=3&code=29463-7&patient=1"},{"relation":"next","url":"https://fhir.chmkcc9xgiqu.workload-prod-fhiraas.isccloud.io/Observation?page=2&queryId=935db10c-7a6a-11ed-b253-0230819ed7ba"},{"relation":"last","url":"https://fhir.chmkcc9xgiqu.workload-prod-fhiraas.isccloud.io/Observation?page=4&queryId=935db10c-7a6a-11ed-b253-0230819ed7ba"}],"entry":[{"fullUrl":"https://fhir.chmkcc9xgiqu.workload-prod-fhiraas.isccloud.io/Observation/410","resource":{"resourceType":"Observation","id":"410","status":"final","category":[{"coding":[{"system":"https://terminology.hl7.org/CodeSystem/observation-category","code":"vital-signs","display":"vital-signs"}]}],"code":{"coding":[{"system":"https://loinc.org","code":"29463-7","display":"Body Weight"}],"text":"Body Weight"},"subject":{"reference":"Patient/1"},"encounter":{"reference":"Encounter/407"},"effectiveDateTime":"2010-08-30T11:59:49+00:00","issued":"2010-08-30T11:59:49.565+00:00","valueQuantity":{"value":84.3,"unit":"kg","system":"https://unitsofmeasure.org","code":"kg"},"meta":{"lastUpdated":"2022-12-11T16:21:19Z","versionId":"1"}},"search":{"mode":"match"}},{"fullUrl":"https://fhir.chmkcc9xgiqu.workload-prod-fhiraas.isccloud.io/Observation/464","resource":{"resourceType":"Observation","id":"464","status":"final","category":[{"coding":[{"system":"https://terminology.hl7.org/CodeSystem/observation-category","code":"vital-signs","display":"vital-signs"}]}],"code":{"coding":[{"system":"https://loinc.org","code":"29463-7","display":"Body Weight"}],"text":"Body Weight"},"subject":{"reference":"Patient/1"},"encounter":{"reference":"Encounter/461"},"effectiveDateTime":"2011-09-05T11:59:49+00:00","issued":"2011-09-05T11:59:49.565+00:00","valueQuantity":{"value":84.3,"unit":"kg","system":"https://unitsofmeasure.org","code":"kg"},"meta":{"lastUpdated":"2022-12-11T16:21:19Z","versionId":"1"}},"search":{"mode":"match"}},{"fullUrl":"https://fhir.chmkcc9xgiqu.workload-prod-fhiraas.isccloud.io/Observation/532","resource":{"resourceType":"Observation","id":"532","status":"final","category":[{"coding":[{"system":"https://terminology.hl7.org/CodeSystem/observation-category","code":"vital-signs","display":"vital-signs"}]}],"code":{"coding":[{"system":"https://loinc.org","code":"29463-7","display":"Body Weight"}],"text":"Body Weight"},"subject":{"reference":"Patient/1"},"encounter":{"reference":"Encounter/529"},"effectiveDateTime":"2012-09-10T11:59:49+00:00","issued":"2012-09-10T11:59:49.565+00:00","valueQuantity":{"value":84.3,"unit":"kg","system":"https://unitsofmeasure.org","code":"kg"},"meta":{"lastUpdated":"2022-12-11T16:21:20Z","versionId":"1"}},"search":{"mode":"match"}}]}
	
	set jsonobj = jsonresponse.entry.%Get(0).%ToJSON()
	set stream = ##class(%Stream.GlobalCharacter).%New()
    do stream.Write(jsonobj)
	$$$TOE(sc, ##class(ISC.SE.Tools.JSON).GenerateClassesFromStream(jsonobj, "tmp", "FHIRConditionSchema", 0, 1, "crk", 1))

	do ##class(tmp.FHIRConditionSchema).%KillExtent()
	do ##class(tmp.FHIRConditionSchema.resource).%KillExtent()
	do ##class(tmp.FHIRConditionSchema.search).%KillExtent()

	set o = ##class(tmp.FHIRConditionSchema).%New()
	$$$TOE(st, o.%JSONImport(jsonobj))
	$$$TOE(sc, o.%Save())

	set jsonobj = jsonresponse.entry.%Get(1).%ToJSON()
	set o = ##class(tmp.FHIRConditionSchema).%New()
	$$$TOE(st, o.%JSONImport(jsonobj))
	$$$TOE(sc, o.%Save())
	
	set jsonobj = jsonresponse.entry.%Get(2).%ToJSON()
	set o = ##class(tmp.FHIRConditionSchema).%New()
	$$$TOE(st, o.%JSONImport(jsonobj))
	$$$TOE(sc, o.%Save())

    set o = ##class(tmp.FHIRConditionSchema).%OpenId(1)
    write o.resource.id,!
    write o.resource.code.coding.GetAt(1).code,!

    set o = ##class(tmp.FHIRConditionSchema).%OpenId(2)
    write o.resource.id,!
    write o.resource.code.coding.GetAt(1).code,!

    set o = ##class(tmp.FHIRConditionSchema).%OpenId(3)
    write o.resource.id,!
    write o.resource.code.coding.GetAt(1).code,!
}

}
