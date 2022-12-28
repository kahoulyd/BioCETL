import json

try:
  with open('litcovid2BioCJSON.json', 'r') as f:
    data = json.load(f)
except FileNotFoundError:
  print("Error: Input file not found")
  exit()
except json.decoder.JSONDecodeError:
  print("Error: Input file is not a valid JSON file")
  exit()

array = data[1]

for i, element in enumerate(array):
  try:
    with open('document{}.json'.format(i), 'w') as f:
      json.dump(element, f)
      f.write(json.dumps(element))
      print("created" + i)
  except IOError:
    print(f"Error: Could not write to output file element{i}.json")
