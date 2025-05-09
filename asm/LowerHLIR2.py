from math import log2
from Statics import Var, Type, Pointer, Int, C_Array, NoVar

log = lambda x:int(log2(x))
IsPow2 = lambda x: type(x) == int and (x==x&-x)
CeilDiv = lambda n, d: -(-n//d)

##Var = None
##Type = None

FULLWIDTH = 0 #In assembly 0 is interpetted as 32 for bitwidth of reads, writes, slices, etc

ALLOW_COMPTIME_KNOWN_UNALIGNED_IO = False

hltempnum = 0

def NewTemp():
    global hltempnum
    hltempnum += 1
    return Var(f't_hl{hltempnum-1}', Type(Int(32, False)))

class Block:
    def __init__(self, entry, From):
        self.entry = entry
        self.body = []
        self.From = From
    def Addline(self, line):
        self.body.append(line)

class LLIR:
    def __init__(self):
        self.funcs = []
        self.data = {}
    def __repr__(self):
        o = ''
        for func in self.funcs:
            oa = ", ".join([f'{name}' for name in func['args']])
            o += (f'fn {func["name"]} ({oa}) {func["ret"]} '+'{') + '\n'
##            o +=f'fn {func["name"]}\n'
            for block in func['body']:
                o += '  '
                o += f'{block.entry}'
                if block.From != None:
                    o += f' <- {block.From}'
                o += ':\n'
                for line in block.body:
                    o += '    '+repr(line) + '\n'
            o += ('}') + '\n'
        
        o += f'\nDATA:\n'
        for k,v in self.data.items():
            o += f'{k!r} => {v!r}\n'
        return o
    def NewFunc(self, name, args, ret):
        self.funcs.append({})
        func = self.func = self.funcs[-1]
        func['name'] = name
        func['args'] = args
        func['ret'] = ret
        func['body'] = []

def IsNative(var):
    if var == None: return True
    var = Var(var.name, Type.FromStr(str(var.kind)) if var.kind else var.kind)
    var = Var(var.name, Type.FromStr(str(var.kind)) if var.kind else var.kind)
    return var == None or (var.kind == var.name == None) or var.kind != None and (var.kind.IsBasicInt() or type(var.kind.body) in [Pointer, C_Array] or var.kind.comptime)

def SubRegs(var):
    return [SubReg(var, i) for i in range(WordSizeOf(var.kind))]

def SubReg(var, i):
    global comp
    if var == None or var.kind == None:
        return var
    if var.kind.comptime:
        if var.name in comp:
            val = comp[var.name]
        else:
            val = var.name
        return Var.FromVal(None, (val >> (32 * i)) % (1<<32) )
    if var.name.endswith('.&'):
        rootvar = Var(var.name[:-2], var.kind.Deref())
        #print(f'{rootvar=}')
        subreg = SubReg(rootvar, i)
        return Var(subreg.name+'.&', var.kind)
    bitwidth = var.kind.OpWidth()
    words = WordSizeOf(var.kind)
    assert i < words, f'Cannot take register index `{i}` of variable `{var}` with wordsize `{words}`'
    p = len(str(words-1))
    ename = var.name + ('_' + str(i).zfill(p) if words > 1 else '')
    return Var(ename, Type(Int(32 if i+1 < words else bitwidth - 32*i, False)))

def WordSizeOf(kind):
    return CeilDiv(kind.OpWidth(), 32)

def AddPent(block, op, D, S0, S1, S2, mods = []):
    block.Addline(('expr', (op, D, S0, S1, S2), mods))



def Add(nblock, res, x, y):
    raise NotImplementedError

def AddWrap(nblock, res, x, y):
    raise NotImplementedError

def Sub(nblock, res, x, y):
    raise NotImplementedError

def Mul(nblock, res, x, y):
    raise NotImplementedError

def Div(nblock, res, x, y):
    raise NotImplementedError

def Mod(nblock, res, x, y):
    raise NotImplementedError

def Assg(nblock, res, x, sticky):
    assert not sticky
    bitwidth = min(res.kind.OpWidth(), x.kind.OpWidth())
    regwidth = CeilDiv(bitwidth, 32)
    for i in range(regwidth):
        sRes = SubReg(res, i)
        sX = SubReg(x, i)
        AddPent(nblock, 'mov', sRes, sX, None, None)

def Bsl(nblock, res, x, y):
    raise NotImplementedError

def Bsr(nblock, res, x, y):
    raise NotImplementedError

def Brl(nblock, res, x, y):
    raise NotImplementedError

def Brr(nblock, res, x, y):
    raise NotImplementedError

def Bit(nblock, res, x, y, table):
    raise NotImplementedError

def Or(nblock, res, x, y):
    raise NotImplementedError

def And(nblock, res, x, y):
    raise NotImplementedError

def Xor(nblock, res, x, y):
    raise NotImplementedError

def Inv(nblock, res, x):
    raise NotImplementedError

def Store(nblock, val, array, offset, width, sticky):
    assert not sticky
    if offset.kind.comptime:
        assert offset.kind.comptime, f'Offset must be comptime known, not `{offset!r}`'
        bitwidth = width.name if width.name else array.kind.ElementSize()
        regid = 0
        while bitwidth > 0:
            bits = 32 if bitwidth > 32 else bitwidth
            bitwidth -= 32
            
            AddPent(nblock, 'st', SubReg(val, regid), array, Var(offset.name + 32*regid, 'comptime'), bits % 32)
            regid += 1
        return
    else:
        tmp = NewTemp()
        #print(f'Temp is `{tmp!r}`')
        #assert False, f'Val is: `{val!r}`, {SubReg(val, 0)=}, {tmp=}'
        bitwidth = array.kind.ElementSize()
        regid = 0
        nblock.Addline(('decl', tmp, 32))
        AddPent(nblock, 'mov', tmp, Var(0, 'comptime'), None, None)
        while bitwidth > 0:
            bits = 32 if bitwidth > 32 else bitwidth
            bitwidth -= 32
            AddPent(nblock, 'st', SubReg(val, regid), array, tmp, bits % 32)
            AddPent(nblock, 'add', tmp, tmp, Var(32, 'comptime'), None)
            regid += 1
        nblock.Addline(('undecl', tmp))
        return
        
    raise NotImplementedError

def Load(nblock, res, array, offset, sticky):
    assert not sticky
    opWidth = array.kind.ElementSize()
    print(f'{array=}')
    perOpWidth = 32 if opWidth >= 32 else opWidth #How many bits per read

    bitwidth = res.kind.OpWidth()
    regwidth = CeilDiv(bitwidth, 32)
    for i in range(regwidth):
        eD = SubReg(res, i)
        if offset.kind.comptime:
            AddPent(nblock, 'ld', eD, array, Var(offset.name+32*i, 'comptime'), perOpWidth % 32)
        else:
            raise NotImplementedError
    return

#PRECONDITION:
#If offset is runtime known, it must not cross word boundaries, meaning that if width > 32, then offset must be a multiple of 32
#This may or maynot be handled by the compiler if it is comptime known
def MovlikePrepare(offset, width):
    assert width.kind.comptime, f'Movlike Width but be comptime known'

    bitwidth = width.name
    wordwidth = CeilDiv(bitwidth, 32)
    
    aligned = True
    if offset.kind.comptime:
        wordoffset, bitoffset = divmod(offset.name, 32)
        if bitwidth > 32:
            assert bitoffset == 0 or ALLOW_COMPTIME_KNOWN_UNALIGNED_IO, f'Unaligned Bitslicing is not allowed'
            aligned = bitoffset == 0

    return aligned, wordoffset, bitoffset, wordwidth, bitwidth


def SliceTo(nblock, dest, val, offset, width, sticky):
    assert not sticky
    aligned, wordoffset, bitoffset, wordwidth, bitwidth = MovlikePrepare(offset, width)

    i = 0
    bitsleft = bitwidth
    while bitsleft > 0:
        bitsleft -= 32
        if offset.kind.comptime:
            eD = SubReg(dest, i + wordoffset)
            eV = SubReg(val, i)
            if bitsleft > 32:
                if aligned:
                    AddPent(nblock, 'bst', eD, eV, bitoffset, FULLWIDTH if bitsleft > 32 else (bitsleft % 32))
                else:
                    raise NotImplementedError
            else:
                AddPent(nblock, 'bst', eD, eV, bitoffset, bitsleft % 32)
        else:
            raise NotImplementedError
        i += 1
    return

def SliceFrom(nblock, dest, val, offset, width, sticky):
    assert not sticky
    aligned, wordoffset, bitoffset, wordwidth, bitwidth = MovlikePrepare(offset, width)

    i = 0
    bitsleft = bitwidth
    while bitsleft > 0:
        bitsleft -= 32
        if offset.kind.comptime:
            eD = SubReg(dest, i)
            eV = SubReg(val, i + wordoffset)
            if bitsleft > 32:
                if aligned:
                    AddPent(nblock, 'bsf', eD, eV, 0, FULLWIDTH if bitsleft > 32 else (bitsleft % 32))
                else:
                    raise NotImplementedError
            else:
                AddPent(nblock, 'bsf', eD, eV, 0, bitsleft % 32)
        else:
            raise NotImplementedError
        i += 1
    return

def ComplexCast(nblock, dest, val, sticky):
    assert not sticky
    if not (val.kind.IsBasicInt() and dest.kind.IsBasicInt()):
        Assg(nblock, dest, val, False)
        return
    raise NotImplementedError


def NativeCast(nblock, D, S):
    Assg(nblock, D, S, False)
    return
    
    if S.kind.comptime:
        for i in range(WordSizeOf(dk)):
            p = len(str(WordSizeOf(dk)-1))
            ename = D + '_' + str(i).zfill(p) if WordSizeOf(dk) > 1 else D
            AddPent(nblock, 'mov', ename, S % (1<<32), None, None)
            S >>= 32
    elif D.kind.OpWidth() // 32 == D.kind.OpWidth() / 32:
        for i in range(WordSizeOf(dk)):
            pD = len(str(WordSizeOf(dk)-1))
            pS = len(str(WordSizeOf(sk)-1))
            eD = D + '_' + str(i).zfill(pD) if WordSizeOf(dk) > 1 else D
            eS = (S + '_' + str(i).zfill(pS) if WordSizeOf(sk) > 1 else S) if i < WordSizeOf(sk) else 0
            AddPent(nblock, 'mov', eD, eS, None, None)
    elif dk.OpWidth() < 32:
        for i in range(WordSizeOf(dk)):
            pD = len(str(WordSizeOf(dk)-1))
            pS = len(str(WordSizeOf(sk)-1))
            eD = D + '_' + str(i).zfill(pD) if WordSizeOf(dk) > 1 else D
            eS = (S + '_' + str(i).zfill(pS) if WordSizeOf(sk) > 1 else S) if i < WordSizeOf(sk) else 0
            AddPent(nblock, 'mov', eD, eS, None, None)
    else:
        print(f'Compiling line:\n{line}')
        assert False, f'(Comptime) Cannot cast from type `{sk}` to `{dk}`'

def AddrOf(var):
    rootvar = SubReg(var, 0)
    return Var(rootvar.name+'.&', Type())

def ArgStore(nblock, dest, value, sticky):
    assert not sticky
    assert dest.kind.comptime, f'Destination is not comptime known, is `{dest}`'
    wordwidth = CeilDiv(value.kind.OpWidth(), 32)
    for i, eS in enumerate(SubRegs(value)):
        AddPent(nblock, 'argst', Var.FromVal(None, dest.name+i), eS, None, None)

def ArgLoad(nblock, value, dest, sticky):
    assert not sticky
    assert dest.kind.comptime, f'Destination is not comptime known, is `{dest}`'
    wordwidth = CeilDiv(value.kind.OpWidth(), 32)
    for i, eS in enumerate(SubRegs(value)):
        AddPent(nblock, 'argld', eS, Var.FromVal(None, dest.name+i), None, None)

def RetStore(nblock, dest, value, sticky):
    assert not sticky
    assert dest.kind.comptime, f'Destination is not comptime known, is `{dest}`'
    wordwidth = CeilDiv(value.kind.OpWidth(), 32)
    for i, eS in enumerate(SubRegs(value)):
        AddPent(nblock, 'retst', Var.FromVal(None, dest.name+i), eS, None, None)

def RetLoad(nblock, value, dest, sticky):
    assert not sticky
    assert dest.kind.comptime, f'Destination is not comptime known, is `{dest}`'
    wordwidth = CeilDiv(value.kind.OpWidth(), 32)
    for i, eS in enumerate(SubRegs(value)):
        AddPent(nblock, 'retld', eS, Var.FromVal(None, dest.name+i), None, None)


OPMAP = {
    '+': Add,
    '+%': AddWrap,
    '-': Sub,
    '*': Mul,
    '/': Div,
    '=': Assg,
    '<<': Bsl,
    '>>': Bsr,
    '<<<': Brl,
    '>>>': Brr,
    'bit': Bit,
    '|': Or,
    '&': And,
    '^': Xor,
    '%': Mod,
    '~': Inv,
    '[]=': Store,
    '=[]': Load,
    '[:]=': SliceTo,
    '=[:]': SliceFrom,
    '=<>': ComplexCast,
    'argst': ArgStore,
    'argld': ArgLoad,
    'retst': RetStore,
    'retld': RetLoad,
    'call': lambda nblock, lbl: AddPent(nblock, 'call', lbl, None, None, None),
}

def Native(nblock, op, D, S0, S1, S2, sticky): #For 32 bit native instructions
    S0 = SubReg(S0, 0)
    S1 = SubReg(S1, 0)
    S2 = SubReg(S2, 0)
    if op == 'breakpoint':      AddPent(nblock, op, D, S0, S1, S2)
    elif op[0]=='@':            AddPent(nblock, op[1:], D, S0, S1, S2)
    elif op == '+':             AddPent(nblock, 'add', D, S0, S1, S2)
    elif op == '-':             AddPent(nblock, 'sub', D, S0, S1, S2)
    elif op == '+%':            AddPent(nblock, 'add', D, S0, S1, S2)
    elif op == '-%':            AddPent(nblock, 'sub', D, S0, S1, S2)
    elif op == '&':             AddPent(nblock, 'and', D, S0, S1, S2)
    elif op == '|':             AddPent(nblock, 'or', D, S0, S1, S2)
    elif op == '=':             AddPent(nblock, 'mov', D, S0, S1, S2)
    elif op == '[]=':           AddPent(nblock, 'st', D, S0, S1, 0 if S2 == NoVar else S2)
    elif op == '=[]':           AddPent(nblock, 'ld', D, S0, S1, 0 if S2 == NoVar else S2)
    elif op == '[:]=':          AddPent(nblock, 'bst', D, S0, S1, Var(S2.name % 32, S2.kind))
    elif op == '=[:]':          AddPent(nblock, 'bsf', D, S0, S1, Var(S2.name % 32, S2.kind))
    elif op == '<<':            AddPent(nblock, 'bsl', D, S0, S1, S2)
    elif op == '>>':            AddPent(nblock, 'bsr', D, S0, S1, S2)
    elif op == 'argst':         AddPent(nblock, 'argst', D, S0, S1, S2)
    elif op == 'retld':         AddPent(nblock, 'retld', D, S0, S1, S2)
    elif op == 'argld':         AddPent(nblock, 'argld', D, S0, None, S2)
    elif op == 'retst':         AddPent(nblock, 'retst', D, S0, S1, S2)
    elif op == 'call':          AddPent(nblock, 'call', D, S0, S1, S2)
    elif op == 'of':            AddPent(nblock, 'of', D, S0, S1, S2)
    elif op == '=<>':           NativeCast(nblock, D, S0)

    elif op == '*' and IsPow2(S1):
        AddPent(nblock, 'bsl', D, S0, log(S1), S2)

    elif op == '*':
        print('WARNING: COMPILING USING BAD MULTIPLICATION')
        AddPent(nblock, 'mul', D, S0, S1, S2)

    elif op in ['+>', '+>=', '+<', '+<=', '->', '->=', '-<', '-<=', '==', '!=']:
        cmp = op; lhs = S0; rhs = S1
        if cmp in ['==', '!=']:         cmp = {'==': 'eq', '!=': 'ne'}[cmp]
        else:                           cmp = 'us'['+-'.index(cmp[0])] + {'>': 'gt', '>=': 'ge', '<=': 'le', '<': 'lt'}[cmp[1:]]
        AddPent(nblock, cmp, None, lhs, rhs, None)
    else:
        assert False, f'Cannot lower operand `{op}` 32 width'
    if sticky:
        print(nblock.body[-1])
        nblock.body[-1] = list(nblock.body[-1])
        nblock.body[-1][1] = list(nblock.body[-1][1])
        nblock.body[-1][1][0] += '.s'
        nblock.body[-1][1] = tuple(nblock.body[-1][1])
        nblock.body[-1] = tuple(nblock.body[-1])

def Comptime(comp, op, D, S0, S1, S2):
    S0 = S0.name
    S1 = S1.name
    S2 = S2.name
    if op[0]=='@':      op = op[1:]
    if op == '+':           comp[D] = S0 + S1
    elif op == '-':         comp[D] = S0 - S1
    elif op == '=':         comp[D] = S0
    elif op == '<<':        comp[D] = S0 << S1
    elif op == '>>':        comp[D] = S0 >> S1
    elif op == '&':         comp[D] = S0 & S1
    elif op == '|':         comp[D] = S0 | S1
    elif op == '^':         comp[D] = S0 ^ S1
    elif op == '%':         comp[D] = S0 % S1
    elif op == '/':         comp[D] = S0 // S1
    elif op == '~':         comp[D] = ~S0
    elif op == '*':         comp[D] = S0 * S1
    elif op == 'bit':
        i0 = S0 & S1
        i1 = S0 & ~S1
        i2 = ~S0 & S1
        i3 = ~S0 & ~S1
        comp[D] = ((S2 >> 0 & 1) * i0) | ((S2 >> 1 & 1) * i1) | ((S2 >> 2 & 1) * i2) | ((S2 >> 3 & 1) * i3)
    else:
        assert op != '<<<' and op != '>>>', f'Cannot perform bit rotation on unsized compile time integers'
        assert False, f'Cannot lower comptime operand `{op}`'
    comp[D] = Var(comp[D], 'comptime')

def ConvertMeta(block):
    nbody = []
    for line in block.body:
        if line[0] == 'expr':
            nbody.append(('expr', (line[1][0], *[arg.name if type(arg)==Var else arg for arg in line[1][1:]])))
            if not( 'Var' not in str(repr(nbody[-1]))):
                print(f'{line!r} and arg {nbody[-1][1][3]!r} has type {type(nbody[-1][1][3])}')
                for arg in line[1][1:]:
                    print(f'Arg is {arg!r} has type({type(arg)}) == Var ({type(arg)==Var}) thus `{arg.name if type(arg)==Var else arg}` ({"name" if type(arg)==Var else "raw"}`)\n')
                assert False
        elif line[0] == 'decl':
            var = line[1]
            nbody.append(('decl', var.name, var.kind.OpWidth()))
        elif line[0] == 'predecl':
            amt = line[1]
            kind = line[2]
            nbody.append(('predecl', amt, kind.OpWidth()))
        elif line[0] == 'alloc':
            #alloc name count size
            varname = line[1]
            nbody.append(('alloc', varname, line[2], line[3]))
        elif line[0] in ['undecl', 'regrst', 'memsave']:
            var = line[1]
            nbody.append((line[0], var.name))
        elif line[0] in ['unreachable']:
            nbody.append(line)
        else:
            assert False, f'Unreachable: Uncompiled control word `{line[0]}` from line `{line}`'
    block.body = nbody

def Lower(hlir):
    global comp
    llir = LLIR()
    llir.data = hlir.data
    comp = {}
    assocs = {}
    for func in hlir.funcs:
        llir.NewFunc(func['name'], None, None)
        llir.func['args'] = []
        for var in func['args']:
            for subreg in SubRegs(var):
                llir.func['args'].append(subreg.name)
        llir.func['ret'] = WordSizeOf(func['ret'])
        for block in func['body']:
            nblock = Block(block.entry, block.From)
            for line in block.body:
                try:
                    cmd = line[0]
                    #ALLOCATIONS
                    if cmd == 'decl':
                        var = line[1]
                        assocs[var.name] = var.kind
                        if var.kind.comptime:
                            comp[var.name] = None
                        elif type(var.kind.body) == C_Array:
                            nblock.Addline(('alloc', var.name, var.kind.count, var.kind.ElementSize()))
                        else:
                            ws = WordSizeOf(var.kind)
                            nblock.Addline(('predecl', ws, var.kind))
                            for i in range(ws):
                                svar = SubReg(var, i)
                                nblock.Addline(('decl', svar))
                    #DEALLOCATIONS
                    elif cmd == 'undecl':
                        var = line[1]
                        if not var.kind.comptime:
                            for subreg in SubRegs(var):
                                nblock.Addline(('undecl', subreg))

                    #REGISTER RESET / INVALIDATION
                    elif cmd == 'regrst':
                        var = line[1]
                        if not var.kind.comptime:
                            for subreg in SubRegs(var):
                                nblock.Addline(('regrst', subreg))

                    #BIT LEVEL REGISTER RESET / INVALIDATION
                    elif cmd == 'regrstbit':
                        var = line[1]
                        offset = line[2]
                        width = line[3]
                        minreg = offset // 32
                        maxreg = (offset + width - 1) // 32
                        if not var.kind.comptime:
                            for regid in range(minreg, maxreg+1):
                                nblock.Addline(('regrst', SubReg(var, regid)))

                    #REGISTER EVICTION / SAVE TO MEMORY
                    elif cmd == 'memsave':
                        var = line[1]
                        if not var.kind.comptime:
                            for subreg in SubRegs(var):
                                nblock.Addline(('memsave', subreg))

                    #BIT LEVEL REGISTER EVICTION / SAVE TO MEMORY
                    elif cmd == 'memsavebit':
                        var = line[1]
                        offset = line[2]
                        width = line[3]
                        minreg = offset // 32
                        maxreg = (offset + width - 1) // 32
                        if not var.kind.comptime:
                            for regid in range(minreg, maxreg+1):
                                nblock.Addline(('memsave', SubReg(var, regid)))
                                
                    #EXPRESSIONS
                    elif cmd == 'expr':
                        op, D, S0, S1, S2 = line[1]
                        if D not in assocs and D != None and D.kind != None:
                            assocs[D.name] = D.kind
                        S0 = comp.get(S0, S0)
                        S1 = comp.get(S1, S1)
                        S2 = comp.get(S2, S2)
                        if D.name in comp:
                            Comptime(comp, op, D, S0, S1, S2)
                        elif all([IsNative(x) for x in [D, S0, S1, S2]]) or op == 'breakpoint':
                            Native(nblock, op, D, S0, S1, S2, sticky = line[2])
                        else:
                            if op[0] == '@':
                                for arg in [D, S0, S1, S2]:
                                    if not IsNative(arg):
                                        print(f'Arg {arg} is not native')
                            assert op[0] != '@', f'Cannot perform instrincs on non-native operands'

                            OpHandler = OPMAP[op]
                            numargs = OpHandler.__code__.co_argcount - 2 #1 is always `nblock`, and one is sticky
                            args = [D, S0, S1, S2][:numargs]
                            try:
                                OpHandler(nblock, *args, sticky = line[2])
                            except NotImplementedError:
                                print(f'Compiling line:\n{line}')
                                raise NotImplementedError(f'HLIR -> LLIR does not currently support operation `{op}` with args: {D=}; {S0=}; {S1=}; {S2=}')

                    #UNREACHABLE
                    elif cmd == 'unreachable':
                        nblock.Addline(('unreachable',))
                    else:
                        assert False, f'Bad Command `{cmd}`'
                except Exception as err:
                    print(f'Error `{err}` occured on line:\n\t{line}')
                    raise
                    
            if block.exit:
                mode = block.exit[0]
                if mode == 'goto':
                    lbl = block.exit[1]
##                    eid = block.exit[2]
                    AddPent(nblock, 'jmp', lbl+':', None, None, None)
                elif mode == 'c.jmp':
                    lbl = block.exit[1]
##                    eid = block.exit[2]
                    AddPent(nblock, 'c.jmp', lbl+':', None, None, None)
                elif mode == 'return':
                    eid = block.exit[1]
                    i = 0
                    AddPent(nblock, 'ret', None, None, None, None)
                else:
                    assert False, f'HLIR -> LLIR does not support block exit `{mode}`'

            ConvertMeta(nblock)
            llir.func['body'].append(nblock)
    with open('HLIR_typeinfo.txt', 'w') as f:
        f.write(repr(assocs))
    for i, func in enumerate(llir.funcs):
        if func['name'] == 'Boot':
            llir.funcs.insert(0, llir.funcs[i])
            del llir.funcs[i+1]
    #print(llir.funcs)
        
    return llir

def Init(caller):
    global Var, Type, comp
    Var = caller.Var
    Type = caller.Type

if __name__ == '__main__':
    print(f'This file should not be run directly')
