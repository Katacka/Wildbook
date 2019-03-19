<%@ page contentType="text/html; charset=utf-8" language="java"
     import="org.ecocean.*,
java.util.Collection,
java.io.IOException,
java.util.ArrayList,
java.util.Arrays,
javax.jdo.Query,
java.util.List,
java.util.Iterator,
java.util.Map,
java.util.HashMap,
org.json.JSONArray,
org.json.JSONObject,

org.ecocean.servlet.ServletUtilities,
org.ecocean.media.*
              "
%><%

boolean data = "data".equals(request.getQueryString());
String context = ServletUtilities.getContext(request);
Shepherd myShepherd = new Shepherd(context);
myShepherd = new Shepherd("context0");


if (data) {
    String sql = "select \"MEDIAASSET\".\"ID\" as assetId, \"MEDIAASSET\".\"ACMID\" as assetAcmId,\"MEDIAASSET\".\"PARAMETERS\" as assetParams,\"ANNOTATION\".\"ID\" as annotId, \"ANNOTATION\".\"ACMID\" as annotAcmId from \"MEDIAASSET\" join \"MEDIAASSET_FEATURES\" on (\"ID\" = \"ID_OID\") join \"ANNOTATION_FEATURES\" using (\"ID_EID\") join \"ANNOTATION\" on (\"ANNOTATION_FEATURES\".\"ID_OID\" = \"ANNOTATION\".\"ID\") where \"MEDIAASSET\".\"ACMID\" is not null AND \"ANNOTATION\".\"ACMID\" is not null order by \"MEDIAASSET\".\"ID\" limit 300";

    Map<String,Integer> count = new HashMap<String,Integer>();
    List<List<String>> all = new ArrayList<List<String>>();
    Query q = myShepherd.getPM().newQuery("javax.jdo.query.SQL", sql);
    List results = (List)q.execute();
    Iterator it = results.iterator();
    while (it.hasNext()) {
        Object[] row = (Object[]) it.next();
        List<String> lrow = new ArrayList<String>();
        String assetAcmId = (String)row[1];
        String annotAcmId = (String)row[4];
        lrow.add(assetAcmId);
        lrow.add(annotAcmId);
        lrow.add(Integer.toString((Integer)row[0]));
        lrow.add((String)row[3]);  //annotId
        JSONObject params = Util.stringToJSONObject((String)row[2]);  //asset.params
        if (params != null) {
            lrow.add(params.optString("path"));
        } else {
            lrow.add("");
        }
        all.add(lrow);

        if (count.get(assetAcmId) == null) count.put(assetAcmId, 0);
        if (count.get(annotAcmId) == null) count.put(annotAcmId, 0);
        count.put(assetAcmId, count.get(assetAcmId) + 1);
        count.put(annotAcmId, count.get(annotAcmId) + 1);
    }

    JSONArray jall = new JSONArray();
    for (List<String> row : all) {
        Integer assetCt = count.get(row.get(0));
        if (assetCt == null) assetCt = 1;
        Integer annotCt = count.get(row.get(1));
        if (annotCt == null) annotCt = 1;
        if (assetCt + annotCt < 3) continue;
        JSONArray jrow = new JSONArray(row);
        jrow.put(assetCt);
        jrow.put(annotCt);
        jall.put(jrow);
    }
    out.println(jall.toString());


    return;
}

/*
Query query = myShepherd.getPM().newQuery("select from org.ecocean.media.MediaAsset where id > " + startId + " && features.size() > 1");
query.setOrdering("id");
query.setRange(pageNum,pageSize);
Collection c = (Collection) (query.execute());
ArrayList<MediaAsset> mas = new ArrayList<MediaAsset>(c);
query.closeAll();
*/



List<String> colName = Arrays.asList("assetAcmId", "annotAcmId", "assetId", "annotId", "path", "assetAcmCt", "annotAcmCt");
List<String> colLabel = Arrays.asList("asset acm", "annot acm", "asset id", "annot id", "filename", "asset acm ct", "annot acm ct");


JSONArray colDefn = new JSONArray();
for (int i = 0 ; i < colName.size() ; i++) {
    JSONObject jc = new JSONObject();
    jc.put("field", colName.get(i));
    jc.put("title", colLabel.get(i));
    colDefn.put(jc);
}


