<%@ page contentType="text/html; charset=utf-8" language="java"
     import="org.ecocean.*,
org.ecocean.servlet.ServletUtilities,
javax.jdo.*,
java.util.Iterator,
java.util.Arrays,
java.util.List,
org.json.JSONArray,
org.json.JSONObject,
org.ecocean.media.*
              "
%><%


String context = ServletUtilities.getContext(request);
Shepherd myShepherd = new Shepherd(context);
List<String> colName = Arrays.asList("encId", "encTimestamp", "encLocId", "assetId", "annotId", "indivId");
List<String> colClass = Arrays.asList("java.lang.String", "java.lang.Long", "java.lang.String", "java.lang.Integer", "java.lang.String", "java.lang.String");
List<String> colLabel = Arrays.asList("enc id", "time", "loc id", "ma", "ann", "indiv");


if (Util.requestParameterSet(request.getParameter("data"))) {
    String sqlMagic = "SELECT \"ENCOUNTER\".\"CATALOGNUMBER\" as encId," +
        "\"ENCOUNTER\".\"DATEINMILLISECONDS\" as encTimestamp," +
        "\"ENCOUNTER\".\"LOCATIONID\" as encLocId," +
        "\"MEDIAASSET\".\"ID\" as assetId," +
        "\"ENCOUNTER_ANNOTATIONS\".\"ID_EID\" as annotId," +
        "\"ENCOUNTER\".\"INDIVIDUALID\" as indivId FROM " +
        "\"MEDIAASSET\" join \"MEDIAASSET_FEATURES\" on (\"ID\" = \"ID_OID\") " +
        "JOIN \"ANNOTATION_FEATURES\" USING (\"ID_EID\") " + 
        "JOIN \"ENCOUNTER_ANNOTATIONS\" on (\"ANNOTATION_FEATURES\".\"ID_OID\" = \"ENCOUNTER_ANNOTATIONS\".\"ID_EID\") " +
        "JOIN \"ENCOUNTER\" on (\"ENCOUNTER_ANNOTATIONS\".\"CATALOGNUMBER_OID\" = \"ENCOUNTER\".\"CATALOGNUMBER\") " +
        "ORDER BY \"MEDIAASSET\".\"ID\" limit 10;";

    Query q = myShepherd.getPM().newQuery("javax.jdo.query.SQL", sqlMagic);
    List results = (List)q.execute();
    Iterator it = results.iterator();
    JSONObject rtn = new JSONObject();
    //JSONArray colArr = new JSONArray(colName);
    //rtn.put("cols", colArr);

    JSONArray dataArr = new JSONArray();
    while (it.hasNext()) {
        Object[] fields = (Object[])it.next();
/*  this is for label-less array....
        JSONArray jrow = new JSONArray();
        jrow.put((String)fields[0]);
        jrow.put((Long)fields[1]);
        jrow.put((String)fields[2]);
        jrow.put((Integer)fields[3]);
        jrow.put((String)fields[4]);
        jrow.put((String)fields[5]);
*/
        JSONObject jrow = new JSONObject();
        for (int i = 0 ; i < colName.size() ; i++) {
            Class<?> cls = Class.forName(colClass.get(i));
            jrow.put(colName.get(i), cls.cast(fields[i]));
        }
        dataArr.put(jrow);
    }
    ////rtn.put("data", dataArr);

    response.setContentType("application/json");
    out.println(dataArr);
    return;
}

JSONArray colDefn = new JSONArray();
for (int i = 0 ; i < colName.size() ; i++) {
    JSONObject jc = new JSONObject();
    jc.put("field", colName.get(i));
    jc.put("title", colLabel.get(i));
    jc.put("sortable", true);
    colDefn.put(jc);
}


%>
<!doctype html>
<html><head><title>ID Overview</title>

    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.2.1/css/bootstrap.min.css" integrity="sha384-GJzZqFGwb1QTTN6wy59ffF1BuGJpLSa9DkKMp0DgiMDm4iYMj70gZWKYbI706tWS" crossorigin="anonymous">
    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.6.3/css/all.css" integrity="sha384-UHRtZLI+pbxtHCWp1t77Bi1L4ZtiqrqD80Kn4Z8NTSRyMA2Fd33n5dQ8lWUE00s/" crossorigin="anonymous">
    <link rel="stylesheet" href="https://unpkg.com/bootstrap-table@1.13.4/dist/bootstrap-table.min.css">

    <!-- jQuery first, then Popper.js, then Bootstrap JS, and then Bootstrap Table JS -->
    <script src="https://code.jquery.com/jquery-3.3.1.min.js" integrity="sha256-FgpCb/KJQlLNfOu91ta32o/NMZxltwRo8QtmkMRdAu8=" crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.6/umd/popper.min.js" integrity="sha384-wHAiFfRlMFy6i5SRaxvfOCifBUQy1xHdJ/yoi7FRNXMRBu5WHdZYu1hA6ZOblgut" crossorigin="anonymous"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.2.1/js/bootstrap.min.js" integrity="sha384-B0UglyR+jN6CkvvICOB2joaf5I4l3gm9GU6Hc1og6Ls7i6U/mkkaduKaBhlAXv9k" crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/core-js/2.6.2/core.min.js"></script>
    <script src="https://unpkg.com/bootstrap-table@1.13.4/dist/bootstrap-table.min.js"></script>


<script type="application/javascript">
function init() {

    $('#test-table').bootstrapTable({
        url: 'idOverview.jsp?data',
        pagination: true,
        search: true,
        columns: <%=colDefn.toString()%>
    });
}
</script>

</head>
<body onLoad="init()">


<table
    id="test-table"
    xdata-toggle="table"
    xdata-sortable="true"
    xdata-height="460"
></table>



</body>
</html>