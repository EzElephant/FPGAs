import random as rand
print('記得把最後的逗號換成分號')
filename = input("Type in map file name with .txt\n")

try:
    with open(filename, "r") as fp:
        content = []
        content.append("memory_initialization_radix=10;\n")
        content.append("memory_initialization_vector=\n")

        while True:
            data = fp.readline()

            if data == "" or data == '\n':
                break
            L = data.split(' ')
            for item in L:
                if item == '0':
                    probability = rand.randint(0, 100)

                    if probability > 92:
                        content.append('2,\n')
                    elif probability > 45:
                        content.append("1,\n")
                    else:
                        content.append("0,\n")
                elif item == '1':
                    content.append(f"{rand.randint(12, 14)},\n")
                else:
                    content.append(item + ",\n")
            

        with open("map.coe", "w") as out:
            out.writelines(content)
except:
    print("filename error!")