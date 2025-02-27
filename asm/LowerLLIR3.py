import AssemblerV3 as asmblr
from copy import deepcopy as copy

NUM_REGS = 29
SCRATCH_REGS = [29, 30]
STKPTR = 31

class Block:
    def __init__(self, label: str, instructions: list[tuple]):
        self.label: str = label
        self.instructions: list[tuple] = instructions

        self.fall_through: str|None = None

        self.function: str = ''

class Func:
    def __init__(self, name: str, args: list[str], blocks: list[Block]):
        self.name: str = name
        self.args: list[str] = args

        self.start: str = blocks[0].label

        for i in range(len(blocks)):
            if i < len(blocks) - 1: blocks[i].fall_through = blocks[i+1].label
            blocks[i].function = name

        self.blocks: {str: Block} = {block.label: block for block in blocks}

class CompilerState:
    def __init__(self, functions: list[Func]):
        self.functions: dict[str, Func] = {f.name: f for f in functions}

        self.blocks: dict[str, Block] = {b.label: b for f in functions for b in f.blocks.values()}

        self.compilation_queue: list[str] = [functions[0].start]

        self.entrance_states: dict[str, BlockState] = {functions[0].start: BlockState()}
        self.block_states: dict[str, BlockState] = {}

        self.labels: dict[str, int] = {}
        self.assembly: list[tuple] = [None] # gets overwritten later (sets stkptr)

        self.comments: list[tuple[int, str]] = []

    def add_comment(self, comment: str, inline=False):
        self.comments.append((len(self.assembly), comment, inline))

    def add_assembly(self, instr: tuple):
        self.assembly.append((*instr, *[None for _ in range(6 - len(instr))]))

    def add_all_assembly(self, instrs: list[tuple]):
        for instr in instrs: self.add_assembly(instr)

class Variable:
    def __init__(self, name: str, offset: int, width: int):
        self.name: str = name
        self.offset: int = offset
        self.width: int = width

    # makes sure the var is in a reg, returns that reg descriptor
    def use(self, comp_state, state) -> str:
        reg = None

        min_last_used = Register.reg_counter # guaranteed higher than all `last_used`s
        last_used_reg = None
        for i in range(NUM_REGS):
            if state.registers[i].contained == self.name: reg = i
            if state.registers[i].last_used < min_last_used:
                min_last_used = state.registers[i].last_used
                last_used_reg = i

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
            comp_state.add_assembly(self.load(reg))

            comp_state.add_comment(f"assign r{reg} = `{self.name}`")

        state.registers[reg].contained = self.name
        state.registers[reg].use()

        return f'r{reg}'


    # TODO: left-aligned numbers
    def store(self, reg: int, mods: list[str]=[]) -> tuple:
        return 'stw', mods,  f'r{reg}', f'r{STKPTR}', self.offset << 5

    def load(self, reg: int, mods: list[str]=[]) -> tuple:
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

    def declare_var(self, name: str, width: int, addr: int = None):
        self.variables[name] = Variable(name, self.stack_top if not addr else addr, width)
        if not addr: self.stack_top += 1

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

