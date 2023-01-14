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
                    content.append(f'{rand.randint(0, 2)},\n')
                else:
                    content.append(item + ",\n")

            

        with open("map.coe", "w") as out:
            out.writelines(content)
except:
    print("filename error!")