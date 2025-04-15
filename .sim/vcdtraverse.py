import os
import sys
from bitarray import bitarray
sys.path.insert(1, '../asm')
from LowerHLIR2 import SubReg, SubRegs

from Statics import Type, Var
import Statics

autoflush = True
printbuf = []
printcol = 0
printrow = 0
breakpoints = []

with open('../asm/asm_info.txt', 'r') as f:
    breakpoints = [x>>5 for x in eval(f.read())]

states = {}
with open('../asm/state_dump.txt', 'r') as f:
    for line in f.read().splitlines():
        idx, data = line.split(': ', maxsplit=1)
        idx = int(idx, 16)
        data = eval(data)
        states[idx] = data


simple = True

trueprint = print
def print(*args, sep = ' ', end = '\n', file = None, flush = True):
    global printbuf, printcol, printrow
    msg = sep.join([str(x) for x in args]) + end
    msgs = msg.split('\n')
    while printrow + len(msgs) > len(printbuf):
        printbuf.append('')
    for msg in msgs:
        printbuf[printrow] = str(printbuf[printrow]).ljust(printcol)
        printbuf[printrow] += msg
        printrow += 1
    printrow -= 1
    if autoflush:
        flushprint()

def flushprint():
    global printbuf, printcol, printrow
    trueprint('\n'.join(printbuf))
    printbuf = []
    printrow = 0

def decodeline(line):
    if line[0] == 'b':
        v, char = line.split(' ')
        v = v[1:]
    else:
        v = line[0]
        char = line[1:]
    return (v, char)

def findbyname(name):
    for key, val in defs.items():
        if val[0] == name:
            return key
    else:
        assert False, f'Couldnt find: {name}'

def clear():
    global changes, predump, dump
    changes = predump = dump = ''

def updatebyline(line):
    global vals
    v, k = decodeline(line) if type(line) == str else line
    if v in 'xz':
        vals[nameof(k)] = v
    else:
        vals[nameof(k)] = int(v, 2)
    return v, k

def step():
    global chgs, time, ntime, lineid
    chgs = []
    time = ntime
    while True:
        lineid += 1
        if lineid > len(changes):
            ntime = None
            break
        line = changes[lineid]
        if line == '': continue
        if line[0] == '#':
            time = int(line[1:])
            break
        else:
            chgs.append(decodeline(line))
    updatemem()

def fullstep():
    global nchgs
    nchgs = []
    while not nchgs:
        step()
        for v, k in chgs:
            if k in notes:
                updatebyline((v, k))
                nchgs.append([v, k])

def nameof(code):
    return defs[code][0]

def fmtregs():
    def fmtval(x):
        if type(x) == str:
            return x
        x = hex(x)[2:].zfill(8)
        return f'{x[:4]} {x[4:]}'

    def printfwds():
        buf = list(' '*200)
        exdir = -1 if exfor else None
        redir = -1 if refor else None
        if exfor and exfor[0] == 0: exdir = +1
        if refor and refor[0] == 0: redir = +1
        if exfor and refor and exfor[0] == refor[0]-1: exdir = -1; redir = +1
        if exfor and refor and refor[0] == exfor[0]-1: redir = -1; exdir = +1

        if exfor and exfor[0] < 16:
            l = 3+12*exfor[0]
            buf[l:l+9] = fmtval(exfor[1])
        if refor and refor[0] < 16:
            l = 3+12*refor[0]
            buf[l:l+9] = fmtval(refor[1])

        if exdir and exfor[0] < 16:
            l = 3+12*exfor[0]
            if exdir == -1:
                buf[l-3:l-1] = 'R>'
                buf[l+10] = '|'
            else:
                buf[l+10:l+12] = '<R'
                buf[l-2] = '|'

        if redir and refor[0] < 16:
            l = 3+12*refor[0]
            if redir == -1:
                buf[l-3:l-1] = 'W>'
                buf[l+10] = '|'
            else:
                buf[l+10:l+12] = '<W'
                buf[l-2] = '|'

        print(''.join(buf))

    exfor, refor = getforwards()

    if simple and exfor:
        vals[f'reg{exfor[0]}'] = exfor[1]
    if simple and refor:
        vals[f'reg{refor[0]}'] = refor[1]
    
    print(' | '+' | '.join([f'reg{i}'.center(9) for i in range(16)]))
    print(' | '+' | '.join([f'{fmtval(vals[f"reg{i}"])}' for i in range(16)]))
    if not simple: printfwds()
    print()

    if exfor: exfor[0] -= 16
    if exfor and exfor[0] < 0: exfor = None
    if refor: refor[0] -= 16
    if refor and refor[0] < 0: refor = None
    print(' | '+' | '.join([f'reg{i}'.center(9) for i in range(16, 32)]))
    print(' | '+' | '.join([fmtval(vals[f"reg{i}"]) for i in range(16, 32)]))
    if not simple: printfwds()
    print()

