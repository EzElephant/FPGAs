filename = input("Type in map file name with .txt")

try:
    with open(filename, "r") as fp:
        content = []
        content.append("memory_initialization_radix=10;\n")
        content.append("memory_initialization_vector=\n")

        while True:
            data = fp.readline()

            if(data == ""):
                break
            else:
                for item in data:
                    content.append(item + ",\n")

            

        with open("map.coe", "w") as out:
            out.writelines(content)
except:
    print("filename error!")