filename = input("Type in map file name with .txt\n")

try:
    with open(filename, "r") as fp:
        content = []
        content.append("memory_initialization_radix=10;\n")
        content.append("memory_initialization_vector=\n")
        flag = fp.readline()
        if flag == "H\n":
            shift = 14
        else:
            shift = 0

        while True:
            data = fp.readline()
            if data == '\n' or data == '':
                break
            tone, n = data.split(' ')
            for i in range(int(n)):
                if tone == '#5':
                    content.append('1,\n')
                elif tone == 'b13':
                    content.append('2,\n')
                elif tone == 'b6':
                    content.append('3,\n')
                elif tone == '#12':
                    content.append('4,\n')
                else:
                    content.append(f'{int(tone) + shift},\n')

            

        with open(filename[:-4] + ".coe", "w") as out:
            out.writelines(content)
except Exception as e:
    print(e)