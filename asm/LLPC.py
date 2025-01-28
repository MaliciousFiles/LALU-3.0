from lark import Lark, Token, Tree
import LowerHLIR as LHL
import LowerLLIR2 as LLL

PTRWIDTH = 32

parser = Lark.open("LLPC_grammar.lark", rel_to=__file__, parser="lalr", propagate_positions = True)
with open('prog.lpc', 'r') as f:
    tree = parser.parse(txt := f.read())

def Write(txt):
    global out
    out += '  '*ind + txt
def WriteLine(txt):
    global out
    out += '  '*ind + txt + '\n'

def Indent():
    global ind
    ind += 1
def Dendent():
    global ind
    ind -= 1

def TrackLine(func):
    global inter, srcs
    def inner(*args, **kwargs):
        ret = func(*args, **kwargs)
        for i, block in enumerate(inter.func['body']):
            for j, line in enumerate(block.body):
                nsrc = func.__name__
                if type(args[0]) == Tree:
                    nsrc = nsrc + f'({args[0].meta.start_pos}, {args[0].meta.end_pos})'
                if line[-2] != 'src':
                    srcs.append([nsrc])
                    inter.func['body'][i].body[j] = line + ('src', len(srcs)-1,)
                else:
                    src = line[-1]
                    srcs[src].append(nsrc)
        return ret
    return inner

def logerror(func):
    def inner(*args, **kwargs):
        global FAILEDLINE
        try:
            return func(*args, **kwargs)
        except Exception as e:
            tree = args[0]
            start = tree.meta.start_pos
            end = tree.meta.end_pos
            line = txt[:start].count('\n')
            pline = txt[:start].split('\n')[-1]
            body = txt[start:].split('\n')[0]
            body = pline + body
            if FAILEDLINE != body:
                FAILEDLINE = body
                print(f'Error on line {line+1}:\n  ' + body.lstrip(' ').lstrip('\t'))
            raise e
    return inner

FAILEDLINE = None