def fmtflgs():
    flags = 'generalFlag negativeFlag overflowFlag carryFlag zeroFlag'.split()
    flglets = 'GNOCZ'
    print('G N O C Z')
    for flag in flags:
        print(vals[flag], end = ' ')
    print()
    print()

def fmtdbg(x):
    o = []
    for line in x.splitlines():
        oline = line
        if ' :' not in line:
            o.append(line)
            continue
        #0007 :		c.jmp L5:				// expr `c.jmp L5:`
        addr, line = line.split(' :', maxsplit = 1)
        line = line.lstrip()
        op, line = line.split(maxsplit = 1)
##        print(op)
        if '//' in line:
            args, comment = line.split('// ', maxsplit = 1)
        else:
            args =  line
##        print(addr, len(o))
        dbgmap[int(addr, 16)] = len(o)
        o.append(oline)
        if op.endswith('.e'):
            dbgmap[int(addr, 16)+1] = len(o)
            o.append(f'{hex(int(addr, 16)+1)[2:].upper().zfill(4)} :\t\tEXIMM')
    return '\n'.join(o)

varlocs = {}

def dispvars():
    global varlocs
    IP = vals['expectedIP']
    stkPtr = vals['reg31']
    if IP in states:
        state = states[IP]
    elif IP+1 in states:
        state = states[IP+1]
    else:
        state = states[list(states.keys())[0]]
    lvars = state['variables']
    nvarlocs = {}
    print()
    for var, data in lvars.items():
        if var in varlocs:
            nvarlocs[var] = addr = varlocs[var]
        else:
            nvarlocs[var] = addr = stkPtr + data['offset']
        width = data["width"]

        regs = state['registers']
        for i in range(29):
            if regs[i] == var:
                regstate = f'r{i}'.ljust(3)
                value = vals[f'reg{i}']
                break
        else:
            regstate = 'mem'
            if all(memoryseen[addr:][:width]):
                value = int(''.join([str(x) for x in memoryval[addr:][:width]])[::-1],2)
            else:
                value = '?'
        print(f'{var.ljust(20)} @ ({hex(addr)[2:].upper().zfill(6)} +: {width}) ({regstate}) :: {value}')
    varlocs = nvarlocs

def dispcompvars():
    IP = vals['expectedIP']
    stkPtr = vals['reg31']
    if IP in states:
        state = states[IP]
    elif IP+1 in states:
        state = states[IP+1]
    else:
        state = states[list(states.keys())[0]]
    lvars = state['variables']
    print()
    compvars = {}
    for var, data in lvars.items():
        rootvar = None
        offset = 0
        for varname, varkind in vartypes.items():
            if varkind.comptime: continue
            for i, subvar in enumerate(SubRegs(Var(varname, varkind))):
                if subvar.name == var:
                    rootvar = varname
                    offset = 32 * i
                    if varname not in compvars:
                        compvars[varname] = [['?']*varkind.OpWidth(), varkind]
        if not rootvar: continue                    

        if var in varlocs:
            addr = varlocs[var]
        else:
            addr = stkPtr + data['offset']
        width = data["width"]

        regs = state['registers']
        for i in range(29):
            if regs[i] == var:
                regstate = f'r{i}'.ljust(3)
                try:
                    value = bin(int(vals[f'reg{i}']))[2:].zfill(width)[::-1]
                    break
                except:
                    pass
        else:
            regstate = 'mem'
            if all(memoryseen[addr:][:width]):
                value = ''.join([str(x) for x in memoryval[addr:][:width]])[::-1]
            else:
                value = '?' * width
##        print(rootvar, offset, width, value, ''.join(compvars[rootvar][0][offset:offset+width]))
##        print(''.join(compvars[rootvar][0]))
        compvars[rootvar][0][offset:offset+width] = list(value)
##        print(''.join(compvars[rootvar][0]))
##        compvars[rootvar][0][33:34] = 'a'

##    print(compvars)

    stk = []
    for key, val in compvars.items():
        stk.append((key, ''.join(val[0]), val[1]))