%>
<!doctype html>
<html><head><title>Resolve Duplicates</title>
<style>
    #result-table td {
        padding: 1px 4px;
        white-space: nowrap;
        overflow-x: hidden;
        max-width: 14em;
    }
    #controls {
        padding: 10px;
        display: inline-block;
    }
    #status-message {
        color: #238;
        font-size: 0.8em;
        padding: 5px;
    }

    #result-table tbody {
        font-size: 0.8em;
    }
    img.tiny {
        max-height: 75px;
    }

    div.enc-annot {
        max-height: 200px;
        position: relative;
    }
    .enc-annot img {
        max-width: 100px;
        max-height: 100%;
    }
    .enc-annot-ma, .enc-annot-id, .enc-annot-indiv {
        width: 100%;
        position: absolute;
        background-color: rgba(0,0,0,0.3);
        color: rgba(255,255,255,0.8) !important;
        display: inline-block;
        text-decoration: none;
        font-size: 0.9em;
        padding-left: 2px;
        cursor: pointer;
    }
    .enc-annot-ma {
        top: 0;
        left: 0;
    }
    .enc-annot-id {
        bottom: 0;
        left: 0;
        overflow-x: hidden;
        white-space: nowrap;
    }
    .enc-annot-indiv {
        display: none;
        bottom: 1.3em;
        left: 0;
    }
    .enc-annot-ma:hover, .enc-annot-id:hover, .enc-annot-indiv:hover {
        background-color: #444;
        color: #FFF !important;
    }

    .enc-annot:hover .enc-annot-indiv {
        display: inline-block;
    }


</style>

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

var currentServerTime = <%=System.currentTimeMillis()%>;
var colDefn = <%= colDefn.toString() %>;
var tableEl;
var rawData = null;

function init() {
    tableEl = $('#result-table');
    status('reading data....');
    $.ajax({
        url: 'resolveDuplicates.jsp?data',
        dataType: 'json',
        success: function(d) {
            rawData = d;
            //var meta = rawData.splice(0, 1);
            //showDataMeta(meta);
            //rawTable();
            mkTable();
        },
        error: function(x) {
            console.log('error fetching data %o', x);
            alert('ERROR loading data');
        },
        contentType: 'application/json',
        type: 'GET'
    });
}


function resetTable() {
    $('.bootstrap-table').remove();
    $('#result-table').remove();
    tableEl = $('<div id="result-table" />');
    tableEl.appendTo($('body'));
}

function mkTable() {
    resetTable();
    var cols = new Array();
    for (var i = 0 ; i < colDefn.length ; i++) {
        cols.push(Object.assign({ sortable: true }, colDefn[i]));
/*
        if (colDefn[i].field == 'assetId') cols.push({
            sortable: false,
            field: 'maUrl',
            title: 'img'
        });
*/
    }
    cols[6].sortable = false;
    tableEl.bootstrapTable({
        data: convertData(function(row) {
            var newRow = {};
            for (var i = 0 ; i < row.length ; i++) {
                newRow[colDefn[i].field] = row[i];
            }
            if (newRow.assetUrl) newRow.assetUrl = '<ximg class="tiny" src="' + newRow.assetUrl + '" />';
            return newRow;
        }),
        search: true,
        pagination: true,
        columns: cols
    });
    postTableUpdate();
}
 

function encTable() {
    resetTable();
    var cols = new Array();
    var edata = encData();
    tableEl.bootstrapTable({
        data: edata,
        search: true,
        pagination: true,
        //customSort: encSort,
        sortName: 'encId',
        onPostBody: function() { encTableTweak(); },
        columns: encDataCols
    });
    postTableUpdate();
}

function encTableTweak() {
    $('.enc-annot').parent().css('padding', '1px');

    $('tr td:first-child').attr('title', function() { return this.innerHTML; }).css({
        'max-width': '4em',
        'white-space': 'nowrap',
        'overflow-x': 'hidden',
        'cursor': 'pointer'
    }).bind('click', function(ev) {
        var eid = ev.target.innerText;
        openInTab('../encounters/encounter.jsp?number=' + eid);
        return false;
    });

    $('tr td:nth-child(3)').css({
        'font-weight': 'bold',
        'cursor': 'pointer'
    }).bind('click', function(ev) {
        var eid = ev.target.innerText;
        openInTab('../individuals.jsp?number=' + eid);
        return false;
    });

    $('.enc-annot').css('cursor', 'pointer').bind('click', function(ev) {
        var jel = $(ev.currentTarget);
        var annId = jel.find('.enc-annot-id').text();
        if (annId) openInTab('../obrowse.jsp?type=Annotation&id=' + annId);
    });
}