@logerror
@TrackLine
def Gen(tree):
    global out, ind, inter
    if type(tree) == Tree:
        data = tree.data
        if data == 'break':
            assert len(inter.loops) > 0, f'Cannot break out of no loop'
            top, bot = inter.loops[-1]
            inter.Jump(bot)
        elif data == 'continue':
            assert len(inter.loops) > 0, f'Cannot continue from no loop'
            top, bot = inter.loops[-1]
            inter.Jump(top)
        elif data == 'return':
            inter.Return()
        elif data == 'returnexpr':
            _, expr, _, = tree.children
            inter.Return(Rvalue(expr.children[0]))
        elif type(data) == str:
            print(data)
            print(expr)
            err
        
        elif data.type == 'RULE' and data.value == 'start':
            Gen(tree.children[0])
        elif data.type == 'RULE' and data.value == 'ex_decl':
            _, name, _, rargs, _, ret, body = tree.children
            args = []
            if rargs:
                for arg in rargs.children:
                    aname, _, akind = arg.children
                    args.append((aname.children[0].value, Type.FromStr(akind.children[0].value)))
            ret = Type.FromStr(ret.children[0].value)
            inter.NewFunc(name.children[0].value, args, ret)
            Gen(body)
            inter.PopEnv()
        elif data.type == 'RULE' and data.value == 'declstmt':
            _, name, _, kind, _, = tree.children
            kind = kind.children[0].value
            name = name.children[0].value
            inter.Decl(name, Type.FromStr(kind))
        elif data.type == 'RULE' and data.value == 'declexpr':
            _, name, _, kind, _, expr, _, = tree.children
            rhs, tkind = Rvalue(expr.children[0])
            name = name.children[0].value
            kind = Type.FromStr(kind.children[0].value)
            assert tkind.CanCoerceTo(kind), f'Type `{tkind}` cannot coerce into type `{kind}`'
            inter.Decl(name, kind)
            assert tkind.CanCoerceTo(kind)
            inter.CastAddPent(op = '=', D = name, S0 = rhs, S1 = None, S2 = None, desttype = kind, origtype = tkind)
        elif data.type == 'RULE' and data.value == 'exprstmt':
            expr, _, = tree.children
            if expr:
                _ = Rvalue(expr.children[0])
        elif data.type == 'RULE' and data.value == 'encexprstmt':
            if type(tree.children[0]) == Tree:
                _ = Rvalue(expr.children[0])
        elif data.type == 'RULE' and data.value == 'blockstmt':
            stmts = tree.children[1:-1]
            inter.NewEnv()
            for stmt in stmts:
                Gen(stmt)
            inter.PopEnv()
        elif data.type == 'RULE' and data.value == 'dostmt':
            _, _, expr, _, stmt = tree.children
            pre = NewLabel()
            inner = NewLabel()
            post = NewLabel()
            inter.PushLoopLabels(pre, post)
            inter.AddLabel(inner)
            Gen(stmt.children[0])
            inter.AddLabel(pre)
            inter.trues.append(inner)
            inter.falses.append(post)
            cond, _ = Rvalue(expr.children[0])
            assert len(inter.trues) == 1, f'Len(Trues) should be 1, got {inter.trues}'
            assert len(inter.falses) == 1, f'Len(Falses) should be 1, got {inter.falses}'
            inter.trues = []; inter.falses = []
            if cond:
                inter.CJump(cond, post)
            inter.PopLoopLabels(pre, post)
            inter.AddLabel(post)
        elif data.type == 'RULE' and data.value == 'doelsestmt':
            _, _, expr, _, stmt0, _, stmt1 = tree.children
            pre = NewLabel()
            inner = NewLabel()
            post = NewLabel()
            _else = NewLabel()
            inter.PushLoopLabels(pre, post)
            inter.AddLabel(inner)
            Gen(stmt0.children[0])
            inter.trues.append(inner)
            inter.falses.append(_else)
            inter.AddLabel(pre)
            cond, _ = Rvalue(expr.children[0])
            assert len(inter.trues) == 1, f'Len(Trues) should be 1, got {inter.trues}'
            assert len(inter.falses) == 1, f'Len(Falses) should be 1, got {inter.falses}'
            inter.trues = []; inter.falses = []
            if cond:
                inter.CJump(cond, _else)
            inter.PopLoopLabels(pre, post)
            inter.AddLabel(_else)
            Gen(stmt1.children[0])
            inter.AddLabel(post)
        elif data.type == 'RULE' and data.value == 'whilestmt':
            _, _, expr, _, stmt = tree.children
            pre = NewLabel()
            inner = NewLabel()
            post = NewLabel()
            inter.trues.append(inner)
            inter.falses.append(post)
            inter.PushLoopLabels(pre, post)
            inter.AddLabel(pre)
            cond, _ = Rvalue(expr.children[0])
            assert len(inter.trues) == 1, f'Len(Trues) should be 1, got {inter.trues}'
            assert len(inter.falses) == 1, f'Len(Falses) should be 1, got {inter.falses}'
            inter.trues = []; inter.falses = []
            if cond:
                inter.CJump(cond, post)
            inter.AddLabel(inner)
            Gen(stmt.children[0])
            inter.Jump(pre)
            inter.PopLoopLabels(pre, post)
            inter.AddLabel(post)
        elif data.type == 'RULE' and data.value == 'whileelsestmt':
            _, _, expr, _, stmt0, _, stmt1 = tree.children
            pre = NewLabel()
            inner = NewLabel()
            post = NewLabel()
            _else = NewLabel()
            inter.trues.append(inner)
            inter.falses.append(_else)
            inter.PushLoopLabels(pre, post)
            inter.AddLabel(pre)
            cond, _ = Rvalue(expr.children[0])
            assert len(inter.trues) == 1, f'Len(Trues) should be 1, got {inter.trues}'
            assert len(inter.falses) == 1, f'Len(Falses) should be 1, got {inter.falses}'
            inter.trues = []; inter.falses = []
            if cond:
                inter.CJump(cond, _else)
            inter.AddLabel(inner)
            Gen(stmt0.children[0])
            inter.Jump(pre)
            inter.PopLoopLabels(pre, post)
            inter.AddLabel(_else)
            Gen(stmt1.children[0])
            inter.AddLabel(post)
        elif data.type == 'RULE' and data.value == 'forelsestmt':
            _, _, preexpr, cond, postexpr, _, body, _, elseexpr = tree.children
            pre = NewLabel()
            inner = NewLabel()
            post = NewLabel()
            _else = NewLabel()
            inter.trues.append(inner)
            inter.falses.append(_else)
            inter.PushLoopLabels(pre, post)
            Gen(preexpr.children[0])
            inter.AddLabel(pre)
            cond, _ = Rvalue(cond.children[0])
            assert len(inter.trues) == 1, f'Len(Trues) should be 1, got {inter.trues}'
            assert len(inter.falses) == 1, f'Len(Falses) should be 1, got {inter.falses}'
            inter.trues = []; inter.falses = []
            if cond:
                inter.CJump(cond, _else)
            inter.AddLabel(inner)
            Gen(body.children[0])
            if type(postexpr.children[0]) == Tree:
                _ = Rvalue(postexpr.children[0])
            inter.Jump(pre)
            inter.PopLoopLabels(pre, post)
            inter.AddLabel(_else)
            Gen(elseexpr.children[0])
            inter.AddLabel(post)
        elif data.type == 'RULE' and data.value == 'forstmt':
            _, _, preexpr, cond, postexpr, _, body, = tree.children
            pre = NewLabel()
            inner = NewLabel()
            post = NewLabel()
            inter.trues.append(inner)
            inter.falses.append(post)
            inter.PushLoopLabels(pre, post)
            inter.NewEnv()
            Gen(preexpr.children[0])
            inter.AddLabel(pre)
            cond, _ = Rvalue(cond.children[0])
            assert len(inter.trues) == 1, f'Len(Trues) should be 1, got {inter.trues}'
            assert len(inter.falses) == 1, f'Len(Falses) should be 1, got {inter.falses}'
            inter.trues = []; inter.falses = []
            if cond:
                inter.CJump(cond, post)
            inter.AddLabel(inner)
            inter.NewEnv()
            Gen(body.children[0])
            if type(postexpr.children[0]) == Tree:
                _ = Rvalue(postexpr.children[0])
            inter.Jump(pre)
            inter.PopEnv()
            inter.PopEnv()
            inter.PopLoopLabels(pre, post)
            inter.AddLabel(post)
        elif data.type == 'RULE' and data.value == 'ifstmt':
            _, _, cond, _, body, = tree.children
            inner = NewLabel()
            post = NewLabel()
            inter.trues.append(inner)
            inter.falses.append(post)
            cond, _ = Rvalue(cond.children[0])
            assert len(inter.trues) == 1, f'Len(Trues) should be 1, got {inter.trues}'
            assert len(inter.falses) == 1, f'Len(Falses) should be 1, got {inter.falses}'
            inter.trues = []; inter.falses = []
            if cond:
                inter.CJump(cond, post)
            inter.AddLabel(inner)
            Gen(body.children[0])
            inter.AddLabel(post)
        elif data.type == 'RULE' and data.value == 'ifelsestmt':
            _, _, cond, _, body, _, _else = tree.children
            inner = NewLabel()
            einner = NewLabel()
            post = NewLabel()
            inter.trues.append(inner)
            inter.falses.append(einner)
            cond, _ = Rvalue(cond.children[0])
            assert len(inter.trues) == 1, f'Len(Trues) should be 1, got {inter.trues}'
            assert len(inter.falses) == 1, f'Len(Falses) should be 1, got {inter.falses}'
            inter.trues = []; inter.falses = []
            if cond:
                inter.CJump(cond, einner)
            inter.AddLabel(inner)
            Gen(body.children[0])
            inter.Jump(post)
            inter.AddLabel(einner)
            Gen(_else.children[0])
            inter.AddLabel(post)
        
        elif data.type == 'RULE' and data.value == 'stmt':
            Gen(tree.children[0])
        else:
            print(tree)
            assert False, f'Uh oh'
    else:
        assert False, f'Bad'

