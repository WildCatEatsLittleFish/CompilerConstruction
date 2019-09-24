// [NYU Courant Institute] Compiler Construction/Fall 2016/Project Milestone 3 -*-hacs-*-
//
// Contents.
// 1. MiniC Lexical analysis and grammar
// 2. MinARM32 assembler grammar
// 3. Compiler from MiniC to MinARM32
//
// Refer to documentation in \url{http://cs.nyu.edu/courses/fall16/CSCI-GA.2130-001/}.

module edu.nyu.cs.cc.Pr3YulinLiu {

  
  ////////////////////////////////////////////////////////////////////////
  // 1. MiniC LEXICAL ANALYSIS AND GRAMMAR
  ////////////////////////////////////////////////////////////////////////

  // pr1: refers to http://cs.nyu.edu/courses/fall16/CSCI-GA.2130-001/project1/pr1.pdf

  // TOKENS (pr1:1.1).

  space [ \t\n\r] | '//' [^\n]* | '/*' ( [^*] | '*' [^/] )* '*/'  ; // Inner /* ignored

  token ID  	| ⟨LetterEtc⟩ (⟨LetterEtc⟩ | ⟨Digit⟩)* ;
  token INT	| ⟨Digit⟩+ ;
  token STR | "\"" ( [^\"\\\n] | \\ ⟨Escape⟩ )* "\"";

  token fragment Letter     | [A-Za-z] ;
  token fragment LetterEtc  | ⟨Letter⟩ | [$_] ;
  token fragment Digit      | [0-9] ;
  
  token fragment Escape  | [\n\\nt"] | "x" ⟨Hex⟩ ⟨Hex⟩ | ⟨Octal⟩;
  token fragment Hex     | [0-9A-Fa-f] ;
  token fragment Octal   | [0-7] | [0-7][0-7] | [0-7][0-7][0-7];
 
  // PROGRAM (pr1:2.6)

  main sort Program  |  ⟦ ⟨Declarations⟩ ⟧ ;

  // DECLARATIONS (pr1:1.5)

  sort Declarations | ⟦ ⟨Declaration⟩ ⟨Declarations⟩ ⟧ | ⟦⟧ ;

  sort Declaration
    |  ⟦ function ⟨Type⟩ ⟨Identifier⟩ ⟨ArgumentSignature⟩ { ⟨Statements⟩ } ⟧
    ;

  sort ArgumentSignature
    |  ⟦ ( ) ⟧
    |  ⟦ ( ⟨Type⟩ ⟨Identifier⟩ ⟨TypeIdentifierTail⟩ ) ⟧
    ;
  sort TypeIdentifierTail |  ⟦ , ⟨Type⟩ ⟨Identifier⟩ ⟨TypeIdentifierTail⟩ ⟧  |  ⟦ ⟧ ;

  // STATEMENTS (pr1:1.4)

  sort Statements | ⟦ ⟨Statement⟩ ⟨Statements⟩ ⟧ | ⟦⟧ ;

  sort Statement
    |  ⟦ { ⟨Statements⟩ } ⟧
    |  ⟦ var ⟨Type⟩ ⟨Identifier⟩ ; ⟧
    |  ⟦ ⟨Expression⟩ = ⟨Expression⟩ ; ⟧
    |  ⟦ if ( ⟨Expression⟩ ) ⟨IfTail⟩ ⟧
    |  ⟦ while ( ⟨Expression⟩ ) ⟨Statement⟩ ⟧
    |  ⟦ return ⟨Expression⟩ ; ⟧
    ;

  sort IfTail | ⟦ ⟨Statement⟩ else ⟨Statement⟩ ⟧ | ⟦ ⟨Statement⟩ ⟧ ;

  // TYPES (pr1:1.3)

  sort Type
    |  ⟦ int ⟧@3
    |  ⟦ char ⟧@3
    |  ⟦ ( ⟨Type⟩ )⟧@3
    |  ⟦ ⟨Type@2⟩ ( ⟨TypeList⟩ )⟧@2
    |  ⟦ * ⟨Type@1⟩ ⟧@1
    ;
    
  sort TypeList | ⟦ ⟨Type⟩ ⟨TypeListTail⟩ ⟧ | ⟦⟧;
  sort TypeListTail | ⟦ , ⟨Type⟩ ⟨TypeListTail⟩ ⟧ | ⟦⟧;  

  // EXPRESSIONS (pr1:2.2)

  sort Expression

    |  sugar ⟦ ( ⟨Expression#e⟩ ) ⟧@10 → #e

    |  ⟦ ⟨Integer⟩ ⟧@10
    |  ⟦ ⟨String⟩ ⟧@10
    |  ⟦ ⟨Identifier⟩ ⟧@10

    |  ⟦ ⟨Expression@9⟩ ( ⟨ExpressionList⟩ ) ⟧@9
    |  ⟦ null ( ⟨Type⟩ ) ⟧@9
    |  ⟦ sizeof ( ⟨Type⟩ )⟧@9

    |  ⟦ ! ⟨Expression@8⟩ ⟧@8
    |  ⟦ - ⟨Expression@8⟩ ⟧@8
    |  ⟦ + ⟨Expression@8⟩ ⟧@8
    |  ⟦ * ⟨Expression@8⟩ ⟧@8
    |  ⟦ & ⟨Expression@8⟩ ⟧@8

    |  ⟦ ⟨Expression@7⟩ * ⟨Expression@8⟩ ⟧@7

    |  ⟦ ⟨Expression@6⟩ + ⟨Expression@7⟩ ⟧@6
    |  ⟦ ⟨Expression@6⟩ - ⟨Expression@7⟩ ⟧@6

    |  ⟦ ⟨Expression@6⟩ < ⟨Expression@6⟩ ⟧@5
    |  ⟦ ⟨Expression@6⟩ > ⟨Expression@6⟩ ⟧@5
    |  ⟦ ⟨Expression@6⟩ <= ⟨Expression@6⟩ ⟧@5
    |  ⟦ ⟨Expression@6⟩ >= ⟨Expression@6⟩ ⟧@5

    |  ⟦ ⟨Expression@5⟩ == ⟨Expression@5⟩ ⟧@4
    |  ⟦ ⟨Expression@5⟩ != ⟨Expression@5⟩ ⟧@4

    |  ⟦ ⟨Expression@3⟩ && ⟨Expression@4⟩ ⟧@3

    |  ⟦ ⟨Expression@2⟩ || ⟨Expression@3⟩ ⟧@2
    ;
    
  // Helper to describe actual list of arguments of function call.
  sort ExpressionList | ⟦ ⟨Expression⟩ ⟨ExpressionListTail⟩ ⟧  |  ⟦⟧ ;
  sort ExpressionListTail | ⟦ , ⟨Expression⟩ ⟨ExpressionListTail⟩ ⟧  |  ⟦⟧ ;  

  sort Integer		| ⟦ ⟨INT⟩ ⟧ ;
  sort String		| ⟦ ⟨STR⟩ ⟧ ;
  sort Identifier	| symbol ⟦⟨ID⟩⟧ ;

 
  ////////////////////////////////////////////////////////////////////////
  // 2. MinARM32 ASSEMBLER GRAMMAR
  ////////////////////////////////////////////////////////////////////////

  // arm: refers to http://cs.nyu.edu/courses/fall14/CSCI-GA.2130-001/pr3/MinARM32.pdf
 
  // Instructions.
  sort Instructions | ⟦ ⟨Instruction⟩ ⟨Instructions⟩ ⟧ | ⟦⟧ ;

  // Directives (arm:2.1)
  sort Instruction
    | ⟦DEF ⟨ID⟩ = ⟨Integer⟩ ¶⟧  // define identifier
    | ⟦¶⟨Label⟩ ⟧               // define address label
    | ⟦DCI ⟨Integers⟩ ¶⟧        // allocate integers
    | ⟦DCS ⟨String⟩ ¶⟧          // allocate strings
    | ⟦⟨Op⟩ ¶⟧                  // machine instruction
    ;

  sort Integers | ⟦ ⟨Integer⟩, ⟨Integers⟩ ⟧ | ⟦ ⟨Integer⟩ ⟧ ;

  sort Label | symbol ⟦⟨ID⟩⟧ ;
 
  // Syntax of individual machine instructions (arm:2.2).
  sort Op

    | ⟦MOV ⟨Reg⟩, ⟨Arg⟩ ⟧		// move
    | ⟦MOV ⟨Reg⟩, &⟨Label⟩ ⟧
    | ⟦MVN ⟨Reg⟩, ⟨Arg⟩ ⟧		// move not
    | ⟦ADD ⟨Reg⟩, ⟨Reg⟩, ⟨Arg⟩ ⟧	// add
    | ⟦SUB ⟨Reg⟩, ⟨Reg⟩, ⟨Arg⟩ ⟧	// subtract
    | ⟦RSB ⟨Reg⟩, ⟨Reg⟩, ⟨Arg⟩ ⟧	// reverse subtract
    | ⟦AND ⟨Reg⟩, ⟨Reg⟩, ⟨Arg⟩ ⟧	// bitwise and
    | ⟦ORR ⟨Reg⟩, ⟨Reg⟩, ⟨Arg⟩ ⟧	// bitwise or
    | ⟦EOR ⟨Reg⟩, ⟨Reg⟩, ⟨Arg⟩ ⟧	// bitwise exclusive or
    | ⟦CMP ⟨Reg⟩, ⟨Arg⟩ ⟧	    	// compare
    | ⟦MUL ⟨Reg⟩, ⟨Reg⟩, ⟨Reg⟩ ⟧	// multiply

    | ⟦B ⟨Label⟩ ⟧			// branch always
    | ⟦BEQ ⟨Label⟩ ⟧			// branch if equal
    | ⟦BNE ⟨Label⟩ ⟧			// branch if not equal
    | ⟦BGT ⟨Label⟩ ⟧			// branch if greater than
    | ⟦BLT ⟨Label⟩ ⟧			// branch if less than
    | ⟦BGE ⟨Label⟩ ⟧			// branch if greater than or equal
    | ⟦BLE ⟨Label⟩ ⟧			// branch if less than or equal
    | ⟦BL ⟨Label⟩ ⟧			// branch and link

    | ⟦LDR ⟨Reg⟩, ⟨Mem⟩ ⟧		// load register from memory
    | ⟦STR ⟨Reg⟩, ⟨Mem⟩ ⟧		// store register to memory

    | ⟦LDMFD ⟨Reg⟩! , {⟨Regs⟩} ⟧ 	// load multiple fully descending (pop)
    | ⟦STMFD ⟨Reg⟩! , {⟨Regs⟩} ⟧	// store multiple fully descending (push)
    | ⟦ ⟨Label⟩ ⟧
    ;

  // Arguments.

  sort Reg	| ⟦R0⟧ | ⟦R1⟧ | ⟦R2⟧ | ⟦R3⟧ | ⟦R4⟧ | ⟦R5⟧ | ⟦R6⟧ | ⟦R7⟧
		| ⟦R8⟧ | ⟦R9⟧ | ⟦R10⟧ | ⟦R11⟧ | ⟦R12⟧ | ⟦SP⟧ | ⟦LR⟧ | ⟦PC⟧ ;

  sort Arg | ⟦⟨Constant⟩⟧ | ⟦⟨Reg⟩⟧ | ⟦⟨Reg⟩, LSL ⟨Constant⟩⟧ | ⟦⟨Reg⟩, LSR ⟨Constant⟩⟧ ;

  sort Mem | ⟦[⟨Reg⟩, ⟨Sign⟩⟨Arg⟩]⟧ ;
  sort Sign | ⟦+⟧ | ⟦-⟧ | ⟦⟧ ;

  sort Regs | ⟦⟨Reg⟩⟧ | ⟦⟨Reg⟩-⟨Reg⟩⟧ | ⟦⟨Reg⟩, ⟨Regs⟩⟧ | ⟦⟨Reg⟩-⟨Reg⟩, ⟨Regs⟩⟧ ;

  sort Constant | ⟦#⟨Integer⟩⟧ | ⟦&⟨ID⟩⟧ ;

  // Helper concatenation/flattening of Instructions.
  sort Instructions | scheme ⟦ { ⟨Instructions⟩ } ⟨Instructions⟩ ⟧ ;
  ⟦ {} ⟨Instructions#⟩ ⟧ → # ;
  ⟦ {⟨Instruction#1⟩ ⟨Instructions#2⟩} ⟨Instructions#3⟩ ⟧
    → ⟦ ⟨Instruction#1⟩ {⟨Instructions#2⟩} ⟨Instructions#3⟩ ⟧ ;

  // Helper data structure for list of registers.
  sort Rs | NoRs | MoRs(Reg, Rs) | scheme AppendRs(Rs, Rs) ;
  AppendRs(NoRs, #Rs) → #Rs ;
  AppendRs(MoRs(#Rn, #Rs1), #Rs2) → MoRs(#Rn, AppendRs(#Rs1, #Rs2)) ;

  // Helper conversion from Regs syntax to register list.
  | scheme XRegs(Regs) ;
  XRegs(⟦⟨Reg#r⟩⟧) → MoRs(#r, NoRs) ;
  XRegs(⟦⟨Reg#r1⟩-⟨Reg#r2⟩⟧) → XRegs1(#r1, #r2) ;
  XRegs(⟦⟨Reg#r⟩, ⟨Regs#Rs⟩⟧) → MoRs(#r, XRegs(#Rs)) ;
  XRegs(⟦⟨Reg#r1⟩-⟨Reg#r2⟩, ⟨Regs#Rs⟩⟧) → AppendRs(XRegs1(#r1, #r2), XRegs(#Rs)) ;

  | scheme XRegs1(Reg, Reg) ;
  XRegs1(#r, #r) → MoRs(#r, NoRs) ;
  default XRegs1(#r1, #r2) → XRegs2(#r1, #r2) ;

  | scheme XRegs2(Reg, Reg) ;
  XRegs2(⟦R0⟧, #r2) → MoRs(⟦R0⟧, XRegs1(⟦R1⟧, #r2)) ;
  XRegs2(⟦R1⟧, #r2) → MoRs(⟦R1⟧, XRegs1(⟦R2⟧, #r2)) ;
  XRegs2(⟦R2⟧, #r2) → MoRs(⟦R2⟧, XRegs1(⟦R3⟧, #r2)) ;
  XRegs2(⟦R3⟧, #r2) → MoRs(⟦R3⟧, XRegs1(⟦R4⟧, #r2)) ;
  XRegs2(⟦R4⟧, #r2) → MoRs(⟦R4⟧, XRegs1(⟦R5⟧, #r2)) ;
  XRegs2(⟦R5⟧, #r2) → MoRs(⟦R5⟧, XRegs1(⟦R6⟧, #r2)) ;
  XRegs2(⟦R6⟧, #r2) → MoRs(⟦R6⟧, XRegs1(⟦R7⟧, #r2)) ;
  XRegs2(⟦R7⟧, #r2) → MoRs(⟦R7⟧, XRegs1(⟦R8⟧, #r2)) ;
  XRegs2(⟦R8⟧, #r2) → MoRs(⟦R8⟧, XRegs1(⟦R9⟧, #r2)) ;
  XRegs2(⟦R9⟧, #r2) → MoRs(⟦R9⟧, XRegs1(⟦R10⟧, #r2)) ;
  XRegs2(⟦R10⟧, #r2) → MoRs(⟦R10⟧, XRegs1(⟦R11⟧, #r2)) ;
  XRegs2(⟦R11⟧, #r2) → MoRs(⟦R11⟧, XRegs1(⟦R12⟧, #r2)) ;
  XRegs2(⟦R12⟧, #r2) → MoRs(⟦R12⟧, NoRs) ;
  XRegs1(⟦SP⟧, #r2) → error⟦MinARM32 error: Cannot use SP in Regs range.⟧ ;
  XRegs1(⟦LR⟧, #r2) → error⟦MinARM32 error: Cannot use LR in Regs range.⟧ ;
  XRegs1(⟦PC⟧, #r2) → error⟦MinARM32 error: Cannot use PC in Regs range.⟧ ;
  
  // Helpers to insert computed assembly constants.
  sort Constant | scheme Immediate(Computed) | scheme Reference(Computed) ;
  Immediate(#x) → ⟦#⟨INT#x⟩⟧ ;
  Reference(#id) → ⟦&⟨ID#id⟩⟧ ;

  //sort Constant | scheme SReference(Label) ;
  //SReference(#l) → ⟦&⟨Label#l⟩⟧ ;

  sort Mem | scheme FrameAccess(Computed) ;
  FrameAccess(#x)
    → FrameAccess1(#x, ⟦ [R12, ⟨Constant Immediate(#x)⟩] ⟧, ⟦ [R12, -⟨Constant Immediate(⟦0-#x⟧)⟩] ⟧) ;
  | scheme FrameAccess1(Computed, Mem, Mem) ;
  FrameAccess1(#x, #pos, #neg) → FrameAccess2(⟦ #x ≥ 0 ? #pos : #neg ⟧) ;
  | scheme FrameAccess2(Computed) ;
  FrameAccess2(#mem) → #mem ;

  sort Instruction | scheme AddConstant(Reg, Reg, Computed) ;
  AddConstant(#Rd, #Rn, #x)
    → AddConstant1(#x,
		   ⟦ ADD ⟨Reg#Rd⟩, ⟨Reg#Rn⟩, ⟨Constant Immediate(#x)⟩ ⟧,
		   ⟦ SUB ⟨Reg#Rd⟩, ⟨Reg#Rn⟩, ⟨Constant Immediate(⟦0-#x⟧)⟩ ⟧) ;
  | scheme AddConstant1(Computed, Instruction, Instruction) ;
  AddConstant1(#x, #pos, #neg) → AddConstant2(⟦ #x ≥ 0 ? #pos : #neg ⟧) ;
  | scheme AddConstant2(Computed) ;
  AddConstant2(#add) → #add ;
  

  ////////////////////////////////////////////////////////////////////////
  // 3. COMPILER FROM MiniC TO MinARM32
  ////////////////////////////////////////////////////////////////////////

  // HACS doesn't like to compile with Computed sort
  // unless there exists a scheme that can generate Computed
  sort Computed | scheme Dummy ;
  Dummy → ⟦ 0 ⟧;

  // MAIN SCHEME

  sort Instructions  |  scheme Compile(Program) ;
  Compile(#1) → P2(P1(#1), #1) ;

  // PASS 1

  // Result sort for first pass, with join operation.
  sort After1 | Data1(Instructions, FT) | scheme Join1(After1, After1) ;
  Join1(Data1(#1, #ft1), Data1(#2, #ft2))
    → Data1(⟦ { ⟨Instructions#1⟩ } ⟨Instructions#2⟩ ⟧, AppendFT(#ft1, #ft2)) ;

  // Function to return type environment (list of pairs with append).
  sort FT | NoFT | MoFT(Identifier, Type, FT) | scheme AppendFT(FT, FT) ;
  AppendFT(NoFT, #ft2) → #ft2 ;
  AppendFT(MoFT(#id1, #T1, #ft1), #ft2) → MoFT(#id1, #T1, AppendFT(#ft1, #ft2)) ;

  // Pass 1 recursion.
  sort After1 | scheme P1(Program) ;
  P1(⟦⟨Declarations#Ds⟩⟧) → P1Ds(#Ds) ;

  sort After1 | scheme P1Ds(Declarations);  // Def. \ref{def:P}.
  P1Ds(⟦⟨Declaration#D⟩ ⟨Declarations#Ds⟩⟧) → Join1(D(#D), P1Ds(#Ds)) ;
  P1Ds(⟦⟧) → Data1(⟦⟧, NoFT) ;

  // \sem{D} scheme (Def. \ref{def:D}).
  
  sort After1 | scheme D(Declaration) ;
  D(⟦ function ⟨Type#T⟩ f ⟨ArgumentSignature#As⟩ { ⟨Statements#S⟩ } ⟧)
    → Data1(⟦⟧, MoFT(⟦f⟧, #T, NoFT)) ;

  // PASS 2

  // Pass 2 strategy: first load type environment $ρ$ then tail-call recursion.
  sort Instructions | scheme P2(After1, Program) ;
  P2(Data1(#1, #ft1), #P) → P2Load(#1, #ft1, #P) ;

  // Type environment ($ρ$) is split in two components (by used sorts).
  attribute ↓ft{Identifier : Type} ;	// map from function name to return type
  attribute ↓vt{Identifier : Local} ;	// map from local variable name to type\&location
  sort Local | RegLocal(Type, Reg) | FrameLocal(Type, Computed) ;  // type\&location

  // Other inherited attributes.
  attribute ↓return(Label) ;		// label of return code
  attribute ↓true(Label) ;		// label to jump for true result
  attribute ↓false(Label) ;		// label to jump for false result
  attribute ↓value(Reg) ;		// register for expression result
  attribute ↓offset(Computed) ;		// frame offset for first unused local
  attribute ↓unused(Rs) ;		// list of unused registers
  
  // Pass 2 Loader: extract type environment $ρ$ and emit pass 1 directives.
  sort Instructions | scheme P2Load(Instructions, FT, Program) ↓ft ↓vt ;
  P2Load(#is, MoFT(⟦f⟧, #T, #ft), #P) → P2Load(#is, #ft, #P) ↓ft{⟦f⟧ : #T} ;
  P2Load(#is, NoFT, #P) → ⟦ { ⟨Instructions#is⟩ } ⟨Instructions P(#P)⟩ ⟧ ;

  // Pass 2 recursion.
  sort Instructions | scheme P(Program) ↓ft ↓vt ;
  P(⟦ ⟨Declarations#Ds⟩ ⟧) → Ds(#Ds) ;

  sort Instructions | scheme Ds(Declarations) ↓ft ↓vt ;
  Ds(⟦ ⟨Declaration#D⟩ ⟨Declarations#Ds⟩ ⟧) → ⟦ { ⟨Instructions F(#D)⟩ } ⟨Instructions Ds(#Ds)⟩ ⟧ ;
  Ds(⟦⟧) → ⟦⟧ ;

  // \sem{F} scheme (Def. \ref{def:F}), with argument signature iteration helpers.
  
  sort Instructions | scheme F(Declaration) ↓ft ↓vt ;
  F(⟦ function ⟨Type#T⟩ f ⟨ArgumentSignature#AS⟩ { ⟨Statements#S⟩ } ⟧) → ⟦
	f	STMFD SP!, {R4-R11,LR}
		MOV R12, SP
		{ ⟨Instructions AS(#AS, XRegs(⟦R0-R3⟧), #S) ↓return(⟦L⟧)⟩ }
	L	MOV SP, R12
		LDMFD SP!, {R4-R11,PC}
  ⟧ ;
  
  sort Instructions | scheme AS(ArgumentSignature, Rs, Statements) ↓ft ↓vt ↓return ;
  AS(⟦ () ⟧, #Rs, #S) → S(#S) ↓offset(⟦0-4⟧) ↓unused(XRegs(⟦R4-R11⟧)) ;
  AS(⟦ ( ⟨Type#T⟩ a ⟨TypeIdentifierTail#TIT⟩ ) ⟧, MoRs(#r, #Rs), #S)
    → AS2(#TIT, #Rs, #S) ↓vt{⟦a⟧ : RegLocal(#T, #r)} ;

  sort Instructions | scheme AS2(TypeIdentifierTail, Rs, Statements) ↓ft ↓vt ↓return ;
  AS2(⟦ ⟧, #Rs, #S) → S(#S) ↓offset(⟦0-4⟧) ↓unused(XRegs(⟦R4-R11⟧))  ;
  AS2(⟦ , ⟨Type#T⟩ a ⟨TypeIdentifierTail#TIT⟩ ⟧, MoRs(#r, #Rs), #S)
    → AS2(#TIT, #Rs, #S) ↓vt{⟦a⟧ : RegLocal(#T, #r)} ;
  AS2(⟦ , ⟨Type#T⟩ a ⟨TypeIdentifierTail#TIT⟩ ⟧, NoRs, #S)
    → error⟦More than four arguments to function not allowed.⟧ ;

  // TODO: REMAINING CODE GENERATION.

  attribute ↓test(Label) ;   //pass the the label for the basic block of condition-test 

  sort Instructions | scheme S(Statements) ↓ft ↓vt ↓return ↓unused ;
  S(⟦ { ⟨Statements#1⟩ }  ⟨Statements#2⟩ ⟧↓unused(#Rs) ) → ⟦ { ⟨Instructions S(#1)↓unused(#Rs)⟩ } ⟨Instructions S(#2)↓unused(#Rs)⟩ ⟧ ;
  S(⟦ var ⟨Type#T⟩ id ; ⟨Statements#S⟩ ⟧)↓unused(MoRs(#r, #Rs)) → S(#S)↓unused(#Rs)↓vt{⟦id⟧ : RegLocal(#T, #r)} ;
  S(⟦ id = ⟨Expression#E⟩ ; ⟨Statements#S⟩ ⟧)↓unused(#Rs)↓vt{⟦id⟧ : RegLocal(#T, #r)} → ⟦ { ⟨Instructions SExp(#E)↓value(#r)↓unused(#Rs)⟩ } ⟨Instructions S(#S)↓unused(#Rs)⟩ ⟧ ;
  S(⟦ * id1 = * id2 ; ⟨Statements#S⟩ ⟧)↓unused(#Rs)↓vt{⟦id1⟧ : RegLocal(#T1, #r1)} ↓vt{⟦id2⟧ : RegLocal(#T1, #r2)} → ⟦ { MOV ⟨Reg#r1⟩, ⟨Reg#r2⟩ } ⟨Instructions S(#S)↓unused(#Rs)⟩ ⟧ ;
  S(⟦ * id = ⟨Expression#E⟩ ; ⟨Statements#S⟩ ⟧)↓unused(#Rs)↓vt{⟦id⟧ : RegLocal(#T, #r)} → ⟦ { ⟨Instructions SExp(#E)↓value(#r)↓unused(#Rs)⟩ } ⟨Instructions S(#S)↓unused(#Rs)⟩ ⟧ ;
  S(⟦ while ( ⟨Expression#1⟩ ) ⟨Statement#2⟩ ⟨Statements#3⟩ ⟧)↓return(#l)  → SWhile(#1, #2, #3)↓test(⟦LTest⟧)↓true(⟦Ltrue⟧)↓false(⟦Lfalse⟧)↓return(#l)  ; 
  S(⟦ return ⟨Expression#E⟩ ; ⟨Statements#S⟩ ⟧)↓return(#l) → ⟦ { { ⟨Instructions SExp(#E)↓value(⟦R0⟧)⟩ } B ⟨Label#l⟩ } ⟨Instructions S(#S)⟩⟧ ;
  S(⟦⟧) → ⟦ ⟧ ;
  default S(#) → error⟦Wrong Statements⟧ ;


  //handle the while-loop and create lable LTest, LTrue and LFalse for the condition-test, statement inside the loop and the following statements outside the loop.
  sort Instructions | scheme SWhile(Expression, Statement, Statements) ↓test ↓true ↓false ↓return ↓unused ↓vt ↓ft ;
  SWhile(Expression#1, Statement#2, Statements#3) ↓test(#test) ↓true(#t) ↓false(#f)  → ⟦
    { ⟨Label#test⟩ ⟨Instructions STest(#1)↓true(#t)↓false(#f)⟩ } 
    { ⟨Label#t⟩ ⟨Instructions SStat(#2)↓test(#test)⟩ } 
    { ⟨Label#f⟩ ⟨Instructions S(#3) ⟩ } ⟧ ;


  // Condition-test, only handling two cases
  sort Instructions | scheme STest(Expression) ↓true ↓false ↓vt ↓ft ↓unused;
  STest(⟦ id ⟧)↓vt{⟦id⟧ : RegLocal(#T, #r)}↓true(#t)↓false(#f) → ⟦
    CMP ⟨Reg#r⟩, #0 
    BEQ ⟨Label#f⟩
    BNE ⟨Label#t⟩ ⟧ ;
  STest(⟦ * id ⟧)↓unused(MoRs(#r1, #Rs))↓vt{⟦id⟧ : RegLocal(#T, #r2)}↓true(#t)↓false(#f) → ⟦ 
    LDR ⟨Reg#r1⟩, [⟨Reg#r2⟩, #0] 
    CMP ⟨Reg#r1⟩, #0  
    BEQ ⟨Label#f⟩
    BNE ⟨Label#t⟩ ⟧ ;
  default STest(#) → error⟦Wrong Condition Variable.⟧ ;


  // 
  sort Instructions | scheme SStat(Statement) ↓test ↓unused ↓ft ↓vt ↓return;
  SStat(⟦ { ⟨Statements#⟩ } ⟧)↓test(#l) → ⟦ { ⟨Instructions S(#)⟩ }  B ⟨Label#l⟩ ⟧;
  default SStat(#) → error⟦Wrong Statement inside the loop.⟧ ;


  sort Instructions | scheme SExp(Expression) ↓ft ↓vt ↓return ↓unused ↓value ;
  SExp(⟦ ⟨Integer#1⟩ ⟧)↓value(#2) → ⟦ MOV ⟨Reg#2⟩, #⟨Integer#1⟩ ⟧ ;
  SExp(⟦ ⟨String#1⟩ ⟧)↓value(#2) →  StringPara(#1)↓s(⟦String⟧)↓value(#2);
  SExp(⟦ id ⟧)↓value(#2)↓vt{⟦id⟧ : RegLocal(#T, #r)}  → ⟦ MOV ⟨Reg#2⟩, ⟨Reg#r⟩ ⟧  ;
  SExp(⟦ * id ⟧)↓value(#2)↓vt{⟦id⟧ : RegLocal(#T, #r)}  → ⟦ MOV ⟨Reg#2⟩, ⟨Reg#r⟩ ⟧  ;
  SExp(⟦ ⟨Expression#1⟩ + ⟨Expression#2⟩ ⟧)↓unused(#Rs)↓value(#r)↓vt{:#v}  → ⟦ TA ⟨Expression#1⟩ ⟨Expression#2⟩ ⟨Operator ⟦+⟧⟩ ⟧ ↓value(#r)↓unused(#Rs)↓vt{:#v} ;
  SExp(⟦ ⟨Expression#1⟩ * ⟨Expression#2⟩ ⟧)↓unused(MoRs(#r1, MoRs(#r2, #Rs)))↓value(#r) → ⟦ { { ⟨Instructions SExp(#1)↓unused(AppendRs(#r2, #Rs))↓value(#r1)⟩ } ⟨Instructions SExp(#2)↓unused(AppendRs(#r1, #Rs))↓value(#r2)⟩ } MUL ⟨Reg#r⟩, ⟨Reg#r1⟩, ⟨Reg#r2⟩ ⟧ ;
  SExp(⟦ ⟨Expression#1⟩ - ⟨Expression#2⟩ ⟧)↓unused(MoRs(#r1, MoRs(#r2, #Rs)))↓value(#r) → ⟦ { { ⟨Instructions SExp(#1)↓unused(AppendRs(#r2, #Rs))↓value(#r1)⟩ } ⟨Instructions SExp(#2)↓unused(AppendRs(#r1, #Rs))↓value(#r2)⟩ } SUB ⟨Reg#r⟩, ⟨Reg#r1⟩, ⟨Reg#r2⟩ ⟧ ;
  SExp(⟦ f ( ⟨ExpressionList#E⟩ ) ⟧)↓value(#r) → ⟦ 
    STMFD SP!, {R0-R3} 
    { ⟨Instructions ReadPara(#E)↓unused(XRegs(⟦R0-R3⟧))⟩ } 
    BL f 
    MOV ⟨Reg#r⟩, R0 
    LDMFD SP!,  {R0-R3} ⟧ ;
  default SExp(#) → error⟦Wrong Expression.⟧ ;

  // handle the addition between an integer and a pointer
  sort Operator | ⟦+⟧ | ⟦-⟧ | ⟦*⟧ ;
  sort Instructions | ⟦ TA ⟨Expression⟩ ⟨Expression⟩ ⟨Operator⟩ ⟧ ↓unused ↓value ↓vt ;
  ⟦ TA ⟨Integer#1⟩ ⟨Integer#2⟩ ⟨Operator ⟦+⟧⟩ ⟧↓unused(MoRs(#r1, #Rs)) ↓value(#r2) → ⟦ { MOV ⟨Reg#r1⟩, #⟨Integer#1⟩ } ADD ⟨Reg#r2⟩, ⟨Reg#r1⟩,  #⟨Integer#2⟩ ⟧ ;
  ⟦ TA id ⟨Integer#1⟩ ⟨Operator ⟦+⟧⟩ ⟧ ↓vt{⟦id⟧ : RegLocal(⟦int⟧, #r1)} ↓value(#r2) → ⟦ ADD ⟨Reg#r2⟩, ⟨Reg#r1⟩,  #⟨Integer#1⟩ ⟧ ;
  ⟦ TA id ⟨Integer#1⟩ ⟨Operator ⟦+⟧⟩ ⟧ ↓vt{⟦id⟧ : RegLocal(⟦* char⟧, #r1)} ↓value(#r2) ↓unused(MoRs(#r3, MoRs(#r4, #Rs))) → ⟦ { { { ⟨Instructions ⟦SIZEOF id⟧ ↓value(#r3) ↓vt{⟦id⟧ : RegLocal(⟦* char⟧, #r1)}⟩ } MOV ⟨Reg#r4⟩, #⟨Integer#1⟩ } MUL ⟨Reg#r4⟩, ⟨Reg#r3⟩, ⟨Reg#r4⟩ } ADD ⟨Reg#r2⟩, ⟨Reg#r1⟩, ⟨Reg#r4⟩ ⟧ ;
  ⟦ TA ⟨Integer#1⟩ id ⟨Operator ⟦+⟧⟩ ⟧ ↓vt{⟦id⟧ : RegLocal(⟦int⟧, #r1)} ↓value(#r2) → ⟦ ADD ⟨Reg#r2⟩, ⟨Reg#r1⟩,  #⟨Integer#1⟩ ⟧ ;
  ⟦ TA ⟨Integer#1⟩ id ⟨Operator ⟦+⟧⟩ ⟧ ↓vt{⟦id⟧ : RegLocal(⟦* char⟧, #r1)} ↓value(#r2) ↓unused(MoRs(#r3, MoRs(#r4, #Rs))) → ⟦ { { { ⟨Instructions ⟦SIZEOF id⟧ ↓value(#r3) ↓vt{⟦id⟧ : RegLocal(⟦* char⟧, #r1)}⟩ } MOV ⟨Reg#r4⟩, #⟨Integer#1⟩ }  MUL ⟨Reg#r4⟩, ⟨Reg#r3⟩, ⟨Reg#r4⟩ } ADD ⟨Reg#r2⟩, ⟨Reg#r1⟩, ⟨Reg#r4⟩ ⟧ ;
  ⟦ TA id1 id2 ⟨Operator ⟦+⟧⟩ ⟧↓vt{⟦id1⟧ : RegLocal(⟦* char⟧, #r1)}↓vt{⟦id2⟧ : RegLocal(⟦* char⟧, #r2)} ↓value(#r) → ⟦ ADD ⟨Reg#r⟩, ⟨Reg#r1⟩, ⟨Reg#r2⟩ ⟧ ;
  ⟦ TA id1 id2 ⟨Operator ⟦+⟧⟩ ⟧↓vt{⟦id1⟧ : RegLocal(⟦* char⟧, #r1)}↓vt{⟦id2⟧ : RegLocal(⟦int⟧, #r2)} ↓value(#r)↓unused(MoRs(#r3, #Rs)) → ⟦ { { ⟨Instructions ⟦SIZEOF id1⟧ ↓value(#r3) ↓vt{⟦id1⟧ : RegLocal(⟦* char⟧, #r1)}⟩ }   MUL ⟨Reg#r3⟩, ⟨Reg#r3⟩, ⟨Reg#r2⟩ } ADD ⟨Reg#r⟩, ⟨Reg#r1⟩, ⟨Reg#r3⟩ ⟧ ;
  ⟦ TA id1 id2 ⟨Operator ⟦+⟧⟩ ⟧↓vt{⟦id1⟧ : RegLocal(⟦int⟧, #r1)}↓vt{⟦id2⟧ : RegLocal(⟦* char⟧, #r2)} ↓value(#r)↓unused(MoRs(#r3, #Rs)) → ⟦ { { ⟨Instructions ⟦SIZEOF id2⟧ ↓value(#r3) ↓vt{⟦id2⟧ : RegLocal(⟦* char⟧, #r2)}⟩ }  MUL ⟨Reg#r3⟩, ⟨Reg#r3⟩, ⟨Reg#r1⟩ } ADD ⟨Reg#r⟩, ⟨Reg#r2⟩, ⟨Reg#r3⟩ ⟧ ;

  // helper to compute the size, right now the size of string pointer is defined as 4 bytes 
  sort Instructions | ⟦ SIZEOF ⟨Identifier⟩ ⟧  ↓value ↓vt;
  ⟦ SIZEOF id ⟧ ↓value(#r) ↓vt{⟦id⟧ : RegLocal(⟦* char⟧, #r2)}  → ⟦MOV ⟨Reg#r⟩, #4⟧ ;
  ⟦ SIZEOF id ⟧ ↓value(#r) ↓vt{⟦id⟧ : RegLocal(⟦char⟧, #r2)}   → ⟦MOV ⟨Reg#r⟩, #1⟧ ;

  //the label for string 
  attribute ↓s(Label) ;

  // handle the parameter list for the function call
  sort Instructions | scheme ReadPara(ExpressionList) ↓unused ↓vt ↓s;
  ReadPara(⟦ ⟧) → ⟦⟧ ;
  ReadPara(⟦ ⟨String#S⟩ ⟨ExpressionListTail#E⟩ ⟧) ↓unused(MoRs(#r, #Rs)) → ⟦ { ⟨Instructions StringPara(#S)↓s(⟦String⟧)↓value(#r)⟩ } ⟨Instructions ReadParaTail(#E)↓unused(#Rs)⟩ ⟧ ;
  ReadPara(⟦ id ( ⟨ExpressionList#1⟩ ) ⟨ExpressionListTail#2⟩ ⟧)↓unused(MoRs(#r, #Rs)) → ⟦ { ⟨Instructions SExp(⟦ id ( ⟨ExpressionList#1⟩ ) ⟧)↓value(#r)↓unused(#Rs)⟩ } ⟨Instructions ReadParaTail(#2)↓unused(#Rs)⟩ ⟧ ;

  ReadPara(⟦ id ⟨ExpressionListTail#E⟩ ⟧)↓vt{⟦id⟧ : RegLocal(#T, #r1)} ↓unused(MoRs(#r2, #Rs)) → ⟦ { MOV ⟨Reg#r2⟩, ⟨Reg#r1⟩ } ⟨Instructions ReadParaTail(#E)↓unused(#Rs)⟩ ⟧ ;
  ReadPara(⟦ ⟨Integer#1⟩ ⟨ExpressionListTail#2⟩ ⟧)↓unused(MoRs(#r, #Rs)) → ⟦ { MOV ⟨Reg#r⟩, #⟨Integer#1⟩ } ⟨Instructions ReadParaTail(#2)↓unused(#Rs)⟩ ⟧ ;
  ReadPara(⟦ ⟨Expression#1⟩ ⟨ExpressionListTail#2⟩ ⟧)↓unused(MoRs(#r, #Rs)) → ⟦ { ⟨Instructions SExp(#1)↓unused(#Rs)↓value(#r)⟩ } ⟨Instructions ReadParaTail(#2)↓unused(#Rs)⟩ ⟧ ;

  sort Instructions | scheme ReadParaTail(ExpressionListTail) ↓unused ↓vt ;
  ReadParaTail(⟦ ⟧) → ⟦⟧ ;
  ReadParaTail(⟦ , id ⟨ExpressionListTail#E⟩ ⟧)↓vt{⟦id⟧ : RegLocal(#T, #r1)} ↓unused(MoRs(#r2, #Rs)) → ⟦ { MOV ⟨Reg#r2⟩, ⟨Reg#r1⟩ } ⟨Instructions ReadParaTail(#E)↓unused(#Rs)⟩ ⟧ ;
  ReadParaTail(⟦ , ⟨Integer#1⟩ ⟨ExpressionListTail#2⟩ ⟧) ↓unused(MoRs(#r, #Rs)) → ⟦ { MOV ⟨Reg#r⟩, #⟨Integer#1⟩ } ⟨Instructions ReadParaTail(#2)↓unused(#Rs)⟩ ⟧ ;

  ReadParaTail(⟦ , id ( ⟨ExpressionList#1⟩ ) ⟨ExpressionListTail#2⟩ ⟧)↓unused(MoRs(#r, #Rs)) → ⟦ { ⟨Instructions SExp(⟦ id ( ⟨ExpressionList#1⟩ ) ⟧)↓value(#r)↓unused(#Rs)⟩ } ⟨Instructions ReadParaTail(#2)↓unused(#Rs)⟩ ⟧ ;

  ReadParaTail(⟦ , ⟨Expression#1⟩ ⟨ExpressionListTail#2⟩ ⟧) ↓unused(NoRs) → error⟦More than four arguments to function not allowed.⟧ ;

  //handle the case when the parameter is a string
  sort Instructions | scheme StringPara(String) ↓s ↓value;
  StringPara(String#S)↓s(#string)↓value(#r) → ⟦ { { ⟨Label#string⟩ } DCS ⟨String#S⟩ } MOV ⟨Reg#r⟩, &⟨Label#string⟩ ⟧ ; 

}
