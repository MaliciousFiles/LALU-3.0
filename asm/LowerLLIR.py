import AssemblerV3 as asmblr
from copy import deepcopy as copy

countup = range(0, 1<<24, 32)


srcs = []
def TrackWithAsm(asm):
    def TrackLine(func):
        nonlocal asm
        global srcs
        def inner(*args, **kwargs):
            oldlen = len(asm.body)
            ret = func(*args, **kwargs)
            for i, line in enumerate(asm.body[oldlen:]):
                nsrc = func.__name__
                nsrc += '('
                nsrc += ', '.join([repr(x) for x in args])
                nsrc += ', '.join([f'{name} = {value!r}' for name, value in kwargs.items()])
                nsrc += ')'
                if 'src' not in line:
                    srcs.append([])
                    line['src'] = len(srcs)-1
                
                srcs[line['src']].append(nsrc)

            return ret
        return inner
    return TrackLine

class State:
    def __init__(self, expvars, finals, stk, lru, regs, fresh):
        self.expvars = expvars[:]
        self.finals = dict(finals)
        self.stk = dict(stk)
        self.lru = lru[:]
        self.regs = regs[:]
        self.fresh = fresh[:]
    def __repr__(self):
        return f'State({self.expvars}, {self.finals}, {self.stk}, {self.lru}, {self.regs}, {self.fresh})'

def Coi(x):
    return sum([x.count(c) for c in x])/(len(x)*len(x))

def FormInt(x):
    if type(x) == str and not x.isdecimal():
        return x
    ch = Coi(hex(x))
    cd = Coi(str(x).replace('99', '9').replace('00', '0'))
    cb = Coi('STUVWXYZ'+bin(x))
    if len(bin(x)[2:]) // 8 != len(bin(x)[2:]) / 8:
        cb /= 2
    if len(hex(x)[2:]) <= len(str(x)) > 2:
        ch *= 2
    cm = max((cd, ch, cb))
    return str(x) if cd == cm else '0x'+hex(x)[2:].upper() if ch == cm else '0b'+bin(x)[2:].upper()