@logerror
@TrackLine
def Rvalue(expr):
    global inter
    if type(expr) == Tree:
        data = expr.data

        if data == 'indexpr':
            le, _, re, _, = expr.children
            rhs, rk = Rvalue(re)
            lhs, lk = Rvalue(le)
            tmp = NewTemp(lk.Deref())
            inter.AddPent(op = '=[]', D = tmp, S0 = lhs, S1 = rhs, S2 = None)
            return tmp, lk.Deref()
        elif data == 'derefexpr':
            le, _, _, = expr.children
            lhs, lk = Rvalue(le)
            tmp = NewTemp(lk.Deref())
            inter.AddPent(op = '=[]', D = tmp, S0 = lhs, S1 = 0, S2 = None)
            return tmp, lk.Deref()
        elif data == 'addrexpr':
            le, _, _, = expr.children
            lhs, lk = Rvalue(le)
            inter.PreUse(lhs)
            return f'{lhs}.&', lk.Addr()
        elif data == 'intrinsic':
            _, name, _, args, _, = expr.children
            name = name.children[0].value
            ct = False
            if args:
                ct=True
                nargs = []
                for arg in args.children:
                    if type(arg)==Tree:
                        v, k = Rvalue(arg)
                        nargs.append(v)
                        if not k.comptime:
                            ct = False
                args = nargs
            else:
                args = []
