-- create table
CREATE TABLE bioxml (id NUMBER PRIMARY KEY, doc XMLType);


-- create symbolic directory

CREATE DIRECTORY DOC_DIR AS 'C:\Users\Lydia\Desktop\Master 2\Data mining\Projet\Code\Spliting\'; 
GRANT ALL DIRECTORY DOC_DIR TO SYS; 
GRANT WRITE ON DIRECTORY DOC_DIR TO SYS; 


-- put data into table 
DECLARE
  i INTEGER := 1;
BEGIN
  LOOP
    INSERT INTO bioxml(id, doc)
    VALUES (i, XMLType(bfilename('DOC_DIR', 'document' || i || '.xml'), nls_charset_id('AL32UTF8')));
    i := i + 1;
    EXIT WHEN i > 100001;
  END LOOP;
END;

-- Extract
SELECT
  EXTRACTVALUE(doc, '/document/passage/infon[@key="article-id_pmid"]') AS pmid,
  EXTRACT(doc, '/document/passage/infon[@key="type" and string(.)="ref"]/preceding-sibling::infon[@key="pub-id_pmid"]').getClobVal() AS refs,
  EXTRACTVALUE(doc, '/document/passage/infon[@key="article-id_pmid"][1]/following-sibling::infon[@key = "section_type" and string(.)="TITLE"][1]/following-sibling::text[1]') AS title,
  EXTRACT(doc, '/document/passage/infon[@key="article-id_pmid"][1]/following::passage/infon[@key = "section_type" and string(.)="ABSTRACT"][1]/following-sibling::text[1]').getClobVal() AS abstract
FROM bioxml
WHERE EXTRACTVALUE(doc, '/document/passage/infon[@key="article-id_pmid"]') IS NOT NULL
  AND EXTRACT(doc, '/document/passage/infon[@key="type" and string(.)="ref"]/preceding-sibling::infon[@key="pub-id_pmid"]').getClobVal() IS NOT NULL
  AND EXTRACTVALUE(doc, '/document/passage/infon[@key="article-id_pmid"][1]/following-sibling::infon[@key = "section_type" and string(.)="TITLE"][1]/following-sibling::text[1]') IS NOT NULL
  AND EXTRACT(doc, '/document/passage/infon[@key="article-id_pmid"][1]/following::passage/infon[@key = "section_type" and string(.)="ABSTRACT"][1]/following-sibling::text[1]').getClobVal() IS NOT NULL;



-- Another solution


  SELECT XMLQuery('
let $newline := fn:codepoints-to-string(10)

for $document in /document
let $title := $document/passage/infon[@key="section_type" and string(.) eq "TITLE"]
let $abstractU := $title/following::passage/infon[@key="section_type" and string(.) eq "ABSTRACT"]
let $abstractL := $abstractU/following-sibling::infon[@key="type" and string(.) eq "abstract"]
where exists($title)
  and (exists($abstractU) and exists($abstractL)) 
  return
let $pmid := $document/passage/infon[@key="article-id_pmid"]
let $title1 := $pmid[1]/following-sibling::infon[@key = "section_type" and string(.) eq "TITLE"]
let $title2 := $title1/following-sibling::text[1]/text()
let $refs := $pmid/following::passage/infon[@key="type" and string(.) eq "ref"]
let $references := string-join(
    for $ref in $refs
       return
         $ref/preceding-sibling::infon[@key="pub-id_pmid"]/text(), "/")
let $abstracts := $pmid[1]/following::passage/infon[@key = "section_type" and string(.) eq "ABSTRACT"]
let $resume := string-join(
  for $abstract in $abstracts
  let $isin := $abstract/following-sibling::infon[@key="type" and string(.) eq "abstract"]
  return
    if (exists($isin)) then
      $abstract/following-sibling::text[1]
    else ()
, $newline)
let $results := string-join((concat($pmid, "/",$references, " ", $title2), $resume, $newline), $newline)
return ($results)' PASSING doc RETURNING CONTENT 
  ).getClobVal() as results FROM bioxml WHERE XMLQuery('
let $newline := fn:codepoints-to-string(10)

for $document in /document
let $title := $document/passage/infon[@key="section_type" and string(.) eq "TITLE"]
let $abstractU := $title/following::passage/infon[@key="section_type" and string(.) eq "ABSTRACT"]
let $abstractL := $abstractU/following-sibling::infon[@key="type" and string(.) eq "abstract"]
where exists($title)
  and (exists($abstractU) and exists($abstractL)) 
  return
let $pmid := $document/passage/infon[@key="article-id_pmid"]
let $title1 := $pmid[1]/following-sibling::infon[@key = "section_type" and string(.) eq "TITLE"]
let $title2 := $title1/following-sibling::text[1]/text()
let $refs := $pmid/following::passage/infon[@key="type" and string(.) eq "ref"]
let $references := string-join(
    for $ref in $refs
       return
         $ref/preceding-sibling::infon[@key="pub-id_pmid"]/text(), "/")
let $abstracts := $pmid[1]/following::passage/infon[@key = "section_type" and string(.) eq "ABSTRACT"]
let $resume := string-join(
  for $abstract in $abstracts
  let $isin := $abstract/following-sibling::infon[@key="type" and string(.) eq "abstract"]
  return
    if (exists($isin)) then
      $abstract/following-sibling::text[1]
    else ()
, $newline)
let $results := string-join((concat($pmid, "/",$references, " ", $title2), $resume, $newline), $newline)
return ($results)' PASSING doc RETURNING CONTENT 
  ).getClobVal() IS NOT NULL;