def RoundStr(x, w):
    return x.ljust(w*-(-len(x)//w))

class Asm:
    def __init__(self):
        self.body = []
        self.lbls = {}
        self.vlbls = {}
        self.sts = {}
        self.nextvloc = 0
        self.nextline = 0
    def Copy(self):
        nasm = Asm()
        nasm.body = self.body[:]
        nasm.lbls = dict(self.lbls)
        nasm.vlbls = dict(self.vlbls)
        nasm.sts = dict(self.sts)
        nasm.nextvloc = self.nextvloc
        nasm.nextline = self.nextline
        return nasm
    def __repr__(self):
        o=''
        lbls = sorted(self.lbls.items(), key = lambda x: x[1])
        vlbls = sorted(self.vlbls.items(), key = lambda x: x[1])
        s = (lambda x: x['loc']) if 'loc' in self.body[0] else (lambda x: x['vloc'])
        for line in sorted(self.body, key = s):
            if 'eximm' not in line:
                o += repr(line)+'\n'
            else:
                addr = hex(line['loc'])[2:].zfill(6).upper() if 'loc' in line else hex(line['vloc'])[2:].zfill(6).upper()
##                print(line)
##                [FormInt(x) for l, x in line['args']]
                try:
##                    if line['args'][0][-3:] == 'lit':
##
##                    print(line)
                    args = ','.join(''.join([RoundStr((('r'*(l=='reg'))+('#'*(l[-3:]=='lit'))+FormInt(x)+(':'*(l=='lbl'))+', '), 8) for l, x in line['args']]).split(',')[:-1])
                except:
                    print(repr(line))
##                    err
##                if asmblr.instrs[line['name']]['fmtpnm']=='J' and 'loc' in line:
##                    print(line)
##                    err
                op = 'c.'*(line['c'] and not line['n']) + 'cn.'*line['n'] + line['name'] + '.s'*line['s'] + '.e'*line['eximm']
                for lbl, loc in lbls[:]:
                    if 'loc' in line:
                        if loc == line['loc']:
                            o += f'{lbl}:\n'
                            del lbls[0]
                        else:
                            break
            for lbl, loc in vlbls[:]:
                if 'vloc' in line:
                    if loc == line['vloc']:
                        o += f'{lbl}:\n'
                        del vlbls[0]
                    else:
                        break
            o += f'{str(line.get("src", "????")).zfill(4)} {addr[:2]} {addr[2:]}:  {op.ljust(12)}{args}\n'
        o += f'`{self.lbls}` `{self.vlbls}`\n'
        o += f'`{self.sts}`\n'
        return o

    def Addline(self, line):
        line['vloc'] = self.nextvloc
        self.nextvloc += 1
        self.body.append(line)

    def LocLines(self):
        svlbls = sorted(self.vlbls.items(), key = lambda x: x[1])
        for line in self.body:
            vloc = line['vloc']
            line['loc'] = self.nextline
            for key, tvloc in svlbls[:]:
                if tvloc <= vloc:
                    self.lbls[key] = line['loc']
                    del svlbls[0]
                else:
                    break
            self.nextline += 64 if line['eximm'] else 32
            

    def AddLabel(self, lbl):
        self.vlbls[lbl] = self.nextvloc

numRegs = 32 - 3 #1 for stk ptr, 2 for scratch regs
STKPTR = 31
TEMP_0 = 30
TEMP_1 = 29

def MinBitsOf(x):
    if type(x) == str:
        if x[0]=='r':
            return 5
        elif x[-1] == ':':
            return 24
        else:
            assert False, f'Unknown variable `{x}`'
    return len(bin(x)[2:])

def TypeOf(x):
    if type(x) == str:
        if x[0]=='r':
            return 'reg'
        elif x[-1] == ':':
            return 'lbl'
        else:
            assert False, f'Unknown variable `{x}`'
    return 'lit'

def SepVar(x):
    kind = TypeOf(x)
    if kind == 'reg':
        return (kind, int(x[1:]))
    elif kind == 'lbl':
        return (kind, x[:-1])
    return (kind, x)

def Lower(llir):
    asm = Asm()
    expvars = []
    finals = {}
    stk = {}
    lru = list(range(numRegs))
    regs = []
    fresh = []
    for i in range(numRegs):
        regs.append(None)

    @TrackWithAsm(asm)
    def I_Final(name):
        print(f'Mark delete {name}')
        finals[name] = None

    @TrackWithAsm(asm)
    def I_RegUse(reg):
        lru.remove(reg)
        lru.append(reg)

    @TrackWithAsm(asm)
    def M_Use(name):
        print(f'Use {name}')
        if name in finals:
            if finals[name] == None:
                reg = M_ReplaceAny(name)
                I_RegUse(reg)
                finals[name] = reg
                print(f'Delete {name}')
                del stk[name]
                return f'r{reg}'
##                return reg
            else:
                return f'r{finals[name]}'
        if name in regs:
            reg = regs.index(name)
            I_RegUse(reg)
            return f'r{reg}'
        else:
            reg = M_ReplaceAny(name)
            I_RegUse(reg)
            return f'r{reg}'

    @TrackWithAsm(asm)
    def I_Invalidate(name):
        if name in regs:
            regs[regs.index[name]] = None

    @TrackWithAsm(asm)
    def AddrOf(name):
        return stk[name]

    @TrackWithAsm(asm)
    def M_ReplaceAny(name):
        if None in regs:
            tar = regs.index(None)
        else:
            tar = lru[0]
        M_EvictReplace(name, tar)
        return tar

    @TrackWithAsm(asm)
    def M_EvictReplace(name, reg):
        if regs[reg]:
            if name in stk:
                addr = AddrOf(name)
                M_AddPent('stw', (f'r{reg}', f'r{STKPTR}', addr))
        if name in fresh:
            fresh.remove(name)
        else:
            addr = AddrOf(name)
            M_AddPent('ldw', (f'r{reg}', f'r{STKPTR}', addr))
        regs[reg] = name

    @TrackWithAsm(asm)
    def M_ExChangeState(ip, old, new):
        if type(old) == State:
            expvars = old.expvars
            finals = old.finals
            stk = old.stk
            lru = old.lru
            regs = old.regs
            fresh = old.fresh
            oldn = old
            newn = new
            new = asm.sts[newn]
        elif type(new) == State:
            expvars = new.expvars
            finals = new.finals
            stk = new.stk
            lru = new.lru
            regs = new.regs
            fresh = new.fresh
            oldn = old
            newn = new
            old = asm.sts[oldn]
        
        olen = len(asm.body)
        for v in new.stk:
            assert v in old.stk, f'Expected to find variable `{v}` from dest segment `{newn}`, local state is `{oldn}`, but did not'
            if v in new.regs:
                if v in old.regs and new.regs.index(v) == old.regs.index(v):
                    continue
                M_EvictReplace(v, new.regs.index(v))
        ap = asm.body[olen:]
        del asm.body[olen:]
        for l in ap:
            asm.body.insert(ip, l)
        print(f'Expanded:\n{ap}')
        return ap

    @TrackWithAsm(asm)
    def M_ChangeState(lbl):
        asm.Addline({'name':'CHANGE', 'tar': lbl[:-1], 'old': State(expvars, finals, stk, lru, regs, fresh)})
    @TrackWithAsm(asm)
    def M_RevChangeState(lbl):
        asm.Addline({'name':'CHANGE', 'old': lbl[:-1], 'tar': State(expvars, finals, stk, lru, regs, fresh)})

    @TrackWithAsm(asm)
    def M_AddPent(op, args, mods = []):
        nonlocal finals
        if op == 'jmp':
            jp=args[0]
            M_ChangeState(jp)
        width = 24 if op == 'jmp' else 5
        eximm = False
        tps = 0

        c = list(args)
        oargs = c[:]
        args = []
        for x in c[:]:
            if x != None:
                args.append(x)
                del c[0]
            else:
                break
        assert all([x == None for x in c]), f'Very bad: {c}'
        
        data = asmblr.instrs[op]
        if 'ps' in data:
            fmt = data['fmt']
            op, line = fmt.split(maxsplit=1)
            args = [f'#{x}' if type(x) == int else x for x in args]
            op, line = asmblr.BuildPSEUDO(op, data['numargs'], data['fmt'], args).split(maxsplit=1)
            args = [x.lstrip(' \t').rstrip(' \t') for x in line.split(',')] if line != '' else []
            args = [int(x[1:]) if x[0] == '#' else x for x in args]
        data = asmblr.instrs[op]
        argtypes = asmblr.instrs[op]['Args']
        c = args[:]
        args = []
        hassideeffects = '.s' in mods or data['fmtpnm'] == 'J'
##        print((op, c, mods, len(srcs)))
##        print(f'c: {c}')
##        print(f'a: {argtypes}')
        if len(c) > len(argtypes):
            if len(c) == 1:
                M_Use(c[0])
            else:
                assert False, f'C: `{c}` > `{argtypes}`'
        for x, kind in zip(c, argtypes):
            if x != None:
                if IsVar(x):
##                    print(f'F var: {x}')
                    if kind == 'Rd' and (x in finals or x in expvars) and not hassideeffects:
                        del stk[x]
                        print(f'Skipping line due to expired destination {(op, c, mods)}')
                        return
                    x = M_Use(x)
##                else:
##                    print(f'N var: {x}')
                if MinBitsOf(x) > width:
                    if not eximm:
                        eximm = True
                        if TypeOf(x) == 'lit':
                            args.append(('ex' + TypeOf(x), x))
                        else:
                            args.append(('ex' + TypeOf(x), x.replace(':', '')))
                    else:
                        args.append(M_PushTemp(tps, x))
                        tps += 1
                else:
                    args.append(SepVar(x))
            else:
                break
        C = 'c.' in mods or 'cn.' in mods
        asm.Addline({'name': op, 'c': C, 'n': 'cn.' in mods, 's': '.s' in mods, 'args': args, 'eximm': eximm})
        if op == 'jmp' and C:
            M_RevChangeState(jp)
        for name in finals:
            if name in regs:
                regs[regs.index(name)] = None
            expvars.append(name)
        finals = {}

    @TrackWithAsm(asm)
    def M_PushTemp(loc, x):
        reg = TEMP_0 if loc == 0 else TEMP_1
        M_AddPent('mov', [f'r{loc}', x], ['.e'])
##        asm.Addline({'name': 'mov', 'c': False, 'n': False, 's': False, 'args': [('reg', loc), x], 'eximm': True})
        return ('reg', reg)

    @TrackWithAsm(asm)
    def I_Decl(name):
        for loc in countup:
            if loc not in stk.values():
                stk[name] = loc
                fresh.append(name)
                return

    @TrackWithAsm(asm)
    def IsVar(name):
        return name in stk or name in finals

    for func in llir.funcs:
        if func['name'] == 'Main':
            M_AddPent('mov', ['r31', 1], [])
        for block in func['body']:
            asm.sts[block.entry] = State(expvars, finals, stk, lru, regs, fresh)
            asm.AddLabel(block.entry)
            for line in block.body:
                cmd = line[0]
                if cmd == 'decl':
                    I_Decl(line[1])
                elif cmd == 'final':
                    I_Final(line[1])
                elif cmd == 'nodecl':
                    I_Decl(line[1])
                    I_Final(line[1])
                elif cmd == 'expr':
                    op = line[1][0]
                    args = line[1][1:]
                    mods = line[2]
##                    print(op, args, mods)
                    M_AddPent(op, args, mods if mods else [])
                elif cmd == 'argret':
                    name = line[1]
                    loc = line[2]
                    M_EvictReplace(name, loc)
                else:
                    print('??? '+cmd)
##                    assert False, f'Unknown command `{cmd}`'
    print(asm)
    nbd = []
    for i, line in list(enumerate(asm.body)):
        if line['name'] == 'CHANGE':
            old = line['old']
            tar = line['tar']
##            tar = asm.sts[tar]
##            del asm.body[i]
##            print(asm)
            nbd.extend(M_ExChangeState(i, old, tar))
        else:
            nbd.append(line)
    asm.body = nbd
    print('bod')
    print(asm.body)
    asm.LocLines()
    print(asm.lbls, asm.vlbls)
    mem = {}
    for code in asm.body:
        print(code)
        hx, ex = asmblr.ResolveInstr(code, asm.lbls)
        mem[code['loc']] = hx
        if ex:
            mem[code['loc']+32] = ex
    return asm, mem, State(expvars, finals, stk, lru, regs, fresh)