##            args = [x.children[0].value for x in args.children if type(x)==Tree] if args else []
            assert len(args) <= 3, f'Intrinsic functions do not support more than 3 arguements'
            args += [None]*3
##            if ct:
            tmp = NewTemp(Type(comptime = ct))
            inter.AddPent(op = '@'+name, D = tmp, S0 = args[0], S1 = args[1], S2 = args[2])
            return tmp, Type()
        elif data == 'true':
            inter.Jump(inter.trues[-1])
            return None, Type(isbool = True)
        elif data == 'false':
            inter.Jump(inter.falses[-1])
            return None, Type(isbool = True)
        elif type(data) == str:
            print(data)
            print(expr)
            err
        
        if data.type == 'RULE' and data.value == 'ident':
            ident = expr.children[0].value
            kind = inter.Lookup(ident)
            return ident, kind
        elif data.value == 'decint':
            return int(''.join([x for x in expr.children]).replace('_', '')), Type(comptime = True)
        elif data.value == 'hexint':
            return int(''.join([x for x in expr.children]).replace('_', ''), 16), Type(comptime = True)
        elif data.value == 'landexpr':
            lhs, _, rhs = expr.children
            lbl = NewLabel()
            inter.trues.append(lbl)
            Rvalue(lhs)
            inter.AddLabel(lbl)
            del inter.trues[-1]
            Rvalue(rhs)
            return None, Type(isbool = True)
        elif data.value == 'lorexpr':
            lhs, _, rhs = expr.children
            lbl = NewLabel()
            inter.falses.append(lbl)
            Rvalue(lhs)
            inter.AddLabel(lbl)
            del inter.falses[-1]
            Rvalue(rhs)
            return None, Type(isbool = True)
        elif data.value == 'addexpr':
            le, op, re = expr.children
            lhs, lk = Rvalue(le)
            rhs, rk = Rvalue(re)
            op = op.children[0].value
            kind = lk.Common(rk)
            tmp = NewTemp(kind)
            inter.CastAddPent(op = op, D = tmp, S0 = lhs, S1 = rhs, S2 = None, desttype = kind, origtype = kind)
            return tmp, kind
        elif data.value == 'multexpr':
            le, op, re = expr.children
            lhs, lk = Rvalue(le)
            rhs, rk = Rvalue(re)
            op = op.children[0].value
            kind = lk.Common(rk)
            tmp = NewTemp(kind)
            inter.CastAddPent(op = op, D = tmp, S0 = lhs, S1 = rhs, S2 = None, desttype = kind, origtype = kind)
            return tmp, kind
        elif data.value == 'bandexpr':
            le, _, re = expr.children
            lhs, lk = Rvalue(le)
            rhs, rk = Rvalue(re)
            kind = lk.Common(rk)
            tmp = NewTemp(kind)
            inter.CastAddPent(op = '&', D = tmp, S0 = lhs, S1 = rhs, S2 = None, desttype = kind, origtype = kind)
            return tmp, kind
        elif data.value == 'bxorexpr':
            le, _, re = expr.children
            lhs, lk = Rvalue(le)
            rhs, rk = Rvalue(re)
            kind = lk.Common(rk)
            tmp = NewTemp(kind)
            inter.CastAddPent(op = '^', D = tmp, S0 = lhs, S1 = rhs, S2 = None, desttype = kind, origtype = kind)
            return tmp, kind
        elif data.value == 'borexpr':
            le, _, re = expr.children
            lhs, lk = Rvalue(le)
            rhs, rk = Rvalue(re)
            kind = lk.Common(rk)
            tmp = NewTemp(kind)
            inter.CastAddPent(op = '|', D = tmp, S0 = lhs, S1 = rhs, S2 = None, desttype = kind, origtype = kind)
            return tmp, kind
        elif data.value == 'relexpr':
            le, op, re = expr.children
            lhs, lk = Rvalue(le)
            rhs, rk = Rvalue(re)
            op = op.children[0].value
            assert lk.CanCoerceTo(rk) or rk.CanCoerceTo(lk), f'Cannot do comparison on uncoerceable types `{lk}` and `{rk}`'
            if op in ['>', '>=', '<=', '<']:
                inter.IfJump(lhs, '+-'[lk.signed]+op, rhs, inter.trues[-1])
            else:
                inter.IfJump(lhs, op, rhs, inter.trues[-1])
            inter.Jump(inter.falses[-1])
            return None, Type(isbool = True)
        elif data.value == 'assgexpr':
            le, op, re = expr.children
            lhs, lk = Lvalue(le)
            rhs, rk = Rvalue(re)
