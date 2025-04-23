import LowerHLIR2 as LHL

Ceil = lambda x:-(-x//1)

MAXUINT = 1<<32
MaxOptions = 4
ExpScaleUp = .5

jumps = ['jmp', 'c.jmp', 'cn.jmp']
usesRd = ['st', 'stchr']
depsGlobal = ['glcd']
modsRd = ['bst']
memReads = ['ld', 'lda', 'ldw']
memWrites = ['st', 'sta', 'stw']
hasSideEffects = ['susp', 'use']+memWrites
funcRenumId = 0
NOASSERT = False
globalticker = 0
gExprID = 0

class BlockSet:
    def __init__(self, blocks):
        self.blocks = blocks
        self.dom = {}
        self.idom = {}
        self.dom_fr = {}
        self.ids = {}
        self.frefs = set()

    def __repr__(self):
        global NOASSERT
        NOASSERT += 1
        ret =  '\n'.join([repr(x) for x in self.blocks])
        NOASSERT -= 1
        return ret

    def UpdateDominators(self):
        self.dom = {}
        self.idom = {}
        self.dom_fr = {}
        self.dom[self.blocks[0].label] = set([self.blocks[0].label])
        anynode = set([x.label for x in self.blocks])
        for block in self.blocks[1:]:
            self.dom[block.label] = set(anynode)

        do = True
        while do:
            do = False
            for block in self.blocks[1:]:
                ndoms = set(anynode)
                for pred in block.Preds():
                    ndoms &= self.dom[pred]
                res = set([block.label]) | ndoms
                if res != self.dom[block.label]:
                    do = True
                    self.dom[block.label] = res
        for block in self.blocks:
            self.dom[block.label] -= set([block.label])

        for block in self.blocks[1:]:
            for dom in self.dom[block.label]:
                for odom in self.dom[block.label]:
                    if odom == dom: continue
                    if dom in self.dom[odom]: break #If we found a dominator of block that is dominated by another, its not the idom
                else:
                    self.idom[block.label] = dom #Nothing dominates this dominator, we have what we want
                    break
            else:
                assert False, f'Block `{block.label}` with dominators `{self.dom[block.label]}` has no idom'
        for block in self.blocks:
            self.dom_fr[block.label] = set()

##        print(f'new dominators is {self.dom!r}, with idom {self.idom!r}')

        for block in self.blocks:
            preds = block.Preds()
            if len(preds) >= 2:
                for pred in preds:
                    runner = pred
                    while runner != self.idom[block.label]:
                        self.dom_fr[runner] |= set([block.label])
                        runner = self.idom[runner]
        
                    
        
##        print(f'{self.dom_fr=}')

    def Renumber(self, prefix = ''):
        reps = {}
        for i, block in enumerate(self.blocks[1:], 0):
            lbl = f'L{i}' if prefix == '' else f'L{prefix}{i}'
            reps[block.label] = block.label = lbl
        for block in self.blocks:
            if block.exit[0] in jumps:
                block.exit = (block.exit[0], reps[block.exit[1].rstrip(':')])

    def GlobalRenumber(self):
        global funcRenumId
        prefix = ''
        r = funcRenumId
        while True:
            r, m = divmod(r, 26)
            prefix = chr(ord('A')+m)+prefix
            if r == 0: break
        self.Renumber(prefix)
        funcRenumId += 1
            

    def ForwardJumps(self):
        didOpt = True
        while didOpt:
            didOpt = False


            for block in self.blocks[1:]:
                if len(block.Preds()) == 0:
                    del self.blocks[self.blocks.index(block)]
                    didOpt = True

            #Replace jumps to empty blocks with their destination
            for block in self.blocks:
                if block.exit[0] in jumps:
                    succ = block.exit[1]
                    succblock = self.ByName(succ)
                    if succblock.IsEffEmpty():
                        block.exit = list(block.exit)
##                        assert succblock.Succs() not in [(None,), ()], f'{block.label} -> {succblock.label} {succblock.Succs()=}\n{self}'
                        succ = succblock.Succs()
                        if succ == ():
                            block.exit = ('ret',)
                            didOpt = True
                        else:
                            if succ[0] != block.exit[1]: didOpt = True
                            block.exit[1] = succ[0]
                        block.exit = tuple(block.exit)
                        block.body += succblock.body
##                        didOpt = True

            #Replace empty block fall throughs with the destination
            for i, block in enumerate(self.blocks):
                if block.IsEffEmpty() and len(block.JumpPreds()) == 0:
                    for pred in block.Preds():
                        predblock = self.ByName(pred)
##                        print(f'{block.label} <- {pred} : {predblock.exit}')
                        if predblock.exit != 'FALL': continue
                        predblock.exit = block.exit
                        predblock.body += block.body
                        didOpt = True
                        del self.blocks[i]
                        break

            #Replace jumps past an empty jump with a negated jump
            for i, block in enumerate(self.blocks):
                if block.IsEffEmpty() and block.exit[0] == 'jmp':
                    np = block.NatPreds()
                    if len(np) == 0: continue
                    pred = np[0]
                    predblock = self.ByName(pred)
                    
                    if predblock.exit[0] not in jumps: continue
                    predest = predblock.exit[1]
                    if predest != block.FallThru(): continue

                    newexit = (['c.jmp', 'cn.jmp'][['cn.jmp', 'c.jmp'].index(predblock.exit[0])], block.exit[1])
                    predblock.exit = newexit

                    del self.blocks[i]
                    didOpt = True
                    break

    def ByName(self, label):
        for block in self.blocks:
            if block.label == label: return block
        assert False, f'Could not find block label `{label}`'

    def PropogateUses(self):
        for block in self.blocks:
            block.localvars = {}
            for line in block.body:
                if line[0] == 'decl':
                    block.localvars[line[1]] = ['loc', 'loc']
                    idx = block.body.index(line)
##                    block.body.insert(idx+1, ('expr', 'mov', line[1], [None]))
                if line[0] == 'alloc':
                    self.frefs.add(line[1])
                    block.localvars[line[1]] = ['loc', 'loc']
                if line[0] == 'expr' and line[1] == 'argld':
                    block.localvars[line[2]] = ['loc', 'loc']
                    continue
                if line[0] != 'expr': continue
                for arg in line[3]:
                    if type(arg) == str:
                        pre = 'pre' if block.label != self.blocks[0].label else 'loc'
                        life = block.localvars[arg] = block.localvars.get(arg, [pre, 'loc'])
        do = True
        while do:
            do = False
            for block in self.blocks:
                for pred in block.Preds():
                    predblock = self.ByName(pred)
                    for var, life in block.localvars.items():
                        if life[0] != 'pre': continue
                        pre = 'pre' if block.label != self.blocks[0].label else 'loc'
                        prelife = predblock.localvars[var] = predblock.localvars.get(var, [pre, 'loc'])
##                        print(f'Local variable `{var}` of `{block.label}` has life in predecessor block `{pred}` of `{prelife}`')
                        if prelife[1] != 'post':
                            prelife[1] = 'post'
                            do = True
                     

    def ToSSA(self):
        self.ids = {}
        self.UpdateDominators()
        self.PropogateUses()
        phiblocks = set()
        for k in self.dom_fr.values():
            phiblocks |= k
        varsonexit = {}
        for block in self.blocks:
            isphi = block.label in phiblocks
            if isphi:
                for var, life in block.localvars.items():
                    if life[0] != 'pre': continue
                    block.body.insert(0, ['expr', '..phi', var, []])
            else:
                for var, life in block.localvars.items():
                    if life[0] != 'pre': continue
                    block.body.insert(0, ['expr', '..mov', var, []])
            for line in block.body[:]:
                i = block.body.index(line)
                line = block.body[i] = list([list(x) if type(x) == tuple else x for x in line])
                if line[0] != 'expr': continue
                dest = line[2]
                args = line[3]
                for j, arg in enumerate(args):
                    if type(arg) == int: continue
                    self.ids[arg] = self.ids.get(arg, 0)
                    line[3][j] = f'{self.ids[arg]}_{arg}'
                if type(dest) == int or dest == None: continue
                self.ids[dest] = self.ids.get(dest, -1)+1
                line[2] = f'{self.ids[dest]}_{dest}'
            localexitnames = {}
            for var, life in block.localvars.items():
                if life[1] != 'post': continue
                localexitnames[var] = self.ids.get(var, 0)
            varsonexit[block.label] = localexitnames
        for block in self.blocks:
            if block.label in phiblocks:
                for line in block.body:
                    if not(line[0] == 'expr' and line[1][:2] == '..'): continue
                    var = line[2]
                    for pred in block.Preds():
                        redname = var.split('_', maxsplit=1)[1]
                        idx = varsonexit[pred][redname]
                        line[3].append(f'{idx}_{redname}')
                        line[1] = 'phi'
                    if all([x == line[3][0] for x in line[3]]):
                        line[:4] = ['expr', 'mov', line[2], line[3][:1]]
            else:
                for line in block.body:
                    if not(line[0] == 'expr' and line[1][:2] == '..'): continue
                    var = line[2]
                    pred = self.idom.get(block.label)
                    if pred == None: assert False, f'While converting to SSA, found a non phi block thats unreachable `{block.label}` with preds `{block.Preds()}` on line `{line}`\nThis usually occurs if youre trying to access a variable not properly defined in the first logical block and it fails to fetch it'
                    redname = var.split('_', maxsplit=1)[1]
                    idx = varsonexit[pred][redname]
                    line[3].append(f'{idx}_{redname}')
                    line[1] = 'mov'
            block.EnsureTagged()

    #Small note, due to how SSA works, we cannot mov into phi functions as these dont actually exist an when theyre dropped bugs will appear
    #Unless we want to aggressively optimize, we'll keep moves into named variables so that when we MovTrace we get better variable names
    def MovForward(self, aggressive = False):
        do = True
        while do:
            do = False
            reps = {}
            for block in self.blocks:
                for line in block.body:
                    if line[0] != 'expr': continue
                    if line[1] != 'mov': continue
##                    print(f'LINE: {line}')
                    if not aggressive and type(line[3][0]) == str and line[3][0].split('_')[1][0] == 't':
                        reps[line[3][0]] = line[2]
                    else:
                        reps[line[2]] ,= line[3]
            print(reps)

            for block in self.blocks:
                for i, line in enumerate(block.body):
                    if line[0] != 'expr' or line[1] == 'phi': continue
                    for j, arg in enumerate(line[3]):
                        if arg in reps:
                            if reps[arg] == arg or reps[arg] == line[2]: continue
                            block.body[i][3][j] = reps[arg]
                            do = True

    def MovTrace(self):
        #Expect SSA
        #If we find a construct of `op A B C D` and `mov Z A`, we can mov trace and do `op Z B C D`
        do = True
        while do:
            do = False
            writes = set()
            reads = {}
            brep = {}

            for block in self.blocks:
                for line in block.body:
                    if line[0] == 'decl': continue
                    if line[0] != 'expr': continue
                    if line[1] == 'call': continue
                    if type(line[2]) == str: writes.add(line[2])
                    for arg in line[3]:
                        if type(arg) == str and arg != line[2]:
                            reads[arg] = reads.get(arg, 0)+1
                            if line[1] == 'mov':
                                brep[arg] = line[2]
            for block in self.blocks:
                for line in block.body:
                    if line[0] == 'decl': continue
                    if line[0] != 'expr': continue
                    if line[1] == 'call': continue
                    idx = block.body.index(line)
                    if reads.get(line[2], 0) == 1 and line[2] in brep:
                        line[2] = brep[line[2]]
                        del block.body[idx+1]
                        do = True
                        break
                else: continue
                break
            

    def ElimWritesWithoutRead(self) -> bool:
        #Expects SSA, and as such a read of own self write is illegal and illdefined
        writes = set()
        reads = set()
        decls = set()
        names = set()
        did = False
        for block in self.blocks:
            for line in block.body:
                if line[0] == 'decl': decls.add(line[1])
                if line[0] != 'expr': continue
                if line[1] == 'call': continue
                if type(line[2]) == str: writes.add(line[2])
                for arg in line[3]:
                    if type(arg) == str and arg != line[2]:
                        reads.add(arg)
                        names.add(arg.split('_', maxsplit=1)[1])
        diff = writes - reads
        do = True
        while do:
            do = False
            for block in self.blocks:
                for line in block.body[:]:
                    idx = block.body.index(line)
                    if line[0] != 'expr' or line[2] not in diff:
                        if line[0] == 'expr' and line[1] == 'mov' and line[2] == line[3][0]:
                            pass
                        else:
                            continue
                    elif line[0] == 'expr' and (line[1] in hasSideEffects or line[1].endswith('.s')): continue
                    assert block.body[idx] == line
                    del block.body[idx]
                    do = True
                    did = True
##        print(f'Needless declares: `{decls-names}`')
        #Declarations without read
        for decl in decls - names:
            for block in self.blocks:
                for line in block.body[:]:
                    idx = block.body.index(line)
                    if line[0] == 'predecl' and line[1] <= 1:
                        del block.body[idx]
                        did = True
                    if not(line[0] == 'decl' and line[1] == decl): continue
                    del block.body[idx]
                    did = True
                    for j in range(1, 1<<100):
                        line = block.body[idx-j]
                        if line[0] == 'predecl':
                            line[1] -= 1
                            if line[1] <= 1:
                                del block.body[idx-j]
                        elif line[0] == 'decl':
                            continue
                        break
        return did

    def ComputeRefables(self):
        for block in self.blocks:
            block.refs=set()|self.frefs
            for line in block.body:
                if line[0]=='expr' and line[1]=='addr':
                    arg = line[3][0]
                elif line[0] == 'expr' and line[1] == 'argld':
                    arg = line[2]
                    self.frefs.add(arg.split('_')[1])
                elif line[0] in ['alloc']:
                    arg = line[1]
                    
                else: continue
                if arg[0].isnumeric():
                    arg = arg.split('_', maxsplit=1)[1]
                if '_' in arg and arg[-1].isnumeric():
                    arg = arg[::-1].split('_', maxsplit=1)[1][::-1]
                block.refs.add(arg)

    def PropPotValues(self):
        def ValueOf(ident: str|int) -> ValueOption:
            if type(ident) == int:
                return ValueOption(32, ident)
            else:
                return values.get(ident, None)
        
        #Expect SSA
        oldvalues = None
        values = {}
        maxiter = 100
        while values != oldvalues:
            maxiter -= 1
            if maxiter == 0: assert False, f'Optimization loop failed to terminate after 100 iters'
            oldvalues = values.copy()
            for block in self.blocks:
                for line in block.body[:]:
                    i = block.body.index(line)
                    if line[0] == 'decl':
                        values[f'0_{line[1]}'] = ValueOption(line[2], None, True)
                    elif line[0] == 'alloc':
                        values[f'0_{line[1]}'] = ValueOption(32, line[1])
                    elif line[0] == 'expr':
##                        print(f'LINE[1] = {line[1]}')
                        dest = line[2]
                        args = [ValueOf(x) for x in line[3]]

                        if line[1] == 'mayread':
##                            print('MAYREAD')
                            if not args[0]: continue
                            for opt in args[0].opts:
                                if type(opt) == Symbolic:
                                    ref = opt.symbol
                                    if ref[0].isnumeric():
                                        ref = ref.split('_', maxsplit=1)[1]
                                    if ref[-1].isnumeric() and '_' in ref:
                                        ref = ref[::-1].split('_', maxsplit=1)[1][::-1]
                                    var = line[3][1]
                                    if var[0].isnumeric():
                                        var = var.split('_', maxsplit=1)[1]
                                    if var[-1].isnumeric() and '_' in var:
                                        var = var[::-1].split('_', maxsplit=1)[1][::-1]
                                    if var == ref:
##                                        print(var, ref)
##                                        assert False
                                        break
                            else:
                                del block.body[i]
                        
                        if type(dest) != str: continue
                        if line[1] == 'mov':
                            values[dest] = args[0]
                        elif line[1] == 'phi':
                            res = args[0]
                            for arg in args[1:]:
                                if res == None or arg == None:
                                    res = None
                                    break
                                res = res.MergeWith(arg)
                            else:
                                values[dest] = res
                        elif line[1] == 'addr':
                            values[dest] = ValueOption(32, line[3][0].rstrip('.&'))
                        elif line[1] == 'add':
                            if any(x == None for x in args): continue
                            values[dest] = args[0] + args[1]
                        elif line[1] == 'sub':
                            if any(x == None for x in args): continue
                            values[dest] = args[0] - args[1]
                        elif line[1] == 'bsl':
                            if any(x == None for x in args): continue
                            values[dest] = args[0].bsl(args[1])
                        elif line[1] == 'bsr':
                            if any(x == None for x in args): continue
                            values[dest] = args[0].bsr(args[1])
                        elif line[1] == 'argld':
                            values[dest] = ValueOption(32, str(line[2]).split('_', maxsplit=1)[1])
##                            if line[3][0] in
                        else:
                            mayundef = any(x != None and x.mayBeUndefined for x in args)
                            values[dest] = ValueOption(32, [Any], mayundef)
                        pass
##        print('New Iter')
##        for k,v in values.items():
##            print(f'{str(k).ljust(20)}{v}')

    def FromSSA(self):
        for block in self.blocks:
            for line in block.body[:]:
                if line[0] != 'expr': continue
                idx = block.body.index(line)
                for j, arg in enumerate(line[3]):
                    if type(arg) == str:
                        line[3][j] = arg.split('_', maxsplit=1)[1]
                if type(line[2]) == str:
                    line[2] = line[2].split('_', maxsplit=1)[1]
                if line[1] in ['phi'] or line[1] == 'mov' and line[2] == line[3][0]:
                    del block.body[idx]
                    continue

    def PruneUnreachable(self):
        do = True
        while do:
            do = False
            unreaches = set()
            for block in self.blocks:
                 for line in block.body:
                     if line[0] == 'unreachable':
                         unreaches.add(block.label)
                         break
            for block in self.blocks:
                if block.exit[0] in ['c.jmp', 'cn.jmp'] and block.exit[1] in unreaches:
                    block.exit = ('FALL',)
                elif block.exit[0] in ['FALL'] and block.FallThru() in unreaches:
                    unreaches.add(block.label)
                    do = True
        for block in unreaches:
            idx = [i for i,x in enumerate(self.blocks) if x.label == block][0]
            del self.blocks[idx]

    def InsertPotMutations(self):
        for block in self.blocks:
            for line in block.body[:]:
                i = block.body.index(line)
                if line[0] == 'expr' and line[1]=='call': 
##                    print(f'FOUND CALL w/ refs {block.refs=}')
                    for var in block.localvars:
                        _var = var
                        for refvar in block.refs:
                            if '_' in var and var[-1].isnumeric():
                                var = var[::-1].split('_', maxsplit=1)[1][::-1]
                            if var == refvar:
                                block.body.insert(i, ('expr', 'maywrite', _var, ()))
                elif line[0] == 'expr' and line[1] in memReads: 
                    for var in block.localvars:
                        _var = var
                        for refvar in block.refs:
                            if '_' in var and var[-1].isnumeric():
                                var = var[::-1].split('_', maxsplit=1)[1][::-1]
                            if var == refvar:
                                block.body.insert(i, ('expr', 'mayread', None, (line[3][0], _var)))
                elif line[0] == 'expr' and line[1]in memWrites: 
##                    print(f'FOUND CALL w/ refs {block.refs=}')
                    for var in block.localvars:
                        _var = var
                        for refvar in block.refs:
                            if '_' in var and var[-1].isnumeric():
                                var = var[::-1].split('_', maxsplit=1)[1][::-1]
                            if var == refvar:
                                block.body.insert(i, ('expr', 'maywrite', _var, ()))
            block.EnsureTagged()

    def EliminateRedundantReads(self):
        for block in self.blocks:
            reads = set()
            decls = set()
            for line in block.body[:]:
                i = block.body.index(line)
                if line[0] == 'decl':
                    decls.add(line[1])
                if line[0] == 'expr' and line[1] == 'mayread':
                    arg = line[3][1]
                    if arg in reads:
                        del block.body[i]
                    elif arg.split('_', maxsplit=1)[1] not in block.localvars or (block.localvars[arg.split('_', maxsplit=1)[1]][0] == 'loc' and arg.split('_', maxsplit=1)[1] not in decls):
                        print('DELETE', block.body[i], arg.split('_', maxsplit=1)[1], decls)
                        del block.body[i]
                    reads.add(arg)


class Block:
    def __init__(self, parent: BlockSet, unoptBlock: LHL.Block):
        global globalticker, globalExprID
        self.label = unoptBlock.entry
        self.body = unoptBlock.body[:]
        self.parent = parent
        self.localvars = {}
        self.refs = {}
        if len(self.body) > 0 and self.body[-1][0] == 'expr' and self.body[-1][1][0] in ['jmp', 'c.jmp', 'ret']:
            self.exit = self.body[-1][1]
            del self.body[-1]
        else:
            self.exit = ('FALL',)
        if ('unreachable',) in self.body:
            self.exit = ('ret',)

        for line in self.body[:]:
            i = self.body.index(line)
            if line[0] == 'expr':
                if line[1][0] in usesRd+modsRd:
                    if line[1][0] in modsRd:
                        self.body[i] = ('expr', line[1][0], line[1][1], tuple([x for x in line[1][1:] if x != None]))
                    else:
                        self.body[i] = ('expr', line[1][0], None, tuple([x for x in line[1][1:] if x != None]))
                else:
                    self.body[i] = ('expr', line[1][0], line[1][1], tuple([x for x in line[1][2:] if x != None]))
                if line[1][0] in memWrites:
                    self.body[i] = list(self.body[i])
                    self.body[i][2] = self.body[i][3][1]
                    self.body[i] = tuple(self.body[i])

                if self.body[i][1] == 'argst':
                    globalticker += 2
            if line[0] == 'decl':
                self.body.insert(i+1, ('expr', 'addr', line[1]+'.&', (line[1],)))
                #Also does double duty as the immediate use means that the variable naming gets properly init'd
                
            

        while True:
            for line in self.body[:]:
                if line[0] in ['undecl', 'memsave', 'memsavebit', 'regrst']:
                    del self.body[self.body.index(line)]
            break
        for line in self.body: assert line[0] != 'undecl'
        self.EnsureTagged()

    def ToLLIR(self):
        out = LHL.Block(self.label, None)
        for i, line in enumerate(self.body):
            if line[-1].startswith('eid'): del line[-1]
            if line[0] == 'expr':
                nline = ['expr', [line[1], line[2], *line[3]]]
                if line[1] in usesRd+modsRd:
                    if line[1] in modsRd:
                        del nline[1][1]
                    else:
                        del nline[1][1]
                nline[1] = tuple(nline[1])
                self.body[i] = nline
            self.body[i] = tuple(self.body[i])
        out.body = self.body
        out.exit = self.exit
        return out

    def EnsureTagged(self):
        global gExprID
        for line in self.body:
            if not (type(line[-1]) == str and line[-1].startswith('eid ')):
                self.body[self.body.index(line)] = (list(line)+[f'eid {gExprID}'])
                gExprID += 1

    def __repr__(self):
        def fmtline(line):
            if type(line[-1]) == str and line[-1].startswith('eid '):
                return f'    [{hex(int(line[-1][4:]))[2:].upper().zfill(4)}] {line[:-1]}\n'
            else:
                return f'    -    - {line}\n'
        return self.label + f' -> {self.Succs()} <- J{self.JumpPreds()} + N{self.NatPreds()} *{self.refs}:\n' \
        + f'  Vars: `{self.localvars}`\n' \
        + ''.join([fmtline(line) for line in self.body])+f'  {self.exit}\n'

    def JumpPreds(self):
        preds = []
        for block in self.parent.blocks:
            if self.label in block.JumpSuccs():
                preds.append(block.label)
        return tuple(preds)

    def NatPreds(self):
        jp = self.JumpPreds()
        return tuple([x for x in self.Preds() if x not in jp])

    def Preds(self):
        global NOASSERT
        preds = []
        for block in self.parent.blocks:
            NOASSERT += 1
            if self.label in block.Succs():
                preds.append(block.label)
            NOASSERT -= 1
        return tuple(preds)

    def FallThru(self):
        idx = self.parent.blocks.index(self)
        if idx >= len(self.parent.blocks)-1: return None
        return self.parent.blocks[idx+1].label

    def Succs(self):
        global NOASSERT
        if self.exit[0] == 'ret':
            return ()
        if self.exit[0] == 'FALL':
            ret =  (self.FallThru(),)
            assert ret[0] != None or NOASSERT, (''*(NOASSERT := NOASSERT + 1) + f'CENSURE: Block {self.label} implicitly returns of function {self.parent.blocks[0].label}. Printed below\n\n\n{self.parent}')
            return ret
        elif self.exit[0] in ['c.jmp', 'cn.jmp']:
            return (self.exit[1], self.FallThru())
        elif self.exit[0] == 'jmp':
            return (self.exit[1],)
        else: assert False, f'Unreachable, exit is `{self.exit!r}`'

    def JumpSuccs(self):
        fall = self.FallThru()
        return tuple([x for x in self.Succs() if x != fall])

    def IsEffEmpty(self):
        for line in self.body:
            if line[0] in ['expr', 'unreachable']: return False
        return True
        

class ValueOption:
    def __init__(self, bits, val: str|int|list|None, mayBeUndefined = False, fallbacks = 8):
        self.bits = bits
        self.opts = []
        self.mayBeUndefined = mayBeUndefined
        self.fallbacks = fallbacks
        if val == None:
            pass
        elif type(val) == int:
            self.opts.append(IntRange(bits, val, val+1))
        elif type(val) == str:
            self.opts.append(Symbolic(val))
        elif type(val) == list:
            self.opts = val
        else: assert False

    def __repr__(self):
        return f'ValueOption({self.bits}, {self.opts!r}, mayBeUndefined = {self.mayBeUndefined}, fallbacks = {self.fallbacks!r})'

    def __str__(self):
        return f'{{{" || ".join([str(x) for x in self.opts+["Undef"]*self.mayBeUndefined])}}}@({self.fallbacks}/8)'

    def ReStruct(self, forced = False):
        newopts = self.opts
        if len(newopts) == 0:
            return self
        mfs = self.fallbacks
        mayundef = self.mayBeUndefined
        filtered = newopts[:1]
        for opt in newopts[1:]:
            if type(opt) == IntRange and opt.high > filtered[-1].high and opt.high > opt.low:
                filtered.append(opt)
            elif type(opt) == Symbolic and (type(filtered[-1]) == Symbolic or filtered[-1].high != filtered[-1].maxuint):
                filtered.append(opt)
        if forced or len(filtered) > MaxOptions:
            if (forced or mfs > 0) and all([type(x) == IntRange for x in filtered]):
                newwidth = filtered[-1].high - filtered[0].low
                oldwidth = max([1]+[x.high-x.low for x in self.opts])
                tarwidth = Ceil(oldwidth * (1+ExpScaleUp))
                if newwidth < tarwidth:
                    mfs -= 1
##                    print(f'Decrement of mfs to `{mfs}`')
                return ValueOption(self.bits, [IntRange(self.bits, filtered[0].low, filtered[-1].high)], mayundef, mfs)
            else:
                if mfs == 0 or any([x.low == 0 for x in filtered if type(x) == IntRange]):
##                    print(f'Fail open -> {ValueOption(self.bits, [Any], mayundef, mfs)}')
                    return ValueOption(self.bits, [Any], mayundef, mfs)
                return ValueOption(self.bits, [IntRange(self.bits, 1, MAXUINT)], mayundef, mfs)
        return ValueOption(self.bits, filtered, mayundef, mfs)

    def MergeWith(self, other):
        rawconcat = self.opts + other.opts
        newopts = sorted(rawconcat)
        mfs = min(self.fallbacks, other.fallbacks)
        mayundef = self.mayBeUndefined or other.mayBeUndefined
        return ValueOption(self.bits, newopts, mayundef, mfs).ReStruct()

    def ToSigned(self):
        opts = []
        sopts = sorted(self.opts)
        for opt in sopts:
            if type(opt) == IntRange and opt.high >= opt.maxint:
                opts.append(IntRange(self.bits, opt.low, opt.maxint, checked = False))
                opts.append(IntRange(self.bits, -opt.maxint, opt.high - opt.maxuint, checked = False))
            else:
                opts.append(opt)
        return ValueOption(self.bits, opts).CombineRuns()

    def FromSigned(self):
        opts = []
        sopts = sorted(self.opts)
        for opt in sopts:
            if type(opt) == IntRange and opt.low < 0:
                opts.append(IntRange(self.bits, 0, opt.high, checked = False))
                opts.append(IntRange(self.bits, opt.low + opt.maxuint, opt.maxuint, checked = False))
            else:
                opts.append(opt)
        return ValueOption(self.bits, opts).CombineRuns()

    def CombineRuns(self):
        opts = sorted(self.opts)
        nopts = opts[:1]
        for opt in opts[1:]:
            if type(opt) == IntRange and opt.low <= nopts[-1].high:
                nopts[-1].high = opt.high
            else:
                nopts.append(opt)
        return ValueOption(self.bits, nopts)

    def __eq__(self, other):
        if type(other) != type(self): return False
        return repr(self.ReStruct(True)) == repr(other.ReStruct(True))

    def BinaryOp(self, func, other):
        nopts = []
        for l in self.opts:
            for r in other.opts:
                nopts.append(func(l, r))
        return ValueOption(self.bits, nopts, self.mayBeUndefined or other.mayBeUndefined, min(self.fallbacks, other.fallbacks)).ReStruct()

    def __add__(self, other):
        return self.BinaryOp(lambda x, y: x + y, other)

    def __sub__(self, other):
        return self.BinaryOp(lambda x, y: x - y, other)

    def bsl(self, other):
        return self.BinaryOp(lambda x, y: x.bsl(y), other)

    def bsr(self, other):
        return self.BinaryOp(lambda x, y: x.bsr(y), other)

class Symbolic:
    def __init__(self, symbol: str, inv: bool = False):
        self.symbol = symbol
        self.inv = inv

    def __repr__(self):
        return f'Symbolic({self.symbol!r}, {self.inv})'

    def __str__(self):
        return '~'*self.inv + repr(self.symbol)

    def __lt__(self, _):
        return False

    def __gt__(self, _):
        return True

    def __add__(self, other):
        if type(other) == IntRange: return self
        elif type(other) == Symbolic: return Any

    def __sub__(self, other):
        if type(other) == IntRange: return self
        elif type(other) == Symbolic: return Any

    def bsl(self, other):
        if type(other) == IntRange: return self
        elif type(other) == Symbolic: return Any

    def bsr(self, other):
        if type(other) == IntRange: return self
        elif type(other) == Symbolic: return Any

    

#Upper value not included
class IntRange:
    def __init__(self, bits: int, low: int, high: int, checked = True):
        self.low = low if not checked or low >= 0 else 0
        self.maxuint = 1<<bits
        self.maxint = 1<<(bits-1)
        self.bits = bits
        self.high = high if not checked or high <= self.maxuint else self.maxuint

    def __repr__(self):
        return f'IntRange({self.bits}, {self.low}, {self.high})'

    def __str__(self):
        if self.high == self.low + 1:
            return str(self.low)
        if self.high == self.maxuint and self.low == 0:
            return f'Any'
        if self.high == self.maxuint and self.low == 1:
            return f'NonZero'
        return f'[{self.low}, {self.high})'

    def __lt__(self, other):
        if type(other) == Symbolic:
            return True
        elif self.low == other.low:
            self.high > other.high
        else:
            return self.low < other.low

    def __gt__(self, other):
        return other < self

    #True case, False case
    def cmp(self, op, other):
        negops = ['le', 'ge', 'ne']
        posops = ['gt', 'lt', 'eq']
        if op in negops:
            return self.cmp(posops[negops.index(op)], other[::-1])
        if type(other) == Symbolic:
            return [self, self]
        if op == 'gt':
            self, other = other, self
            op = 'lt'
        if op == 'lt':
            tlow = self.low
            thigh = other.high-1
            flow = other.low
            fhigh = self.high
            return [IntRange(self.bits, tlow, thigh),
                    IntRange(self.bits, flow, fhigh)]
        elif op == 'eq':
            pass

    def __add__(self, other):
        if type(other) == IntRange:
            return IntRange(self.bits, self.low + other.low, self.high + other.high)
        elif type(other) == Symbolic: return other

    def __sub__(self, other):
        if type(other) == IntRange:
            return IntRange(self.bits, self.low - other.high, self.high - other.low)
        elif type(other) == Symbolic: return other

    def bsl(self, other):
        if type(other) == IntRange:
            return IntRange(self.bits, self.low << other.low, self.high << other.high)
        elif type(other) == Symbolic: return other

    def bsr(self, other):
        if type(other) == IntRange:
            return IntRange(self.bits, self.low >> other.high, self.high >> other.low)
        elif type(other) == Symbolic: return other

def Optimize(llir: LHL.LLIR) -> None:
    global funcRenumId
    newfuncs = []
    preprune = ''
    for func in llir.funcs:
        body = BlockSet([])
        newfuncs.append(body)
        for block in func['body']:
            body.blocks.append(Block(body, block))
            
        body.Renumber()
        body.ForwardJumps()
        body.Renumber()

##        print(repr(body))

        
        body.ToSSA()
        body.MovForward()

##        print(repr(body))

        body.MovTrace()

##        print(repr(body))

        
##        body.ComputeRefables()
##        body.FromSSA()
##        print(repr(body))
##        body.InsertPotMutations()
##        print(repr(body))
##        body.ToSSA()
##        print(repr(body))

        while body.ElimWritesWithoutRead():
            pass
        #body.ComputeRefables()

##        print(repr(body))
        
        #body.PropPotValues()
        body.EliminateRedundantReads()
        body.ElimWritesWithoutRead()
        body.PropogateUses()


        preprune += repr(body)+'\n'

##        print(repr(body))
        
##        body.FromSSA()
##        body.ToSSA()
##        body.EliminateRedundantReads()
##        body.ElimWritesWithoutRead()
##        body.ElimWritesWithoutRead()
        body.FromSSA()

        body.PruneUnreachable()

##        func['body'] = []
##        for block in body.blocks:
##            func['body'].append(block.ToLLIR())

##        assert '____Init' not in func['name']

    funcRenumId = 0
    optlr = ''
    for ofunc, ifunc in zip(llir.funcs, newfuncs):
        ifunc.GlobalRenumber()
        optlr += repr(ifunc)+'\n'
        ofunc['body'] = []
        print(repr(ifunc))
        for block in ifunc.blocks:
            ofunc['body'].append(block.ToLLIR())
    with open(f'out_opt.llr', 'w') as f:
        f.write(optlr)
    with open(f'out_preprune_opt.llr', 'w') as f:
        f.write(preprune)


Any = IntRange(32, 0, MAXUINT)
