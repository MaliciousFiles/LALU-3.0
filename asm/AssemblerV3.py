import sys
import pyperclip
from time import sleep
from threading import Thread
import os
import os.path
import inspect
import traceback

#Thx Stack Exchange (https://stackoverflow.com/questions/3056048/filename-and-line-number-of-python-script)
def __LINE__() -> int:
    return inspect.currentframe().f_back.f_lineno
def __CALL_LINE__() -> int:
    return inspect.currentframe().f_back.f_back.f_lineno

formats = {
    'T': {
        'c':1,
        'n': 1,
        's': 1,
        'Rd': 5,
        'Rs0': 5,
        'Rs1': 5,
        'Func_ID': 9,
        'i0': 1,
        'i1': 1,
        'Fmt_Code': 3,
    }, 'Q': {
        'c':1,
        'n': 1,
        's': 1,
        'Rd': 5,
        'Rs0': 5,
        'Rs1': 5,
        'Rs2': 5,
        'Func_ID': 4,
        'i1': 1,
        'i2': 1,
        'Fmt_Code': 3,
    }, 'J': {
        'c':1,
        'n': 1,
        's': 1,
        'Addr': 24,
        'Func_ID': 2,
        'Fmt_Code': 3,
    }
}

for name, fmt in formats.items():
    bits = sum([v for k,v in fmt.items()])
    assert bits == 32, f'Format: {name} does not have total bit width 32, got width: {bits}\n'

def T_CODE(**kwargs):
    self = 'T'
    d = kwargs
    d['Args'] = ['Rd', 'Rs0', 'Rs1']
    d['fmtpnm'] = self
    d['Func_ID'] = d['Func_ID'].replace('_', '')
    assert d['Fmt_Code'] in ['000', '100'], f'Fmt Code `{d["Fmt_Code"]}` is not valid for type Fmt {self}\n'
    assert len(d['Func_ID']) == formats[self]['Func_ID'], f'Func_ID `{d["Func_ID"]}` should have {formats[self]["Func_ID"]} bits\n'
    return d
def D_CODE(**kwargs):
    self = 'T'
    d = kwargs
    d['Args'] = ['Rd']
    d['fmtpnm'] = self
    d['Func_ID'] = d['Func_ID'].replace('_', '')
    assert d['Fmt_Code'] in ['000', '100'], f'Fmt Code `{d["Fmt_Code"]}` is not valid for type Fmt {self}\n'
    assert len(d['Func_ID']) == formats[self]['Func_ID'], f'Func_ID `{d["Func_ID"]}` should have {formats[self]["Func_ID"]} bits\n'
    return d
def N_CODE(**kwargs):
    self = 'T'
    d = kwargs
    d['Args'] = []
    d['fmtpnm'] = self
    d['Func_ID'] = d['Func_ID'].replace('_', '')
    assert d['Fmt_Code'] in ['000', '100'], f'Fmt Code `{d["Fmt_Code"]}` is not valid for type Fmt {self}\n'
    assert len(d['Func_ID']) == formats[self]['Func_ID'], f'Func_ID `{d["Func_ID"]}` should have {formats[self]["Func_ID"]} bits\n'
    return d
def V_CODE(**kwargs):
    self = 'T'
    d = kwargs
    d['Args'] = ['Rs0', 'Rs1']
    d['fmtpnm'] = self
    d['Func_ID'] = d['Func_ID'].replace('_', '')
    assert d['Fmt_Code'] in ['000', '100'], f'Fmt Code `{d["Fmt_Code"]}` is not valid for type Fmt {self}\n'
    assert len(d['Func_ID']) == formats[self]['Func_ID'], f'Func_ID `{d["Func_ID"]}` should have {formats[self]["Func_ID"]} bits\n'
    return d
def S_CODE(**kwargs):
    self = 'T'
    d = kwargs
    d['Args'] = ['Rd', 'Rs0']
    d['fmtpnm'] = self
    d['Func_ID'] = d['Func_ID'].replace('_', '')
    assert d['Fmt_Code'] in ['000', '100'], f'Fmt Code `{d["Fmt_Code"]}` is not valid for type Fmt {self}\n'
    assert len(d['Func_ID']) == formats[self]['Func_ID'], f'Func_ID `{d["Func_ID"]}` should have {formats[self]["Func_ID"]} bits\n'
    return d