##            print(op.children)
            if len(op.children[0].value) == 2:
                op = op.children[0].value[:-1]
                assert rk.CanCoerceTo(lk)
                kind = lk.Common(rk)
                inter.CastAddPent(op = op, D = lhs, S0 = lhs, S1 = rhs, S2 = None, desttype = lk, origtype = kind)
            else:
                assert rk.CanCoerceTo(lk), f'Cannot coerce `{lk}` into type `{rk}`'
                inter.CastAddPent(op = '=', D = lhs, S0 = rhs, S1 = None, S2 = None, desttype = lk, origtype = rk)
            return lhs, lk
        elif data.value == 'unaryexpr':
            op, re = expr.children
            rhs, rk = Rvalue(re)
            if (op.children[0].value == '+'):
                return rhs, rk
            elif op.children[0].value == '-':
                tmp = NewTemp(rk)
                inter.AddPent(op = '-', D = tmp, S0 = 0, S1 = rhs, S2 = None, width = rk.OpWidth())
                return tmp, rk
            elif op.children[0].value == '~':
                tmp = NewTemp(rk)
                inter.AddPent(op = 'bit', D = tmp, S0 = rhs, S1 = 0, S2 = 0b1001, width = rk.OpWidth())
                return tmp, rk
##                assert False, f'Not yet implemented'
            else:
                assert False, f'Bad unary: `{op}`'
        elif data.value == 'lunaryexpr':
            _, re = expr.children
            print(inter.trues)
            inter.trues[-1], inter.falses[-1] = inter.falses[-1], inter.trues[-1]
            print(inter.trues)
            rhs, rk = Rvalue(re)
            return None, Type(isbool = True)
        elif data.value == 'castexpr':
            le, re, = expr.children
            lk = Type.FromStr(le.children[0].value)
            rhs, rk = Rvalue(re)
            tmp = NewTemp(lk)
            inter.Cast(tmp, rhs, lk, rk)