# compiles a block, assuming it already has an `entrance_state`
def CompileBlock(comp_state: CompilerState, block: Block):
    state = comp_state.entrance_states[block.label].fork()

    comp_state.labels[block.label] = len(comp_state.assembly)
    comp_state.block_states[block.label] = state

    exits: bool = False
    for instr in block.instructions:
        if instr[0] == 'decl': # ('decl', name, width=32)
            comp_state.add_comment(f"decl `{instr[1]}`: u{instr[2] if len(instr) > 2 else 32}")

            state.declare_var(instr[1], instr[2] if len(instr) > 2 else 32)
        elif instr[0] == 'undecl': # ('undecl', name)
            comp_state.add_comment(f"undecl `{instr[1]}`")

            del state.variables[instr[1]]
            # TODO: mark mem as free so it can be reallocated?
            for reg in state.registers:
                if reg.contained == instr[1]: reg.contained = None
        elif instr[0] == 'alloc': # ('alloc', name, length, width=32)
            comp_state.add_comment(f"alloc `{instr[1]}`: u{instr[3] if len(instr) > 3 else 32}[{instr[2]}]")

            state.variables[instr[1]] = Variable(instr[1], state.stack_top, instr[3] if len(instr) > 3 else 32)
            state.stack_top += instr[2]
        elif instr[0] == 'regrst': # ('regrst', reg)
            comp_state.add_comment(f"regrst `{instr[1]}`")

            state.registers[instr[1]].contained = None
        elif instr[0] == 'expr': # ('expr', (op, Rd, Rs0, Rs1, Rs2))
            op = instr[1][0]
            args = instr[1][1:]
            preFlags = ['c', 'n'] if op.startswith("cn.") else ['c'] if op.startswith("c.") else []
            postFlags = ['s'] if ".s" in op else []
            op = op.replace("cn.", "").replace("c.", "").replace(".s", "").replace(".e", "")

            if op == 'jmp': # ('jmp', label)
                label = args[0].replace(":", "")
                if label in comp_state.entrance_states:
                    comp_state.add_all_assembly(state.transform(comp_state.entrance_states[label], preFlags))
                else:
                    comp_state.compilation_queue.append(label)
                    comp_state.entrance_states[label] = state.fork()

                comp_state.add_assembly(('jmp', preFlags, args[0]))
                if 'c' not in preFlags: exits = True
            elif op == 'ret': # ('ret',)
                comp_state.add_assembly(('sub', preFlags, f'r{STKPTR}', f'r{STKPTR}', state.stack_top << 5))
                comp_state.add_assembly(('ret', preFlags))
                exits = True
            elif op == 'argst': # ('argst', addr, var)
                if args[0] < NUM_REGS:
                    comp_state.add_assembly(('mov', preFlags, f'r{args[0]}', state.variables[args[1]].use(comp_state, state) if isinstance(args[1], str) else args[1]))
                else:
                    if isinstance(args[1], int):
                        comp_state.add_assembly(('mov', preFlags, f'r{SCRATCH_REGS[0]}', args[1]))
                    comp_state.add_assembly(('stw', preFlags, state.variables[args[1]].use(comp_state, state) if isinstance(args[1], str) else f'r{SCRATCH_REGS[0]}', f'r{STKPTR}', (state.stack_top + args[0] - NUM_REGS) << 5))
            elif op == 'argld': # ('argld', var, addr, width=32)
                state.declare_var(args[0], args[2] if len(args) > 2 else 32, args[1] - NUM_REGS if args[1] >= NUM_REGS else None)
                if args[1] < NUM_REGS:
                    state.registers[args[1]].contained = args[0]
            elif op == 'call': # ('call', label)
                label = comp_state.functions[args[0].replace(":", "")].start

                comp_state.add_all_assembly(state.dump_regs(preFlags))
                comp_state.add_assembly(('add', preFlags, f'r{STKPTR}', f'r{STKPTR}', state.stack_top << 5))
                comp_state.add_assembly(('call', preFlags, label+":"))

                if label not in comp_state.entrance_states:
                    comp_state.compilation_queue.append(label)
                    comp_state.entrance_states[label] = BlockState()
            elif op == 'retst': # ('retst', addr, var)
                if args[0] < NUM_REGS:
                    comp_state.add_assembly(('mov', preFlags, f'r{args[0]}', state.variables[args[1]].use(comp_state, state) if isinstance(args[1], str) else args[1]))
                else:
                    if isinstance(args[1], int):
                        comp_state.add_assembly(('mov', preFlags, f'r{SCRATCH_REGS[0]}', args[1]))
                    comp_state.add_assembly(('stw', preFlags, state.variables[args[1]].use(comp_state, state) if isinstance(args[1], str) else f'r{SCRATCH_REGS[0]}', f'r{STKPTR}', (args[0] - NUM_REGS) << 5))
            elif op == 'retld': # ('retld', var, addr, width=32)
                state.declare_var(args[0], args[2] if len(args) > 2 else 32, state.stack_top + args[1] - NUM_REGS if args[1] >= NUM_REGS else None)
                if args[1] < NUM_REGS:
                    state.registers[args[1]].contained = args[0]
            else:
                comp_state.add_assembly((op, preFlags + postFlags, *[state.variables[arg].use(comp_state, state) if isinstance(arg, str) else arg for arg in args]))

            comp_state.add_comment(f"expr `{instr[1][0]} {', '.join(str(a) for a in instr[1][1:] if a is not None)}`", True)

    if not exits and block.fall_through is not None and block.fall_through not in comp_state.entrance_states:
        comp_state.compilation_queue.insert(0, block.fall_through)
        comp_state.entrance_states[block.fall_through] = state.fork()

def Lower(llir):
    # this just converts from what HLIR emits to my own data structures
    comp_state: CompilerState = CompilerState([Func(func['name'], func['args'], [Block(block.entry, block.body) for block in func['body']]) for func in llir.funcs])

    while len(comp_state.compilation_queue) > 0:
        block = comp_state.compilation_queue.pop(0)
        CompileBlock(comp_state, comp_state.blocks[block])

    comp_state.assembly[0] = ('mov', [], f'r{STKPTR}', (len(comp_state.assembly)+1+len([i for i in comp_state.assembly[1:] if any(isinstance(a, int) and a >= 32 for a in i[2:])])) << 5)

    for i in range(len(comp_state.assembly)):
        for label, idx in comp_state.labels.items():
            if idx == i: print(f"{label}:")
        comment = "\t\t\t"
        for c in comp_state.comments:
            if c[0] == i:
                if c[2]: comment += f"\t// {c[1]}"
                else: print("\t//", c[1])

        instr = comp_state.assembly[i]

        pre = ('cn.' if 'n' in instr[1] else 'c.') if 'c' in instr[1] else ''
        post = ('.s' if 's' in instr[1] else '') + ('.e' if any(isinstance(arg, int) and arg >= 32 for arg in instr[2:]) else '')

        print(f"\t{pre}{instr[0]}{post} {', '.join([('#' if isinstance(arg, int) else '')+str(arg) for arg in instr[2:] if arg is not None])}{comment if comment.strip() else ''}")

    pass