def Q_CODE(**kwargs):
    self = 'Q'
    d = kwargs
    d['Args'] = ['Rd', 'Rs0', 'Rs1', 'Rs2']
    d['fmtpnm'] = self
    d['Func_ID'] = d['Func_ID'].replace('_', '')
    assert d['Fmt_Code'] in ['001', '101'], f'Fmt Code `{d["Fmt_Code"]}` is not valid for type Fmt {self}\n'
    assert len(d['Func_ID']) == formats[self]['Func_ID'], f'Func_ID `{d["Func_ID"]}` should have {formats[self]["Func_ID"]} bits\n'
    return d
def J_CODE(**kwargs):
    self = 'J'
    d = kwargs
    d['Args'] = ['Addr']
    d['fmtpnm'] = self
    d['Func_ID'] = d['Func_ID'].replace('_', '')
    assert d['Fmt_Code'] in ['110'], f'Fmt Code `{d["Fmt_Code"]}` is not valid for type Fmt {self}\n'
    assert len(d['Func_ID']) == formats[self]['Func_ID'], f'Func_ID `{d["Func_ID"]}` should have {formats[self]["Func_ID"]} bits\n'
    return d

def PSEUDO(numargs, fmt):
    for i in range(numargs):
        assert f'@{i}' in fmt, f"{numargs} format expected usage of arg `{f'@{i}'}`\n"
    
    return {'ps': True, 'numargs': numargs, 'fmt': fmt}