##            inter.AddPent(op = '=', D = tmp, S0 = rhs, S1 = None, S2 = None, width = lk.OpWidth())
            return tmp, lk
        elif data.value == 'constant':
            return Rvalue(expr.children[0])
        elif data.value == 'primexpr':
            _, ex, _, = expr.children
            return Rvalue(ex)
        elif data.value == 'expr':
            return Rvalue(expr.children[0])
        else:
            print(data.value)
            print(expr)
            bad
    else:
        print(expr)
        err

@logerror
@TrackLine
def Lvalue(expr):
    global inter
    if type(expr) == Tree:
        data = expr.data

        if data == 'indexpr':
            le, _, re, _, = expr.children
            rhs, rk = Rvalue(re)
            lhs, lk = Rvalue(le)
            tmp = f'{lhs}[{rhs}]'
##            inter.PreUse(lhs)
            return tmp, lk.Deref()
        elif data == 'derefexpr':
            le, _, _, = expr.children
            lhs, lk = Rvalue(le)
##            tmp = NewTemp(lk.Deref())
            tmp = f'{lhs}[0]'
##            inter.PreUse(lhs)
            return tmp, lk.Deref()
        elif type(data) == str:
            print(data)
            print(expr)
            err
        
        if data.type == 'RULE' and data.value == 'ident':
            ident = expr.children[0].value
            kind = inter.Lookup(ident)
            return ident, kind
        elif data.value == 'addexpr':
            assert False, f'Cannot take L-value of arithmetic'
        elif data.value == 'assgexpr':
            assert False, f'Cannot take L-value of assignment'
        elif data.value == 'decint':
            assert False, f'Cannot take L-value of constant'
        elif data.value == 'hexint':
            assert False, f'Cannot take L-value of constant'
        else:
            print(expr)
            print(data.value)
            bad
    else:
        print(expr)
        err

def NewTemp(kind):
    global tid
    tid += 1; ID = f't{tid}'
    inter.Decl(ID, kind)
    return ID

def NewLabel():
    global tid
    tid += 1; ID = f'L{tid}'
    return ID

