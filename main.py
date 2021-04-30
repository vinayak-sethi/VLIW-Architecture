from Compiler import Compiler

if __name__ == '__main__':
    filePath = input('\x1b[0;35;49m'+'\nEnter the file path: '+'\x1b[0m')
    print()
    compiler = Compiler(filePath)
    for j in compiler.data:
        print('\x1b[0;33;40m', end="")
        for i in j:
            if i!= 'R0':
                print(i, end=" ")
        print()
        print('\x1b[0m', end="")
    for idx in range(len(compiler.packets)):
        print()
        print(f"Instruction: {idx}, Delay: {compiler.delay[idx]}")
        if type(compiler.packets[idx]) == dict:
            for mod, inst in compiler.packets[idx].items():
                print('\x1b[6;36;49m'+mod+':\t' +
                      '\x1b[6;32;49m'+str(inst)+'\x1b[0m')
        else:
            print(compiler.packets[idx])

    print("\nGenerating a testbench...")
    compiler.generateTestBench()
    print('\x1b[0;34;40m'+"\tTestBench generated"+'\x1b[0m')
    print("\nExecuting a testbench...\n")
    compiler.executeTestBench()

    print('\x1b[1;32;40m'+"Note: Here R31 is Program Counter(PC)\n"+'\x1b[0m')
    for out in compiler.outputData:
        print(f"$time: {out['time']}\t PC: {out['31']}")
        for key, value in out.items():
            if key in ["time", "31"]:
                continue
            print('\x1b[6;32;49m'+"R"+key+': ' +'\x1b[6;34;49m'+str(value)+'\x1b[0m', end= "\t")
        print('\n')
