Class ISC.SE.REST.JSON Extends %CSP.REST
{

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
    <!-- <Route Url="/retrieve/name/:package" Method="GET" Call="retrieveByPackage" /> -->
    <Route Url="/generate/:package/:classname" Method="POST" Call="generate" />
    <!-- <Route Url="/generate/:message" Method="POST" Call="generate" /> -->
    <!-- <Route Url="/generate/:message/:compile" Method="POST" Call="generate" /> -->
</Routes>
}

ClassMethod generate(package As %String = {$$$NULLOREF}, classname As %String = {$$$NULLOREF})
{
    #dim %request As %CSP.Request
    set resp = {}
    IF (package = $$$NULLOREF) || (classname = $$$NULLOREF) {
        do %response.SetHeader("Content-Type", "application/json")
        set resp.message = "Cannot generate classes. Fix classname"
        write resp.%ToJSON()
        quit $$$OK
    } ELSE {
        set oldIO = $Io
        OPEN "mytest":("WNS":/OBUFSIZE=65536:/GZIP=0:32767):10
        USE "mytest"
        set tSC = ##class(ISC.SE.Tools.JSON).GenerateClassesFromStream(%request.Content, package, classname, 1, 1)
        IF $$$ISERR(tSC) {
            CLOSE "mytest"
            USE oldIO
            do %response.SetHeader("Content-Type", "application/json")
            set resp.message = "Error Generating Classes  " _ $system.Status.GetErrorText(tSC)
			write resp.%ToJSON()
            quit $$$OK
		} ELSE {
            SET obj = $ClassMethod(package _ "." _ classname, "%New")
            IF $IsObject(obj){
                SET tSC = obj.%JSONImport(%request.Content)
                IF $$$ISERR(tSC){  
                    CLOSE "mytest"
                    USE oldIO
                    do %response.SetHeader("Content-Type", "application/json")
                    set resp.message = "Error validating import. Try reviewing your json file " _ $system.Status.GetErrorText(tSC)
			        write resp.%ToJSON()
                    quit $$$OK
                } ELSE {
                    set stre = ##class(%Stream.TmpCharacter).%New()
                    set tSC = $System.OBJ.ExportPackageToStream(package, .stre)
                    CLOSE "mytest"
                    USE oldIO
                    do %response.SetHeader("Content-Type", "application/xml")
                    do stre.Rewind()
                    while (stre.AtEnd = 0)
                    {
                        set len = 2048 
                        write stre.Read(.len)
                        if len < 2048
                        {
                            quit
                        }
                    }
                    quit $$$OK
                }
            } ELSE {
                CLOSE "mytest"
                USE oldIO
                do %response.SetHeader("Content-Type", "application/json")
                set resp.message = "Error validating import. Try reviewing your json file " _ $system.Status.GetErrorText(tSC)
                write resp.%ToJSON()
                quit $$$OK
                SET tSC = $$$ERROR($$$DatatypeValidationFailed)
            }
		}
    }
}

}