class HLIR:
    def __init__(self):
        self.funcs = []
        self.envs = []
        self.loops = []
        self.trues = []
        self.falses = []

    def __repr__(self):
        o = ''
        for func in self.funcs:
            oa = ", ".join([f'{name}: {kind}' for name,kind in func['args']])
            o += (f'fn {func["name"]} ({oa}) {func["ret"]} '+'{') + '\n'
            for block in func['body']:
                o += '  '+(f'{block.entry}:') + '\n'
                for line in block.body:
                    o += '    '+repr(line) + '\n'
                o += '  '+(f'{block.exit} \n    FALL: {block.fall}') + '\n\n'
            o += ('}') + '\n'
        return o

    def NewFunc(self, name, args, ret):
        self.funcs.append({})
        func = self.func = self.funcs[-1]
        func['name'] = name
        func['args'] = args
        func['ret'] = ret
        self.body = Block('_')
        func['body'] = [self.body]
        
        self.NewEnv()
        for name, kind in args:
            self.Register(name, kind)

    def NewEnv(self):
        self.envs.append({})
    
    def PopEnv(self):
        for env in self.envs[:-1]:
            for var in env:
                print(f'Extend variable `{var}`')
                self.PreUse(var)
        for var in self.envs[-1]:
            print(f'End of var `{var}`')
        del self.envs[-1]

    def Register(self, name, kind):
        self.envs[-1][name] = kind

    def Lookup(self, name):
        for env in self.envs[::-1]:
            if name in env:
                return env[name]
        assert False, f'Cannot find name: `{name}` in current scope'
    def Decl(self, name, kind):
        self.Register(name, kind)
        self.body.Addline(('decl', name, kind, None))
    def CastAddPent(self, op, D, S0, S1, S2, desttype, origtype):
        if desttype.BitSameAs(origtype):
            self.AddPent(op, D, S0, S1, S2, width = desttype.OpWidth())
        else:
            tmp = NewTemp(origtype)
            self.AddPent(op, tmp, S0, S1, S2, width = origtype.OpWidth())
            self.Cast(D, tmp, desttype, origtype)
    def Cast(self, D, S, dk, sk):
        self.Use(S)
        self.AddPent('=<>', D, S, dk, sk)
    def AddPent(self, op, D, S0, S1, S2, width = 32):
        global eid
        eid += 1
        if type(D) == str and '[' in D:
            if op == '=<>':
                tmp = NewTemp(S1)
                eid -= 1
                self.AddPent('=<>', tmp, S0, S1, S2)
                eid += 1
                S0 = tmp
                S2 = None
                op = '='
            l, r = D[:-1].split('[')
            assert op == '=', f'Expected operation to be `=` when lhs is array, got `{op}`.\nLine was: `{(op, D, S0, S1, S2, width)}`'
            self.Use(S0)
            self.Use(r)
            self.Use(S2)
            self.Use(l)
            self.body.Addline(('expr', ('[]=', l, r, S0, S2, width), eid))
        elif type(S0) == str and '[' in S0:
            l, r = S0[:-1].split('[')
            assert op == '=', f'Expected operation to be `=` when rhs is array, got `{op}`.\nLine was: `{(op, D, S0, S1, S2, width)}`'
            self.Use(l)
            self.Use(r)
            self.Use(S2)
            self.body.Addline(('expr', ('=[]', D, l, r, S2, width), eid))
        else:
            self.Use(S0)
            self.Use(S1)
            self.Use(S2)
            if op[0] == '@':
                self.Use(D)
            self.body.Addline(('expr', (op, D, S0, S1, S2, width), eid))
    def AddLabel(self, lbl):
        self.body.fall = lbl
        self.body = Block(lbl)
        self.func['body'].append(self.body)
    def NoFallLabel(self, lbl):
        self.body = Block(lbl)
        self.func['body'].append(self.body)
    def IfJump(self, lhs, op, rhs, lbl):
        global eid
        eid += 1
        self.Use(lhs)
        self.Use(rhs)
        self.body.exit = ('if', (lhs, op, rhs, lbl), eid)
        self.AddLabel('_'+NewLabel())
    def IfFalseJump(self, lhs, op, rhs, lbl):
        global eid
        eid += 1
        self.Use(lhs)
        self.Use(rhs)
        self.body.exit = ('ifFalse', (lhs, op, rhs, lbl), eid)
        self.AddLabel('_'+NewLabel())
    def CJump(self, cond, lbl):
        global eid
        eid += 1
        self.Use(cond)
        self.body.exit = ('if', (cond, '!=', 0, lbl), eid)
        self.AddLabel('_'+NewLabel())
    def Jump(self, lbl):
        global eid
        eid += 1
        self.body.exit = ('goto', (lbl), eid)
        self.body.fall = None
        self.NoFallLabel('_'+NewLabel())
    def PushLoopLabels(self, pre, post):
        self.loops.append([pre, post])
    def PopLoopLabels(self, pre, post):
        del self.loops[-1]
    def Return(self, *args):
        global eid
        eid += 1
        for arg, kind in args:
            print(kind, self.func['ret'])
            assert kind.CanCoerceTo(self.func['ret']), f'Cannot coerce type `{kind}` to `{self.func["ret"]}`'
            self.Use(arg)
        if len(args) == 0:
            assert Type.FromStr('void').CanCoerceTo(self.func['ret']), f'Cannot return without value for function with return type `{self.func["ret"]}`'
        self.body.exit = ('return', args, eid)
        self.body.fall = None
        self.NoFallLabel('_'+NewLabel())
    def PreUse(self, name):
        global eid
        eid += 1
        self.Use(name)
        eid -= 1
    def Use(self, name):
        for j, block in enumerate(self.func['body']):
            for i, line in enumerate(block.body):
                if line[0] == 'decl' and line[1] == name:
                    self.func['body'][j].body[i] = line[:3] + (eid,)
