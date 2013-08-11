LATEX = latex
TEXODE = texode
FLAGS = --document
DVIOUT = dvi
TEXOUT = ./build/latex
define render
	$(TEXODE) $(FLAGS) chapters/$(1).md $(TEXOUT)
	$(LATEX) build/latex/$(1).md.tex
	mv $(1).md.dvi build/dvi/
	dvipdf build/dvi/$(1).md.dvi build/pdf/$(1).pdf
endef	

all: bootstrap interpret register sexprs sfuncs twotheories clean

bootstrap: chapters/Bootstrap.md
	$(call render,Bootstrap)
	
interpret: chapters/Interpret.md
	$(call render,Interpret)

register: chapters/RegisterMachines.md
	$(call render,RegisterMachines)
	
sexprs: chapters/SExprs.md
	$(call render,SExprs)
	
sfuncs: chapters/SFuncs.md
	$(call render,SFuncs)	
	
twotheories: chapters/TwoTheories.md
	$(call render,TwoTheories)		

clean:
	- $(RM) *.aux *.log