LATEX = latex -quiet
TEXODE = texode
FLAGS = -b book
DVIOUT = dvi
TEXOUT = ./build/latex
define render
	$(TEXODE) $(FLAGS) chapters/$(1).md $(TEXOUT)	
endef	

all: computation bootstrap interpret register sexprs sfuncs twotheories simulate compile clean

bootstrap: chapters/Bootstrap.md
	$(call render,Bootstrap)
	
computation: chapters/Computation.md
	$(call render,Computation)	
	
interpret: chapters/Interpret.md
	$(call render,Interpret)

register: chapters/RegisterMachines.md
	$(call render,RegisterMachines)
	
simulate: chapters/Simulate.md
	$(call render,Simulate)
	
sexprs: chapters/SExprs.md
	$(call render,SExprs)
	
sfuncs: chapters/SFuncs.md
	$(call render,SFuncs)	
	
twotheories: chapters/TwoTheories.md
	$(call render,TwoTheories)		
	
compile: chapters/*.md
	$(LATEX) $(TEXOUT)/book.tex
	mv book.dvi build/dvi/
	dvipdf build/dvi/book.dvi build/pdf/book.pdf	

clean:
	- $(RM) *.aux *.log