##    print(stk)
    while stk != []:
        var = stk[0]
        del stk[0]
        if type(var[2].body) != Statics.Struct or type(var[2]) in [Statics.Pointer, Statics.C_Array]:
##        if type(var[2].body) in [Statics.Pointer, Statics.C_Array]:
            if var[1].isnumeric():
                val = int(var[1][::-1], 2)
            else:
                val = var[1][::-1]
            print(var[0].ljust(20), val)
        elif type(var[2].body) == Statics.Struct:
            for arg, data in structs[var[2].name]['args'].items():
##                print(var[0], var[1])
                stk.append((f'{var[0]}.{arg}', var[1][data['offset']:][:data['width']], data['type']))
        else:
            print(f'Unknown var: `{var}` @ (`{type(var[2].body)}`)')
##    print(compvars)
            
    
    

def revdict(d, v0):
    return [k for k,v in d.items() if v == v0][0]

def dispdbg():
    F = dbgmap.get(vals['IP'], 0)
    D = dbgmap.get(vals['IP_f'], 0)
    E = dbgmap.get(vals['expectedIP'], 0)
    e = dbgmap.get(vals['IP_d'], 0) if vals['isValid_d'] else E

    lidx = max(0, E-10)
    if lidx == 0:
        print('-'*90)
    lines = dbg.splitlines()[lidx:][:30]
    for i, line in enumerate(lines):
##        addr = revdict(dbgmap,i + lidx) if i + lidx in dbgmap.values() else None
        addr = i + lidx
        if simple:
            pref = ('>>>' if E == addr else '').ljust(3)
        else:
            pref = (('F' if F == addr else '') + ('D' if D == addr else '') + ('E' if E == addr else '') + ('e' if e == addr and e != E else '')).ljust(3)
        print(f'{pref} | '+line)
##    if E-1 >= 0 and dbg.splitlines()[E-1].startswith('\t_') and dbg.splitlines()[E-1].endswith('__:'):
##        callstk.append(dbg.splitlines()[E-1][2:-3])
    if ':\t\tcall _' in dbg.splitlines()[E]:
        callstk.append(dbg.splitlines()[E].split(':\t\tcall _')[1].split('__:')[0])
    if ':\t\tret' in dbg.splitlines()[E]:
        del callstk[-1]

def getmeminfo():
    wordaddr = vals['memAccessAddress']
    bitaddr = vals['memAccessNumBitsBefore_m']
    bitwidth = vals['memAccessNumBits_m']
    bitwidth = 32 if bitwidth == 0 else bitwidth
    if vals['memAccessRden'] and vals['isExecuting']:
        wordline = vals['memOutput']
        return ('r', wordaddr, bitaddr, bitwidth, wordline)
    if vals['memAccessWren'] and vals['isExecuting']:
        write = vals['memAccessInput']
        return ('w', wordaddr, bitaddr, bitwidth, write)
    
def updatemem():
    inf = getmeminfo()
    if inf and False: #Ignore this old code, it wasnt based on how the process works :|
        mode, waddr, baddr, width, v = inf
        low = waddr << 5 | baddr
        high = low + width
        memoryseen[low:high] = width*bitarray('1')
        memoryval[low:high] = bitarray(bin(v)[2:].zfill(width)[::-1])
    if inf: 
        mode, waddr, baddr, width, v = inf
        low = waddr << 5
        high = low + 32
        memoryseen[low:high] = 32*bitarray('1')
        memoryval[low:high] = bitarray(bin(v)[2:].zfill(32)[::-1])

def getforwards():
    exfor = None
    if vals['isWriteback_e']:
        exfor = [vals['Rd_e'], vals['result_e']]
        if vals['isMemRead_e']:
            exfor[1] = '???? ????'
    refor = None
    if vals['isWriteback_m']:
        refor = [vals['Rd_m'], vals['finalResult_w']]
    return exfor, refor

def fulldisp():
    global autoflush, printcol, printrow
    autoflush = False
    fmtregs()
    fmtflgs()
    print(f'Call Stack: {callstk}')
    dispmem()
    dispvars()
    printcol = 70
    printrow = 12
    dispdbg()
    dispcompvars()
    printcol = 0
    flushprint()
    autoflush = True

def breakstep():
    while vals['IP_d'] not in breakpoints:
        fullstep()
    fulldisp()

def fullstepE():
    while True:
        fullstep()
        if vals['isExecuting']:
            return

