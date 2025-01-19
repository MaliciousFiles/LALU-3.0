from lark import Lark, Token, Tree

parser = Lark.open("LLPC_grammar.lark", rel_to=__file__, parser="lalr")
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

def logerror(func):
    def inner(*args, **kwargs):
        global FAILED
        try:
            return func(*args, **kwargs)
        except Exception as e:
            tree = args[0]
            if type(tree) == Tree:
                if type(tree.data) == str:
                    print(f'In `{tree.data}`')
                    start = tree.children[0].data.start_pos
                    end = tree.children[0].data.end_pos
                else:
                    start = tree.data.start_pos
                    end = tree.data.end_pos
                line = txt[:start].count('\n')
                if len(txt[start:].split('\n')) > 1:
                    body = txt[start:].split('\n')[1]
                else:
                    body = txt[start:].split('\n')[0]
                if body:
                    print(f'Error on line {line+1}:\n' + body)
            elif type(tree) == Token:
                start = tree.start_pos
                end = tree.end_pos
                line = txt[:start].count('\n')
                body = txt[start:].split('\n')[0]
                if body:
                    print(f'Error on line {line+1}:\n' + body)
            raise e
    return inner

##FAILED = False

@logerror
def Gen(tree):
    global out, ind, inter
    if type(tree) == Tree:
        data = tree.data
        if data.type == 'RULE' and data.value == 'start':
            Gen(tree.children[0])
        elif data.type == 'RULE' and data.value == 'ex_decl':
            _, name, _, rargs, _, ret, body = tree.children
            args = []
            if rargs:
                for arg in rargs.children:
                    aname, _, akind = arg.children
                    args.append((aname.children[0].value, akind.children[0].value))
            inter.NewFunc(name.children[0].value, args, ret.children[0].value)
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
            inter.AddPent(op = '=', D = name, S0 = rhs, S1 = None, S2 = None)
        elif data.type == 'RULE' and data.value == 'exprstmt':
            expr, _, = tree.children
            _ = Rvalue(expr.children[0])
        elif data.type == 'RULE' and data.value == 'blockstmt':
            stmts = tree.children[1:-1]
            for stmt in stmts:
                Gen(stmt)

        elif data.type == 'RULE' and data.value == 'stmt':
            Gen(tree.children[0])
        else:
            print(tree)
            assert False, f'Uh oh'
    else:
        assert False, f'Bad'

@logerror
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
            return f'{lhs}.&', lk.Addr()
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
        elif data.value == 'addexpr':
            le, op, re = expr.children
            lhs, lk = Rvalue(le)
            rhs, rk = Rvalue(re)
            op = op.children[0].value
            kind = lk.Common(rk)
            tmp = NewTemp(kind)
            inter.AddPent(op = op, D = tmp, S0 = lhs, S1 = rhs, S2 = None, width = kind.OpWidth())
            return tmp, kind
        elif data.value == 'multexpr':
            le, op, re = expr.children
            lhs, lk = Rvalue(le)
            rhs, rk = Rvalue(re)
            op = op.children[0].value
            kind = lk.Common(rk)
            tmp = NewTemp(kind)
            inter.AddPent(op = op, D = tmp, S0 = lhs, S1 = rhs, S2 = None, width = kind.OpWidth())
            return tmp, kind
        elif data.value == 'bandexpr':
            le, _, re = expr.children
            lhs, lk = Rvalue(le)
            rhs, rk = Rvalue(re)
            kind = lk.Common(rk)
            tmp = NewTemp(kind)
            inter.AddPent(op = '&', D = tmp, S0 = lhs, S1 = rhs, S2 = None, width = kind.OpWidth())
            return tmp, kind
        elif data.value == 'bxorexpr':
            le, _, re = expr.children
            lhs, lk = Rvalue(le)
            rhs, rk = Rvalue(re)
            kind = lk.Common(rk)
            tmp = NewTemp(kind)
            inter.AddPent(op = '^', D = tmp, S0 = lhs, S1 = rhs, S2 = None, width = kind.OpWidth())
            return tmp, kind
        elif data.value == 'borexpr':
            le, _, re = expr.children
            lhs, lk = Rvalue(le)
            rhs, rk = Rvalue(re)
            kind = lk.Common(rk)
            tmp = NewTemp(kind)
            inter.AddPent(op = '|', D = tmp, S0 = lhs, S1 = rhs, S2 = None, width = kind.OpWidth())
            return tmp, kind
        elif data.value == 'relexpr':
            le, op, re = expr.children
            lhs, lk = Rvalue(le)
            rhs, rk = Rvalue(re)
            op = op.children[0].value
            kind = lk.Common(rk)
            tmp = NewTemp(kind)
            inter.AddPent(op = op, D = lhs, S0 = rhs, S1 = None, S2 = None, width = kind.OpWidth())
            return tmp, kind
        elif data.value == 'assgexpr':
            le, _, re = expr.children
            lhs, lk = Lvalue(le)
            rhs, rk = Rvalue(re)
            assert rk.CanCoerceTo(lk)
            inter.AddPent(op = '=', D = lhs, S0 = rhs, S1 = None, S2 = None, width = lk.OpWidth())
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
            elif op.children[0].value == '!':
                assert False, f'Not yet implemented'
            else:
                assert False, f'Bad unary: `{op}`'
        elif data.value == 'castexpr':
            le, re, = expr.children
            lk = Type.FromStr(le.children[0].value)
            rhs, rk = Rvalue(re)
            tmp = NewTemp(lk)
            inter.AddPent(op = '=', D = tmp, S0 = rhs, S1 = None, S2 = None, width = lk.OpWidth())
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
def Lvalue(expr):
    global inter
    if type(expr) == Tree:
        data = expr.data

        if data == 'indexpr':
            le, _, re, _, = expr.children
            rhs, rk = Rvalue(re)
            lhs, lk = Rvalue(le)
            tmp = f'{lhs}[{rhs}]'
            return tmp, lk.Deref()
        elif data == 'derefexpr':
            le, _, _, = expr.children
            lhs, lk = Rvalue(le)
            tmp = NewTemp(lk.Deref())
            tmp = f'{lhs}[0]'
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
            print(data.value)
            bad
    else:
        print(expr)
        err

