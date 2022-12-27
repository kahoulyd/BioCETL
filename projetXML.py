import xml.etree.ElementTree as ET
idDoc = 1
context = ET.iterparse('./litcovid2BioCXML.xml', events=('end', ))
for event, elem in context:
    if elem.tag == 'document':
        fileName = 'document'+str(idDoc)+'.xml'
        with open(fileName, 'wb') as f:
            f.write(("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n").encode('utf-8'))
            f.write(ET.tostring(elem))
        idDoc += 1