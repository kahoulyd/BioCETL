import json

with open('litcovid2BioCJSON.json', 'r') as f:
  data = json.load(f)

  array = data[1]

  for i, element in enumerate(array):
    with open('document{}.json'.format(i), 'w') as f:
      json.dump(element, f)
      f.write(json.dumps(element))
      print("created" + i)