class Type:
    def __init__(self, width = 32, signed = False, numPtrs = 0, comptime = False, isbool = False, isvoid = False):
        self.width = width
        self.signed = signed
        self.numPtrs = numPtrs
        self.comptime = comptime
        self.isbool = isbool
        self.isvoid = isvoid
    def FromStr(txt):
        self = Type()
        if txt == 'void':
            return Type(isvoid = True)
        if txt == 'bool':
            return Type(isbool = True)
        if txt == 'comp':
             return Type(comptime = True)
        self.signed = txt[0]=='i'
        self.numPtrs = txt.count('*')
        self.width = int(txt[1:len(txt)-self.numPtrs])
        return self
    def OpWidth(self):
        return PTRWIDTH if self.numPtrs else self.width
    def __repr__(self):
        return f'Type.FromStr("{self}")'
    def __str__(self):
        if self.isvoid:
            return 'void'
        if self.isbool:
            return 'bool'
        if self.comptime:
            return 'comp'
        else:
            return f'{"ui"[self.signed]}{self.width}{"*"*self.numPtrs}'
    def CanCoerceTo(self, other):
        if self.isbool or other.isvoid:
            return False
        if self.comptime:
            return True
        if other.comptime:
            return False
        if self.numPtrs > 0:
            if other.numPtrs > 0:
                return other.numPtrs == self.numPtrs
            else:
                return False == other.signed and other.width >= PTRWIDTH
        else:
            return self.signed == other.signed and other.width >= self.width
    def BitSameAs(self, other):
        return self.CanCoerceTo(other) and other.CanCoerceTo(self)
    def Common(self, other):
        assert not self.isbool, 'Cannot take a common type of boolean and `{other}`'
        
        bc = self.comptime and other.comptime
        if self.comptime:
            return other
        elif not bc and other.comptime:
            return self
        if self.numPtrs > 0:
            if other.numPtrs > 0:
                assert False, f'Cannot do math on two pointer types `{self}` and `{other}`'
            else:
                return self
        else:
            if other.numPtrs > 0:
                return other
            assert self.signed == other.signed, f'Cannot do math on different signs `{self}` and `{other}`'
            return Type(max(self.width, other.width), self.signed, 0)
    def Deref(self):
        assert self.numPtrs > 0, f'Cannot dereference type `{self}`'
        return Type(self.width, self.signed, self.numPtrs - 1)
    def Addr(self):
        assert not self.comptime, f'Cannot take address of comptime variable `{self}`'
        return Type(self.width, self.signed, self.numPtrs + 1)
    def Runtime(self):
        return Type(self.width, self.signed, self.numPtrs)

class Block:
    def __init__(self, entry):
        self.entry = entry
        self.body = []
        self.exit = None
        self.fall = 'EOF'
    def Addline(self, line):
        self.body.append(line)
   
syms = [{}]
out = ''
ind = 0
tid = 0
eid = 0
srcs=[]

inter = HLIR()
try:
    Gen(tree)
except Exception as e:
    print(e)
    raise e

print('\nOUT:')
print(out)
print('\nHLIR:')
print(repr(inter))

llir = LHL.Lower(inter)

print('\nLLIR:')
print(repr(llir))

asm, bn, fstate = LLL.Lower(llir)

print('\nASM:')
print(repr(asm))

print('\nBIN:')
print(repr(bn))
