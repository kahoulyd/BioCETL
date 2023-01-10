db = connect( 'mongodb://localhost/dataminingxbigdata' );
//db.Litcovid.insert(load('litcovid1.json').slice(0,10))

/**db.dataMxbigD.find({"passages.infons.article-id_pmid": {$exists: true}}).limit(3).forEach(function(x) {
    var result = ""
    if(x.pmid) {
        result = result + x.pmid +  '/';
    }
  for (var i in x.passages) {
    
    if (x.passages[i].infons.section_type === "TITLE") {
      result = result + " " + x.passages[i].text + '\n';

    }
    if (x.passages[i].infons.section_type === "ABSTRACT" && x.passages[i].infons.type === "abstract") {
      result = result + " " + x.passages[i].text + '\n';
    }

  }
  result = result + '\n';
 print(result);
});
*/

db.dataMxbigD.find({"passages.infons.article-id_pmid": {$exists: true}}).limit(3).forEach(function(x) {
  var result = ""
  if(x.pmid) {
      result = result + x.pmid +  '/';
  }
for (var i in x.passages) {
  if (x.passages[i].infons.section_type === "REF" && x.passages[i].infons.type === "ref") {
    if(x.passages[i].infons["pub-id_pmid"]){
      result = result + " " + x.passages[i].infons["pub-id_pmid"] + '/';
    }
  }
}
result = result + '\n';
print(result);
});