import sys
import pyperclip
from time import sleep
from threading import Thread
import os
import inspect
import traceback

#Thx Stack Exchange (https://stackoverflow.com/questions/3056048/filename-and-line-number-of-python-script)
def __LINE__() -> int:
    return inspect.currentframe().f_back.f_lineno
def __CALL_LINE__() -> int:
    return inspect.currentframe().f_back.f_back.f_lineno

fName = sys.argv[1] if len(sys.argv) > 1 else input("Program File: ")

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

def PSUEDO(numargs, fmt):
    for i in range(numargs):
        assert f'@{i}' in fmt, f"{numargs} format expected usage of arg `{f'@{i}'}`\n"
    
    return {'ps': True, 'numargs': numargs, 'fmt': fmt}

instrs = { #An instruction must have a format pnumonic called its fmtpnm, which is a valid key into the formats dict. All other params represent values in its encoding that are known for all instance of that instruction
    'nop':  N_CODE(Fmt_Code = '000', Func_ID = '0_0000_0000'),

    'add':  T_CODE(Fmt_Code = '000', Func_ID = '0_0000_0001'),
    'sub':  T_CODE(Fmt_Code = '000', Func_ID = '0_0000_0010'),
    'mul':  T_CODE(Fmt_Code = '000', Func_ID = '0_0000_0011'),
    'bsl':  T_CODE(Fmt_Code = '000', Func_ID = '0_0000_0100'),
    'bsr':  T_CODE(Fmt_Code = '000', Func_ID = '0_0000_0101'),
    'brl':  T_CODE(Fmt_Code = '000', Func_ID = '0_0000_0110'),
    'brr':  T_CODE(Fmt_Code = '000', Func_ID = '0_0000_0111'),
    'any':  T_CODE(Fmt_Code = '000', Func_ID = '0_0000_1000'),
    'hsb':  T_CODE(Fmt_Code = '000', Func_ID = '0_0000_1001'),

    'and':  PSUEDO(3, 'bit @0, @1, @2, #0b0001'),
    'or':   PSUEDO(3, 'bit @0, @1, @2, #0b0111'),
    'xor':  PSUEDO(3, 'bit @0, @1, @2, #0b0110'),
    'andn': PSUEDO(3, 'bit @0, @1, @2, #0b0100'),
    'orn':  PSUEDO(3, 'bit @0, @1, @2, #0b1101'),
    'nxor': PSUEDO(3, 'bit @0, @1, @2, #0b1001'),
    'bit':  Q_CODE(Fmt_Code = '001', Func_ID = '0000'),

    'ld':   Q_CODE(Fmt_Code = '001', Func_ID = '0010'),
    'st':   Q_CODE(Fmt_Code = '101', Func_ID = '0011'),
    'ldw':  PSUEDO(3, 'ld @0, @1, @2, #0'),
    'stw':  PSUEDO(3, 'ld @0, @1, @2, #0'),
    'lda':  PSUEDO(3, 'ld @0, @1, #0, @2'),
    'sta':  PSUEDO(3, 'ld @0, @1, #0, @2'),
    'bsf':  Q_CODE(Fmt_Code = '001', Func_ID = '0100'),
    'bst':  Q_CODE(Fmt_Code = '001', Func_ID = '0101'),

    'mov':  PSUEDO(2, 'add @0, @1, #0'),
    'psh':  D_CODE(Fmt_Code = '100', Func_ID = '0_0010_0001'),
    'pop':  D_CODE(Fmt_Code = '000', Func_ID = '0_0010_0010'),
    'ret':  N_CODE(Fmt_Code = '100', Func_ID = '0_0010_0011'),
    'call': J_CODE(Fmt_Code = '110', Func_ID = '00'),
    'jmp':  J_CODE(Fmt_Code = '110', Func_ID = '01'),

    'ugt':  V_CODE(Fmt_Code = '100', Func_ID = '0_1000_0000'),
    'uge':  V_CODE(Fmt_Code = '100', Func_ID = '0_1000_0001'),
    'ult':  V_CODE(Fmt_Code = '100', Func_ID = '0_1000_0010'),
    'ule':  V_CODE(Fmt_Code = '100', Func_ID = '0_1000_0011'),
    'sgt':  V_CODE(Fmt_Code = '100', Func_ID = '0_1000_0100'),
    'sge':  V_CODE(Fmt_Code = '100', Func_ID = '0_1000_0101'),
    'slt':  V_CODE(Fmt_Code = '100', Func_ID = '0_1000_0110'),
    'sle':  V_CODE(Fmt_Code = '100', Func_ID = '0_1000_0111'),
    'eq':   V_CODE(Fmt_Code = '100', Func_ID = '0_1000_1000'),
    'ne':   V_CODE(Fmt_Code = '100', Func_ID = '0_1000_1001'),

    'nf':   N_CODE(Fmt_Code = '100', Func_ID = '0_1001_0000'),
    'zf':   N_CODE(Fmt_Code = '100', Func_ID = '0_1001_0001'),
    'cf':   N_CODE(Fmt_Code = '100', Func_ID = '0_1001_0010'),
    'of':   N_CODE(Fmt_Code = '100', Func_ID = '0_1001_0011'),
    'nnf':  N_CODE(Fmt_Code = '100', Func_ID = '0_1001_0100'),
    'nzf':  N_CODE(Fmt_Code = '100', Func_ID = '0_1001_0101'),
    'ncf':  N_CODE(Fmt_Code = '100', Func_ID = '0_1001_0110'),
    'nof':  N_CODE(Fmt_Code = '100', Func_ID = '0_1001_0111'),
}

