from concurrent.futures import ThreadPoolExecutor
import requests
import lxml.etree as ET
import os

EXIST_DB_URL = "http://localhost:8080/exist/rest/db/BigDataxDataMining"
EXIST_DB_USERNAME = "admin"
EXIST_DB_PASSWORD = "Lydia"

auth = requests.auth.HTTPBasicAuth(EXIST_DB_USERNAME, EXIST_DB_PASSWORD)
def iterate_over_xml_documents() :
    with ThreadPoolExecutor(max_workers=10) as executor:
        for i in range(1, 101):
            start = (i - 1) * 1000 + 1
            end = i * 1000
            executor.submit(process_document_group, start, end)
    squash_result_files()

def process_document_group(start, end):
    file_name = "resultat_{}_{}.txt".format(start, end)
    with open(file_name, "a") as f:
        for i in range(start, end + 1):
            doc = "'/db/BigDataxDataMining/document{}.xml'".format(i)
            query = '''
<query xmlns="http://exist.sourceforge.net/NS/exist">
<text>
<![CDATA[
xquery version "3.1";
let $newline := fn:codepoints-to-string(10)

for $document in doc(''' + doc + ''')/document
let $title := $document/passage/infon[@key="section_type" and data() eq "TITLE"]
let $abstractU := $title/following::passage/infon[@key="section_type" and data() eq "ABSTRACT"]
let $abstractL := $abstractU/following-sibling::infon[@key="type" and data() eq "abstract"]
where exists($title)
  and (exists($abstractU) and exists($abstractL))
let $pmid := $document/passage/infon[@key="article-id_pmid"]
let $title1 := $pmid[1]/following-sibling::infon[index-of(./@key, "section_type") = 1 and data() eq "TITLE"]
let $title2 := $title1/following-sibling::text[1]/data()
let $refs := $pmid/following::passage/infon[@key="type" and data() eq "ref"]
let $references := string-join(
    for $ref in $refs
       return
         $ref/preceding-sibling::infon[@key="pub-id_pmid"]/data()
, '/')
let $abstracts := $pmid[1]/following::passage/infon[index-of(./@key, "section_type") = 1 and data() eq "ABSTRACT"]
let $resume := string-join(
  for $abstract in $abstracts
  let $isin := $abstract/following-sibling::infon[@key="type" and data() eq "abstract"]
  return
    if (exists($isin)) then
      $abstract/following-sibling::text[1]/data()
    else ()
, $newline)
let $results := string-join((concat($pmid, '/ ',$references, ' ', $title2), $resume, $newline), $newline)
return $results
]]>
</text>
</query>
'''
           # print(query)
            response = requests.post(
                EXIST_DB_URL,
                auth=auth,
                headers={
                    "Accept": "text/plain",
                },
                data=query
            )
            print(response.status_code)
            print(response.text)
            root = ET.fromstring(response.text)
            value_element = root.find('.//{http://exist.sourceforge.net/NS/exist}value')
            if value_element is not None:
                value_text = value_element.text
                #value_text = value_element.text
                print(value_text)
                f.write(value_text)

def squash_result_files() : 
    for i in range(1, 101):
        start = (i - 1) * 1000 + 1
        end = i * 1000
        file_name = "resultat_{}_{}.txt".format(start, end)
        with open("result.txt", "a") as result_file:
            with open(file_name, "r") as f:
                contents = f.read()
                result_file.write(contents)
                os.remove(file_name)

iterate_over_xml_documents()