var encDataCache = false;
var encDataCols = new Array();
var MAX_LEN = 8;
function encData() {
    if (encDataCache) return encDataCache;

    //make it the first time, boo :(
    encDataCols.push(
        { field: 'encId', title: 'enc', sortable: true },
        { field: 'encTimestamp', title: 'date', sortable: true },
        { field: 'indivId', title: 'indiv(s)', sortable: true },
        { field: 'annCt', title: '# anns', sortable: true }
    );
    var e = {};
    var maxLen = 0;
    for (var i = 0 ; i < rawData.length ; i++) {
//if (i % 100 == 0) console.info('%d of %d', i, rawData.length);
        if (!e[rawData[i][0]]) e[rawData[i][0]] = new Array();
        e[rawData[i][0]].push([ rawData[i][3], rawData[i][4], rawData[i][5], rawData[i][6], rawData[i][1] ]);
        if (e[rawData[i][0]].length > maxLen) maxLen = e[rawData[i][0]].length;
    }

    if (maxLen > MAX_LEN) {
        //alert('too many annots on some encounters; truncated from (max) ' + maxLen + ' to ' + MAX_LEN);
        console.warn('too many annots on some encounters; truncated from (max) ' + maxLen + ' to ' + MAX_LEN);
        maxLen = MAX_LEN;
    }
    for (var i = 0 ; i < maxLen ; i++) {
        encDataCols.push({
            field: 'annot' + i,
            title: 'Ann ' + i,
            sortable: false
        });
    }
    encDataCache = new Array();
    for (var eid in e) {
        var row = { encId: eid };
        row.indivId = encIndivCell(e[eid]);
        row.encTimestamp = toDateString(e[eid]);
        row.annCt = e[eid].length;
        var i = 0;
        while ((i < e[eid].length) && (i < maxLen)) {
            row['annot' + i] = encAnnot(e[eid][i]);
            i++;
        }
        encDataCache.push(row);
    }
    return encDataCache;
}

/*
var dtimer = null;
function updateDataStatus() {
    dtimer = window.setTimeout(function() {
        status(new Date());
        updateDataStatus();
    }, 1000);
console.log('started? %o', dtimer);
}
*/

function encSort(sortName, sortOrder, sdata) {
    var order = sortOrder === 'desc' ? -1 : 1;
console.log('%o %d', sortName, order);
console.log('%o', sdata);
    if (sortName.startsWith('xxxannot')) {  //this doesnt really do what i want it to, so skipping... :(
        sdata.sort(function(a,b) {
            var aS = encMAId(a[sortName]);
            var bS = encMAId(b[sortName]);
//console.log('%o ? %o', aS, bS);
            if (aS > bS) return order * 1;
            if (aS < bS) return order * -1;
            return 0;
        });

    } else {  //default
        sdata.sort(function(a,b) {
            if (a[sortName] > b[sortName]) return order * 1;
            if (a[sortName] < b[sortName]) return order * -1;
            return 0;
        });
    }
}


var encMAIdRegExp = new RegExp('"enc-annot-ma">(\\d+)<');
function encMAId(h) {
    var m = encMAIdRegExp.exec(h);
console.info('%o ==> %o', h, m);
    if (!m || !m[1]) return 0;
    return m[1] - 0;
}

function toDateString(milli) {
    if (!milli[0][4]) return null;
    var d = new Date(milli[0][4]);
    return d.toISOString().substr(0,10);
}

function encIndivCell(annots) {
    if (!annots) return '';
    var inds = {};
    for (var i = 0 ; i < annots.length ; i++) {
        if (annots[i][2]) inds[annots[i][2]] = 1;
    }
    return Object.keys(inds).join(',');
}

function encAnnot(data) {
    var h = '<div class="enc-annot">';
    if (data[3]) h += '<img src="' + data[3] + '" />';
    h += '<a class="enc-annot-ma">' + data[0] + '</a>';
    h += '<a class="enc-annot-id" title="' + data[1] + '">' + data[1] + '</a>';
    if (data[2]) h += '<a class="enc-annot-indiv">' + data[2] + '</a>';
    h += '</div>';
    return h;
}


//this takes each row (from rawData) of flat data and returns each row as a proper json obj
function convertData(rowFunc) {
    var rtn = new Array();
    for (var i = 0 ; i < rawData.length ; i++) {
        var newRow = rowFunc(rawData[i]);
        if (newRow) rtn.push(newRow);
    }
    return rtn;
}


function postTableUpdate() {
    status('&nbsp;');
/*
    $('.search').after('<div id="controls">' +
        '<input type="button" onClick="encTable()" value="by encounter" />' +
        '<input type="button" onClick="rawTable()" value="raw data" />' +
    '</div>');
*/
}

function showDataMeta(m) {
    if (!m || !m[0] || !m[0].timestamp) return;
    console.info('meta %o', m);
    var d = currentServerTime - m[0].timestamp;
    var days = d / (24*60*60*1000);
    var msg = 'data is ' + Math.floor(days) + ' days old';
    if (days > 14) msg += ' -- <a href="?generateData">refresh?</a> (it takes a long time!)';
    status(msg);
}

function status(msg) {
    $('#status-message').html(msg);
}

function openInTab(url) {
    var win = window.open(url, '_blank');
    if (win) win.focus();
}

</script>

</head>
<body onLoad="init()">
<div id="status-message"></div>


<table id="result-table"></table>


</body>
</html>