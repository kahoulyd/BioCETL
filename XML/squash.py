

for i in range(1, 101):
    start = (i - 1) * 1000 + 1
    end = i * 1000
    file_name = "resultat_{}_{}.txt".format(start, end)
    with open("result.txt", "a") as result_file:
        with open(file_name, "r") as f:
            contents = f.read()
            result_file.write(contents)

