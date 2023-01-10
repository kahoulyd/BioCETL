db = connect( 'mongodb://localhost/dataminingxbigdata' );
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