instrs = { #An instruction must have a format pnumonic called its fmtpnm, which is a valid key into the formats dict. All other params represent values in its encoding that are known for all instance of that instruction
    'nop':  N_CODE(Fmt_Code = '000', Func_ID = '0_0000_0000'),

    'add':   T_CODE(Fmt_Code = '000', Func_ID = '0_0000_0001'),
    'sub':   T_CODE(Fmt_Code = '000', Func_ID = '0_0000_0010'),
    'radd':  T_CODE(Fmt_Code = '000', Func_ID = '0_0000_1101'),
    'rsub':  T_CODE(Fmt_Code = '000', Func_ID = '0_0000_1110'),
    'adds':  Q_CODE(Fmt_Code = '001', Func_ID = '1000'),
    'addrs': Q_CODE(Fmt_Code = '001', Func_ID = '1001'),
    'csub':  T_CODE(Fmt_Code = '000', Func_ID = '0_0010_0000'),
    'mul':   T_CODE(Fmt_Code = '000', Func_ID = '0_0000_0011'),
    'uumul': T_CODE(Fmt_Code = '000', Func_ID = '0_0000_1010'),
    'ulmul': T_CODE(Fmt_Code = '000', Func_ID = '0_0000_1011'),
    'lumul': T_CODE(Fmt_Code = '000', Func_ID = '0_0000_1100'),
    'abs':   S_CODE(Fmt_Code = '000', Func_ID = '0_0001_0000'),
    'bsl':   T_CODE(Fmt_Code = '000', Func_ID = '0_0000_0100'),
    'bsr':   T_CODE(Fmt_Code = '000', Func_ID = '0_0000_0101'),
    'brl':   T_CODE(Fmt_Code = '000', Func_ID = '0_0000_0110'),
    'brr':   T_CODE(Fmt_Code = '000', Func_ID = '0_0000_0111'),
    'umax':  T_CODE(Fmt_Code = '000', Func_ID = '0_0001_0001'),
    'umin':  T_CODE(Fmt_Code = '000', Func_ID = '0_0001_0010'),
    'smax':  T_CODE(Fmt_Code = '000', Func_ID = '0_0001_0011'),
    'smin':  T_CODE(Fmt_Code = '000', Func_ID = '0_0001_0100'),
    'any':   T_CODE(Fmt_Code = '000', Func_ID = '0_0000_1000'),
    'log':   S_CODE(Fmt_Code = '000', Func_ID = '0_0001_0101'),
    'ctz':   S_CODE(Fmt_Code = '000', Func_ID = '0_0001_0110'),
    'pcnt':  S_CODE(Fmt_Code = '000', Func_ID = '0_0001_0111'),
    'brvs':  S_CODE(Fmt_Code = '000', Func_ID = '0_0001_1000'),
    'srvs':  T_CODE(Fmt_Code = '000', Func_ID = '0_0001_1111'),
    'vany':  T_CODE(Fmt_Code = '000', Func_ID = '0_0001_1001'),
    'vadd':  Q_CODE(Fmt_Code = '001', Func_ID = '0110'),
    'vsub':  Q_CODE(Fmt_Code = '001', Func_ID = '0111'),
    'bext':  T_CODE(Fmt_Code = '000', Func_ID = '0_0001_1100'),
    'bdep':  T_CODE(Fmt_Code = '000', Func_ID = '0_0001_1101'),
    'exs':   T_CODE(Fmt_Code = '000', Func_ID = '0_0001_1110'),
    'lsb':   S_CODE(Fmt_Code = '000', Func_ID = '0_0000_1111'),
    'hsb':   S_CODE(Fmt_Code = '000', Func_ID = '0_0000_1001'),

    'and':   PSEUDO(3, 'bit @0, @1, @2, #0b0001'),
    'or':    PSEUDO(3, 'bit @0, @1, @2, #0b0111'),
    'xor':   PSEUDO(3, 'bit @0, @1, @2, #0b0110'),
    'andn':  PSEUDO(3, 'bit @0, @1, @2, #0b0100'),
    'orn':   PSEUDO(3, 'bit @0, @1, @2, #0b1101'),
    'nxor':  PSEUDO(3, 'bit @0, @1, @2, #0b1001'),
    'bit':   Q_CODE(Fmt_Code = '001', Func_ID = '0000'),

    'ld':    Q_CODE(Fmt_Code = '001', Func_ID = '0010'),
    'st':    Q_CODE(Fmt_Code = '101', Func_ID = '0011'),
    'ldw':   PSEUDO(3, 'ld @0, @1, @2, #0'),
    'stw':   PSEUDO(3, 'st @0, @1, @2, #0'),
    'lda':   PSEUDO(3, 'ld @0, @1, #0, @2'),
    'sta':   PSEUDO(3, 'st @0, @1, #0, @2'),
    'bsf':   Q_CODE(Fmt_Code = '001', Func_ID = '0100'),
    'bst':   Q_CODE(Fmt_Code = '001', Func_ID = '0101'),

    'mov':   PSEUDO(2, 'add @0, @1, #0'),
    'psh':   D_CODE(Fmt_Code = '100', Func_ID = '0_0010_0001'),
    'pop':   D_CODE(Fmt_Code = '000', Func_ID = '0_0010_0010'),
    'ret':   N_CODE(Fmt_Code = '100', Func_ID = '0_0010_0011'),
    'call':  J_CODE(Fmt_Code = '110', Func_ID = '00'),
    'jmp':   J_CODE(Fmt_Code = '110', Func_ID = '01'),

    'stchr': Q_CODE(Fmt_Code = '101', Func_ID = '0000'),
    'ldkey': D_CODE(Fmt_Code = '000', Func_ID = '0_0011_0001'),
    'keypr': S_CODE(Fmt_Code = '000', Func_ID = '0_0011_0010'),
    'rstkey':N_CODE(Fmt_Code = '100', Func_ID = '0_0011_0011'),

    'ugt':   V_CODE(Fmt_Code = '100', Func_ID = '0_1000_0000'),
    'uge':   V_CODE(Fmt_Code = '100', Func_ID = '0_1000_0001'),
    'ult':   V_CODE(Fmt_Code = '100', Func_ID = '0_1000_0010'),
    'ule':   V_CODE(Fmt_Code = '100', Func_ID = '0_1000_0011'),
    'sgt':   V_CODE(Fmt_Code = '100', Func_ID = '0_1000_0100'),
    'sge':   V_CODE(Fmt_Code = '100', Func_ID = '0_1000_0101'),
    'slt':   V_CODE(Fmt_Code = '100', Func_ID = '0_1000_0110'),
    'sle':   V_CODE(Fmt_Code = '100', Func_ID = '0_1000_0111'),
    'eq':    V_CODE(Fmt_Code = '100', Func_ID = '0_1000_1000'),
    'ne':    V_CODE(Fmt_Code = '100', Func_ID = '0_1000_1001'),

    'nf':    N_CODE(Fmt_Code = '100', Func_ID = '0_1001_0000'),
    'zf':    N_CODE(Fmt_Code = '100', Func_ID = '0_1001_0001'),
    'cf':    N_CODE(Fmt_Code = '100', Func_ID = '0_1001_0010'),
    'of':    N_CODE(Fmt_Code = '100', Func_ID = '0_1001_0011'),
    'nnf':   N_CODE(Fmt_Code = '100', Func_ID = '0_1001_0100'),
    'nzf':   N_CODE(Fmt_Code = '100', Func_ID = '0_1001_0101'),
    'ncf':   N_CODE(Fmt_Code = '100', Func_ID = '0_1001_0110'),
    'nof':   N_CODE(Fmt_Code = '100', Func_ID = '0_1001_0111'),

    'gcld':  D_CODE(Fmt_Code = '000', Func_ID = '1_1111_1111'),
    'susp':  N_CODE(Fmt_Code = '100', Func_ID = '1_1111_1111'),
}

