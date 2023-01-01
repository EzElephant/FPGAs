with open('r.txt') as f:
    buffer = f.readlines()
cnt = 0
with open('r_out.txt', 'w') as f:
    for tmp in buffer:
        tone, n = tmp.split(' ')
        n = int(n) * 2 + 1
        for i in range(n - 1):
            print(str(cnt) + ',', end = ' ', file = f)
            cnt = cnt + 1
        print(str(cnt) + ': freqR = `' + tone + ';', file = f)
        cnt = cnt + 1
        print(str(cnt) + ': freqR = `si;', file = f)
        cnt = cnt + 1

