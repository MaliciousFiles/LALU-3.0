#DCC: Ducktape Compiler Chain
import LLPC2 as LLPC
import PreProcess
import sys
from time import sleep
import os
import traceback

MACRODEST = 'expanded.lpc'

def HideWrappers(tracebackmsg):
    out = ''
    buf = ''
    ininner = False
    for line in tracebackmsg.splitlines():
        if line.startswith('  File "'):
            ininner = True
            if not line.endswith(', in inner') and not line.endswith(', in PrintTokenSource'):
                ininner = False
                buf += line+'\n'
                out += buf
                buf = ''
        elif not ininner:
            buf += line+'\n'
##        else:
##            print(f'Skip line {line}')
    out += buf
    if False or ininner:
        return tracebackmsg
    return out
            

if __name__ == "__main__":
    args = sys.argv[2:]
    fName = sys.argv[1] if len(sys.argv) > 1 else input("Program File: ")
    verb = "--verb" in args
    optimize = '--optimize' in args
    beta = '--beta' in args
    if beta:
        import LLPC3 as LLPC
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
                            ncontents += f'\n//NEWFILEBEGIN `{prepath}{ident}.lpc`\nnamespace {ident} {{\n' + g.read() + f'\n}}\n//NEWFILEEND `{prepath}{ident}.lpc`\n'
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
        except LLPC.CompileError as e:
            print(f'{str(type(e)).split("._")[1][:-2]}: {e}')
        except Exception as e:
            print(f'\nUnexpected assembler crash')
            print(e)
            print(HideWrappers(traceback.format_exc()))
