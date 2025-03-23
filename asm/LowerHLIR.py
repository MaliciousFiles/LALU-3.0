from math import log2
log = lambda x:int(log2(x))


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
            for block in func['body']:
                o += '  '
                o += f'{block.entry}'
                if block.From != None:
                    o += f' <- {block.From}'
                o += ':\n'
                for line in block.body:
                    o += '    '+repr(line) + '\n'
            o += ('}') + '\n'
        return o
    def NewFunc(self, name, args, ret):
        self.funcs.append({})
        func = self.func = self.funcs[-1]
        func['name'] = name
        func['args'] = args
        func['ret'] = ret
        func['body'] = []
    
def ENamesOf(name, kind):
    o = []
    bits = WidthOf(kind) if type(kind) != int else kind
    p = len(str(bits-1))
    for i in range(bits):
        ename = name + '_' + str(i).zfill(p) if bits > 1 else name
        o.append(ename)
    return o

def EName(name, kind, i):
    bits = WidthOf(kind) if type(kind) != int else kind
    p = len(str(bits-1))
    ename = name + '_' + str(i).zfill(p) if bits > 1 else name
    assert ename != 't4', f'{name=}; {kind=}; {i=}'
    return ename

def WidthOf(kind):
    if kind == 'void':
        return 0
    if kind.numPtrs > 0:
        return 1
    else:
        return -(-kind.width//32)

def AddPent(block, op, D, S0, S1, S2, mods = []):
    block.Addline(('expr', (op, D, S0, S1, S2), mods))

def Lower(hlir):
    llir = LLIR()
    llir.data = hlir.data
    finals = []
    comp = {}
    finex = []
    def HandleFinals(eid):
        return
        nonlocal finals, nblock
##        print(eid, finals)
        i = 0
        for i, (name, loc) in enumerate(finals):
##            print(name, loc)
            if loc == eid:
                if name in comp:
                    finex.append(name)
                else:
                    nblock.Addline(('final', name))
            else:
                assert loc > eid, f'Bad final loc `{loc}` when on line `{eid}`'
                i -= 1
                break
        del finals[:i+1]
    for func in hlir.funcs:
        args = []
        for name, kind in func['args']:
            for i in range(WidthOf(kind)):
                p = len(str(WidthOf(kind)-1))
                args.append(name + '_' + str(i).zfill(p))
        llir.NewFunc(func['name'], args, WidthOf(func['ret']))
        for block in func['body']:
            nblock = Block(block.entry, block.From)
            for line in block.body:
                cmd = line[0]
                if cmd == 'decl':
                    name, kind, final = line[1], line[2], line[3]
                    if kind.comptime:
                        comp[name] = None
##                        nblock.Addline(('comptimedecl', name))
                        if final:
                            finals.append((name, final))
                    elif final:     #Vestigially always true, final always == -1 which is True-ish
                        if kind.arylen:
                            nblock.Addline(('alloc', name, kind.arylen, kind.OpWidth()))
                        else:
                            for i in range(WidthOf(kind)):
                                p = len(str(WidthOf(kind)-1))
                                ename = name + '_' + str(i).zfill(p) if WidthOf(kind) > 1 else name
                                finals.append((ename, final))
                                nblock.Addline(('decl', ename, kind.OpWidth()))
                    else:
                        for i in range(WidthOf(kind)):
                            p = len(str(WidthOf(kind)-1))
                            ename = name + '_' + str(i).zfill(p) if WidthOf(kind) > 1 else name
##                            finals.append((ename, final))
                            nblock.Addline(('nodecl', ename))
##                        nblock.Addline(('nodecl', name))
                        print(f'Unused variable `{name}`')
                    finals = sorted(finals, key = lambda x:x[1])
                elif cmd == 'undecl':
                    name, kind = line[1], line[2]
                    if not kind.comptime:
                        for i in range(WidthOf(kind)):
                            p = len(str(WidthOf(kind)-1))
                            ename = name + '_' + str(i).zfill(p) if WidthOf(kind) > 1 else name
                            nblock.Addline(('undecl', ename))
                elif cmd == 'expr':
                    op, D, S0, S1, S2, width = line[1]
##                    print(comp)
                    S0 = comp.get(S0, S0)
##                    if type(S0) == str and S0.endswith('.&'): S0 = f'{EName(S0, -(-width//32), 0)}.&'
                    try:
                        S1 = comp.get(S1, S1)
                    except:
                        print(f'{S1=}, {line=}')
##                    if type(S1) == str and S1.endswith('.&'): S1 = f'{EName(S1, -(-width//32), 0)}.&'
                    
                    S2 = comp.get(S2, S2)
                    eid = line[2]
                    HandleFinals(eid)
##                    print(D, comp)
                    if D in comp:
                        if op[0]=='@':
                            op = op[1:]
                        if op == '+':
                            comp[D] = S0 + S1
                        elif op == '-':
                            comp[D] = S0 - S1
                        elif op == '=':
                            comp[D] = S0
                        elif op == '<<':
                            comp[D] = S0 << S1
                        elif op == '>>':
                            comp[D] = S0 >> S1
                        elif op == 'bit':
                            i0 = S0 & S1
                            i1 = S0 & ~S1
                            i2 = ~S0 & S1
                            i3 = ~S0 & ~S1
                            comp[D] = ((S2 >> 0 & 1) * i0) | ((S2 >> 1 & 1) * i1) | ((S2 >> 2 & 1) * i2) | ((S2 >> 3 & 1) * i3)
                        elif op == '&':
                            comp[D] = S0 & S1
                        elif op == '|':
                            comp[D] = S0 | S1
                        elif op == '^':
                            comp[D] = S0 ^ S1
                        elif op == '%':
                            comp[D] = S0 % S1
                        elif op == '/':
                            comp[D] = S0 // S1
                        elif op == '~':
                            comp[D] = ~S0
                        elif op == '*':
                            comp[D] = S0 * S1
                        else:
                            assert op != '<<<' and op != '>>>', f'Cannot perform bit rotation on unsized compile time integers'
                            assert False, f'Cannot lower comptime operand `{op}`'
                    elif width == 32:
                        if op == 'breakpoint':
                            AddPent(nblock, op, D, S0, S1, S2)
                        elif op[0]=='@':
                            AddPent(nblock, op[1:], D, S0, S1, S2)
                        elif op == '+':
                            AddPent(nblock, 'add', D, S0, S1, S2)
                        elif op == '-':
                            AddPent(nblock, 'sub', D, S0, S1, S2)
                        elif op == '&':
                            AddPent(nblock, 'and', D, S0, S1, S2)
                        elif op == '|':
                            AddPent(nblock, 'or', D, S0, S1, S2)
                        elif op == '*' and type(S1) == int and (S1==S1&-S1):
                            AddPent(nblock, 'bsl', D, S0, log(S1), S2)
                        elif op == '*':
                            print('WARNING: COMPILING USING BAD MULTIPLICATION')
                            AddPent(nblock, 'mul', D, S0, S1, S2)
                        elif op == '=':
                            AddPent(nblock, 'mov', D, S0, S1, S2)
                        elif op == '[]=':
                            AddPent(nblock, 'stw', D, S0, S1, S2)
                        elif op == '=[]':
                            AddPent(nblock, 'ldw', D, S0, S1, S2)
                        elif op == '[:]=':
                            AddPent(nblock, 'bst', D, S0, S1, S2 % 32)
                        elif op == '=[:]':
                            AddPent(nblock, 'bsf', D, S0, S1, S2 % 32)
                        
                        elif op == '<<':
                            AddPent(nblock, 'bsl', D, S0, S1, S2)
                        elif op == '>>':
                            AddPent(nblock, 'bsr', D, S0, S1, S2)
                        
                        elif op == 'argst':
                            AddPent(nblock, 'argst', D, S0, S1, S2)
                        elif op == 'retld':
                            AddPent(nblock, 'retld', D, S0, S1, S2)
                        elif op == 'argld':
                            AddPent(nblock, 'argld', D, S0, None, S2)
                        elif op == 'retst':
                            AddPent(nblock, 'retst', D, S0, S1, S2)
                        elif op == 'call':
                            AddPent(nblock, 'call', D, S0, S1, S2)
                        elif op in ['+>', '+>=', '+<', '+<=', '->', '->=', '-<', '-<=', '==', '!=']:
                            cmp = op
                            lhs = S0
                            rhs = S1
                            if cmp in ['==', '!=']:
                                cmp = {'==': 'eq', '!=': 'ne'}[cmp]
                            else:
                                cmp = 'us'['+-'.index(cmp[0])] + {'>': 'gt', '>=': 'ge', '<=': 'le', '<': 'lt'}[cmp[1:]]
                            AddPent(nblock, cmp, None, lhs, rhs, None)
                        elif op == '=<>':
                            D, S, dk, sk = D, S0, S1, S2
                            if sk.comptime:
                                for i in range(WidthOf(dk)):
                                    p = len(str(WidthOf(dk)-1))
                                    ename = D + '_' + str(i).zfill(p) if WidthOf(dk) > 1 else D
                                    AddPent(nblock, 'mov', ename, S % (1<<32), None, None)
                                    S >>= 32
                            elif dk.OpWidth() // 32 == dk.OpWidth() / 32:
                                for i in range(WidthOf(dk)):
                                    pD = len(str(WidthOf(dk)-1))
                                    pS = len(str(WidthOf(sk)-1))
                                    eD = D + '_' + str(i).zfill(pD) if WidthOf(dk) > 1 else D
                                    eS = (S + '_' + str(i).zfill(pS) if WidthOf(sk) > 1 else S) if i < WidthOf(sk) else 0
                                    AddPent(nblock, 'mov', eD, eS, None, None)
                            elif dk.OpWidth() < 32:
                                for i in range(WidthOf(dk)):
                                    pD = len(str(WidthOf(dk)-1))
                                    pS = len(str(WidthOf(sk)-1))
                                    eD = D + '_' + str(i).zfill(pD) if WidthOf(dk) > 1 else D
                                    eS = (S + '_' + str(i).zfill(pS) if WidthOf(sk) > 1 else S) if i < WidthOf(sk) else 0
                                    AddPent(nblock, 'mov', eD, eS, None, None)
                            else:
                                print(f'Compiling line:\n{line}')
                                assert False, f'(Comptime) Cannot cast from type `{sk}` to `{dk}`'
                        else:
                            assert False, f'Cannot lower operand `{op}` 32 width'
                    else:
                        assert op[0] != '@', f'Cannot perform instrincs on non 32 width instructions'
                        if op == '=':
                            rwidth = -(-width//32)
                            for i in range(rwidth):
                                eD = EName(D, rwidth, i) 
##                                p = len(str(rwidth-1))
##                                eD = D + '_' + str(i).zfill(p) if rwidth > 1 else D
                                if type(S0) == str:
                                    if S0[-2:] == '.&':
                                        eS = EName(S0[:-2], rwidth, i) +'.&'
                                    else:
                                        eS = EName(S0, rwidth, i) 
##                                        eS = S0 + '_' + str(i).zfill(p)
                                else:
                                    eS = S0
##                                eS = eS.replace('.&', '') + '.&' if '.&' in eS else eS
                                AddPent(nblock, 'mov', eD, eS, None, None)
                        elif op == 'argst':
                            rwidth = -(-width//32)
                            for i in range(rwidth):
                                p = len(str(rwidth-1))
                                eD = D + '_' + str(i).zfill(p) if rwidth > 1 else D
##                                eS = eS.replace('.&', '') + '.&' if '.&' in eS else eS
                                AddPent(nblock, 'argst', eD, S0+i, None, None)
                        elif op == '=[:]':
                            rwidth = -(-width//32)
                            i = 0
                            eS0 = EName(S0, rwidth, 0)
                            while S2 > 32:
                                S2 -= 32
                                eD = EName(D, rwidth, i)
                                eS = EName(S0, rwidth, i)
                                if type(S1) == int:
                                    nblock.Addline(('memsave', eS))
                                    AddPent(nblock, 'ld', eD, eS0+'.&', S1+32*i, 32 % 32)
                                else:
                                    sad
                                i += 1
                            eD = EName(D, rwidth, i)
                            eS = EName(S0, rwidth, i)
                            if type(S1) == int:
                                nblock.Addline(('memsave', eS))
                                AddPent(nblock, 'ld', eD, eS0+'.&', S1+32*i, S2 % 32)
                        elif op == '[:]=':
                            D, S0 = S0, D
                            print(width)
                            rwidth = -(-width//32)
                            i = 0
                            eS0 = EName(S0, rwidth, 0)
                            while S2 > 32:
                                S2 -= 32
                                eD = EName(D, rwidth, i)
                                eS = EName(S0, rwidth, i)
                                if type(S1) == int:
                                    nblock.Addline(('memsave', eS))
                                    AddPent(nblock, 'st', eD, eS0+'.&', S1+32*i, 32 % 32)
                                    nblock.Addline(('regrst', eS))
                                else:
                                    sad
                                i += 1
                            eD = EName(D, rwidth, i)
                            eS = EName(S0, rwidth, i)
                            if type(S1) == int:
                                nblock.Addline(('memsave', eS))
                                AddPent(nblock, 'st', eD, eS0+'.&', S1+32*i, S2 % 32)
                                nblock.Addline(('regrst', eS))
                            else:
                                sad
                        else:
                            print(f'Compiling line:\n{line}')
                            assert False, f'HLIR -> LLIR does not currently support non-primative width `{width}` on operation `{op}`'
                    finex = []
                else:
                    assert False, f'Bad Command `{cmd}`'
                    err
            if block.exit:
                mode = block.exit[0]
                if mode == 'goto':
                    lbl = block.exit[1]
                    eid = block.exit[2]
                    HandleFinals(eid)
                    AddPent(nblock, 'jmp', lbl+':', None, None, None)
                elif mode == 'c.jmp':
                    lbl = block.exit[1]
                    AddPent(nblock, 'c.jmp', lbl+':', None, None, None)
                elif mode == 'if':
                    lhs, cmp, rhs, lbl = block.exit[1]
                    eid = block.exit[2]
                    HandleFinals(eid)
                    if cmp in ['==', '!=']:
                        cmp = {'==': 'eq', '!=': 'ne'}[cmp]
                    else:
                        cmp = 'us'['+-'.index(cmp[0])] + {'>': 'gt', '>=': 'ge', '<=': 'le', '<': 'lt'}[cmp[1:]]
                    AddPent(nblock, cmp, lhs, rhs, None, None)
                    AddPent(nblock, 'jmp', lbl+':', None, None, None, ['c.'])
                elif mode == 'return':
                    eid = block.exit[1]
                    HandleFinals(eid)
                    i = 0
##                    for name, kind in args:
##                        for j in range(WidthOf(kind)):
##                            p = len(str(WidthOf(kind)-1))
##                            ename = name + '_' + str(i).zfill(p) if WidthOf(kind) > 1 else name
##                            nblock.Addline(('argret', ename, i))
##                            i += 1
                    AddPent(nblock, 'ret', None, None, None, None)
                else:
                    assert False, f'HLIR -> LLIR does not support block exit `{mode}`'
            llir.func['body'].append(nblock)

    return llir

if __name__ == '__main__':
    print(f'This file should not be run directly')
