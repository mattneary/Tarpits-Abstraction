LATEX = latex
TEXODE = texode
FLAGS = --document
DVIOUT = dvi
TEXOUT = ./latex
define render
	$(TEXODE) $(FLAGS) markdown/$(1).md $(TEXOUT)
	$(LATEX) latex/$(1).md.tex
	mv $(1).md.dvi dvi/
	dvipdf dvi/$(1).md.dvi pdf/$(1).pdf
endef	

all: bootstrap interpret register sexprs sfuncs twotheories clean

bootstrap: markdown/Bootstrap.md
	$(call render,Bootstrap)
	
interpret: markdown/Interpret.md
	$(call render,Interpret)

register: markdown/RegisterMachines.md
	$(call render,RegisterMachines)
	
sexprs: markdown/SExprs.md
	$(call render,SExprs)
	
sfuncs: markdown/SFuncs.md
	$(call render,SFuncs)	
	
twotheories: markdown/TwoTheories.md
	$(call render,TwoTheories)		

clean:
	- $(RM) *.aux *.log