def ParseValue(txt, foundInstruction=True):
    if foundInstruction and txt.lower()[0]=='r' and txt[1:].isdigit():
        reg = int(txt[1:])
        assert 0 <= reg < 32, f'Register {reg} is not in valid range [0, 32)'
        return ('reg', reg)
    elif foundInstruction and txt[0] == '#':
        if txt != '#0':
            if txt[1] == '0' and txt[2] in 'xdb':
                base = [16, 10, 2]['xdb'.index(txt[2])]
                val = int(txt[3:], base)
            else:
                assert not (txt[1] == '0' and txt[2] not in '0123456789'), f'Unknown base `{txt[2]}` for integer literal'
                val = int(txt[1:])
        else:
            val = 0
        return ('lit', val)
    elif txt[-1] == ':':
        return ('lbl', txt[:-1])
    elif any([x in instrs for x in txt.split('.')]):
        sp = txt.split('.')
        mts = [i for i,x in enumerate(sp) if x in instrs]
        assert len(mts) == 1, f'!?'
        i ,= mts
        mods = [x+'.' for x in sp[:i]] + ['.'+x for x in sp[i+1:]]
        for mod in mods:
            assert mod in ['.e', '.s', 'c.', 'cn.'], f'Unrecognized instruction modifier `{mod}`'
        return ('instr', (sp[i], mods))
    else:
        assert False, f'Got unknown value `{txt}`'

def PrepInstr(name, args, mods):
    data = instrs[name]
    fmt = formats[data['fmtpnm']]
    eximm = False
    assert len(args) == len(data['Args']), f'Instruction `{name}` expects {len(data["Args"])} args, but was given {len(args)}'

    c = 'c.' in mods or 'cn.' in mods
    n = 'cn.' in mods
    s = '.s' in mods
    ret = {'name': name, 'c': c, 'n': n, 's': s}
    
    for argname, suparg in zip(data['Args'], args):
        if argname == 'Rd':
            assert suparg[0]=='reg', f'Rd of instruction `{name}` must be register, not {suparg[0]}'
        elif argname[:2] == 'Rs':
            rsi = int(argname[2])
            if suparg[0] == 'lbl':
                assert f'i{rsi}' in fmt, f'Cannot use label for argument `{argname}` of instruction `{name}` as it does not take immediates'
                ret[f'i{rsi}'] = True
                assert not eximm, f'Cannot have two extended immediates'
                eximm = True
            elif suparg[0] == 'lit':
                assert f'i{rsi}' in fmt, f'Cannot use immediate for argument `{argname}` of instruction `{name}` as it does not take immediates'
                ret[f'i{rsi}'] = True
                if suparg[1] >= 31:
                    assert not eximm, f'Cannot have two extended immediates'
                    eximm = True
                    args[args.index(suparg)] = ('exlit', suparg[1])
            elif suparg[0] == 'reg':
                if f'i{rsi}' in fmt:
                    ret[f'i{rsi}'] = False
            else:
                assert False, f'Argument must be immediate, register, or label'
        elif argname == 'Addr':
            if suparg[0] == 'lbl':
                pass
            elif suparg[0] == 'lit':
                assert suparg[1] < 1<<24, f'Address `{hex(suparg[1])[2:]}` is larger than 24 bits'
            else:
                assert False, f'Argument must be immediate or label'
        else:
            assert False, f'Unknown argument type `{argname}`'
    if eximm:
        assert '.e' in mods, f'Instruction `{name}` must be marked with `.e` for extended immediates'
    else:
        assert '.e' not in mods, f'Instruction `{name}` should not have `.e` if it does not use extended immediates'

    ret['args'] = args
    ret['eximm'] = eximm

    return ret

