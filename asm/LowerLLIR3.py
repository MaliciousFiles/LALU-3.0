from copy import deepcopy as copy
from math import log2

NUM_REGS = 29
SCRATCH_REGS = [29, 30]
STKPTR = 31

def RoundUp(x, k):
    return -k*(-x//k)

def AlignOf(bitwidth):
    if bitwidth <= 32:
        return 1<<int(log2(bitwidth-1)+1)
    else:
        return RoundUp(bitwidth, 32)
assert AlignOf(32) == 32
assert AlignOf(8) == 8
assert AlignOf(7) == 8
assert AlignOf(9) == 16
assert AlignOf(48) == 64
assert AlignOf(64) == 64


class Block:
    def __init__(self, label: str, instructions: list[tuple]):
        self.label: str = label
        self.instructions: list[tuple] = instructions

        self.fall_through: str|None = None

        self.function: str = ''

        self.assembly: list[tuple] = []
        self.comments: list[tuple[int, str, bool]] = []

        self.state_dump: list[BlockState] = []

        self.compiled_from: str = ""

    def add_comment(self, comment: str, inline=False):
        self.comments.append((len(self.assembly) - inline, comment, inline))

    def add_assembly(self, instr: tuple|None, state):
        if not instr: return # handy to be able to return None in some places
        self.assembly.append((*instr, *[None for _ in range(6 - len(instr))]))
        self.state_dump.append(state)

class Func:
    def __init__(self, name: str, args: list[str], blocks: list[Block]):
        self.name: str = name
        self.args: list[str] = args

        self.start: str = blocks[0].label

        for i in range(len(blocks)):
            if i < len(blocks) - 1: blocks[i].fall_through = blocks[i+1].label
            blocks[i].function = name

        self.blocks: list[Block] = blocks # maintain order

class CompilerState:
    def __init__(self, functions: list[Func]):
        self.functions: dict[str, Func] = {f.name: f for f in functions}

        self.blocks: dict[str, Block] = {b.label: b for f in functions for b in f.blocks}

        self.compilation_queue: list[str] = [functions[0].start]

        self.entrance_states: dict[str, BlockState] = {functions[0].start: BlockState()}
        self.block_states: dict[str, BlockState] = {}

        self.cur_block = None # the currently compiling block, to know which to add assembly to

    def add_comment(self, comment: str, inline=False):
        self.blocks[self.cur_block].add_comment(comment, inline)

    def add_assembly(self, instr: tuple|None):
        self.blocks[self.cur_block].add_assembly(instr, self.block_states[self.cur_block].fork())

    def add_all_assembly(self, instrs: list[tuple|None]):
        for instr in instrs: self.add_assembly(instr)

class Variable:
    def __init__(self, name: str, width: int, offset: int, stored_data: bool):
        self.name: str = name
        self.offset: int = offset
        self.width: int = width if width else 32
        self.stored_data = stored_data

    # makes sure the var is in a reg, returns that reg descriptor
    def use(self, comp_state, state, reg=None, is_address: bool=False) -> str:
        if is_address:
            r = f'r{reg}' if reg is not None else f'r{SCRATCH_REGS[0]}'
            comp_state.add_assembly(('add', [], r, f'r{STKPTR}', self.offset << 5))
            return r

        # may or may not use this for assignment, but gotta do the preprocessing anyway
        min_last_used = Register.reg_counter  # guaranteed higher than all `last_used`s
        last_used_reg = None

        cur_reg = None
        for i in range(NUM_REGS):
            if state.registers[i].contained == self.name: cur_reg = i
            if state.registers[i].last_used < min_last_used:
                min_last_used = state.registers[i].last_used
                last_used_reg = i

        if reg is None: reg = cur_reg

        # look for empty register
        if reg is None:
            for i in range(NUM_REGS):
                if state.registers[i].contained is None:
                    reg = i
                    break

        # evict the last used register
        if reg is None: reg = last_used_reg

        if state.registers[reg].contained != self.name:
            if state.registers[reg].contained is not None:
                comp_state.add_assembly(state.variables[state.registers[reg].contained].store(reg))
                comp_state.add_comment(f"clobbering r{reg} (`{state.registers[reg].contained}`)", True)

            if cur_reg is not None:
                comp_state.add_assembly(('mov', [], f'r{reg}', f'r{cur_reg}'))
                state.registers[cur_reg].contaiend = None
            else:
                comp_state.add_assembly(self.load(reg))
            comp_state.add_comment(f"assign r{reg} = `{self.name}`", cur_reg is not None or self.stored_data) # in the case where self.load(...) = None, shouldn't be inline

        state.registers[reg].contained = self.name
        state.registers[reg].use()

        return f'r{reg}'


    # TODO: left-aligned numbers
    def store(self, reg: int, mods: list[str]=[]) -> tuple:
        self.stored_data = True
        return 'stw', mods,  f'r{reg}', f'r{STKPTR}', self.offset << 5

    def load(self, reg: int, mods: list[str]=[]) -> tuple|None:
        if not self.stored_data: return None # will get cleared later
        return 'ldw', mods, f'r{reg}', f'r{STKPTR}', self.offset << 5

class Register:
    reg_counter = 0 # just an incremental counter for register eviction

    def __init__(self):
        self.contained: str|None = None
        self.last_used: int = 0

    def use(self):
        self.last_used = Register.reg_counter
        Register.reg_counter += 1

class BlockState:
    def __init__(self):
        self.stack_top: int = 0
        self.variables: dict[str, Variable] = {}
        self.registers: list[Register] = [Register() for _ in range(NUM_REGS)]

    # assumes that if you give an addr, there is data already stored there
    def declare_var(self, name: str, width: int, addr: int = None, alignment = ...):
        if alignment is ...:
            alignment = AlignOf(width)
        var_addr = self.find_free_addr(width, alignment) if addr is None else addr
        self.variables[name] = Variable(name, width, var_addr, addr is not None)
        self.stack_top += 1

    def use_var(self, name: str, state: CompilerState, reg=None) -> str:
        return self.variables[name.rstrip(".&")].use(state, self, reg, name.endswith(".&"))


    def find_free_addr(self, width: int, alignment: int = 32):
        allocs = sorted([(0, 0)]+[(data.offset, data.offset+data.width) for data in self.variables.values()], key = lambda x:x[1])
        for i, (_, old_end) in enumerate(allocs):
            next_start = allocs[i+1][0] if i+1 < len(allocs) else 1<<32
            new_start = RoundUp(old_end, alignment)
            new_end = new_start + width
            if new_end <= next_start:
                return new_start
        else:
            print(f'Allocating block of width: {width} align: {alignment}, next_start: {next_start}, new_end: {new_end}')
            assert False, f'Unreachable block `Allocation failure` reached'

    # clones the state to start a new block
    def fork(self):
        new_state = BlockState()
        new_state.stack_top = self.stack_top
        new_state.variables = copy(self.variables)
        new_state.registers = copy(self.registers)
        return new_state

    # emits the instructions required to transform from `self` to `other`
    # since this is the end of the line for this BlockState, doesn't need to mutate
    def transform(self, other, mods: list[str]) -> list[tuple]:
        instrs: list[tuple] = []

        for i in range(NUM_REGS):
            my_var = self.registers[i].contained
            other_var = other.registers[i].contained

            if my_var != other_var:
                if my_var is not None:
                    instrs.append(self.variables[my_var].store(i, mods))
                elif other_var is not None:
                    instrs.append(self.variables[other_var].load(i, mods))

        return instrs

    def dump_regs(self, mods: list[str]) -> list[tuple]:
        instrs = []

        for i in range(NUM_REGS):
            if self.registers[i].contained is not None:
                instrs.append(self.variables[self.registers[i].contained].store(i, mods))

        return instrs

    def __repr__(self):
        return str({'stack_top': self.stack_top, 'registers': [r.contained for r in self.registers], 'variables': {k: {'width': v.width, 'offset': v.offset, 'stored_data': v.stored_data} for k,v in self.variables.items()}})

# compiles a block, assuming it already has an `entrance_state`
def CompileBlock(comp_state: CompilerState, block: Block):
    comp_state.cur_block = block.label

    state = comp_state.entrance_states[block.label].fork()
    # at the beginning of a block, we have to assume all variables have data stored
    for var in state.variables.values():
        var.stored_data = True

    comp_state.block_states[block.label] = state

    exits: bool = False
    for instr in block.instructions:
        if instr[0] == 'decl': # ('decl', name, width=32)
            comp_state.add_comment(f"decl `{instr[1]}`: u{instr[2] if len(instr) > 2 else 32}")

            state.declare_var(instr[1], instr[2] if len(instr) > 2 else 32)
        elif instr[0] == 'undecl': # ('undecl', name)
            comp_state.add_comment(f"undecl `{instr[1]}`")

            del state.variables[instr[1]]
            # Should be handled by allocation rework
            for reg in state.registers:
                if reg.contained == instr[1]: reg.contained = None
        elif instr[0] == 'alloc': # ('alloc', name, length, width=32)
            comp_state.add_comment(f"alloc `{instr[1]}`: u{instr[3] if len(instr) > 3 else 32}[{instr[2]}]")

            width = instr[3] if len(instr) > 3 and instr[3] else 32
            state.declare_var('_ARRAY_'+instr[1], None, instr[2]*width, AlignOf(width))
            state.declare_var(instr[1], 32)
            #TODO: Set variable to hold the pointer
        elif instr[0] == 'regrst': # ('regrst', reg)
            comp_state.add_comment(f"regrst `{instr[1]}`")

            state.registers[instr[1]].contained = None
        elif instr[0] == 'expr': # ('expr', (op, Rd, Rs0, Rs1, Rs2))
            start_len = len(comp_state.blocks[block.label].assembly)

            op = instr[1][0]
            args = instr[1][1:]
            preFlags = ['c', 'n'] if op.startswith("cn.") else ['c'] if op.startswith("c.") else []
            postFlags = ['s'] if ".s" in op else []
            op = op.replace("cn.", "").replace("c.", "").replace(".s", "").replace(".e", "")

            if op == 'jmp': # ('jmp', label)
                label = args[0].replace(":", "")
                if label in comp_state.entrance_states:
                    comp_state.add_comment(f"prepare state for {label}:")
                    comp_state.add_all_assembly(state.transform(comp_state.entrance_states[label], preFlags))
                else:
                    comp_state.compilation_queue.append(label)
                    comp_state.blocks[label].compiled_from = block.label
                    comp_state.entrance_states[label] = state.fork()

                comp_state.add_assembly(('jmp', preFlags, args[0]))
                if 'c' not in preFlags: exits = True
            elif op == 'ret': # ('ret',)
                comp_state.add_assembly(('ret', preFlags))
                exits = True
            elif op == 'argst': # ('argst', addr, var)
                if args[0] < NUM_REGS:
                    if isinstance(args[1], str):
                        state.use_var(args[1], comp_state, args[0])
                    else:
                        if state.registers[args[0]].contained is not None:
                            comp_state.add_assembly(state.variables[state.registers[args[0]].contained].store(args[0]))

                        comp_state.add_assembly(('mov', preFlags, f'r{args[0]}', args[1]))
                        state.registers[args[0]].contained = None
                else:
                    if isinstance(args[1], int):
                        comp_state.add_assembly(('mov', preFlags, f'r{SCRATCH_REGS[0]}', args[1]))
                    comp_state.add_assembly(('stw', preFlags, state.use_var(args[1], comp_state) if isinstance(args[1], str) else f'r{SCRATCH_REGS[0]}', f'r{STKPTR}', (state.stack_top + args[0] - NUM_REGS) << 5))
            elif op == 'argld': # ('argld', var, addr, width=32)
                state.declare_var(args[0], args[2] if len(args) > 2 and args[2] else 32, args[1] - NUM_REGS if args[1] >= NUM_REGS else None)
                if args[1] < NUM_REGS:
                    state.registers[args[1]].contained = args[0]
            elif op == 'call': # ('call', label)
                label = comp_state.functions[args[0].replace(":", "")].start

                comp_state.add_all_assembly(state.dump_regs(preFlags))
                comp_state.add_assembly(('add', preFlags, f'r{STKPTR}', f'r{STKPTR}', state.stack_top << 5))
                comp_state.add_assembly(('call', preFlags, label+":"))
                comp_state.add_assembly(('sub', preFlags, f'r{STKPTR}', f'r{STKPTR}', state.stack_top << 5))

                # assume the function clobbers everything
                for i in range(NUM_REGS): state.registers[i].contained = None

                if label not in comp_state.entrance_states:
                    comp_state.compilation_queue.append(label)
                    comp_state.blocks[label].compiled_from = block.label
                    comp_state.entrance_states[label] = BlockState()
            elif op == 'retst': # ('retst', addr, var)
                if args[0] < NUM_REGS:
                    if isinstance(args[1], str):
                        state.use_var(args[1], comp_state, args[0])
                    else:
                        if state.registers[args[0]].contained is not None:
                            comp_state.add_assembly(state.variables[state.registers[args[0]].contained].store(args[0]))

                        comp_state.add_assembly(('mov', preFlags, f'r{args[0]}', args[1]))
                        state.registers[args[0]].contained = None
                else:
                    if isinstance(args[1], int):
                        comp_state.add_assembly(('mov', preFlags, f'r{SCRATCH_REGS[0]}', args[1]))
                    comp_state.add_assembly(('stw', preFlags, state.use_var(args[1], comp_state) if isinstance(args[1], str) else f'r{SCRATCH_REGS[0]}', f'r{STKPTR}', (args[0] - NUM_REGS) << 5))
            elif op == 'retld': # ('retld', var, addr, width=32)
                state.declare_var(args[0], args[2] if len(args) > 2 and args[2] else 32, state.stack_top + args[1] - NUM_REGS if args[1] >= NUM_REGS else None)
                if args[1] < NUM_REGS:
                    state.registers[args[1]].contained = args[0]
            else:
                comp_state.add_assembly((op, preFlags + postFlags, *[state.use_var(arg, comp_state) if isinstance(arg, str) else arg for arg in args]))

            comp_state.add_comment(f"expr `{instr[1][0]} {', '.join(str(a) for a in instr[1][1:] if a is not None)}`", len(comp_state.blocks[block.label].assembly) != start_len)

    if not exits and block.fall_through is not None:
        if block.fall_through in comp_state.entrance_states:
            comp_state.add_comment(f"prepare state for {block.fall_through}:")
            comp_state.add_all_assembly(state.transform(comp_state.entrance_states[block.fall_through], []))
        else:
            comp_state.compilation_queue.insert(0, block.fall_through)
            comp_state.blocks[block.fall_through].compiled_from = block.label
            comp_state.entrance_states[block.fall_through] = state.fork()

def Lower(llir):
    # this just converts from what HLIR emits to my own data structures
    comp_state: CompilerState = CompilerState([Func(func['name'], func['args'], [Block(block.entry, block.body) for block in func['body']]) for func in llir.funcs])

    while len(comp_state.compilation_queue) > 0:
        block = comp_state.compilation_queue.pop(0)
        CompileBlock(comp_state, comp_state.blocks[block])

    addr = 2 # one for setting up the stack pointer, and one to point to the address immediately after
    asm_out = ""
    state_dump_out = ""
    for func in comp_state.functions.values():
        asm_out += f"\n//\n// {func.name}\n// args: {', '.join(func.args)}\n//\n"
        for block in func.blocks:
            entrance_state = comp_state.entrance_states[block.label]
            expected = {f"r{i}": entrance_state.registers[i].contained for i in range(NUM_REGS) if entrance_state.registers[i].contained is not None}
            asm_out += "\n"
            for k,v in expected.items():
                asm_out += f"// expecting `{k}` = `{v}`\n"

            vars = {v.offset//32: k for k,v in entrance_state.variables.items()}
            asm_out += f"// stack is [{', '.join(f"`{vars[i]}`" if i in vars else "empty" for i in range(max(vars.keys())+1)) if len(vars) > 0 else ''}]\n"
            asm_out += f"// from {block.compiled_from}:\n"
            asm_out += f"{block.label}:\n"

            for i in range(len(block.assembly)):
                comment = "\t\t\t"
                for c in block.comments:
                    if c[0] == i:
                        if c[2]: comment += f"\t// {c[1]}"
                        else: asm_out += f"\t// {c[1]}\n"

                instr = block.assembly[i]

                pre = ('cn.' if 'n' in instr[1] else 'c.') if 'c' in instr[1] else ''
                post = ('.s' if 's' in instr[1] else '') + ('.e' if any(isinstance(arg, int) and arg >= 32 for arg in instr[2:]) else '')

                asm_out += f"\t{pre}{instr[0]}{post} {', '.join([('#' if isinstance(arg, int) else '')+str(arg) for arg in instr[2:] if arg is not None])}{comment if comment.strip() else ''}\n"

                state_dump_out += f"{hex(addr)[2:].capitalize().zfill(4)}: {block.state_dump[i]}\n"

                addr += 1 if '.e' not in post else 2

            if len(block.comments) > 0:
                for j in range(i+1, max(c[0] for c in block.comments)+1):
                    comment = "\t\t\t"
                    for c in block.comments:
                        if c[0] == j:
                            if c[2]: comment += f"\t// {c[1]}"
                            else: asm_out += f"\t// {c[1]}\n"

                    asm_out += f"{comment}\n"
    asm_out = f"\tmov.e r{STKPTR}, #{addr << 5}\t\t\t// Setup stack pointer\n" + asm_out

    with open("state_dump.txt", "w") as f:
        f.write(state_dump_out)

    return asm_out