def NewTemp(kind):
    global tid
    tid += 1; ID = f't{tid}'
    inter.Decl(ID, kind)
##    WriteLine(f'decl {ID}: {kind}')
    return ID

class LLIR:
    def __init__(self):
        self.funcs = []
        self.envs = []

    def __repr__(self):
        o = ''
        for func in self.funcs:
            oa = ", ".join([f'{name}: {kind}' for name,kind in func['args']])
            o += (f'fn {func["name"]} ({oa}) {func["ret"]} '+'{') + '\n'
            for block in func['body']:
                o += '  '+(f'{block.entry}:') + '\n'
                for line in block.body:
                    o += '    '+repr(line) + '\n'
                o += '  '+(f'{block.exit}') + '\n'
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
        self.body.Addline(('decl', name, kind))
    def AddPent(self, op, D, S0, S1, S2, width = 32):
        if type(D) == str and '[' in D:
            l, r = D[:-1].split('[')
            assert op == '=', f'Expected operation to be `=` when lhs is array, got `{op}`.\nLine was: `{(op, D, S0, S1, S2, width)}`'
            self.body.Addline(('expr', ('[]=', l, r, S0, S2, width)))
        elif type(S0) == str and '[' in S0:
            l, r = S0[:-1].split('[')
            assert op == '=', f'Expected operation to be `=` when rhs is array, got `{op}`.\nLine was: `{(op, D, S0, S1, S2, width)}`'
            self.body.Addline(('expr', ('[]=', D, l, r, S2, width)))
        else:
            self.body.Addline(('expr', (op, D, S0, S1, S2, width)))
class Type:
    def __init__(self, width = 32, signed = False, numPtrs = 0, comptime = False):
        self.width = width
        self.signed = signed
        self.numPtrs = numPtrs
        self.comptime = comptime
    def FromStr(txt):
        self = Type()
        if '!' in txt:
             self.comptime = True
             txt = txt.replace('!', '')
        else:
            self.comptime = False
        self.signed = txt[0]=='s'
        self.numPtrs = txt.count('*')
        self.width = int(txt[1:len(txt)-self.numPtrs])
        return self
    def OpWidth(self):
        return 24 if self.numPtrs else self.width
    def __repr__(self):
        return f'Type.FromStr("{self}")'
    def __str__(self):
        return f'{"!"*self.comptime}{"ui"[self.signed]}{self.width}{"*"*self.numPtrs}'
    def CanCoerceTo(self, other):
        if other.comptime:
            return False
        if self.numPtrs > 0:
            if other.numPtrs > 0:
                return other.numPtrs == self.numPtrs
            else:
                return False == other.signed and other.width >= 24
        else:
            return self.signed == other.signed and other.width >= self.width
    def Common(self, other):
        bc = self.comptime and other.comptime
        if self.numPtrs > 0:
            if other.numPtrs > 0:
                assert False, f'Cannot do math on two pointer types `{self}` and `{other}`'
            else:
                if not bc and self.comptime:
                    return self.Runtime()
                else:
                    return self
        else:
            if other.numPtrs > 0:
                if not bc and other.comptime:
                    return other.Runtime()
                else:
                    return other
            assert self.signed == other.signed, f'Cannot do math on different signs `{self}` and `{other}`'
            return Type(max(self.width, other.width), self.signed, 0, bc)
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
        self.exit = 'EOF'
    def Addline(self, line):
        self.body.append(line)
    def End(self, jmp):
        self.exit = jmp
   
syms = [{}]
out = ''
ind = 0
tid = 0

inter = LLIR()
Gen(tree)

print('\nOUT:')
print(out)
print('\nREP:')
print(repr(inter))