def printstep():
    fullstepE()
    fulldisp()

def memscrollto(x):
    global memmin, memmax
    if x < memmin + 5:
        memmin = max(0, x-5)
        memmax = memmin + 30
    if x > memmax - 5:
        memmax = x+5
        memmin = memmax - 30

def readword(i):
    seen = memoryseen[i<<5:][:32]
    bits = memoryval[i<<5:][:32]
    o = ''.join(['?' if not s else str(b) for s,b in zip(seen,bits)])
    return o[::-1]

def dispmem():
    def bitformatword(x):
        return ' '.join([x[8*i:][:8] for i in range(4)])
    meminf = getmeminfo()
    
    mode = ''
    if meminf:
        mode, waddr, baddr, width, v = meminf
        mode = 'read' if mode == 'r' else 'write'
        memscrollto(waddr)
    print(f'   Addr   :              Memory                 |   {mode.center(5)}    |')
    print(f'----------:-------------------------------------+------------+')
    for i in range(memmin, memmax):
        addr = hex(i<<5)[2:].upper().zfill(8)
        addr = f'{addr[:4]} {addr[4:]}'
        val = readword(i)
        dec = ''
        if meminf and i == waddr:
            dec = str(v)
        print(f'{addr} : {bitformatword(val)} | {dec.center(10)} |')

dbgmap = {}

with open('Icarus Verilog-sim/LALU_tb.vcd' if os.path.exists('Icarus Verilog-sim/LALU_tb.vcd') else 'Icarus Verilog-sim/LALU_tb_waveform.vcd', 'r', encoding='utf-8') as f:
    txt = f.read()

with open('../asm/asm_dbg.txt', 'r') as f:
    dbg = f.read()
    dbg = fmtdbg(dbg)

with open('../asm/struct_dump.txt', 'r') as f:
    fr = f.read()
    Statics.structs = structs = eval(fr)
    Statics.structs = structs = eval(fr)

with open('../asm/HLIR_typeinfo.txt', 'r') as f:
    vartypes = eval(f.read())




dumpidx = txt.find('$dumpvars')
changeidx = txt[dumpidx:].find('\n$end\n')

defs = {}
for line in txt[:dumpidx].splitlines():
    if line.startswith('$var '):
##        print(repr(line))
        _, kind, width, ident, name, _ = line.split(' ')[:6]
        if ident in defs:
##            print(f'SKIPPING: `{name}` as it collides with `{defs[ident][0]}` for symbol: `{ident}`')
            continue
        defs[ident] = (name, width, kind)

printcol = 0

print('File read')

regs = [f'reg{i}' for i in range(32)]

notesN = regs + ['IP', 'IP_f', 'IP_d', 'isExecuting'] + 'generalFlag negativeFlag overflowFlag carryFlag zeroFlag Rd_d Rs0_d Rs1_d Rs2_d i0 i1 i2 jumpLoc sticky_d conditional negate format funcID isWriteback_d expectedIP result_e'.split()
notesN += 'result_m Rd_e Rd_m isWriteback_e isWriteback_m result_m isMemRead_e finalResult_w expectedIP isValid_d'.split()
notesN += 'memAccessAddress memAccessWren memAccessRden memAccessInput memAccessOutput memAccessNumBits_m memAccessNumBitsBefore_m memOutput'.split()

notes = [findbyname(x) for x in notesN]

print('Indexing begin')
changes = txt[dumpidx:][changeidx:].splitlines()[1:]
predump = txt[:dumpidx]
dump = txt[dumpidx:][:changeidx]
print('Indexing complete')
txt = ''
time = 0
ntime = 0

memoryval = bitarray(1<<24)
memoryseen = bitarray(1<<24)

os.system('color')

memmin = 0
memmax = 0
memscrollto(0)
callstk = ['Main']

print('Begin read')
lineid = 0
vals = {}

for line in dump.splitlines():
    v, k = decodeline(line)
    if k in notes:
        updatebyline(line)

##while True:
##    fullstep()
##    for v, k in nchgs:
##        print(f'{nameof(k).ljust(20)}: {v}')
##    input()
I = ''
while True:
    if (platform := sys.platform) == 'win32':
        os.system("cls")
    elif platform == 'darwin':
        os.system("clear")
    if I.lower() == 'b':
        breakstep()
    else:
        printstep()
    I = input()
    if '+s' in I:
        simple = True
    elif '-s' in I:
        simple = False
##    simple = '+s' in I
    
