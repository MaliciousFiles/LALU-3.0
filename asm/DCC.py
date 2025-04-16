#DCC: Ducktape Compiler Chain
import LLPC2 as LLPC
import PreProcess
import sys
from time import sleep
import os
import traceback

MACRODEST = 'expanded.lpc'

if __name__ == "__main__":
    args = sys.argv[2:]
    fName = sys.argv[1] if len(sys.argv) > 1 else input("Program File: ")
    verb = "--verb" in args
    optimize = '--optimize' in args
    prepath = fName[::-1].split('/', maxsplit=1)[-1][::-1]+'/' if '/' in fName else ''

    contents = None
    do = True
    oldcont = None
    ofName = fName
    while do or "--monitor" in args:
        do = False
        sleep(.1)
        with open(ofName, 'r') as f:
            f.seek(0)
            contents = f.read()

        imports = []
        run = True
        while run:
            run = False
            ncontents = ''
            for i, line in enumerate(contents.splitlines()):
                if line.startswith('#include '):
                    ident = line.split('#include ',maxsplit=1)[1]
                    if ident not in imports:
                        imports.append(ident)
                        with open(f'{prepath}{ident}.lpc', 'r') as g:
                            ncontents += f'\n//NEWFILEBEGIN `{prepath}{ident}.lpc`\n'+g.read()+'\n//NEWFILEEND `{prepath}{ident}.lpc`\n'
                            run = True
##                            print(ncontents)
                else:
                    ncontents += line+'\n'
            contents = ncontents

        if contents == oldcont: continue
        oldcont = contents

        if (platform := sys.platform) == 'win32':
            os.system("cls")
        elif platform == 'darwin':
            os.system("clear")
        else:
            exit('Unsupported Operating System `' + platform +'`')

        with open('premacro.txt', 'w') as g:
            g.write(contents)

        if '--nomacro' not in args:
            with open(MACRODEST, 'w') as g:
                g.write(PreProcess.Handle(contents))
            fName = MACRODEST

        try:
            LLPC.Compile(fName, optimize = optimize)
            print(f'Compiled Successfully')
        except Exception as e:
            print(f'\nUnexpected assembler crash')
            print(e)
            print(traceback.format_exc())