def ParseValue(txt):
    if txt.lower()[0]=='r':
        reg = int(txt[1:], 16)
        try:
            dreg = int(txt[1:])
            enc = f'R{hex(dreg)[2:]}'
            if not (0 <= dreg < 32):
                dreg = None
        except:
            dreg = None
        assert 0 <= reg < 32, f'Register {reg} is not in valid range [0, 32)' + ('\n' if dreg==None else f'; registers are coded in hex, did you mean `{enc}`\n')
        return ('reg', reg)
    elif txt[0] == '#':
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
                    out += Binary(lbls[arg[1]], 24)
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

def BuildPsuedo(name, numargs, fmt, subs):
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

def ParseFile(file):
    lines = file.split('\n')
    lbls = {}
    addr = 0
    codes = []
    for line in lines:
        oline = line
        try:
            if line == '':
                continue
            line = line.split('//')[0]
            tkn, line = (line.split(maxsplit=1)+[''])[:2]
            tkn = ParseValue(tkn)
            if tkn[0] == 'lbl':
                lbls[tkn[1]] = addr
            elif tkn[0] == 'instr':
                if 'ps' in instrs[tkn[1][0]]:
                    mods = tkn[1][1]
                    args = [x.lstrip(' \t').rstrip(' \t') for x in line.split(',')]
                    line = BuildPsuedo(tkn[1][0], instrs[tkn[1][0]]['numargs'], instrs[tkn[1][0]]['fmt'], args)
                    tkn, line = line.split(maxsplit=1) if ' ' in line else (line, '')
                    tkn = ParseValue(tkn)
                    tkn = (tkn[0], [tkn[1][0], mods])
                args = [ParseValue(x.lstrip(' \t').rstrip(' \t')) for x in line.split(',')] if line != '' else []
                ret = PrepInstr(tkn[1][0], args, tkn[1][1])
                addr += 64 if ret['eximm'] else 32
                codes.append(ret)
        except Exception as e:
            print(f'Error on line: \n`{oline}`\n\n')
            raise e
##    print(codes, lbls)
    out = []
    for code in codes:
        hx, ex = ResolveInstr(code, lbls)
        out.append(hx)
        if ex:
            out.append(ex)
    return ' '.join(out)

inp = None

def monitor_input():
    global inp
    
    while True:
        inp = input().strip()
        if inp == "q":
            os._exit(1)

if __name__ == "__main__":
    with open(fName) as f:
        verb = "--verb" in sys.argv[2:]
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
                        print(program)
                        pyperclip.copy(program)
                    except Exception as e:
                        print(f'Unexpected assembler crash')
                        print(e)
                        print(traceback.format_exc())
        else:
            run(mx:=macroEXP(f.read(), verb=verb))
