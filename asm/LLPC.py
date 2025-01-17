from lark import Lark, Token, Tree

parser = Lark.open("LLPC_grammar.lark", rel_to=__file__, parser="lalr")
with open('prog.lpc', 'r') as f:
    tree = parser.parse(f.read())

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

def Gen(tree):
    global out, ind
    if type(tree) == Tree:
        data = tree.data
        if data.type == 'RULE' and data.value == 'start':
            Gen(tree.children[0])
        elif data.type == 'RULE' and data.value == 'ex_decl':
            _, name, _, args, _, ret, body = tree.children
            Write(f'fn {name.children[0].value} (')
            if args:
                for arg in args.children:
                    if type(arg) == Tree:
                        name, _, kind = arg.children
                        Write(f'{name.children[0].value}: {kind.children[0].value}, ')
            Write(f') {ret.children[0].value} \n')
            Indent()
            Gen(body)
            Dendent()
        elif data.type == 'RULE' and data.value == 'declstmt':
            _, name, _, kind, _, = tree.children
            kind = kind.children[0].value
            name = name.children[0].value
            WriteLine(f'decl {name}: {kind}')
        elif data.type == 'RULE' and data.value == 'declexpr':
            _, name, _, kind, _, expr, _, = tree.children
            rhs, tkind = Rvalue(expr.children[0])
##            kind = kind.children[0].value
            name = name.children[0].value
            WriteLine(f'decl {name}: {tkind}')
            WriteLine(f'{name} = {rhs}')
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

def Rvalue(expr):
    if type(expr) == Tree:
        data = expr.data

        if data == 'indexpr':
            le, _, re, _, = expr.children
            rhs, rk = Rvalue(re)
            lhs, lk = Rvalue(le)
            tmp = NewTemp(lk)
            WriteLine(f'{tmp} = {lhs}[{rhs}]')
            return tmp, lk
        elif type(data) == str:
            print(data)
            print(expr)
            err
        
        if data.type == 'RULE' and data.value == 'ident':
            ident = expr.children[0].value
            kind = 'u32'
            return ident, kind
        elif data.value == 'decint':
            return int(''.join([x for x in expr.children]).replace('_', '')), 'u32'
        elif data.value == 'hexint':
            return int(''.join([x for x in expr.children]).replace('_', ''), 16), 'u32'
        elif data.value == 'addexpr':
            le, _, re = expr.children
            lhs, lk = Rvalue(le)
            rhs, rk = Rvalue(re)
            tmp = NewTemp(lk)
            WriteLine(f'{tmp} = {lhs} + {rhs}')
            return tmp, lk
        elif data.value == 'assgexpr':
            le, _, re = expr.children
            lhs, lk = Lvalue(le)
            rhs, rk = Rvalue(re)
            WriteLine(f'{lhs} = {rhs}')
            return lhs, lk
        elif data.value == 'unaryexpr':
            op, re = expr.children
            rhs, rk = Rvalue(re)
            if (op.children[0].value == '+'):
                return rhs, rk
            elif op.children[0].value == '-':
                tmp = NewTemp(rk)
                WriteLine(f'{tmp} = 0 - {rhs}')
                return tmp, rk
            elif op.children[0].value == '~':
                tmp = NewTemp(rk)
                WriteLine(f'{tmp} = @nxor(rhs, 0)')
                return tmp, rk
            elif op.children[0].value == '!':
                assert False, f'Not yet implemented'
            else:
                assert False, f'Bad unary: `{op}`'
        elif data.value == 'castexpr':
            le, _, re, = expr.children
            rhs, rk = Rvalue(re)
            print(le)
            err
        elif data.value == 'constant':
            print(expr)
            errexpr
            return expr.children[0].value, 'u32'
        else:
            print(data.value)
            bad
    else:
        print(expr)
        err

def Lvalue(expr):
    if type(expr) == Tree:
        data = expr.data

        if data == 'indexpr':
##            print(f'LV of `{expr}`')
            le, _, re, _, = expr.children
            rhs, rk = Rvalue(re)
            lhs, lk = Rvalue(le)
            tmp = f'{lhs}[{rhs}]'
            return tmp, lk
        elif type(data) == str:
            print(data)
            print(expr)
            err
        
        if data.type == 'RULE' and data.value == 'ident':
            ident = expr.children[0].value
            kind = 'u32'
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
    WriteLine(f'decl {ID}: {kind}')
    return ID
        
syms = [{}]
out = ''
ind = 0
tid = 0
Gen(tree)
print(out)
