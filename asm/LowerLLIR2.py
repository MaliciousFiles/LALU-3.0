import AssemblerV3 as asmblr
from copy import deepcopy as copy
import inspect

countup = range(0, 1<<24, 32)

trueprint = print
def print(*args):
    assert False, f'Please do not call print, use `Debug(lbl = msg)` instead'

#Of form "FUNCNAME": [ALWAYS, ENABLE, DISABLE, NEVER]
#        "KIND": [ALWAYS, ENABLE, DISABLE, NEVER]
#        "FUNCNAME::KIND": [ENABLE, DISABLE]
# Always and Never do not defer and the highest priority (funcname, then kind) found takes precedent
# Enable and disable set the mode, but if a lower priority one is set (kind), then it takes precedent
# If a double is specified, it doesnt affect other modes or names
diagnostics = {
    '*': 'DISABLE',
    'step': 'ENABLE',
    'Ex': 'ENABLE',
    'From': 'ENABLE',
    'Body': 'ENABLE'
    #'M_Use::misc': 'DISABLE',
}


def __CALLER__():
    return inspect.currentframe().f_back.f_back.f_code.co_name
def __CALL_LINE__() -> int:
    return inspect.currentframe().f_back.f_back.f_lineno

def Debug(**kwargs):
    perm = ["ALWAYS", "NEVER"]
    valids = perm + ["ENABLE", "DISABLE"]
    enables = ["ALWAYS", "ENABLE"]
    
    name = __CALLER__()
    assert len(kwargs.items()) == 1, f'Debug should be called with the format `Debug(kind = "msg")`'
    kind, msg = list(kwargs.items())[0]
    mode = 'UNSPEC'
    for key, effect in diagnostics.items():
        assert effect in valids, f'Invalid mode `{effect}`, must be one of `{valids}`'
        if key == '*':
            mode = effect
    for key, effect in diagnostics.items():
        if name == key:
            if mode not in perm:
                mode = effect
    for key, effect in diagnostics.items():
        if kind == key:
            if mode not in perm:
                mode = effect
    for key, effect in diagnostics.items():
        if f'{name}::{kind}' == key:
            if mode not in perm:
                mode = effect
    assert mode != 'UNSPEC', f'{name}::{kind} has unspecified debug mode behavior'
        
    if mode in enables:
        msg = "\n".join(['\n'.join([x[200*i:200*i+200] for i in range(-(-len(x)//200))]) for x in ('\n'+str(msg)).split('\n')])
        cmsg = str(msg).replace("\n", "\n    ")
        line = __CALL_LINE__()
        trueprint(f'{name}::{kind}::{line}{cmsg}\n')
        
                

srcs = []
def TrackLine(func):
    global srcs
    def inner(*args, **kwargs):
        state = args[0]
        prehash = hash(state)

        if func.__name__[:2] == 'M_':
            lbuf = args[1]
            oldlen = len(lbuf)

        ret = func(*args, **kwargs)
        posthash = hash(state)
##        Debug(_ = f'Hashes: {prehash} : {posthash}')

        if func.__name__[:2] == 'M_':
            for i, line in enumerate(lbuf[oldlen:]):
                nsrc = func.__name__
                nsrc += '('
                nsrc += ', '.join([repr(x) for x in args])
                nsrc += ', '.join([f'{name} = {value!r}' for name, value in kwargs.items()])
                nsrc += ')'
                if 'src' not in line:
                    srcs.append([])
                    line['src'] = len(srcs)-1
                srcs[line['src']].append(nsrc)
        assert prehash == posthash or func.__name__[:2] in ['M_', 'I_'], f'Mutation of state for function `{func.__name__}` which is not annotated to mutate'
        return ret
    return inner

class State:
    def __init__(self, expvars = [], finals = {}, stk = {}, lru = None, regs = None, fresh = []):
        self.expvars = expvars[:]
        self.finals = dict(finals)
        self.stk = dict(stk)
        if lru == None:
            lru = list(range(numRegs))
        self.lru = lru[:]
        if regs == None:
            regs = [None] * numRegs
        self.regs = regs[:]
        self.fresh = fresh[:]
    def __repr__(self):
        return f'State({self.expvars}, {self.finals}, {self.stk}, {self.lru}, {self.regs}, {self.fresh})'

    def Copy(self):
        return eval(repr(self))

    def __hash__(self):
        h = 0
##        Debug(_ = self.__dict__)
        for field, val in self.__dict__.items():
            h += hash(repr(val))
        return hash(h)

    @TrackLine
    def I_Final(self, name):
        Debug(misc = f'Mark delete {name}')
        self.finals[name] = None

    @TrackLine
    def I_Undecl(self, name):
##        Debug(misc = f'Mark delete {name}')
        if name in self.regs:
            reg = self.regs.index(name)
            self.regs[reg] = None
        self.expvars.append(name)
        del self.stk[name]

    @TrackLine
    def I_RegUse(self, reg):
        self.lru.remove(reg)
        self.lru.append(reg)

    @TrackLine
    def M_Use(self, buf, name):
        Debug(misc = f'Use {name}')
        if name in self.finals:
            if self.finals[name] == None:
                reg = self.regs.index(name)
                self.M_EvictReplace(buf, reg, None)
##                self.I_RegUse(reg)
                self.finals[name] = reg
                Debug(misc = f'Final Delete {name}')
                del self.stk[name]
                return f'r{reg}'
            else:
                Debug(misc = f'Final Fetch {name}')
                return f'r{finals[name]}'
        if name in self.regs:
            reg = self.regs.index(name)
            self.I_RegUse(reg)
            return f'r{reg}'
        else:
            reg = self.M_ReplaceAny(buf, name)
            self.I_RegUse(reg)
            return f'r{reg}'

    @TrackLine
    def I_Invalidate(self, name):
        if name in self.regs:
            self.regs[self.regs.index[name]] = None

    @TrackLine
    def AddrOf(self, name):
        return self.stk[name]

    @TrackLine
    def M_ReplaceAny(self, buf, name):
        if None in self.regs:
            tar = self.regs.index(None)
        else:
            tar = self.lru[0]
        self.M_EvictReplace(buf, name, tar)
        return tar

    @TrackLine
    def M_EvictReplace(self, buf, name, reg):
        if self.regs[reg]:
            if name in self.stk:
                addr = self.AddrOf(name)
                self.M_AddPent(buf, 'stw', (f'r{reg}', f'r{STKPTR}', addr))
        if name in self.fresh:
            self.fresh.remove(name)
        else:
            Debug(step = self.stk)
            addr = self.AddrOf(name)
            self.M_AddPent(buf, 'ldw', (f'r{reg}', f'r{STKPTR}', addr))
        self.regs[reg] = name

    @TrackLine
    def M_ExChangeState(self, buf, tar, oldn, tarn):
        Debug(Ex = f'Going from:\n\t{self}\nto:\n\t{tar}')
        for v in tar.stk:
            assert v in self.stk, f'Expected to find variable `{v}` from dest segment `{tarn}`, local state is `{oldn}`:`{self}'
            if v in tar.regs:
                if v in self.regs and tar.regs.index(v) == self.regs.index(v):
                    continue
                self.M_EvictReplace(buf, v, tar.regs.index(v))

    @TrackLine
    def M_ChangeState(self, buf, lbl, cond):
        buf.append({'name':'CHANGE', 'tar': lbl[:-1], 'old': self.Copy(), 'cond': cond})

##    @TrackLine
##    def M_RevChangeState(self, buf, lbl):
##        buf.append({'name':'CHANGE', 'old': lbl[:-1], 'tar': self.Copy()})

    @TrackLine
    def M_AddPent(self, buf, op, args, mods = []):
        if op[:2] == 'c.':
            mods.append('c.')
            op = op[2:]
        if op == 'jmp':
            jp=args[0]
##            self.M_ChangeState(buf, jp)
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
        if len(c) > len(argtypes):
            if len(c) == 1:
                self.M_Use(buf, c[0])
            else:
                assert False, f'C: `{c}` > `{argtypes}`'
        for x, kind in zip(c, argtypes):
            if x != None:
                if self.IsVar(x):
                    if kind == 'Rd' and (x in self.finals or x in self.expvars) and not hassideeffects:
                        del self.stk[x]
                        Debug(optimization = f'Skipping line due to expired destination {(op, c, mods)}')
                        return
                    x = self.M_Use(buf, x)
                if MinBitsOf(x) > width:
                    if not eximm:
                        eximm = True
                        if TypeOf(x) == 'lit':
                            args.append(('ex' + TypeOf(x), x))
                        else:
                            args.append(('ex' + TypeOf(x), x.replace(':', '')))
                    else:
                        args.append(self.M_PushTemp(buf, tps, x))
                        tps += 1
                else:
                    args.append(SepVar(x))
            else:
                break
        C = 'c.' in mods or 'cn.' in mods
        if op == 'jmp':
##            jp=args[0]
            self.M_ChangeState(buf, jp, cond=C)
        buf.append({'name': op, 'c': C, 'n': 'cn.' in mods, 's': '.s' in mods, 'args': args, 'eximm': eximm})
##        if op == 'jmp' and C:
##            self.M_RevChangeState(buf, jp)
        for name in self.finals:
            if name in self.regs:
                self.regs[self.regs.index(name)] = None
            self.expvars.append(name)
        self.finals = {}

    @TrackLine
    def M_PushTemp(buf, self, loc, x):
        reg = TEMP_0 if loc == 0 else TEMP_1
        self.M_AddPent(buf, 'mov', [f'r{loc}', x], ['.e'])
        return ('reg', reg)

    @TrackLine
    def I_Decl(self, name):
        for loc in countup:
            if loc not in self.stk.values():
                self.stk[name] = loc
                self.fresh.append(name)
                return

    

    @TrackLine
    def IsVar(self, name):
        return name in self.stk or name in self.finals

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
        self.sts = {}
        self.stsf = {}
        self.nextvloc = 0
        self.nextline = 0
        self.stitched = False
        self.froms = {}
    def Copy(self):
        nasm = Asm()
        nasm.body = self.body[:]
        nasm.lbls = dict(self.lbls)
        nasm.sts = dict(self.sts)
        nasm.stsf = dict(self.stsf)
        nasm.nextline = self.nextline
        nasm.stitched = self.stitched
        nasm.froms = self.froms
        return nasm
    def __repr__(self):
        o=''
        if len(self.body) > 0:
            lbls = sorted(self.lbls.items(), key = lambda x: x[1])
            sortkey = (lambda x: x['loc']) if self.stitched else (lambda x: x['vloc'])
            for line in sorted(self.body, key = sortkey):
                if 'eximm' not in line:
                    o += repr(line)+'\n'
                    continue
                addrkey = 'loc' if self.stitched else 'vloc'
                addr = hex(line[addrkey])[2:].zfill(6).upper()
                try:
                    args = ','.join(''.join([RoundStr((('r'*(l=='reg'))+('#'*(l[-3:]=='lit'))+FormInt(x)+(':'*(l=='lbl'))+', '), 8) for l, x in line['args']]).split(',')[:-1])
                except Exception as e:
                    print(repr(line))
                    raise e
                op = 'c.'*(line['c'] and not line['n']) + 'cn.'*line['n'] + line['name'] + '.s'*line['s'] + '.e'*line['eximm']
                for lbl, loc in lbls[:]:
                    if addrkey in line:
                        if loc <= line[addrkey]:
                            o += f'{lbl}'
                            if lbl in self.froms and not self.stitched:
                                o += f' <- {self.froms[lbl]}'
                            o += ':\n'
                            del lbls[0]
                        else:
                            break
                o += f'{str(line.get("src", "????")).zfill(4)} {"v"*(not self.stitched)}{addr[:2]} {addr[2:]}:  {op.ljust(12)}{args}\n'
        o += f'`{self.lbls}`\n'
        o += f'`{self.froms}`\n'
        
##        o += f'`{self.sts}`\n'
        return o

    def ClearBody(self):
        self.body = []

    def Addline(self, line):
        line['vloc'] = len(self.body)
        self.nextvloc += 1
        self.body.append(line)
    def Addlines(self, lines):
        for line in lines:
            self.Addline(line)
    def Insert(self, index, line):
        line['vloc'] = index
        self.body.insert(index, line)
        for i in range(index+1, len(self.body)):
            self.body[i]['vloc'] += 1
    def Inserts(self, index, lines):
        for line in lines:
            self.Insert(index, line)

    def LocLines(self):
        #error_loc_lines
        nxl = 0
        svlbls = sorted(self.lbls.items(), key = lambda x: x[1])
        for line in self.body:
            assert 'vloc' in line, f'Could not fine `vloc` in {line}'
            vloc = line['vloc']
            line['loc'] = nxl
            for key, tvloc in svlbls[:]:
                if tvloc <= vloc:
                    self.lbls[key] = line['loc']
                    del svlbls[0]
                else:
                    break
            assert 'eximm' in line, f'Could not fine `eximm` in {line}'
            nxl += 64 if line['eximm'] else 32
        assert len(svlbls) == 0, f'Svlbls != [], {svlbls}'
        self.stitched = True
            

    def AddLabel(self, lbl):
        self.lbls[lbl] = len(self.body)

numRegs = 32 - 3 #1 for stk ptr, 2 for scratch regs
##numRegs = 1 #### Just for testing swapping and stuff
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
    state = State()

    for func in llir.funcs:
        if func['name'] == 'Main':
            buf = []
            state.M_AddPent(buf, 'mov', ['r31', 1], [])
            asm.Addlines(buf)
        for block in func['body']:
            if len(asm.sts.keys()) > 0:
                pk = list(asm.sts.keys())[-1]
                asm.stsf[pk] = state.Copy()
            if block.From != None:
                asm.froms[block.entry] = block.From
                state = asm.stsf[block.From].Copy()
                Debug(From = f'{block.entry} has from {block.From} and now has state:\n\t{state}')
            asm.sts[block.entry] = state.Copy()
            asm.AddLabel(block.entry)
            for line in block.body:
                buf = []
                cmd = line[0]
                if cmd == 'decl':
                    state.I_Decl(line[1])
                elif cmd == 'final':
                    state.I_Final(line[1])
                elif cmd == 'undecl':
                    state.I_Undecl(line[1])
                elif cmd == 'nodecl':
                    state.I_Decl(line[1])
                    state.I_Final(line[1])
                elif cmd == 'expr':
                    op = line[1][0]
                    if op == 'retpsh':
                        name = line[1][1]
                        loc = line[1][2]
                        Debug(step = f'name is {name=}, loc is {loc=}')
                        state.M_EvictReplace(buf, name, loc)
                    elif op == 'argpop':
                        name = line[1][1]
                        loc = line[1][2]
                        state.I_Decl(name)
                        state.M_EvictReplace(buf, name, loc)
                    elif op == 'argpsh':
                        err
                    elif op == 'retpop':
                        err
                    else:
                        args = line[1][1:]
                        mods = line[2]
                        state.M_AddPent(buf, op, args, mods if mods else [])
##                elif cmd == 'expr':
##                    
                elif cmd == 'from':
                    tar = line[1]
                    state = asm.stsf[tar].Copy()
                else:
                    Debug(_ = '??? '+cmd)
                    assert False, f'Unknown command `{cmd}`'
                asm.Addlines(buf)
                Debug(buf = buf)
        if len(asm.sts.keys()) > 0:
            pk = list(asm.sts.keys())[-1]
            asm.stsf[pk] = state.Copy()
##    Debug(body = '\n'.join([repr(x) for x in asm.body]))
    Debug(step = f'{asm.sts=}')
    Debug(step = f'{asm.stsf=}')
    Debug(step = asm)
    nasm = asm.Copy()
    nasm.ClearBody()
    lbls = dict(asm.lbls)
    nlbls = {}
    for i, line in list(enumerate(asm.body)):
        if i in lbls.values():
            for k,v in lbls.items():
                if v == i:
                    nlbls[k] = len(nasm.body)
        if line['name'] == 'CHANGE':
            buf = []
            oldn = old = line['old']
            tarn = tar = line['tar']
            if type(old) == str:
                oldn = old
                old = asm.sts[old]
            if type(tar) == str:
                tarn = tar
                tar = asm.sts[tar]
            Debug(Ex = f'Move {oldn} -> {tarn}')
            old.M_ExChangeState(buf, tar, oldn, tarn)
            if line['cond']:
                for i in range(len(buf)):
                    buf[i]['c'] = True
            Debug(buf = buf)
            nasm.Addlines(buf)
##            nbd.extend(buf)
        else:
            nasm.Addline(line)
##            nbd.append(line)
##    asm.body = nbd
    Debug(step = nlbls)
    asm = nasm.Copy()
    asm.lbls = nlbls
    Debug(misc = 'bod')
    Debug(Body = asm)
    asm.LocLines()
    Debug(misc = (asm.lbls))
    mem = {}
    for code in asm.body:
        Debug(misc = code)
        hx, ex = asmblr.ResolveInstr(code, asm.lbls)
        mem[code['loc']] = hx
        if ex:
            mem[code['loc']+32] = ex
##    Debug(step = f'{asm.sts.keys()=}')
    for st,v in asm.sts.items():
        Debug(step = f'State `{st}`:\n\t{v}\n\tEnds with:\n\t{asm.stsf[st]}')
    return asm, mem, state.Copy()