def ResolveInstr(form, lbls):
    data = instrs[form['name']]
    fmt = formats[data['fmtpnm']]
    argnames = data['Args']
    args = form['args']
    out = ''
    ex = None
    for field in fmt:
        if field in argnames:
            i = argnames.index(field)
            arg = args[i]
            if arg[0] == 'reg':
                out += Binary(arg[1], 5)
            elif arg[0] == 'lit':
                out += Binary(arg[1], 5)
            elif arg[0] == 'exlit':
                out += '11111'
                ex = arg[1]
            elif arg[0] == 'lbl':
                if field == 'Addr':
                    out += Binary(lbls[arg[1]] // 32, 24)
                else:
                    out += '11111'
                    ex = lbls[arg[1]]
        else:
            if field in form:
                out += Binary(int(form[field]), fmt[field])
            elif field in data:
                out += data[field]
            else:
                out += Binary(0, fmt[field])
    assert len(out) == 32, f'Binary `{out}` does not have length 32'
    return (Bin2Hex(out, 8), Bin2Hex(bin(ex)[2:], 8) if ex else None)

def ParseVeriNum(txt):
    assert "'" in txt, f"Data segment numbers should follow the format (width)(base)'(value). Missing `'`"
    left, value = txt.split("'")
    width = int(left[:-1])
    basec = left[-1]
    assert basec in 'xdb', f'Expected base to be one of `x`, `d`, or `b`, got `{basec}`'
    base = [16, 10, 2]['xdb'.index(basec)]
    assert int(width)==float(width), f'Width must be an integer'
    assert width > 0, f'Width must greater than 0'
    digs = len(bin(1<<width - 1)[2:])
    val = int(value, base)
    assert 1<<width > val, f'Value `{val}` is greater than maximum representable value of `{1<<width}`'
    raw = [hex, lambda x:'0d'+str(x), bin]['xdb'.index(basec)](val)[2:]
    raw = bin(val)[2:]
    return raw.zfill(digs)
    
def BuildPSEUDO(name, numargs, fmt, subs):
    line = fmt
    assert numargs == len(subs), f'Instruction `{name}` expected {numargs} arguments, but got {len(subs)}'
    for i in range(numargs):
        line = line.replace(f'@{i}', subs[i])
    return line

def Bin2Hex(x, digits):
    return hex(int(x, 2))[2:].zfill(digits)
    
def Binary(num, digs):
    t = bin(num)[2:].zfill(digs)
    assert len(t) == digs, f'`{num}` is `{t}` in binary, which is more than {digs} digits long'
    return t

def ParseDataLine(line):
    stk = []
    s = False
    buf = ''
    mul = False
    def FlushBuf():
        nonlocal buf, mul
        if buf != '':
            if mul:
                stk[-1] *= int(buf)
                mul = False
            else:
                stk.append(ParseVeriNum(buf))
        buf = ''
    while line != '':
        c = line[0]
        line = line[1:]
        if s:
            if c == '"':
                s = False
                tc = stk[-2]
                while tc != '"':
##                    print(stk)
                    stk[-2] += stk[-1]
                    del stk[-1]
                    tc = stk[-2]
                del stk[-2]
            else:
                stk.append(Binary(ord(c), 8))
        else:
            if c == '"':
                stk.append('"')
                s = True
            elif c == '[':
                stk.append('[')
            elif c == ']':
                FlushBuf()
                tc = stk[-2]
                while tc != '[':
                    stk[-2] += stk[-1]
                    del stk[-1]
                    tc = stk[-2]
                del stk[-2]
            elif c == ' ':
                FlushBuf()
            elif c == '*':
                mul = True
            else:
                buf += c
    FlushBuf()
    return ''.join(stk)
            
def ParseFile(file):
    segments = {}
    segment = '.CODE'
    lines = file.split('\n')
    lbls = {}
    addr = 0
    codes = []
    mem = {}
    addr = 0
    for line in lines:
        oline = line
        mline = oline
        try:
            line = line.split('//')[0]
            if not line.strip(): continue

            if line[0] == '.':
                assert line[1:].upper() == line[1:], f'Segments should be in full caps'
                segment = line
                continue
            if segment == '.CODE':
                tkn, line = (line.split(maxsplit=1)+[''])[:2]
                tkn = ParseValue(tkn, False)
                if tkn[0] == 'lbl':
                    lbls[tkn[1]] = addr
                elif tkn[0] == 'instr':
                    if 'ps' in instrs[tkn[1][0]]:
                        mods = tkn[1][1]
                        args = [x.lstrip(' \t').rstrip(' \t') for x in line.split(',')]
                        mline = line = BuildPSEUDO(tkn[1][0], instrs[tkn[1][0]]['numargs'], instrs[tkn[1][0]]['fmt'], args)
                        tkn, line = line.split(maxsplit=1) if ' ' in line else (line, '')
                        tkn = ParseValue(tkn)
                        tkn = (tkn[0], [tkn[1][0], mods])
                    args = [ParseValue(x.lstrip(' \t').rstrip(' \t')) for x in line.split(',')] if line != '' else []
                    ret = PrepInstr(tkn[1][0], args, tkn[1][1])
                    ret['loc'] = addr
                    addr += 64 if ret['eximm'] else 32
                    codes.append(ret)
            elif segment == '.DATA':
                tkn, line = (line.split(maxsplit=1)+[''])[:2]
                tkn = ParseValue(tkn)
                assert tkn[0] == 'lbl', f'Data segments require the first component be a lbl'
                bits = ParseDataLine(line)
                nb = len(bits)
                lbls[tkn[1]] = addr
                while bits != '':
                    mem[addr] = hex(int(bits[:32], 2))[2:].upper().zfill(8)
                    bits = bits[min(len(bits), 32):]
                    addr += 32
##                addr += -(-nb//32)
                        
            else:
                assert False, f'Unknown segment `{segment}`'
        except Exception as e:
            print(f'Error on line: \n`{oline}` -> `{mline}`\n\n')
            raise e
##    print(codes, lbls)
    out = []
    for code in codes:
        hx, ex = ResolveInstr(code, lbls)
        mem[code['loc']] = hx
        if ex:
            mem[code['loc']+32] = ex
    return mem

def Mifify(mem, size):
    header = f"WIDTH=32;\nDEPTH={2**size};\nADDRESS_RADIX=HEX;\nDATA_RADIX=HEX;\nCONTENT BEGIN\n"
    tail = "END;"
    out = header
    maxaddr = 0
    for key, data in sorted(mem.items(), key = lambda x:x[0]):
        addr = key // 32
        maxaddr = max(maxaddr, addr)
        saddr = hex(addr)[2:].zfill(4).upper()
        out += f"    {saddr} : {data.upper()};\n"
    saddr = hex(maxaddr+1)[2:].zfill(4).upper()
    out += f'    [{saddr}..{hex(2**size-1)[2:]}] : 00000000;\n'
    out += tail
    return out

inp = None

def monitor_input():
    global inp
    
    while True:
        inp = input().strip()
        if inp == "q":
            os._exit(1)

if __name__ == "__main__":
    fName = sys.argv[1] if len(sys.argv) > 1 else input("Program File: ")
    with open(fName) as f:
        verb = "--verb" in sys.argv[2:]
        mif = int(sys.argv[sys.argv.index("--mif")+1]) if "--mif" in sys.argv[2:] else 0
        if "--monitor" in sys.argv[2:]:
            Thread(target=monitor_input).start()
            
            contents = None
            while True:
                sleep(.1)
                f.seek(0)
                newContents = f.read()
                
                if inp is not None or newContents != contents:
                    inp = None
                    contents = newContents

                    if (platform := sys.platform) == 'win32':
                        os.system("cls")
                    elif platform == 'darwin':
                        os.system("clear")
                    else:
                        exit('Unsupported Operating System `' + platform +'`')
                    try:
                        program  = ParseFile(contents)
##                        print(program)
                        if mif:
                            program = Mifify(program, mif)
                            if os.path.exists("../.sim/Icarus Verilog-sim"):
                                with open(f'../.sim/Icarus Verilog-sim/RAM.mif', 'w') as f2:
                                    f2.write(program)
                                    print('Wrote:\n\n')
                                    print(program)
                            else:
                                print(program)
                                pyperclip.copy(program)
                        else:
                            print(program)
                            pyperclip.copy(program)
                    except Exception as e:
                        print(f'Unexpected assembler crash')
                        print(e)
                        print(traceback.format_exc())
        else:
            program  = ParseFile(contents)
            print(program)
            pyperclip.copy(program)
